import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/file_type_utils.dart';
import '../../core/vehicle_verification.dart';
import '../../core/verification_docs.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../widgets/full_screen_image_page.dart';

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
                    final clearanceRequests = all
                        .where((c) =>
                            c.isVerified &&
                            barangayClearanceAwaitingReview(c.docs))
                        .toList();
                    if (pending.isEmpty &&
                        vehicleRequests.isEmpty &&
                        clearanceRequests.isEmpty) {
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
                        if (clearanceRequests.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _QueueHeader('BARANGAY CLEARANCE (OPTIONAL)',
                              clearanceRequests.length),
                          const SizedBox(height: 12),
                          ...clearanceRequests.map((c) => _VerifyTile(
                                collector: c,
                                subtitle: 'Uploaded a Barangay Clearance',
                                onTap: () =>
                                    _open(_ClearanceDetail(collector: c)),
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
  String get photoUrl => (profile?['Profile_Photo_URL'] as String?) ?? '';
  bool get isVerified => profile?['Verification_Status'] == 'Verified';
  List<Map<String, dynamic>> get docs =>
      normalizeVerificationDocs(verificationDocsFrom(profile));
  List<String> get pendingVehicles => pendingVehicleTypes(profile);
  List<Map<String, dynamic>> get vehicles =>
      (profile?['Vehicles'] as List<dynamic>? ?? const [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();

  /// Required items still missing: the formal photo, required documents,
  /// and the plate number of any vehicle that has one.
  List<String> get missingItems => [
        if (photoUrl.isEmpty) 'Formal photo',
        ...missingRequiredDocs(docs),
        for (final v in vehicles)
          if (vehicleNeedsPlate(v['Vehicle_Type'] as String? ?? '') &&
              ((v['Plate_Number'] as String?) ?? '').trim().isEmpty)
            'Plate number (${v['Vehicle_Type']})',
      ];
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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.buyerBlue.withValues(alpha: 0.1),
                    backgroundImage: collector.photoUrl.isEmpty
                        ? null
                        : NetworkImage(collector.photoUrl),
                    child: collector.photoUrl.isEmpty
                        ? const Icon(Icons.person_outline,
                            color: AppColors.buyerBlue)
                        : null,
                  ),
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

// Opens an uploaded file: photos full screen in the app, PDFs and Word
// files in the phone's viewer.
void _openUpload(BuildContext context, String label, String url) {
  if (url.isEmpty) return;
  if (isImageUrl(url)) {
    showFullScreenImage(context, title: label, url: url);
  } else {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
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
    final approved = status == 'Verified';
    final missing = widget.collector.missingItems;
    if (approved && missing.isNotEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Some required items are missing'),
          content: Text('${missing.join('\n')}\n\nApprove anyway?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Go back')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Approve anyway')),
          ],
        ),
      );
      if (go != true) return;
    }
    setState(() => _submitting = true);
    final svc = FirestoreService();
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            _PhotoHeader(collector: collector),
            const SizedBox(height: 16),
            _VSec('COLLECTOR DETAILS', [
              ('Name', collector.name),
              ('Phone', collector.phone.isEmpty ? 'Not set' : collector.phone),
              ('Active vehicle', collector.vehicle),
            ]),
            _VehiclesSection(collector: collector),
            const _SectionTitle('DOCUMENTS (TAP TO VIEW)'),
            for (final d in collector.docs)
              _DocRow(
                label: (d['type'] as String?) ?? 'Document',
                status: (d['status'] as String?) ?? 'pending',
                url: (d['url'] as String?) ?? '',
                optional:
                    isOptionalVerificationDoc((d['type'] as String?) ?? ''),
              ),
            const SizedBox(height: 16),
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

// The collector's formal photo, tap to view full size.
class _PhotoHeader extends StatelessWidget {
  final _PendingCollector collector;
  const _PhotoHeader({required this.collector});

  @override
  Widget build(BuildContext context) {
    final url = collector.photoUrl;
    return Row(children: [
      GestureDetector(
        onTap: url.isEmpty
            ? null
            : () => _openUpload(context, 'Formal photo', url),
        child: CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.buyerBlue.withValues(alpha: 0.1),
          backgroundImage: url.isEmpty ? null : NetworkImage(url),
          child: url.isEmpty
              ? const Icon(Icons.person, size: 36, color: AppColors.buyerBlue)
              : null,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
            url.isEmpty
                ? 'No formal photo uploaded yet'
                : 'Formal photo (tap to view)',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: url.isEmpty ? AppColors.error : AppColors.textSecondary)),
      ),
    ]);
  }
}

// Every registered vehicle with its capacity, plate number and photo.
class _VehiclesSection extends StatelessWidget {
  final _PendingCollector collector;
  const _VehiclesSection({required this.collector});

  @override
  Widget build(BuildContext context) {
    final vehicles = collector.vehicles;
    if (vehicles.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('VEHICLES'),
      for (final v in vehicles) _VehicleRow(vehicle: v),
      const SizedBox(height: 8),
    ]);
  }
}

class _VehicleRow extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final type = (vehicle['Vehicle_Type'] as String?) ?? 'Vehicle';
    final plate = ((vehicle['Plate_Number'] as String?) ?? '').trim();
    final capacity = (vehicle['Vehicle_Capacity_Kg'] as num?) ?? 0;
    final needsPlate = vehicleNeedsPlate(type);
    return _DocRow(
      label: type,
      status: '',
      url: (vehicle['Photo_URL'] as String?) ?? '',
      detail: [
        'Capacity $capacity kg',
        if (needsPlate) plate.isEmpty ? 'No plate number' : 'Plate $plate',
      ].join(' · '),
      detailIsWarning: needsPlate && plate.isEmpty,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1)),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          _VSec('COLLECTOR DETAILS', [
            ('Name', collector.name),
            ('Phone', collector.phone),
            ('Active vehicle', collector.vehicle),
          ]),
          for (final type in _remaining) ...[
            _SectionTitle('NEW VEHICLE: ${type.toUpperCase()}'),
            for (final v
                in collector.vehicles.where((v) => v['Vehicle_Type'] == type))
              _VehicleRow(vehicle: v),
            const SizedBox(height: 8),
            _DecisionButtons(
              busy: _busyType != null,
              onApprove: () => _decide(type, true),
              onReject: () => _decide(type, false),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

// A Barangay Clearance a verified collector uploaded afterwards. It is
// optional; approving it gives them the "Barangay Cleared" badge.
class _ClearanceDetail extends StatefulWidget {
  final _PendingCollector collector;
  const _ClearanceDetail({required this.collector});

  @override
  State<_ClearanceDetail> createState() => _ClearanceDetailState();
}

class _ClearanceDetailState extends State<_ClearanceDetail> {
  bool _busy = false;

  Future<void> _decide(bool approve) async {
    if (_busy) return;
    setState(() => _busy = true);
    final svc = FirestoreService();
    final uid = widget.collector.uid;
    try {
      await svc.setVerificationDocStatus(
          uid, barangayClearanceDocType, approve ? 'Verified' : 'Rejected');
      await svc.logAction({
        'Actor_ID': AuthState.instance.uid ?? 'admin',
        'Action': approve ? 'APPROVE_DOCUMENT' : 'REJECT_DOCUMENT',
        'Target_ID': uid,
        'Description': 'Admin ${approve ? 'approved' : 'rejected'} the '
            'Barangay Clearance of collector ${widget.collector.name}.',
      });
      await svc.sendNotification({
        'Recipient_ID': uid,
        'Title': approve
            ? 'Barangay Clearance approved'
            : 'Barangay Clearance not approved',
        'Message': approve
            ? 'You now have the Barangay Cleared badge. Households see it on '
                'your pickups.'
            : 'Your Barangay Clearance was not approved. You can upload a '
                'clearer copy in Verification Documents.',
        'Type': approve ? 'verification_approved' : 'verification_rejected',
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collector = widget.collector;
    final doc = verificationDocOf(collector.docs, barangayClearanceDocType);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
          backgroundColor: AppColors.canvas,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context)),
          title: Text('Clearance: ${collector.name}',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          _PhotoHeader(collector: collector),
          const SizedBox(height: 16),
          _DocRow(
            label: barangayClearanceDocType,
            status: (doc?['status'] as String?) ?? 'pending',
            url: (doc?['url'] as String?) ?? '',
            optional: true,
          ),
          const SizedBox(height: 8),
          const Text(
              'Optional document. Approving it gives this collector the '
              '"Barangay Cleared" badge that households see.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _DecisionButtons(
            busy: _busy,
            onApprove: () => _decide(true),
            onReject: () => _decide(false),
          ),
        ],
      ),
    );
  }
}

class _DecisionButtons extends StatelessWidget {
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _DecisionButtons(
      {required this.busy, required this.onApprove, required this.onReject});

  ButtonStyle _style(Color color) => ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
              style: _style(AppColors.success),
              onPressed: busy ? null : onApprove,
              child: const Text('APPROVE',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
      const SizedBox(width: 8),
      Expanded(
          child: ElevatedButton(
              style: _style(AppColors.error),
              onPressed: busy ? null : onReject,
              child: const Text('REJECT',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
    ]);
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
        _SectionTitle(title),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    Expanded(
                        child: Text(e.value.$2,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textPrimary))),
                  ]));
            }).toList())),
      ]));
}

