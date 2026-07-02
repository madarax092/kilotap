import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RateCollectorScreen extends StatelessWidget {
  const RateCollectorScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black38,
    body: Center(child: Container(
      margin: const EdgeInsets.all(28), padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Rate Your Collector', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('How was your experience?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle), child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Juan Dela Cruz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              Text('Tricycle · #PKP-0040 · June 28', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_border, color: AppColors.star, size: 36))),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: ['On Time', 'Professional', 'Handled Carefully', 'Good Communication'].map((t) => Chip(
          label: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          backgroundColor: ['On Time', 'Professional'].contains(t) ? AppColors.sellerGreen : AppColors.inputGrey,
          labelStyle: TextStyle(color: ['On Time', 'Professional'].contains(t) ? Colors.white : AppColors.textSecondary),
        )).toList()),
        const SizedBox(height: 16),
        TextField(decoration: InputDecoration(hintText: 'Add a comment (optional)...', filled: true, fillColor: AppColors.inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider))), maxLines: 2),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 44, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(context), child: const Text('SUBMIT RATING', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)))),
      ]),
    )),
  );
}
