import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/booking_item.dart';

class BookingSummaryScreen extends StatelessWidget {
  final String totalVolume;
  final double totalWeight;
  final String selectedVehicle;
  final List<BookingItem> items;

  const BookingSummaryScreen({
    super.key,
    required this.totalVolume,
    required this.totalWeight,
    required this.selectedVehicle,
    required this.items,
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
          // Actual Scrap Image
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              image: const DecorationImage(
                image: AssetImage('assets/images/multiple_scrap_sample.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Collector card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF), // Light blue background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.buyerBlue.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + Car
                      SizedBox(
                        width: 90,
                        height: 48,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 32,
                              top: 2,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.buyerBlue.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.local_shipping_outlined, color: AppColors.buyerBlue, size: 22),
                                ),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.buyerBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('JA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Text('Jerico Odal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A))),
                          Text(' \u00b7 5.0 ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                          Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'LAO4594',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A8A),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedVehicle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
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
          const SizedBox(height: 12),
          // Items Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ITEMS BREAKDOWN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 12),
              ...items.map((item) => _ItemRow(item)).toList(),
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

class _ItemRow extends StatelessWidget {
  final BookingItem item;
  const _ItemRow(this.item);

  @override
  Widget build(BuildContext context) {
    final qtyText = '${item.quantity} pc${item.quantity > 1 ? 's' : ''}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)
                  )
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.sizeClass} · ${item.estimatedWeightKg.toStringAsFixed(2)} kg',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280)
                  )
                ),
              ],
            )
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6)
            ),
            child: Text(
              qtyText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563)
              )
            )
          ),
        ]
      )
    );
  }
}
