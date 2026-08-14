import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
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
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'origins': '$originLat,$originLon',
        'destinations': '$destLat,$destLon',
        'mode': 'driving',
        'key': AppConstants.googleMapsApiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return _getCachedRoute(cacheKey);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      if (status != 'OK') return _getCachedRoute(cacheKey);

      final rows = json['rows'] as List?;
      if (rows == null || rows.isEmpty) return _getCachedRoute(cacheKey);

      final elements = (rows.first as Map)['elements'] as List?;
      if (elements == null || elements.isEmpty) return _getCachedRoute(cacheKey);

      final element = elements.first as Map;
      final elementStatus = element['status'] as String?;
      if (elementStatus != 'OK') return _getCachedRoute(cacheKey);

      final distance = (element['distance'] as Map)['value'] as int? ?? 0;
      final duration = (element['duration'] as Map)['value'] as int? ?? 0;

      final route = RouteInfo(
        distanceKm: distance / 1000.0,
        etaMinutes: duration / 60.0,
      );
      await _cacheRoute(cacheKey, route);
      return route;
    } catch (_) {
      return _getCachedRoute(cacheKey);
    }
  }

  static String _cacheKey(double lat1, double lon1, double lat2, double lon2) {
    final r = (double v) => (v * 1000).round().toString();
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
