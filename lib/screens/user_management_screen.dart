import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: const Text('Users (342)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _Chip('All', true, AppColors.buyerBlue), _Chip('Households', false, AppColors.sellerGreen), _Chip('Collectors', false, AppColors.buyerBlue), _Chip('Pending', false, AppColors.warning), _Chip('Suspended', false, AppColors.error),
        ]))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
          _URow('JD', 'Juan Dela Cruz', 'Collector · Maa · Tricycle', 'VERIFIED', AppColors.success, '★4.8', AppColors.buyerBlue),
          _URow('PR', 'Pedro Reyes', 'Collector · Matina · Tricycle', 'PENDING', AppColors.warning, null, AppColors.buyerBlue),
          _URow('MS', 'Maria Santos', 'Household · Maa · House', 'ACTIVE', AppColors.success, null, AppColors.sellerGreen),
          _URow('RT', 'Ramon Torres', 'Collector · Toril · Kariton', 'SUSPENDED', AppColors.error, '★2.1', AppColors.buyerBlue),
          _URow('JR', 'Jose Ramirez', 'Household · Ecoland · House', 'ACTIVE', AppColors.success, null, AppColors.sellerGreen),
        ])),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool active; final Color color;
  const _Chip(this.label, this.active, this.color);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: active ? color : AppColors.inputGrey, borderRadius: BorderRadius.circular(16)), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary)));
}

class _URow extends StatelessWidget {
  final String initials, name, meta, badge; final Color badgeColor, avatarColor; final String? stars;
  const _URow(this.initials, this.name, this.meta, this.badge, this.badgeColor, this.stars, this.avatarColor);
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle), child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: badgeColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: badgeColor))),
        if (stars != null) ...[const SizedBox(width: 8), Text(stars!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.star))],
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.divider, size: 18),
      ]),
    );
  }
}
