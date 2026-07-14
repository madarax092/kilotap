class ProximityFilter {
  ProximityFilter._();

  static const double defaultRadiusKm = 5.0;

  /// Returns true if the collector is within the proximity radius.
  /// Uses coordinate delta approximation — zero API cost.
  static bool isNearby({
    required double collectorLat,
    required double collectorLon,
    required double householdLat,
    required double householdLon,
    double radiusKm = defaultRadiusKm,
  }) {
    final deltaLat = (collectorLat - householdLat).abs();
    final deltaLon = (collectorLon - householdLon).abs();
    return (deltaLat + deltaLon) < (radiusKm / 111.0);
  }

  /// Filters a list of collectors to only those within radius.
  static List<Map<String, dynamic>> filterNearby({
    required List<Map<String, dynamic>> collectors,
    required double householdLat,
    required double householdLon,
    double radiusKm = defaultRadiusKm,
  }) {
    return collectors.where((c) {
      return isNearby(
        collectorLat: (c['latitude'] as num).toDouble(),
        collectorLon: (c['longitude'] as num).toDouble(),
        householdLat: householdLat,
        householdLon: householdLon,
        radiusKm: radiusKm,
      );
    }).toList();
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
