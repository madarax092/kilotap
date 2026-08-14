import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/geo_service.dart';

class CollectorNavigationScreen extends StatelessWidget {
  const CollectorNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {
              'initials': 'MS',
              'name': 'Maria Santos',
              'location': 'Maa · 0.3 km away',
              'pcs': '12 pcs',
              'material': 'Plastic',
              'weight': '15 kg',
              'time': 'ASAP',
              'imagePath': 'assets/images/multiple_scrap_sample.png',
              'mapPath': 'assets/images/davao_nav_map.png',
              'lat': 7.0750,
              'lon': 125.6130,
              'phone': '+639170000000',
            };

    // Household GPS (from request)
    final householdLat = (args['lat'] as num?)?.toDouble() ?? 7.0750;
    final householdLon = (args['lon'] as num?)?.toDouble() ?? 125.6130;

    // Collector GPS (from AuthState, falls back to demo location)
    final auth = AuthState.instance;
    final collectorLat = auth.currentLatitude != 0
        ? auth.currentLatitude
        : 7.0800;
    final collectorLon = auth.currentLongitude != 0
        ? auth.currentLongitude
        : 125.6050;

    // Compute real distance + ETA
    final distanceKm = GeoService.haversineKm(
      lat1: collectorLat,
      lon1: collectorLon,
      lat2: householdLat,
      lon2: householdLon,
    );
    final vehicleType = auth.vehicleType.isNotEmpty
        ? auth.vehicleType
        : 'Tricycle';
    final etaMin = GeoService.etaMinutes(distanceKm, vehicleType);
    final distanceStr = GeoService.formatDistance(distanceKm);
    final etaStr = GeoService.formatEta(etaMin);

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map background
          Positioned.fill(
            child: Image.asset(
              args['mapPath'],
              fit: BoxFit.cover,
            ),
          ),

          // Back / Exit Navigation Button
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

          // Floating Navigation Directions Panel
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 80,
            right: 16,
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
              child: Row(
                children: [
                  const Icon(Icons.turn_right, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('200 m',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text('Turn right onto Maa Road',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Info Card
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
                  // ETA and Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(etaStr,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success)),
                          Text('$distanceStr · ${args['location']}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.buyerBlue.withOpacity(0.1),
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

                  // Household Info
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
                            Text(
                                'Pickup: ${args['weight']} ${args['material']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Arrived Button
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
                      onPressed: () {
                        // In a real app, this would update booking status
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
