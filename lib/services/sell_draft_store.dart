import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Autosaved, unsent Sell Scrap form, so a request in progress survives the
/// app being closed or killed (one draft per signed-in household).
class SellDraftStore {
  SellDraftStore._();

  static const _boxName = 'sell_draft';

  static Box get _box => Hive.box(_boxName);

  static Future<void> init() => Hive.openBox(_boxName);

  static Map<String, dynamic>? load(String uid) {
    final v = _box.get(uid);
    return v is Map ? Map<String, dynamic>.from(v) : null;
  }

  static Future<void> save(String uid, Map<String, dynamic> draft) =>
      _box.put(uid, draft);

  /// Removes the draft. [deletePhoto] is false when the kept photo is still
  /// shown on screen (e.g. by the booking summary after a send).
  static Future<void> clear(String uid, {bool deletePhoto = true}) async {
    final draft = load(uid);
    final photo = draft?['photoPath'] as String?;
    if (deletePhoto && photo != null) {
      try {
        File(photo).deleteSync();
      } catch (_) {}
    }
    await _box.delete(uid);
  }

  /// Copies the scrap photo into app storage (the camera's cache can be
  /// cleared by Android) and returns the kept path.
  static Future<String> keepPhoto(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    if (sourcePath.startsWith(dir.path)) return sourcePath;
    final kept =
        '${dir.path}/sell_draft_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(sourcePath).copy(kept);
    return kept;
  }
}
