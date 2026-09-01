import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../services/google_maps_service.dart';
import '../../widgets/live_route_map.dart';

// ─── Collector Navigation Screen ───

class CollectorNavigationScreen extends StatefulWidget {
  const CollectorNavigationScreen({super.key});

  @override
  State<CollectorNavigationScreen> createState() =>
      _CollectorNavigationScreenState();
}

class _CollectorNavigationScreenState extends State<CollectorNavigationScreen> {
  RouteInfo? _route;
  bool _loading = true;

  Future<void> _openInGoogleMaps(double lat, double lon) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    // Fallback for devices without the Google Maps app installed.
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {
              'initials': '?',
              'name': 'Household',
              'location': 'Address not provided',
              'material': 'Vehicle not specified',
              'mapPath': 'assets/images/davao_nav_map.png',
              'lat': 7.0750,
              'lon': 125.6130,
            };
    final destLat = (args['lat'] as num).toDouble();
    final destLon = (args['lon'] as num).toDouble();
    final auth = AuthState.instance;
    final hasCollectorLocation =
        auth.currentLatitude != 0 && auth.currentLongitude != 0;

    final String etaStr;
    final String distanceStr;
    if (_loading) {
      etaStr = '...';
      distanceStr = 'Calculating route...';
    } else if (_route != null) {
      etaStr = GoogleMapsService.formatEta(_route!.etaMinutes);
      distanceStr =
          '${GoogleMapsService.formatDistance(_route!.distanceKm)} · ${args['location']}';
    } else {
      etaStr = '—';
      distanceStr = 'No network — connect to get directions';
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LiveRouteMap(
              destLat: destLat,
              destLon: destLon,
              originLat: hasCollectorLocation ? auth.currentLatitude : null,
              originLon: hasCollectorLocation ? auth.currentLongitude : null,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
              onRouteLoaded: (route) {
                if (!mounted) return;
                setState(() {
                  _route = route;
                  _loading = false;
                });
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: InkWell(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/collector'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 80,
            right: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openInGoogleMaps(destLat, destLon),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.buyerBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.navigation, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text('Open turn-by-turn in Google Maps',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.success),
                                ),
                              )
                            else
                              Text(etaStr,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.success)),
                            const SizedBox(height: 4),
                            Text(distanceStr,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.buyerBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone,
                            color: AppColors.buyerBlue, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(args['initials'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(args['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('Vehicle needed: ${args['material']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buyerBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final bookingId = args['bookingId'] as String?;
                        if (bookingId != null) {
                          await FirestoreService()
                              .updateBookingStatus(bookingId, 'Completed');
                        }
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/collector');
                      },
                      child: const Text(
                        'ARRIVED',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
