import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../widgets/admin_bottom_nav.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
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
                    const Text('Users (342)',
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
                    _Chip('All', true, AppColors.buyerBlue),
                    _Chip('Households', false, AppColors.sellerGreen),
                    _Chip('Collectors', false, AppColors.buyerBlue),
                    _Chip('Pending', false, AppColors.warning),
                    _Chip('Suspended', false, AppColors.error),
                  ]))),

          Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                _URow('JD', 'Juan Dela Cruz', 'Collector · Maa · Tricycle',
                    'VERIFIED', AppColors.success, '★4.8', AppColors.buyerBlue),
                _URow('PR', 'Pedro Reyes', 'Collector · Matina · Tricycle',
                    'PENDING', AppColors.warning, null, AppColors.buyerBlue),
                _URow('MS', 'Maria Santos', 'Household · Maa · House', 'ACTIVE',
                    AppColors.success, null, AppColors.sellerGreen),
                _URow('RT', 'Ramon Torres', 'Collector · Toril · Kariton',
                    'SUSPENDED', AppColors.error, '★2.1', AppColors.buyerBlue),
                _URow('JR', 'Jose Ramirez', 'Household · Ecoland · House',
                    'ACTIVE', AppColors.success, null, AppColors.sellerGreen),
                const SizedBox(height: 30),
              ])),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 4),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  const _Chip(this.label, this.active, this.color);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: active ? color : AppColors.inputGrey,
          borderRadius: BorderRadius.circular(16)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary)));
}

class _URow extends StatelessWidget {
  final String initials, name, meta, badge;
  final Color badgeColor, avatarColor;
  final String? stars;
  const _URow(this.initials, this.name, this.meta, this.badge, this.badgeColor,
      this.stars, this.avatarColor);
  @override
  Widget build(BuildContext context) {
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
            decoration:
                BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(meta,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textSecondary))
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: badgeColor))),
        if (stars != null) ...[
          const SizedBox(width: 8),
          Text(stars!,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.star))
        ],
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.divider, size: 18),
      ]),
    );
  }
}
