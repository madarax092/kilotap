import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'booking_summary_screen.dart';
import '../../models/booking_item.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_state.dart';

class MyPickupsScreen extends StatelessWidget {
  const MyPickupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Pickups',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.receipt_long,
                          color: Color(0xFF6B7280), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Track and manage your scrap collections',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FilterChip('Active (2)', active: true),
                    const SizedBox(width: 8),
                    _FilterChip('Completed (14)'),
                    const SizedBox(width: 8),
                    _FilterChip('Cancelled'),
                  ]),
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService()
                      .sellerBookingsDetailed(AuthState.instance.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.sellerGreen)),
                      );
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: Text('No pickups yet',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ),
                      );
                    }
                    return Column(
                      children: items.map((item) {
                        final b = item['booking'] as Booking;
                        final label = switch (b.status) {
                          'Pending' => 'PENDING',
                          'Accepted' => 'ON THE WAY',
                          'Completed' => 'COMPLETED',
                          'Cancelled' => 'CANCELLED',
                          _ => b.status.toUpperCase(),
                        };
                        final color = switch (b.status) {
                          'Pending' => const Color(0xFFF59E0B),
                          'Accepted' => AppColors.buyerBlue,
                          'Completed' => const Color(0xFF10B981),
                          _ => AppColors.error,
                        };
                        return _PickupCard(
                          id: b.bookingId,
                          status: label,
                          statusColor: color,
                          initials: item['initials'],
                          name: item['name'].isEmpty
                              ? 'Unassigned'
                              : item['name'],
                          items: b.vehicleRequirement,
                          meta: b.pickupAddress,
                          stars: '—',
                          actions: const [],
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ]),
          child: SafeArea(
              child: BottomNavigationBar(
            currentIndex: 2,
            selectedItemColor: AppColors.sellerGreen,
            unselectedItemColor: const Color(0xFFBBBBBB),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 0) Navigator.pushReplacementNamed(context, '/household');
              if (i == 1) Navigator.pushReplacementNamed(context, '/sell');
              if (i == 3) Navigator.pushReplacementNamed(context, '/chat');
              if (i == 4) Navigator.pushReplacementNamed(context, '/profile');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded), label: 'Pickups'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Messages'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ))),
    );
  }
}

class _DateOptionTile extends StatelessWidget {
  final String label;
  const _DateOptionTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.radio_button_unchecked, color: Color(0xFFD1D5DB)),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip(this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.sellerGreen : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: active ? AppColors.sellerGreen : const Color(0xFFE5E7EB)),
        boxShadow: active
            ? const [
                BoxShadow(
                    color: Color(0x1A4CAF50),
                    blurRadius: 8,
                    offset: Offset(0, 4))
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF6B7280)),
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  final String id, status, initials, name, items, meta, stars;
  final Color statusColor;
  final List<(String, IconData, Color, Color, bool, VoidCallback)> actions;
  final VoidCallback? onTap;

  const _PickupCard({
    required this.id,
    required this.status,
    required this.statusColor,
    required this.initials,
    required this.name,
    required this.items,
    required this.meta,
    required this.stars,
    required this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA0A0A0),
                        fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                final dummyItems = <BookingItem>[
                  BookingItem(
                    itemId: 'ITM-001',
                    bookingId: id,
                    itemName: 'Mixed Scrap',
                    quantity: 1,
                    sizeClass: 'Varies',
                    estimatedWeightKg: 10.0,
                    scrapClass: 'mixed',
                  ),
                ];
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingSummaryScreen(
                              totalVolume: 'N/A',
                              totalWeight: 10.0,
                              selectedVehicle: 'Vehicle',
                              items: dummyItems,
                            )));
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: Colors.blueAccent, shape: BoxShape.circle),
                    child: Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Text(items,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Text(meta,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(stars,
                      style: const TextStyle(
                          color: AppColors.star,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFF3F4F6), height: 1),
            ),
            Row(
              children: actions
                  .map((a) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: a.$5
                              ? OutlinedButton.icon(
                                  icon: Icon(a.$2, size: 18),
                                  label: Text(a.$1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: a.$4,
                                    backgroundColor: a.$3,
                                    side: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: a.$6,
                                )
                              : ElevatedButton.icon(
                                  icon: Icon(a.$2, size: 18),
                                  label: Text(a.$1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: a.$3,
                                    foregroundColor: a.$4,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: a.$6,
                                ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
