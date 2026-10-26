import 'package:flutter/material.dart';
import '../../widgets/empty_section_text.dart';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/auth_state.dart';
import '../../services/booking_outbox.dart';
import '../../services/firestore_service.dart';
import '../../services/system_settings_service.dart';
import '../../widgets/report_problem_sheet.dart';
import 'booking_summary_screen.dart';
import 'chat_detail_screen.dart';
import 'pickup_checklist_screen.dart';
import 'rate_collector_screen.dart';
import 'tracking_screen.dart';

class MyPickupsScreen extends StatelessWidget {
  const MyPickupsScreen({super.key});

  String _shortId(String id) =>
      '#${id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase()}';

  String _initials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).take(2);
    return parts.isEmpty ? '?' : parts.map((w) => w[0]).join().toUpperCase();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.buyerBlue;
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFFD97706);
    }
  }

  Future<_CardData> _loadCardData(FirestoreService svc, Booking b) async {
    String collectorName = 'Awaiting collector';
    if (b.collectorId.isNotEmpty) {
      collectorName = await svc.displayNameFor(b.collectorId);
    }
    final items = await svc.bookingItems(b.bookingId).first;
    final totalWeight =
        items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
    final itemsSummary = items.isEmpty
        ? 'No items recorded'
        : '${items.length} item${items.length > 1 ? 's' : ''} · '
            '${totalWeight.toStringAsFixed(1)} kg · ${b.vehicleRequirement}';
    double? existingRating;
    if (b.status == 'Completed') {
      final ratings = await svc.getRatings(b.bookingId);
      if (ratings.isNotEmpty) existingRating = ratings.first.score.toDouble();
    }
    return _CardData(
        collectorName: collectorName,
        itemsSummary: itemsSummary,
        existingRating: existingRating);
  }

  List<(String, IconData, Color, Color, bool, VoidCallback)> _actionsFor(
      BuildContext context, Booking b, _CardData data, FirestoreService svc) {
    switch (b.status) {
      case 'Pending':
        final cancelMin =
            SystemSettingsService.instance.current.value.cancelWindowMin;
        final withinCancelWindow = DateTime.now().difference(b.createdAt) <=
            Duration(minutes: cancelMin);
        if (!withinCancelWindow) return const [];
        return [
          (
            'Cancel',
            Icons.close,
            Colors.white,
            const Color(0xFF2C2C2C),
            true,
            () => svc.updateBookingStatus(b.bookingId, 'Cancelled'),
          ),
        ];
      case 'Accepted':
        return [
          (
            'Track Pickup',
            Icons.near_me_outlined,
            AppColors.sellerGreen,
            Colors.white,
            false,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TrackingScreen(
                        collectorId: b.collectorId,
                        collectorName: data.collectorName,
                        bookingId: _shortId(b.bookingId),
                        vehicleType: b.vehicleRequirement,
                        destLat: b.pickupGps.latitude,
                        destLon: b.pickupGps.longitude))),
          ),
          (
            'Prepare',
            Icons.checklist_outlined,
            Colors.white,
            const Color(0xFF2C2C2C),
            true,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PickupChecklistScreen(
                        bookingId: b.bookingId,
                        collectorName: data.collectorName,
                        vehicleType: b.vehicleRequirement))),
          ),
          (
            'Message',
            Icons.chat_bubble_outline,
            Colors.white,
            const Color(0xFF2C2C2C),
            true,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(
                        otherUserId: b.collectorId,
                        otherUserName: data.collectorName))),
          ),
          (
            'Cancel',
            Icons.close,
            Colors.white,
            AppColors.error,
            true,
            () => _cancelAccepted(context, svc, b, data.collectorName),
          ),
          _reportAction(context, b),
        ];
      case 'Completed':
        return [
          if (data.existingRating == null)
            (
              'Rate',
              Icons.star_outline,
              AppColors.sellerGreen,
              Colors.white,
              false,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RateCollectorScreen(
                          collectorId: b.collectorId,
                          bookingId: b.bookingId,
                          collectorName: data.collectorName))),
            ),
          _reportAction(context, b),
        ];
      case 'Cancelled':
        // Only a pickup a collector had accepted has someone to report.
        if (b.collectorId.isEmpty) return const [];
        return [_reportAction(context, b)];
      default:
        return const [];
    }
  }

  (String, IconData, Color, Color, bool, VoidCallback) _reportAction(
      BuildContext context, Booking b) {
    return (
      'Report',
      Icons.flag_outlined,
      Colors.white,
      AppColors.error,
      true,
      () => showReportProblemSheet(context, bookingId: b.bookingId),
    );
  }

  Future<void> _cancelAccepted(BuildContext context, FirestoreService svc,
      Booking b, String collectorName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel this pickup?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            '$collectorName already accepted this booking and will be '
            'notified that it\'s cancelled.',
            style: const TextStyle(color: Color(0xFF4B5563))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Booking',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Booking',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await svc.updateBookingStatus(b.bookingId, 'Cancelled');
    await svc.sendNotification({
      'Recipient_ID': b.collectorId,
      'Booking_ID': b.bookingId,
      'Title': 'Booking cancelled',
      'Message': 'The household cancelled a pickup you accepted.',
      'Type': 'booking_cancelled',
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
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
          const _OutboxBanner(),
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream:
                  firestoreService.sellerBookings(AuthState.instance.uid ?? ''),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return const EmptySectionText(
                      'No pickups yet — book one from the Sell tab.',
                      centered: true);
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) {
                    final b = bookings[i];
                    return FutureBuilder<_CardData>(
                      future: _loadCardData(firestoreService, b),
                      builder: (context, dataSnap) {
                        if (!dataSnap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(minHeight: 2),
                          );
                        }
                        final data = dataSnap.data!;
                        return _PickupCard(
                          id: _shortId(b.bookingId),
                          status: b.status.toUpperCase(),
                          statusColor: _statusColor(b.status),
                          initials: _initials(data.collectorName),
                          name: data.collectorName,
                          items: data.itemsSummary,
                          meta: b.pickupType == 'Scheduled'
                              ? 'Pickup ${pickupScheduleLabel(b)}'
                              : _formatDate(b.createdAt),
                          stars: data.existingRating != null
                              ? '★ ${data.existingRating!.toStringAsFixed(1)}'
                              : '',
                          actions:
                              _actionsFor(context, b, data, firestoreService),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BookingSummaryScreen(
                                      bookingId: b.bookingId))),
                        );
                      },
                    );
                  },
                );
              },
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
              if (i == 3) {
                Navigator.pushReplacementNamed(context, '/chat_collector');
              }
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

