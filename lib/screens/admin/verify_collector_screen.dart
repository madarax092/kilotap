import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/file_type_utils.dart';
import '../../core/vehicle_verification.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class VerifyCollectorScreen extends StatefulWidget {
  const VerifyCollectorScreen({super.key});

  @override
  State<VerifyCollectorScreen> createState() => _VerifyCollectorScreenState();
}

class _VerifyCollectorScreenState extends State<VerifyCollectorScreen> {
  // Verification status and vehicles live in the ScrapCollector subdoc, which
  // the listUsers() stream doesn't watch — rebuild after each decision so the
  // queues reflect it.
  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Verify Collectors',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Review and approve collector applications',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.listUsers(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? const <Map<String, dynamic>>[];
                final collectors = users
                    .where((u) => u['Role'] == 'Collector' || u['Role'] == 'VerifiedCollector')
                    .toList();

                return FutureBuilder<List<_PendingCollector>>(
                  future: _loadCollectors(firestoreService, collectors),
                  builder: (context, pendingSnap) {
                    if (!snapshot.hasData || !pendingSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = pendingSnap.data!;
                    final pending = all
                        .where((c) =>
                            (c.profile?['Verification_Status'] as String?) ==
                            'Pending')
                        .toList();
                    final vehicleRequests = all
                        .where((c) => c.pendingVehicles.isNotEmpty)
                        .toList();
                    if (pending.isEmpty && vehicleRequests.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No pending verifications.',
                              style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (pending.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _QueueHeader('PENDING VERIFICATION', pending.length),
                          const SizedBox(height: 12),
                          ...pending.map((c) => _VerifyTile(
                                collector: c,
                                subtitle: c.vehicle,
                                onTap: () =>
                                    _open(_VerifyDetail(collector: c)),
                              )),
                        ],
                        if (vehicleRequests.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _QueueHeader(
                              'VEHICLE APPROVALS', vehicleRequests.length),
                          const SizedBox(height: 12),
                          ...vehicleRequests.map((c) => _VerifyTile(
                                collector: c,
                                subtitle:
                                    'New: ${c.pendingVehicles.join(', ')}',
                                onTap: () =>
                                    _open(_VehicleApprovalDetail(collector: c)),
                              )),
                        ],
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 1),
    );
  }

  Future<List<_PendingCollector>> _loadCollectors(
      FirestoreService svc, List<Map<String, dynamic>> collectors) {
    return Future.wait(collectors.map((u) async {
      final profile = await svc.collectorProfile(u['uid'] as String);
      return _PendingCollector(
          uid: u['uid'] as String, account: u, profile: profile);
    }));
  }
}

class _QueueHeader extends StatelessWidget {
  final String title;
  final int count;
  const _QueueHeader(this.title, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title,
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1)),
      const SizedBox(width: 8),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: const BoxDecoration(
              color: AppColors.adminRed, shape: BoxShape.circle),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white))),
    ]);
  }
}

class _PendingCollector {
  final String uid;
  final Map<String, dynamic> account;
  final Map<String, dynamic>? profile;
  const _PendingCollector({required this.uid, required this.account, this.profile});

  String get name => (account['Display_Name'] as String?) ?? 'Unknown';
  String get vehicle => (profile?['Vehicle_Type'] as String?) ?? 'Not set';
  String get phone => (account['Phone'] as String?) ?? '';
  List<Map<String, dynamic>> get docs =>
      List<Map<String, dynamic>>.from(profile?['Verification_Docs'] ?? const []);
  List<String> get pendingVehicles => pendingVehicleTypes(profile);
  List<Map<String, dynamic>> get vehicles =>
      (profile?['Vehicles'] as List<dynamic>? ?? const [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
}

class _VerifyTile extends StatelessWidget {
  final _PendingCollector collector;
  final String subtitle;
  final VoidCallback onTap;
  const _VerifyTile(
      {required this.collector, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider)),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.buyerBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person_outline,
                          color: AppColors.buyerBlue)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(collector.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ])),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.divider),
                ]))),
      );
}

class _VerifyDetail extends StatefulWidget {
  final _PendingCollector collector;
  const _VerifyDetail({required this.collector});

  @override
  State<_VerifyDetail> createState() => _VerifyDetailState();
}

class _VerifyDetailState extends State<_VerifyDetail> {
  bool _submitting = false;

  Future<void> _decide(String status) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final svc = FirestoreService();
    final approved = status == 'Verified';
    try {
      await svc.setCollectorVerification(widget.collector.uid, status);
      await svc.setAllVerificationDocsStatus(widget.collector.uid, status);
      if (approved) await svc.approveAllVehicles(widget.collector.uid);
      await svc.logAction({
        'Actor_ID': AuthState.instance.uid ?? 'admin',
        'Action': approved ? 'VERIFY_COLLECTOR' : 'REJECT_COLLECTOR',
        'Target_ID': widget.collector.uid,
        'Description':
            'Admin ${approved ? 'verified' : 'rejected'} collector ${widget.collector.name}.',
      });
      await svc.sendNotification({
        'Recipient_ID': widget.collector.uid,
        'Title': approved ? 'You\'re verified!' : 'Verification rejected',
        'Message': approved
            ? 'Your documents were approved. You can now accept pickups.'
            : 'Your documents were rejected. Please re-upload them in Verification Documents.',
        'Type': approved ? 'verification_approved' : 'verification_rejected',
      });
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collector = widget.collector;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context)),
          title: Text('Verify: ${collector.name}',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          children: [
            const SizedBox(height: 8),
            if (collector.docs.isNotEmpty)
              Row(
                  children: collector.docs
                      .map((d) => Expanded(
                          child: _DTile(
                              (d['type'] as String?) ?? 'Document',
                              (d['status'] as String?) ?? 'pending',
                              (d['url'] as String?) ?? '')))
                      .toList()),
            const SizedBox(height: 16),
            _VSec('COLLECTOR DETAILS', [
              ('Name', collector.name),
              ('Phone', collector.phone),
              ('Vehicle', collector.vehicle),
            ]),
            Row(children: [
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _submitting ? null : () => _decide('Verified'),
                      child: const Text('APPROVE',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)))),
              const SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _submitting ? null : () => _decide('Rejected'),
                      child: const Text('REJECT',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)))),
            ]),
            const SizedBox(height: 30),
          ]),
    );
  }
}

