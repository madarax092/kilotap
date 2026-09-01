import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../services/google_maps_service.dart';
import '../../widgets/live_route_map.dart';

class MyRouteScreen extends StatelessWidget {
  const MyRouteScreen({super.key});

  Future<_RouteData> _loadRoute(FirestoreService svc, Booking b) async {
    final sellerName = await svc.displayNameFor(b.sellerId);
    final items = await svc.bookingItems(b.bookingId).first;
    final totalKg = items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
    final auth = AuthState.instance;
    RouteInfo? route;
    if (auth.currentLatitude != 0 && auth.currentLongitude != 0) {
      route = await GoogleMapsService.getRoute(
        originLat: auth.currentLatitude,
        originLon: auth.currentLongitude,
        destLat: b.pickupGps.latitude,
        destLon: b.pickupGps.longitude,
      );
    }
    return _RouteData(
        sellerName: sellerName, totalKg: totalKg, route: route);
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.canvas,
          elevation: 0,
          title: const Text("Today's Route",
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: StreamBuilder<List<Booking>>(
        stream: firestoreService.collectorBookings(AuthState.instance.uid ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final active = snapshot.data!.where((b) => b.status == 'Accepted');
          if (active.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No active pickups right now.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          final booking = active.first;
          return FutureBuilder<_RouteData>(
            future: _loadRoute(firestoreService, booking),
            builder: (context, dataSnap) {
              if (!dataSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = dataSnap.data!;
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  const SizedBox(height: 8),
                  LiveRouteMap(
                    destLat: booking.pickupGps.latitude,
                    destLon: booking.pickupGps.longitude,
                    originLat: AuthState.instance.currentLatitude != 0
                        ? AuthState.instance.currentLatitude
                        : null,
                    originLon: AuthState.instance.currentLongitude != 0
                        ? AuthState.instance.currentLongitude
                        : null,
                    height: 220,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider)),
                    child: Row(children: [
                      _Sum(
                          data.route != null
                              ? GoogleMapsService.formatDistance(
                                  data.route!.distanceKm)
                              : '—',
                          'Distance'),
                      _Sum(
                          data.route != null
                              ? GoogleMapsService.formatEta(data.route!.etaMinutes)
                              : '—',
                          'Est. Time'),
                      _Sum('${data.totalKg.toStringAsFixed(1)} kg', 'Load',
                          accent: true),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.buyerBlue)),
                    child: Row(children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppColors.buyerBlue, shape: BoxShape.circle),
                        child: const Center(
                            child: Icon(Icons.local_shipping,
                                color: Colors.white, size: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.sellerName,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(
                                booking.pickupAddress.isEmpty
                                    ? 'Address not provided'
                                    : booking.pickupAddress,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Text('NOW',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.buyerBlue)),
                    ]),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: AppColors.buyerBlue,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
          if (i == 1) Navigator.pushNamed(context, '/find');
          if (i == 2) Navigator.pushNamed(context, '/idcard');
          if (i == 4) Navigator.pushNamed(context, '/collector_profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Route'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RouteData {
  final String sellerName;
  final double totalKg;
  final RouteInfo? route;
  const _RouteData(
      {required this.sellerName, required this.totalKg, required this.route});
}

class _Sum extends StatelessWidget {
  final String val, label;
  final bool accent;
  const _Sum(this.val, this.label, {this.accent = false});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Text(val,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color:
                        accent ? AppColors.buyerBlue : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary))
          ])));
}
