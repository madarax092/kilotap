import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

// ─── Google Maps Service: Distance + ETA ───

class RouteInfo {
  final double distanceKm;
  final double etaMinutes;
  final String polyline;
  const RouteInfo({
    required this.distanceKm,
    required this.etaMinutes,
    this.polyline = '',
  });
}

class GoogleMapsService {
  GoogleMapsService._();

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  /// Fetches real road distance + ETA from Google Maps Distance Matrix API.
  /// Returns null on failure (offline / invalid key / quota).
  static Future<RouteInfo?> getRoute({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
  }) async {
    if (AppConstants.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return null; // No key configured — caller falls back to cache
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'origins': '$originLat,$originLon',
        'destinations': '$destLat,$destLon',
        'mode': 'driving',
        'key': AppConstants.googleMapsApiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK') return null;

      final rows = json['rows'] as List?;
      if (rows == null || rows.isEmpty) return null;

      final elements = (rows.first as Map)['elements'] as List?;
      if (elements == null || elements.isEmpty) return null;

      final element = elements.first as Map;
      final elementStatus = element['status'] as String?;
      if (elementStatus != 'OK') return null;

      final distance = (element['distance'] as Map)['value'] as int? ?? 0;
      final duration = (element['duration'] as Map)['value'] as int? ?? 0;

      return RouteInfo(
        distanceKm: distance / 1000.0,
        etaMinutes: duration / 60.0,
      );
    } catch (_) {
      return null;
    }
  }

  /// Formats distance (e.g. "2.1 km" or "850 m").
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formats ETA (e.g. "6.2 min" or "1.2 hr").
  static String formatEta(double minutes) {
    if (minutes < 1) return '<1 min';
    if (minutes < 60) return '${minutes.toStringAsFixed(1)} min';
    return '${(minutes / 60).toStringAsFixed(1)} hr';
  }
}
