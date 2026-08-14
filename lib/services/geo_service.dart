import 'dart:math';

/// ─── Geo Service: Haversine Distance + ETA ───
///
/// Implements the Haversine formula (paper Table 10: HaversineDistanceKm)
/// to calculate great-circle distance between two GPS coordinates.
///
/// Also provides ETA estimation based on vehicle speed.

class GeoService {
  GeoService._();

  static const double _earthRadiusKm = 6371.0;

  /// Average vehicle speeds in km/h (Davao City urban conditions)
  static const Map<String, double> vehicleSpeeds = {
    'Pushcart': 3.0,    // walking pace
    'Tricycle': 20.0,   // sidecar in traffic
    'Multicab': 25.0,   // small truck
    'Truck': 30.0,      // larger roads
  };

  /// Haversine formula — great-circle distance in km.
  static double haversineKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Estimated travel time in minutes for a given distance + vehicle.
  static double etaMinutes(double distanceKm, String vehicleType) {
    final speed = vehicleSpeeds[vehicleType] ?? 20.0;
    return (distanceKm / speed) * 60.0;
  }

  /// Formats ETA as a human-readable string (e.g. "6.2 min").
  static String formatEta(double minutes) {
    if (minutes < 1) return '<1 min';
    if (minutes < 60) return '${minutes.toStringAsFixed(1)} min';
    final hrs = minutes / 60;
    return '${hrs.toStringAsFixed(1)} hr';
  }

  /// Formats distance (e.g. "2.1 km" or "850 m").
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static double _toRadians(double deg) => deg * pi / 180.0;
}
