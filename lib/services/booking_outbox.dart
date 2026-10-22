import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'auth_state.dart';
import 'firestore_service.dart';

/// Offline outbox for pickup requests (paper 2.3.3.4). The scrap photo has to
/// reach Cloudinary before the booking can be written, so a request made
/// without a connection is kept here (booking, items and a copy of the
/// photo) and sent automatically once the phone is back online. After the
/// photo uploads, the booking write itself is handed to Firestore, whose
/// offline persistence queues it until the server is reachable.
class BookingOutbox {
  BookingOutbox._();
  static final BookingOutbox instance = BookingOutbox._();

  static const _boxName = 'booking_outbox';
  static const _retryEvery = Duration(seconds: 30);

  /// Requests waiting to be sent for the signed-in household.
  final ValueNotifier<int> pendingCount = ValueNotifier(0);

  Timer? _retryTimer;
  bool _flushing = false;

  Box get _box => Hive.box(_boxName);

  Future<void> init() async {
    await Hive.openBox(_boxName);
    refreshCount();
    if (_box.isNotEmpty) _startRetrying();
  }

  /// True for failures that mean "no connection right now", as opposed to
  /// errors that a retry would never fix.
  static bool isNetworkError(Object e) {
    return e is SocketException ||
        e is TimeoutException ||
        e is http.ClientException ||
        (e is FirebaseException && e.code == 'unavailable');
  }

  /// Saves a request that could not be sent. [bookingId] is generated on the
  /// phone and kept, so the eventual write never creates a duplicate.
  Future<void> enqueue({
    required String sellerId,
    required String bookingId,
    required Map<String, dynamic> booking,
    required List<Map<String, dynamic>> items,
    String? photoPath,
  }) async {
    String? keptPhoto;
    if (photoPath != null && photoPath.isNotEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      keptPhoto = '${dir.path}/outbox_$bookingId.jpg';
      await File(photoPath).copy(keptPhoto);
    }
    await _box.put(bookingId, {
      'sellerId': sellerId,
      'savedAt': DateTime.now().toIso8601String(),
      'booking': _encode(booking),
      'items': items.map(_encode).toList(),
      'photoPath': keptPhoto,
    });
    refreshCount();
    _startRetrying();
  }

  /// Sends every waiting request of [uid]. Stops at the first network
  /// failure and tries again later; returns how many were sent.
  Future<int> flush([String? uid]) async {
    uid ??= AuthState.instance.uid;
    if (_flushing || uid == null || uid.isEmpty) return 0;
    _flushing = true;
    var sent = 0;
    final svc = FirestoreService();
    try {
      for (final key in _box.keys.toList()) {
        final entry = Map<String, dynamic>.from(_box.get(key) as Map);
        if (entry['sellerId'] != uid) continue;
        final booking = Map<String, dynamic>.from(_decode(entry['booking']));
        final items = (entry['items'] as List)
            .map((i) => Map<String, dynamic>.from(_decode(i)))
            .toList();
        final photoPath = entry['photoPath'] as String?;
        try {
          if ((booking['PhotoURL'] ?? '') == '' &&
              photoPath != null &&
              File(photoPath).existsSync()) {
            booking['PhotoURL'] = await svc
                .uploadBookingPhoto(File(photoPath))
                .timeout(const Duration(seconds: 30));
            // Remember the upload so a later retry does not repeat it.
            entry['booking'] = _encode(booking);
            await _box.put(key, entry);
          }
          await svc.createBookingWithItems(booking, items,
              bookingId: key as String);
        } catch (e) {
          if (isNetworkError(e)) rethrow;
          // A retry would never succeed (e.g. rejected by security rules).
          debugPrint('Dropping queued booking $key: $e');
        }
        await _box.delete(key);
        if (photoPath != null) {
          try {
            File(photoPath).deleteSync();
          } catch (_) {}
        }
        sent++;
      }
    } catch (e) {
      debugPrint('Booking outbox still offline: $e');
    } finally {
      _flushing = false;
      refreshCount();
      if (_box.isEmpty) {
        _retryTimer?.cancel();
        _retryTimer = null;
      }
    }
    return sent;
  }

  void refreshCount() {
    final uid = AuthState.instance.uid;
    pendingCount.value = uid == null
        ? 0
        : _box.values
            .where((v) => v is Map && v['sellerId'] == uid)
            .length;
  }

  void _startRetrying() {
    _retryTimer ??= Timer.periodic(_retryEvery, (_) => flush());
  }

  // Hive stores plain values only, so Firestore types are tagged.
  static dynamic _encode(dynamic v) {
    if (v is GeoPoint) return {'__geo': [v.latitude, v.longitude]};
    if (v is Timestamp) return {'__ts': v.millisecondsSinceEpoch};
    if (v is Map) return v.map((k, val) => MapEntry(k, _encode(val)));
    if (v is List) return v.map(_encode).toList();
    return v;
  }

  static dynamic _decode(dynamic v) {
    if (v is Map) {
      if (v.containsKey('__geo')) {
        final p = v['__geo'] as List;
        return GeoPoint((p[0] as num).toDouble(), (p[1] as num).toDouble());
      }
      if (v.containsKey('__ts')) {
        return Timestamp.fromMillisecondsSinceEpoch(v['__ts'] as int);
      }
      return v.map((k, val) => MapEntry(k.toString(), _decode(val)));
    }
    if (v is List) return v.map(_decode).toList();
    return v;
  }
}
