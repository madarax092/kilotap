import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/pre_pickup_checklist.dart';

class PickupChecklistScreen extends StatelessWidget {
  final String bookingId;
  final String collectorName;
  final String vehicleType;

  const PickupChecklistScreen({
    super.key,
    required this.bookingId,
    required this.collectorName,
    required this.vehicleType,
  });

  String _shortId(String id) =>
      '#${id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase()}';

  String _initials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).take(2);
    return parts.isEmpty ? '?' : parts.map((w) => w[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Prepare for Pickup',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_shortId(bookingId),
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.buyerBlue, shape: BoxShape.circle),
                  child: Center(
                      child: Text(_initials(collectorName),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(collectorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        if (vehicleType.isNotEmpty)
                          Text(vehicleType,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<BookingItem>>(
            stream: firestoreService.bookingItems(bookingId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final detectedClasses =
                  snapshot.data!.map((i) => i.scrapClass).toList();
              return PrePickupChecklist(
                detectedClasses: detectedClasses,
                onClose: () => Navigator.pop(context),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
