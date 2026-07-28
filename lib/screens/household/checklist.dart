import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/pre_pickup_checklist.dart';

class PickupChecklistScreen extends StatelessWidget {
  final String bookingId;
  final List<String> detectedClasses;
  final String collectorName;
  final String eta;
  final String vehicle;

  const PickupChecklistScreen({
    super.key,
    required this.bookingId,
    required this.detectedClasses,
    this.collectorName = 'Driver Max',
    this.eta = '5 min',
    this.vehicle = 'Truck',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Prepare for Pickup',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          // Booking context
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bookingId,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle),
                  child: Center(child: Text(collectorName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(collectorName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text('$vehicle \u00b7 ETA $eta',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Checklist
          PrePickupChecklist(detectedClasses: detectedClasses),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
