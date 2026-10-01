import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  Future<_ImpactData> _load() async {
    final svc = FirestoreService();
    final bookings =
        await svc.sellerBookings(AuthState.instance.uid ?? '').first;
    final completed = bookings.where((b) => b.status == 'Completed').toList();

    double totalKg = 0;
    for (final b in completed) {
      final items = await svc.bookingItems(b.bookingId).first;
      totalKg += items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
    }

    return _ImpactData(
      totalKg: totalKg,
      pickups: completed.length,
      treesSaved: (totalKg / 45).floor(),
      co2SavedKg: totalKg * 0.17,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recycling Impact',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<_ImpactData>(
        future: _load(),
        builder: (context, snapshot) {
          final data = snapshot.data ??
              const _ImpactData(
                  totalKg: 0, pickups: 0, treesSaved: 0, co2SavedKg: 0);
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              const Text('Your contribution to the environment',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.eco,
                    value: '${data.treesSaved}',
                    label: 'Trees Saved',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    icon: Icons.recycling,
                    value: data.totalKg.toStringAsFixed(1),
                    label: 'Kg Recycled',
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.local_shipping,
                    value: '${data.pickups}',
                    label: 'Total Pickups',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    icon: Icons.cloud,
                    value: data.co2SavedKg.toStringAsFixed(0),
                    label: 'Kg CO2 Saved',
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              const Text('How This Is Calculated',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow('Trees Saved',
                          'Based on the formula: 45 kg of recycled material prevents the cutting of one mature tree.'),
                      SizedBox(height: 12),
                      _InfoRow('CO2 Saved',
                          'Based on EPA estimates: each kg of recycled material saves approximately 0.17 kg of CO2 emissions compared to landfill disposal.'),
                      SizedBox(height: 12),
                      _InfoRow('Total Kg',
                          'Sum of estimated weights from all your completed pickups.'),
                    ]),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _ImpactData {
  final double totalKg;
  final int pickups;
  final int treesSaved;
  final double co2SavedKg;
  const _ImpactData({
    required this.totalKg,
    required this.pickups,
    required this.treesSaved,
    required this.co2SavedKg,
  });
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatBox(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sellerGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.sellerGreen.withValues(alpha: 0.12)),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.sellerGreen, size: 32),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.sellerGreen)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title, description;
  const _InfoRow(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(description,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
