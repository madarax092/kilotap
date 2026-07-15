import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/impact_tracker.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  static const double _demoTotalKg = 245.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recycling Impact',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text('Your contribution to the environment',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          // Impact stats
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sellerGreen.withOpacity(0.12)),
                ),
                child: const Column(children: [
                  Icon(Icons.eco, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 8),
                  Text('6', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.sellerGreen)),
                  SizedBox(height: 4),
                  Text('Trees Saved', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sellerGreen.withOpacity(0.12)),
                ),
                child: const Column(children: [
                  Icon(Icons.recycling, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 8),
                  Text('245.7', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.sellerGreen)),
                  SizedBox(height: 4),
                  Text('Kg Recycled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sellerGreen.withOpacity(0.12)),
                ),
                child: const Column(children: [
                  Icon(Icons.local_shipping, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 8),
                  Text('16', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.sellerGreen)),
                  SizedBox(height: 4),
                  Text('Total Pickups', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sellerGreen.withOpacity(0.12)),
                ),
                child: const Column(children: [
                  Icon(Icons.cloud, color: AppColors.sellerGreen, size: 32),
                  SizedBox(height: 8),
                  Text('42', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.sellerGreen)),
                  SizedBox(height: 4),
                  Text('Kg CO2 Saved', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text('How This Is Calculated',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _InfoRow('Trees Saved', 'Based on the formula: 45 kg of recycled material prevents the cutting of one mature tree.'),
              const SizedBox(height: 12),
              _InfoRow('CO2 Saved', 'Based on EPA estimates: each kg of recycled material saves approximately 0.17 kg of CO2 emissions compared to landfill disposal.'),
              const SizedBox(height: 12),
              _InfoRow('Total Kg', 'Sum of estimated weights from all completed YOLOv8n-detected pickups.'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title, description;
  const _InfoRow(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
