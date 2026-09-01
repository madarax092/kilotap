import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../services/google_maps_service.dart';
import '../../services/routing_service.dart';

class FindScrapScreen extends StatefulWidget {
  const FindScrapScreen({super.key});
  @override
  State<FindScrapScreen> createState() => _FindScrapScreenState();
}

class _FindScrapScreenState extends State<FindScrapScreen> {
  bool _isOnline = true;

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<_RequestData> _loadRequestData(FirestoreService svc, Booking b) async {
    final sellerName = await svc.displayNameFor(b.sellerId);
    final items = await svc.bookingItems(b.bookingId).first;
    final totalWeight = items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
    final itemsSummary = items.isEmpty
        ? 'No items listed'
        : '${items.length} item${items.length > 1 ? 's' : ''} · '
            '${totalWeight.toStringAsFixed(1)} kg';

    String? distanceLabel;
    final auth = AuthState.instance;
    if (auth.currentLatitude != 0 && auth.currentLongitude != 0) {
      final route = await GoogleMapsService.getRoute(
        originLat: auth.currentLatitude,
        originLon: auth.currentLongitude,
        destLat: b.pickupGps.latitude,
        destLon: b.pickupGps.longitude,
      );
      if (route != null) {
        distanceLabel = GoogleMapsService.formatDistance(route.distanceKm);
      }
    }

    return _RequestData(
        sellerName: sellerName, itemsSummary: itemsSummary, distanceLabel: distanceLabel);
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
                    const Text('Find Scrap',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Row(
                      children: [
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isOnline
                                ? AppColors.buyerBlue
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isOnline,
                          activeThumbColor: AppColors.buyerBlue,
                          onChanged: (val) {
                            setState(() {
                              _isOnline = val;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Discover and accept pickup requests near you',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Expanded(
            child: !_isOnline
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Go online to see pickup requests near you.',
                          style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  )
                : StreamBuilder<List<Booking>>(
                    stream: firestoreService.availableBookings(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Two-stage dispatch: attribute (capacity) filter first,
                      // then Google Maps distance ranking per card below.
                      final myVehicle = AuthState.instance.vehicleType;
                      final bookings = snapshot.data!
                          .where((b) => vehicleCanHandle(myVehicle, b.vehicleRequirement))
                          .toList();
                      if (bookings.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'No pickup requests match your vehicle right now.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF6B7280))),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        itemCount: bookings.length,
                        itemBuilder: (context, i) {
                          final b = bookings[i];
                          return FutureBuilder<_RequestData>(
                            future: _loadRequestData(firestoreService, b),
                            builder: (context, dataSnap) {
                              if (!dataSnap.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: LinearProgressIndicator(minHeight: 2),
                                );
                              }
                              final data = dataSnap.data!;
                              return _RequestCard(
                                booking: b,
                                sellerName: data.sellerName,
                                itemsSummary: data.itemsSummary,
                                timeAgo: data.distanceLabel ?? _timeAgo(b.createdAt),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.pushReplacementNamed(context, '/collector');
                }
                if (i == 1) Navigator.pushReplacementNamed(context, '/find');
                if (i == 2) {
                  Navigator.pushReplacementNamed(context, '/chat');
                }
                if (i == 3) {
                  Navigator.pushReplacementNamed(context, '/earnings');
                }
                if (i == 4) {
                  Navigator.pushReplacementNamed(context, '/collector_profile');
                }
              },
              selectedItemColor: AppColors.buyerBlue,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded), label: 'Find'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    label: 'Messages'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.scale_rounded), label: 'Stats'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestData {
  final String sellerName;
  final String itemsSummary;
  final String? distanceLabel;
  const _RequestData(
      {required this.sellerName, required this.itemsSummary, this.distanceLabel});
}

class _Det extends StatelessWidget {
  final String val, label;
  const _Det(this.val, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(val,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827))),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280)))
    ]);
  }
}

class _RequestCard extends StatelessWidget {
  final Booking booking;
  final String sellerName;
  final String itemsSummary;
  final String timeAgo;

  const _RequestCard({
    required this.booking,
    required this.sellerName,
    required this.itemsSummary,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final initials = sellerName.trim().isNotEmpty
        ? sellerName
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/request_details',
              arguments: {'bookingId': booking.bookingId});
        },
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                      child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sellerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        Text(
                            booking.pickupAddress.isEmpty
                                ? 'Address not provided'
                                : booking.pickupAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(timeAgo,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _Det(itemsSummary, 'Items'),
                _Det(booking.vehicleRequirement, 'Vehicle'),
              ]),
            ])),
      ),
    );
  }
}
