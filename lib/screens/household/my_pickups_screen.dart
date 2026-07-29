import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'pickup_checklist_screen.dart';
import 'chat_detail_screen.dart';
import 'booking_summary_screen.dart';
import 'tracking_screen.dart';
import '../../models/booking_item.dart';

class MyPickupsScreen extends StatelessWidget {
  const MyPickupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
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
                _PickupCard(
                  id: '#PKP-0042',
                  status: 'ON THE WAY',
                  statusColor: AppColors.buyerBlue,
                  initials: 'JD',
                  name: 'Juan Dela Cruz',
                  items:
                      'Plastic 12 pcs (S), Cardboard 3 pcs (M) \u00b7 Tricycle',
                  meta: 'ETA 5 min',
                  stars: '\u2605 4.8',
                  actions: [
                    (
                      'Track Pickup',
                      Icons.near_me_outlined,
                      AppColors.sellerGreen,
                      Colors.white,
                      false,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TrackingScreen(
                                    collectorName: 'Juan Dela Cruz',
                                    bookingId: '#PKP-0042')));
                      }
                    ),
                    (
                      'Message',
                      Icons.chat_bubble_outline,
                      Colors.white,
                      const Color(0xFF2C2C2C),
                      true,
                      () => _openChat(context, 'Juan Dela Cruz', '#PKP-0042')
                    ),
                  ],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PickupChecklistScreen(
                          bookingId: '#PKP-0042',
                          detectedClasses: [
                            'refrigerator_standard',
                            'plastic_bottle_1L',
                            'metal_pipe_1m'
                          ],
                          collectorName: 'Juan Dela Cruz',
                          eta: '5 min',
                          vehicle: 'Tricycle',
                        ),
                      )),
                ),
                _PickupCard(
                  id: '#PKP-0041',
                  status: 'CONFIRMED',
                  statusColor: AppColors.buyerBlue,
                  initials: 'MS',
                  name: 'Maria Santos',
                  items: 'Metal 5 pcs (L), Appliance 1 pc (H) \u00b7 Multicab',
                  meta: 'Tomorrow 9-12PM',
                  stars: '\u2605 4.9',
                  actions: [
                    (
                      'Message',
                      Icons.chat_bubble_outline,
                      Colors.white,
                      const Color(0xFF2C2C2C),
                      true,
                      () => _openChat(context, 'Maria Santos', '#PKP-0041')
                    ),
                    (
                      'Reschedule',
                      Icons.calendar_today_outlined,
                      Colors.white,
                      const Color(0xFF2C2C2C),
                      true,
                      () => _showRescheduleDialog(context, '#PKP-0041')
                    ),
                  ],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PickupChecklistScreen(
                          bookingId: '#PKP-0041',
                          detectedClasses: ['metal_bolt', 'window_aircon'],
                          collectorName: 'Maria Santos',
                          eta: 'Tomorrow 9 AM',
                          vehicle: 'Multicab',
                        ),
                      )),
                ),
                _PickupCard(
                  id: '#PKP-0040',
                  status: 'COMPLETED',
                  statusColor: const Color(0xFF10B981),
                  initials: 'PR',
                  name: 'Pedro Reyes',
                  items: 'Plastic Bottles (S) 5.2 kg',
                  meta: 'June 28, 2026',
                  stars: '\u2605 4.5',
                  actions: [
                    (
                      'Rate',
                      Icons.star_outline,
                      AppColors.sellerGreen,
                      Colors.white,
                      false,
                      () => _showRatingDialog(context, 'Pedro Reyes')
                    ),
                    (
                      'Report',
                      Icons.flag_outlined,
                      const Color(0xFFFEF2F2),
                      const Color(0xFFEF4444),
                      false,
                      () => _showReportDialog(context, 'Pedro Reyes')
                    ),
                  ],
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

  void _openChat(BuildContext context, String name, String bookingId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatDetailScreen(collectorName: name, bookingId: bookingId),
        ));
  }

  void _showRatingDialog(BuildContext context, String collectorName) {
    int rating = 5;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Rate your pickup',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text('How was your experience with $collectorName?',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 44,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < rating
                          ? AppColors.star
                          : const Color(0xFFE5E7EB),
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add an optional comment...',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.sellerGreen)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sellerGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      backgroundColor: AppColors.sellerGreen,
                    ));
                  },
                  child: const Text('SUBMIT RATING',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, String bookingId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Reschedule Pickup',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 8),
            Text('Select a new time for $bookingId',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 24),
            const _DateOptionTile(label: 'Tomorrow, Morning (9AM - 12PM)'),
            const SizedBox(height: 12),
            const _DateOptionTile(label: 'Tomorrow, Afternoon (1PM - 4PM)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sellerGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Pickup rescheduled successfully.'),
                    backgroundColor: AppColors.sellerGreen,
                  ));
                },
                child: const Text('CONFIRM',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String collectorName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Report Issue',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 8),
            Text('What was the issue with $collectorName?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 24),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Please describe the problem...',
                hintStyle:
                    const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Report submitted.'),
                    backgroundColor: AppColors.error,
                  ));
                },
                child: const Text('SUBMIT REPORT',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
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
                    color: statusColor.withOpacity(0.1),
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
                          child: a.$5 // isOutlined
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
