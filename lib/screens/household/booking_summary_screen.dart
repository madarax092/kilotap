import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../services/firestore_service.dart';

class BookingSummaryScreen extends StatelessWidget {
  final String bookingId;
  final String? photoPath;

  const BookingSummaryScreen({
    super.key,
    required this.bookingId,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Pickup Requested',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: FutureBuilder<Booking?>(
        future: firestoreService.getBooking(bookingId),
        builder: (context, bookingSnap) {
          if (bookingSnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final booking = bookingSnap.data;
          if (booking == null) {
            return const Center(child: Text('Booking not found.'));
          }

          return StreamBuilder<List<BookingItem>>(
            stream: firestoreService.bookingItems(bookingId),
            builder: (context, itemsSnap) {
              final items = itemsSnap.data ?? const <BookingItem>[];
              final totalWeight = items.fold<double>(
                  0, (sum, item) => sum + item.estimatedWeightKg);

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  const SizedBox(height: 8),
                  if (photoPath != null)
                    Container(
                      width: double.infinity,
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Image.file(File(photoPath!), fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                            child: Icon(Icons.hourglass_top,
                                color: Color(0xFFB45309), size: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.status,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E))),
                            const Text('Waiting for a nearby collector to accept',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFFB45309))),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BOOKING DETAILS',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                          const SizedBox(height: 12),
                          _DetailRow('Vehicle', booking.vehicleRequirement),
                          _DetailRow(
                              'Est. Weight', '${totalWeight.toStringAsFixed(2)} kg'),
                          _DetailRow('Pickup Address', booking.pickupAddress),
                        ]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ITEMS BREAKDOWN',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                          const SizedBox(height: 12),
                          ...items.map((item) => _ItemRow(item)),
                        ]),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          );
        },
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
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final BookingItem item;
  const _ItemRow(this.item);

  @override
  Widget build(BuildContext context) {
    final qtyText = '${item.quantity} pc${item.quantity > 1 ? 's' : ''}';
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(
                  '${item.sizeClass} · ${item.estimatedWeightKg.toStringAsFixed(2)} kg',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          )),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(qtyText,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563)))),
        ]));
  }
}
