import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.listUsers(),
        builder: (context, snapshot) {
          final allUsers = snapshot.data ?? const <Map<String, dynamic>>[];
          final filtered = allUsers.where((u) {
            final role = u['Role'] as String? ?? '';
            if (_filter == 'All') return true;
            if (_filter == 'Households') return role == 'Household';
            if (_filter == 'Collectors') {
              return role == 'Collector' || role == 'VerifiedCollector';
            }
            return true;
          }).toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: top + 16, left: 24, right: 24, bottom: 16),
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
                        Text('Users (${allUsers.length})',
                            style: const TextStyle(
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
                    const Text('Manage collectors and households',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _Chip('All', _filter == 'All', AppColors.buyerBlue,
                            () => setState(() => _filter = 'All')),
                        _Chip('Households', _filter == 'Households',
                            AppColors.sellerGreen,
                            () => setState(() => _filter = 'Households')),
                        _Chip('Collectors', _filter == 'Collectors',
                            AppColors.buyerBlue,
                            () => setState(() => _filter = 'Collectors')),
                      ]))),
              Expanded(
                child: !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('No users found.',
                                style: TextStyle(color: Color(0xFF6B7280))))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: [
                              ...filtered.map((u) => _URow(
                                  uid: u['uid'] as String,
                                  name: (u['Display_Name'] as String?) ?? 'Unknown',
                                  role: (u['Role'] as String?) ?? '',
                                  svc: firestoreService)),
                              const SizedBox(height: 30),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(current: 4),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip(this.label, this.active, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: active ? color : AppColors.inputGrey,
              borderRadius: BorderRadius.circular(16)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textSecondary))));
}

class _URow extends StatelessWidget {
  final String uid, name, role;
  final FirestoreService svc;
  const _URow(
      {required this.uid,
      required this.name,
      required this.role,
      required this.svc});

  @override
  Widget build(BuildContext context) {
    final isCollector = role == 'Collector' || role == 'VerifiedCollector';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase()
        : '?';
    final avatarColor = isCollector ? AppColors.buyerBlue : AppColors.sellerGreen;

    Widget row({String badge = 'ACTIVE', Color badgeColor = AppColors.success, String? stars}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
              child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(isCollector ? 'Collector' : 'Household',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 8, fontWeight: FontWeight.w700, color: badgeColor))),
          if (stars != null) ...[
            const SizedBox(width: 8),
            Text(stars,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.star)),
          ],
        ]),
      );
    }

    if (!isCollector) return row();

    return FutureBuilder<Map<String, dynamic>?>(
      future: svc.collectorProfile(uid),
      builder: (context, snapshot) {
        final status = (snapshot.data?['Verification_Status'] as String?) ?? 'Pending';
        final rating = (snapshot.data?['Avg_Rating'] as num?)?.toDouble() ?? 0;
        final badgeColor = status == 'Verified'
            ? AppColors.success
            : status == 'Rejected'
                ? AppColors.error
                : AppColors.warning;
        return row(
            badge: status.toUpperCase(),
            badgeColor: badgeColor,
            stars: rating > 0 ? '★${rating.toStringAsFixed(1)}' : null);
      },
    );
  }
}