class _CardData {
  final String collectorName;
  final String itemsSummary;
  final double? existingRating;
  const _CardData({
    required this.collectorName,
    required this.itemsSummary,
    this.existingRating,
  });
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
            Row(
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
                if (stars.isNotEmpty)
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
            if (actions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Color(0xFFF3F4F6), height: 1),
              ),
              // Rows of at most 3 — a 4th action (e.g. Cancel on an Accepted
              // booking) wraps to its own row instead of cramming 4 equal-
              // width buttons into one.
              for (var i = 0; i < actions.length; i += 3)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                  child: Row(
                    children: actions
                        .skip(i)
                        .take(3)
                        .map((a) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// Requests saved on the phone while offline; they are sent automatically,
// and Send now retries immediately.
class _OutboxBanner extends StatefulWidget {
  const _OutboxBanner();

  @override
  State<_OutboxBanner> createState() => _OutboxBannerState();
}

class _OutboxBannerState extends State<_OutboxBanner> {
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    BookingOutbox.instance.refreshCount();
  }

  Future<void> _sendNow() async {
    setState(() => _sending = true);
    final sent = await BookingOutbox.instance.flush();
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sent > 0
            ? 'Sent $sent saved request${sent == 1 ? '' : 's'}.'
            : 'Still offline. We will keep trying automatically.')));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: BookingOutbox.instance.pendingCount,
      builder: (context, count, _) {
        if (count == 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(children: [
            const Icon(Icons.cloud_off, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Waiting to send ($count). Saved on this phone while offline.',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E))),
            ),
            TextButton(
              onPressed: _sending ? null : _sendNow,
              child: Text(_sending ? 'Sending...' : 'Send now',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      },
    );
  }
}
