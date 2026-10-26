import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/collector_info_card.dart';
import '../../widgets/empty_section_text.dart';
import '../../widgets/full_screen_image_page.dart';

class BookingSummaryScreen extends StatelessWidget {
  final String bookingId;
  // The photo still on this phone right after submitting; afterwards the
  // uploaded copy (bookings.PhotoURL, Cloudinary) is shown instead.
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
        title: const Text('Pickup Details',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<Booking?>(
        stream: firestoreService.bookingStream(bookingId),
        builder: (context, bookingSnap) {
          if (!bookingSnap.hasData &&
              bookingSnap.connectionState == ConnectionState.waiting) {
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
                  _Photo(url: booking.photoUrl, localPath: photoPath),
                  const SizedBox(height: 20),
                  _StatusBanner(booking: booking),
                  if (booking.collectorId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CollectorInfoCard(collectorId: booking.collectorId),
                  ],
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
                          const Text('BOOKING DETAILS',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                          const SizedBox(height: 12),
                          _DetailRow('Pickup', pickupScheduleLabel(booking)),
                          _DetailRow('Vehicle', booking.vehicleRequirement),
                          _DetailRow('Est. Weight',
                              '${totalWeight.toStringAsFixed(2)} kg'),
                          _DetailRow('Pickup Address', booking.pickupAddress),
                          _DetailRow(
                              'Requested', formatDateTime(booking.createdAt)),
                          if (booking.notes.isNotEmpty)
                            _DetailRow('Notes', booking.notes),
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

// The scrap photo, tap to view it full screen.
class _Photo extends StatelessWidget {
  final String url;
  final String? localPath;
  const _Photo({required this.url, this.localPath});

  @override
  Widget build(BuildContext context) {
    final hasLocal = !kIsWeb && (localPath ?? '').isNotEmpty;
    if (url.isEmpty && !hasLocal) {
      return const EmptySectionText('No photo for this pickup.',
          padding: EdgeInsets.zero);
    }
    final image = url.isNotEmpty
        ? Image.network(url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: AppColors.textSecondary)))
        : Image.file(File(localPath!), fit: BoxFit.cover);
    return GestureDetector(
      onTap: () => showFullScreenImage(context,
          title: 'Scrap photo', url: url, filePath: localPath ?? ''),
      child: Container(
        width: double.infinity,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(fit: StackFit.expand, children: [
          image,
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('Tap to view',
                    style: TextStyle(fontSize: 11, color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Booking booking;
  const _StatusBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color fg, Color bg, String message) =
        switch (booking.status) {
      'Accepted' => (
          Icons.local_shipping_outlined,
          AppColors.buyerBlue,
          const Color(0xFFEFF6FF),
          'A collector accepted your pickup and is on the way',
        ),
      'Completed' => (
          Icons.check_circle_outline,
          AppColors.success,
          const Color(0xFFF0FDF4),
          booking.completedAt != null
              ? 'Picked up on ${formatDateTime(booking.completedAt!)}'
              : 'This pickup is complete',
        ),
      'Cancelled' => (
          Icons.cancel_outlined,
          AppColors.error,
          const Color(0xFFFEF2F2),
          'This pickup was cancelled',
        ),
      _ => (
          Icons.hourglass_top,
          const Color(0xFFB45309),
          const Color(0xFFFFFBEB),
          'Waiting for a nearby collector to accept',
        ),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, color: fg, size: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.status,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
              Text(message, style: TextStyle(fontSize: 12, color: fg)),
            ],
          ),
        ),
      ]),
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
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
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(item.notes,
                    style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF9CA3AF))),
              ],
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
