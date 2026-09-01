import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class VerifyCollectorScreen extends StatelessWidget {
  const VerifyCollectorScreen({super.key});

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Verify Collectors',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.close,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
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
                  future: _loadPending(firestoreService, collectors),
                  builder: (context, pendingSnap) {
                    if (!snapshot.hasData || !pendingSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final pending = pendingSnap.data!;
                    if (pending.isEmpty) {
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
                        const SizedBox(height: 24),
                        Row(children: [
                          const Text('PENDING VERIFICATION',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: const BoxDecoration(
                                  color: AppColors.adminRed, shape: BoxShape.circle),
                              child: Text('${pending.length}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white))),
                        ]),
                        const SizedBox(height: 12),
                        ...pending.map((c) => _VerifyTile(
                              collector: c,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          _VerifyDetail(collector: c))),
                            )),
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

  Future<List<_PendingCollector>> _loadPending(
      FirestoreService svc, List<Map<String, dynamic>> collectors) async {
    final results = await Future.wait(collectors.map((u) async {
      final profile = await svc.collectorProfile(u['uid'] as String);
      return _PendingCollector(uid: u['uid'] as String, account: u, profile: profile);
    }));
    return results
        .where((c) => (c.profile?['Verification_Status'] as String?) == 'Pending')
        .toList();
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
}

class _VerifyTile extends StatelessWidget {
  final _PendingCollector collector;
  final VoidCallback onTap;
  const _VerifyTile({required this.collector, required this.onTap});
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
                        Text(collector.vehicle,
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
    try {
      await svc.setCollectorVerification(widget.collector.uid, status);
      await svc.logAction({
        'Actor_ID': AuthState.instance.uid ?? 'admin',
        'Action': status == 'Verified' ? 'VERIFY_COLLECTOR' : 'REJECT_COLLECTOR',
        'Target_ID': widget.collector.uid,
        'Description':
            'Admin ${status == 'Verified' ? 'verified' : 'rejected'} collector ${widget.collector.name}.',
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
                          child: _DTile((d['type'] as String?) ?? 'Document',
                              (d['status'] as String?) ?? 'pending')))
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
  final String label, status;
  const _DTile(this.label, this.status);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 90,
      decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider)),
      child: Stack(children: [
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
        Positioned(
            top: 6,
            right: 6,
            child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                    color: status == 'verified' ? AppColors.success : AppColors.warning,
                    shape: BoxShape.circle),
                child: const Icon(Icons.circle, size: 8, color: Colors.transparent))),
      ]));
}