// Approves or rejects vehicles a verified collector added after their
// account was verified. Until approved, they can only go online with (and
// accept bookings for) their already-approved vehicle.
class _VehicleApprovalDetail extends StatefulWidget {
  final _PendingCollector collector;
  const _VehicleApprovalDetail({required this.collector});

  @override
  State<_VehicleApprovalDetail> createState() => _VehicleApprovalDetailState();
}

class _VehicleApprovalDetailState extends State<_VehicleApprovalDetail> {
  late final List<String> _remaining =
      List<String>.from(widget.collector.pendingVehicles);
  String? _busyType;

  Future<void> _decide(String vehicleType, bool approve) async {
    if (_busyType != null) return;
    setState(() => _busyType = vehicleType);
    final svc = FirestoreService();
    final uid = widget.collector.uid;
    try {
      if (approve) {
        await svc.approveVehicle(uid, vehicleType);
      } else {
        await svc.rejectVehicle(uid, vehicleType);
      }
      await svc.logAction({
        'Actor_ID': AuthState.instance.uid ?? 'admin',
        'Action': approve ? 'APPROVE_VEHICLE' : 'REJECT_VEHICLE',
        'Target_ID': uid,
        'Description': 'Admin ${approve ? 'approved' : 'rejected'} '
            '$vehicleType for collector ${widget.collector.name}.',
      });
      await svc.sendNotification({
        'Recipient_ID': uid,
        'Title': approve
            ? '$vehicleType approved'
            : '$vehicleType not approved',
        'Message': approve
            ? 'You can now go online with your $vehicleType and accept '
                'bookings that need it.'
            : 'Your $vehicleType was removed from your vehicles. Re-add it '
                'in Vehicle Details with a clear photo to try again.',
        'Type': approve ? 'verification_approved' : 'verification_rejected',
      });
      if (!mounted) return;
      setState(() => _remaining.remove(vehicleType));
      if (_remaining.isEmpty) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyType = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collector = widget.collector;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context)),
          title: Text('Vehicles: ${collector.name}',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          _VSec('COLLECTOR DETAILS', [
            ('Name', collector.name),
            ('Phone', collector.phone),
            ('Active vehicle', collector.vehicle),
          ]),
          for (final type in _remaining) ...[
            Text('NEW VEHICLE: ${type.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            for (final v
                in collector.vehicles.where((v) => v['Vehicle_Type'] == type))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(
                    width: 110,
                    child: _DTile('Vehicle Photo', 'pending',
                        (v['Photo_URL'] as String?) ?? ''),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Capacity: ${(v['Vehicle_Capacity_Kg'] as num?) ?? 0} kg',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                  ),
                ]),
              ),
            Row(children: [
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed:
                          _busyType != null ? null : () => _decide(type, true),
                      child: const Text('APPROVE',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)))),
              const SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed:
                          _busyType != null ? null : () => _decide(type, false),
                      child: const Text('REJECT',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)))),
            ]),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _VSec extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  const _VSec(this.title, this.rows);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
            decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider)),
            child: Column(
                children: rows.asMap().entries.map((e) {
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: e.key < rows.length - 1
                      ? const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.divider)))
                      : null,
                  child: Row(children: [
                    Text('${e.value.$1}: ',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    Expanded(
                        child: Text(e.value.$2,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textPrimary))),
                  ]));
            }).toList())),
      ]));
}

class _DTile extends StatelessWidget {
  final String label, status, url;
  const _DTile(this.label, this.status, this.url);

  Color get _dotColor {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  void _openFullScreen(BuildContext context) {
    if (url.isEmpty) return;
    if (!isImageUrl(url)) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                      backgroundColor: Colors.black,
                      iconTheme: const IconThemeData(color: Colors.white),
                      title: Text(label,
                          style: const TextStyle(color: Colors.white))),
                  body: Center(
                      child: InteractiveViewer(
                          child: Image.network(url))),
                )));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 90,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider)),
          child: Stack(children: [
            if (url.isNotEmpty && isImageUrl(url))
              Positioned.fill(
                  child: Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.textSecondary, size: 24))))
            else if (url.isNotEmpty)
              Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(fileExtensionLabel(url),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Icon(Icons.open_in_new,
                    color: AppColors.textSecondary, size: 16),
              ]))
            else
              Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.insert_drive_file_outlined,
                    color: AppColors.textSecondary, size: 24),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center)
              ])),
            if (url.isNotEmpty)
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis))),
            Positioned(
                top: 6,
                right: 6,
                child: Container(
                    width: 18,
                    height: 18,
                    decoration:
                        BoxDecoration(color: _dotColor, shape: BoxShape.circle),
                    child: const Icon(Icons.circle,
                        size: 8, color: Colors.transparent))),
          ])));
}
