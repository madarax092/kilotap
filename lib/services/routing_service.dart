import 'google_maps_service.dart';

// ─── Routing: Proximity + Dispatch (Google Maps API) ───

class ProximityFilter {
  ProximityFilter._();

  static const double defaultRadiusKm = 5.0;

  static Future<double> distanceKm({
    required double collectorLat,
    required double collectorLon,
    required double householdLat,
    required double householdLon,
  }) async {
    final route = await GoogleMapsService.getRoute(
      originLat: collectorLat,
      originLon: collectorLon,
      destLat: householdLat,
      destLon: householdLon,
    );
    return route?.distanceKm ?? double.infinity;
  }

  static Future<List<Map<String, dynamic>>> filterNearby({
    required List<Map<String, dynamic>> collectors,
    required double householdLat,
    required double householdLon,
    double radiusKm = defaultRadiusKm,
  }) async {
    final results = <Map<String, dynamic>>[];
    for (final c in collectors) {
      final cLat = (c['latitude'] as num).toDouble();
      final cLon = (c['longitude'] as num).toDouble();
      final route = await GoogleMapsService.getRoute(
        originLat: cLat,
        originLon: cLon,
        destLat: householdLat,
        destLon: householdLon,
      );
      final dist = route?.distanceKm;
      if (dist != null && dist <= radiusKm) {
        results.add({...c, 'distanceKm': dist});
      }
    }
    results.sort((a, b) =>
        (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
    return results;
  }
}

// Vehicle capacity tiers, matching CapacityMatcher.VehicleSize — used to
// check whether a collector's vehicle can handle a booking's requirement.
const List<String> _vehicleCapacityOrder = ['Pushcart', 'Tricycle', 'Multicab', 'Truck'];

bool vehicleCanHandle(String collectorVehicle, String requiredVehicle) {
  final collectorTier = _vehicleCapacityOrder.indexOf(collectorVehicle);
  final requiredTier = _vehicleCapacityOrder.indexOf(requiredVehicle);
  if (collectorTier == -1 || requiredTier == -1) return true;
  return collectorTier >= requiredTier;
}
