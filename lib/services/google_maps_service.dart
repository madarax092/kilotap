import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

// ─── Google Maps Service: Distance + ETA + Route Polyline (Routes API) ───

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

  static const String _baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  static const String _routeBox = 'route_cache';
  static const int _maxCachedRoutes = 20;

  static Future<RouteInfo?> getRoute({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
  }) async {
    final cacheKey = _cacheKey(originLat, originLon, destLat, destLon);

    // No API key configured → serve cached route only
    if (AppConstants.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return _getCachedRoute(cacheKey);
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': AppConstants.googleMapsApiKey,
              'X-Goog-FieldMask':
                  'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
            },
            body: jsonEncode({
              'origin': {
                'location': {
                  'latLng': {'latitude': originLat, 'longitude': originLon}
                }
              },
              'destination': {
                'location': {
                  'latLng': {'latitude': destLat, 'longitude': destLon}
                }
              },
              'travelMode': 'DRIVE',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return _getCachedRoute(cacheKey);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = json['routes'] as List?;
      if (routes == null || routes.isEmpty) return _getCachedRoute(cacheKey);

      final route = routes.first as Map<String, dynamic>;
      final distanceMeters = (route['distanceMeters'] as num?)?.toInt() ?? 0;
      final durationStr = route['duration'] as String? ?? '0s';
      final durationSeconds =
          int.tryParse(durationStr.replaceAll('s', '')) ?? 0;
      final encodedPolyline =
          (route['polyline'] as Map?)?['encodedPolyline'] as String? ?? '';

      final routeInfo = RouteInfo(
        distanceKm: distanceMeters / 1000.0,
        etaMinutes: durationSeconds / 60.0,
        polyline: encodedPolyline,
      );
      await _cacheRoute(cacheKey, routeInfo);
      return routeInfo;
    } catch (_) {
      return _getCachedRoute(cacheKey);
    }
  }

  static String _cacheKey(double lat1, double lon1, double lat2, double lon2) {
    String r(double v) => (v * 1000).round().toString();
    return '${r(lat1)},${r(lon1)}|${r(lat2)},${r(lon2)}';
  }

  static Future<RouteInfo?> _getCachedRoute(String key) async {
    try {
      final box = await Hive.openBox(_routeBox);
      final data = box.get(key) as Map?;
      if (data == null) return null;
      return RouteInfo(
        distanceKm: (data['distanceKm'] as num).toDouble(),
        etaMinutes: (data['etaMinutes'] as num).toDouble(),
        polyline: (data['polyline'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cacheRoute(String key, RouteInfo route) async {
    try {
      final box = await Hive.openBox(_routeBox);
      if (box.length >= _maxCachedRoutes && !box.containsKey(key)) {
        await box.deleteAt(0);
      }
      await box.put(key, {
        'distanceKm': route.distanceKm,
        'etaMinutes': route.etaMinutes,
        'polyline': route.polyline,
      });
    } catch (_) {}
  }

  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatEta(double minutes) {
    if (minutes < 1) return '<1 min';
    if (minutes < 60) return '${minutes.toStringAsFixed(1)} min';
    return '${(minutes / 60).toStringAsFixed(1)} hr';
  }
}
