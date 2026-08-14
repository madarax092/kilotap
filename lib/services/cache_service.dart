import 'package:hive_flutter/hive_flutter.dart';
import 'auth_service.dart';

class CacheService {
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;
  CacheService._();

  static const _profileBox = 'profile';
  static const _prefsBox = 'prefs';
  static const _recentBox = 'recent_pickups';

  // ─── Cache limits (3GB RAM safety) ───
  static const int maxRecentPickups = 50;
  static const int maxCachedRoutes = 20;

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_profileBox);
    await Hive.openBox(_prefsBox);
    await Hive.openBox(_recentBox);
  }


  Future<void> cacheProfile(Map<String, dynamic> data) async {
    final box = Hive.box(_profileBox);
    await box.put('data', data);
    await box.put('cachedAt', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getCachedProfile() {
    final box = Hive.box(_profileBox);
    final cachedAt = box.get('cachedAt') as String?;
    if (cachedAt == null) return null;
    final age = DateTime.now().difference(DateTime.parse(cachedAt));
    if (age.inHours > 24) return null;
    return box.get('data') as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final cached = getCachedProfile();
    if (cached != null) {
      AuthService.instance.getProfile(uid).then((fresh) {
        if (fresh != null) cacheProfile(fresh);
      });
      return cached;
    }
    final fresh = await AuthService.instance.getProfile(uid);
    if (fresh != null) await cacheProfile(fresh);
    return fresh;
  }


  Future<void> setPref(String key, dynamic value) => Hive.box(_prefsBox).put(key, value);
  dynamic getPref(String key) => Hive.box(_prefsBox).get(key);


  Future<void> cacheRecentPickups(List<Map<String, dynamic>> pickups) async {
    final limited = pickups.length > maxRecentPickups
        ? pickups.sublist(0, maxRecentPickups)
        : pickups;
    await Hive.box(_recentBox).put('data', limited);
  }

  List<Map<String, dynamic>>? getCachedRecentPickups() {
    return (Hive.box(_recentBox).get('data') as List?)?.cast<Map<String, dynamic>>();
  }

  Future<void> clear() async {
    await Hive.box(_profileBox).clear();
    await Hive.box(_prefsBox).clear();
    await Hive.box(_recentBox).clear();
  }
}
