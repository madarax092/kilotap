import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/live_route_map.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  bool _accepting = false;

  Future<void> _accept(
      BuildContext context, Booking booking, String sellerName) async {
    if (_accepting) return;
    setState(() => _accepting = true);
    try {
      await FirestoreService().updateBookingStatus(
        booking.bookingId,
        'Accepted',
        collectorId: AuthState.instance.uid,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pickup accepted! Starting navigation...'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pushReplacementNamed(context, '/collector_nav', arguments: {
        'bookingId': booking.bookingId,
        'initials': sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?',
        'name': sellerName,
        'material': booking.vehicleRequirement,
        'location': booking.pickupAddress,
        'lat': booking.pickupGps.latitude,
        'lon': booking.pickupGps.longitude,
      });
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final bookingId = args['bookingId'] as String?;
    final isViewOnly = args['isViewOnly'] == true;

    if (bookingId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
        body: const Center(child: Text('No request selected.')),
      );
    }

    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Request Details',
            style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: FutureBuilder<Booking?>(
        future: firestoreService.getBooking(bookingId),
        builder: (context, bookingSnap) {
          if (!bookingSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final booking = bookingSnap.data;
          if (booking == null) {
            return const Center(child: Text('This request is no longer available.'));
          }
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              firestoreService.displayNameFor(booking.sellerId),
              firestoreService.bookingItems(bookingId).first,
            ]),
            builder: (context, dataSnap) {
              if (!dataSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final sellerName = dataSnap.data![0] as String;
              final items = dataSnap.data![1] as List<BookingItem>;
              final totalWeight =
                  items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
              final initials =
                  sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?';

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  LiveRouteMap(
                    destLat: booking.pickupGps.latitude,
                    destLon: booking.pickupGps.longitude,
                    height: 180,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
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
                                  Text(sellerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: Color(0xFF111827))),
                                  const SizedBox(height: 2),
                                  Text(
                                      booking.pickupAddress.isEmpty
                                          ? 'Address not provided'
                                          : booking.pickupAddress,
                                      style: const TextStyle(
                                          fontSize: 13, color: Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.buyerBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(booking.status,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.buyerBlue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _DetailCol('${items.length}', 'Items'),
                            _DetailCol('${totalWeight.toStringAsFixed(1)} kg',
                                'Est. Weight'),
                            _DetailCol(booking.vehicleRequirement, 'Vehicle'),
                          ],
                        ),
                        if (items.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF3F4F6), height: 1),
                          const SizedBox(height: 12),
                          ...items.map((i) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(i.itemName,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF374151))),
                                    Text(
                                        '${i.quantity} × ${i.estimatedWeightKg.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isViewOnly)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(_accepting ? 'Accepting...' : 'Accept',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buyerBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _accepting
                                ? null
                                : () => _accept(context, booking, sellerName),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Decline',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2C2C2C),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailCol extends StatelessWidget {
  final String val, label;
  const _DetailCol(this.val, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(val,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
      ],
    );
  }
}
