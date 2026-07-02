import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MyPickupsScreen extends StatelessWidget {
  const MyPickupsScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: const Text('My Pickups', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 4),
        Row(children: [Chip(label: const Text('Active (2)'), backgroundColor: AppColors.sellerGreen, labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(width: 8), Chip(label: const Text('Completed (14)'), backgroundColor: AppColors.inputGrey, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11)), const SizedBox(width: 8), Chip(label: const Text('Cancelled'), backgroundColor: AppColors.inputGrey, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11))]),
        const SizedBox(height: 16),
        _PickupCard(id: '#PKP-0042', name: 'Juan Dela Cruz', initials: 'JD', items: 'Plastic, Cardboard ~3.2 kg \u00b7 Tricycle', meta: 'ETA 5 min', rating: '\u2605 4.8', status: 'ON THE WAY', statusColor: AppColors.buyerBlue, actions: [('Track', AppColors.sellerGreen, true), ('Chat', AppColors.inputGrey, false)]),
        _PickupCard(id: '#PKP-0041', name: 'Maria Santos', initials: 'MS', items: 'Scrap Iron, Appliance ~25 kg \u00b7 Multicab', meta: 'Tomorrow 9-12PM', rating: '\u2605 4.9', status: 'CONFIRMED', statusColor: AppColors.buyerBlue, actions: [('Chat', AppColors.inputGrey, false), ('Reschedule', AppColors.inputGrey, false)]),
        _PickupCard(id: '#PKP-0040', name: 'Pedro Reyes', initials: 'PR', items: 'Plastic Bottles 5.2 kg', meta: 'June 28, 2026', rating: '\u2605 4.5', status: 'COMPLETED', statusColor: AppColors.success, actions: [('Rate Collector', AppColors.sellerGreen, true), ('Report', AppColors.error.withOpacity(0.1), false)]),
      ]),
    );
  }
}

class _PickupCard extends StatelessWidget {
  final String id, name, initials, items, meta, rating, status; final Color statusColor; final List<(String, Color, bool)> actions;
  const _PickupCard({required this.id, required this.name, required this.initials, required this.items, required this.meta, required this.rating, required this.status, required this.statusColor, required this.actions});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(id, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)))]),
      const SizedBox(height: 10),
      Row(children: [Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle), child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)), Text(items, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])), Text(rating, style: const TextStyle(color: AppColors.star, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 4),
      Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      const SizedBox(height: 10),
      const Divider(),
      Row(children: actions.map((a) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: a.$2, foregroundColor: a.$3 ? Colors.white : AppColors.textPrimary, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: Text(a.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)))))).toList()),
    ]),
  );
}
