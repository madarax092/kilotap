import 'google_maps_service.dart';

// ─── Routing: Proximity + Dispatch (Google Maps API) ───

class ProximityFilter {
  ProximityFilter._();

  static const double defaultRadiusKm = 5.0;

  /// Returns road distance in km between collector and household.
  /// Uses Google Maps Distance Matrix API (real road distance).
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

  /// Filters collectors within radius using Google Maps road distance.
  /// Returns each collector with a computed `distanceKm` field.
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

/// Hardcoded demo collectors for prototype.
/// In production, this data comes from Firestore.
const List<Map<String, dynamic>> demoCollectors = [
  {
    'id': 'COLLECTOR-001',
    'name': 'Max',
    'latitude': 7.0750,
    'longitude': 125.6130,
    'vehicle': 'Tricycle',
    'online': true,
    'verified': true,
  },
  {
    'id': 'COLLECTOR-002',
    'name': 'Leo',
    'latitude': 7.1000,
    'longitude': 125.6500,
    'vehicle': 'Truck',
    'online': true,
    'verified': true,
  },
  {
    'id': 'COLLECTOR-003',
    'name': 'Rico',
    'latitude': 7.0680,
    'longitude': 125.6070,
    'vehicle': 'Multicab',
    'online': true,
    'verified': true,
  },
  {
    'id': 'COLLECTOR-004',
    'name': 'Jun',
    'latitude': 7.0800,
    'longitude': 125.6050,
    'vehicle': 'Tricycle',
    'online': true,
    'verified': true,
  },
  {
    'id': 'COLLECTOR-005',
    'name': 'Ben',
    'latitude': 7.0850,
    'longitude': 125.6200,
    'vehicle': 'Pushcart',
    'online': true,
    'verified': true,
  },
];