/// One uploaded file as a full-width row: thumbnail, name, status and a
/// View button. The whole row opens the file.
class _DocRow extends StatelessWidget {
  final String label, status, url;
  final bool optional;
  final String? detail;
  final bool detailIsWarning;

  const _DocRow({
    required this.label,
    required this.status,
    required this.url,
    this.optional = false,
    this.detail,
    this.detailIsWarning = false,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String get _statusText {
    if (url.isEmpty) return optional ? 'Not uploaded (optional)' : 'Not uploaded';
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.divider)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: hasFile ? () => _openUpload(context, label, url) : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: !hasFile
                      ? Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.insert_drive_file_outlined,
                              color: AppColors.textMuted))
                      : isImageUrl(url)
                          ? Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.broken_image_outlined,
                                      color: AppColors.textSecondary))
                          : Container(
                              color: const Color(0xFFF3F4F6),
                              child: Center(
                                  child: Text(fileExtensionLabel(url),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary)))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                      if (optional) ...[
                        const SizedBox(width: 6),
                        const Text('Optional',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted)),
                      ],
                    ]),
                    if (detail != null)
                      Text(detail!,
                          style: TextStyle(
                              fontSize: 12,
                              color: detailIsWarning
                                  ? AppColors.error
                                  : AppColors.textSecondary)),
                    if (_statusText.isNotEmpty)
                      Text(_statusText,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasFile
                                  ? _statusColor
                                  : (optional
                                      ? AppColors.textSecondary
                                      : AppColors.error))),
                  ],
                ),
              ),
              if (hasFile)
                TextButton.icon(
                  onPressed: () => _openUpload(context, label, url),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
