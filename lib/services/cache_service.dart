import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_price_model.dart';

/// Local cache for market prices — serves from SharedPreferences
/// so the home screen never shows a loading spinner on revisit.
class CacheService {
  static const _keyMarketPrices = 'cached_market_prices';
  static const _keyMarketPricesTimestamp = 'cached_market_prices_ts';

  // ─── Market Prices ──────────────────────────────────────────

  /// Save prices to local storage
  static Future<void> cacheMarketPrices(List<MarketPriceModel> prices) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prices.map((p) => jsonEncode(p.toFirestore())).toList();
    await prefs.setStringList(_keyMarketPrices, json);
    await prefs.setInt(
        _keyMarketPricesTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  /// Read cached prices — returns null if cache is stale (>30 min)
  static Future<List<MarketPriceModel>?> getCachedMarketPrices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyMarketPrices);
    final timestamp = prefs.getInt(_keyMarketPricesTimestamp);

    if (jsonList == null || timestamp == null) return null;

    // Stale after 30 minutes
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > 30 * 60 * 1000) return null;

    try {
      return jsonList
          .map((j) => MarketPriceModel.fromFirestore(
                Map<String, dynamic>.from(jsonDecode(j)),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMarketPrices);
    await prefs.remove(_keyMarketPricesTimestamp);
  }
}
