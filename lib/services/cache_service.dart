import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Hive local cache — matches ACM Paper NFR 2.2.3.2.3
///
/// "utilize localized Hive database caching to maintain interface
///  functionality when internet network connection drops to 0%"
///
/// Dual-layer caching strategy:
///   Firestore offline persistence — automatic document sync
///   Hive — explicit fast-access cache for profile, preferences, recent pickups
class CacheService {
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;
  CacheService._();

  static const _profileBox = 'profile';
  static const _prefsBox = 'prefs';
  static const _recentBox = 'recent_pickups';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_profileBox);
    await Hive.openBox(_prefsBox);
    await Hive.openBox(_recentBox);
  }

  // ── Profile cache ──

  Future<void> cacheProfile(Map<String, dynamic> data) async {
    final box = Hive.box(_profileBox);
    await box.put('data', data);
    await box.put('cachedAt', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getCachedProfile() {
    final box = Hive.box(_profileBox);
    final cachedAt = box.get('cachedAt') as String?;
    if (cachedAt == null) return null;
    // Cache valid for 24 hours
    final age = DateTime.now().difference(DateTime.parse(cachedAt));
    if (age.inHours > 24) return null;
    return box.get('data') as Map<String, dynamic>?;
  }

  /// Load profile — cache-first, then sync from Firestore
  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    // 1. Try cache first (instant)
    final cached = getCachedProfile();
    if (cached != null) {
      // 2. Refresh from Firestore in background
      AuthService.instance.getProfile(uid).then((fresh) {
        if (fresh != null) cacheProfile(fresh);
      });
      return cached; // return cached immediately — screen loads fast
    }
    // 3. No cache — fetch from Firestore and save
    final fresh = await AuthService.instance.getProfile(uid);
    if (fresh != null) await cacheProfile(fresh);
    return fresh;
  }

  // ── Preferences cache ──

  Future<void> setPref(String key, dynamic value) => Hive.box(_prefsBox).put(key, value);
  dynamic getPref(String key) => Hive.box(_prefsBox).get(key);

  // ── Recent pickups cache ──

  Future<void> cacheRecentPickups(List<Map<String, dynamic>> pickups) async {
    await Hive.box(_recentBox).put('data', pickups);
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
