import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BookingSummaryScreen extends StatelessWidget {
  final String totalVolume;
  final double totalWeight;
  final String selectedVehicle;

  const BookingSummaryScreen({
    super.key,
    required this.totalVolume,
    required this.totalWeight,
    required this.selectedVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Booking Confirmed',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          // Confirmation banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.sellerGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sellerGreen.withOpacity(0.15)),
            ),
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle, color: AppColors.sellerGreen, size: 36),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Booking Submitted',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('A collector is on the way',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 20),
          // Collector card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ASSIGNED COLLECTOR',
                  style: TextStyle(fontSize: 10, color: AppColors.buyerBlue, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle),
                  child: const Center(child: Text('DM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Driver Max', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('$selectedVehicle \u00b7 Verified', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),
                const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\u2605 4.8', style: TextStyle(color: AppColors.star, fontWeight: FontWeight.w700, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('42 pickups', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          // ETA card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sellerGreen.withOpacity(0.15)),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Icon(Icons.directions_car, color: AppColors.sellerGreen, size: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Estimated Arrival', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Via JP Laurel Ave \u00b7 1.2 km', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ),
              const Text('5 min', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.sellerGreen)),
            ]),
          ),
          const SizedBox(height: 20),
          // Booking details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('BOOKING DETAILS', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 12),
              _DetailRow('Pickup Type', 'ASAP'),
              _DetailRow('Vehicle', selectedVehicle),
              _DetailRow('Total Volume', totalVolume),
              _DetailRow('Est. Weight', '${totalWeight.toStringAsFixed(2)} kg'),
            ]),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }
}
