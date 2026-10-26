import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/system_settings.dart';
import 'auth_state.dart';
import 'firestore_service.dart';

/// Keeps the live System Settings (systemSettings/global) for the signed-in
/// user. Until the document loads, or if it doesn't exist, the defaults
/// apply — the same values the app used before settings were configurable.
class SystemSettingsService {
  static final SystemSettingsService instance = SystemSettingsService._();
  SystemSettingsService._();

  final ValueNotifier<SystemSettings> current =
      ValueNotifier(SystemSettings.defaults);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore
      .instance
      .collection(AppConstants.colSystemSettings)
      .doc('global');

  /// Starts listening after sign-in (the rules only allow signed-in reads).
  void start() {
    _sub?.cancel();
    _sub = _doc.snapshots().listen(
        (snap) => current.value = SystemSettings.fromMap(snap.data()),
        onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    current.value = SystemSettings.defaults;
  }

  /// Saves the admin's changes and writes one UPDATE_SETTINGS audit entry
  /// listing each changed value as old -> new. Returns how many changed.
  Future<int> save(SystemSettings updated) async {
    final old = SystemSettings.fromMap((await _doc.get()).data());
    final changes = updated.changesFrom(old);
    if (changes.isEmpty) return 0;
    await _doc.set({
      ...updated.toMap(),
      'Updated_At': FieldValue.serverTimestamp(),
      'Updated_By': AuthState.instance.uid ?? '',
    });
    await FirestoreService().logAction({
      'Actor_ID': AuthState.instance.uid ?? 'admin',
      'Action': AppConstants.auditUpdateSettings,
      'Target_ID': 'systemSettings/global',
      'Description': 'Changed system settings: ${changes.join('; ')}',
    });
    current.value = updated;
    return changes.length;
  }
}
