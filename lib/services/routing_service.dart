import 'geo_service.dart';

class ProximityFilter {
  ProximityFilter._();

  static const double defaultRadiusKm = 5.0;

  /// Returns true if the collector is within the proximity radius.
  /// Uses the Haversine formula for accurate distance.
  static bool isNearby({
    required double collectorLat,
    required double collectorLon,
    required double householdLat,
    required double householdLon,
    double radiusKm = defaultRadiusKm,
  }) {
    final distance = GeoService.haversineKm(
      lat1: collectorLat,
      lon1: collectorLon,
      lat2: householdLat,
      lon2: householdLon,
    );
    return distance <= radiusKm;
  }

  /// Returns distance in km between collector and household.
  static double distanceKm({
    required double collectorLat,
    required double collectorLon,
    required double householdLat,
    required double householdLon,
  }) {
    return GeoService.haversineKm(
      lat1: collectorLat,
      lon1: collectorLon,
      lat2: householdLat,
      lon2: householdLon,
    );
  }

  /// Filters a list of collectors to only those within radius.
  /// Returns each collector with a computed `distanceKm` field.
  static List<Map<String, dynamic>> filterNearby({
    required List<Map<String, dynamic>> collectors,
    required double householdLat,
    required double householdLon,
    double radiusKm = defaultRadiusKm,
  }) {
    final results = <Map<String, dynamic>>[];
    for (final c in collectors) {
      final cLat = (c['latitude'] as num).toDouble();
      final cLon = (c['longitude'] as num).toDouble();
      final dist = GeoService.haversineKm(
        lat1: cLat,
        lon1: cLon,
        lat2: householdLat,
        lon2: householdLon,
      );
      if (dist <= radiusKm) {
        results.add({...c, 'distanceKm': dist});
      }
    }
    // Sort nearest first
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
