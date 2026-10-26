import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// The phone permissions KiloTap uses: notifications (pickup alerts),
/// location (pickup pin, nearby requests, route) and camera (scrap photos,
/// documents).
enum AppPermission { notifications, location, camera }

extension AppPermissionInfo on AppPermission {
  Permission get _permission => switch (this) {
        AppPermission.notifications => Permission.notification,
        AppPermission.location => Permission.locationWhenInUse,
        AppPermission.camera => Permission.camera,
      };

  String get label => switch (this) {
        AppPermission.notifications => 'Notifications',
        AppPermission.location => 'Location',
        AppPermission.camera => 'Camera',
      };

  IconData get icon => switch (this) {
        AppPermission.notifications => Icons.notifications_outlined,
        AppPermission.location => Icons.location_on_outlined,
        AppPermission.camera => Icons.photo_camera_outlined,
      };

  Future<bool> get isGranted => _permission.isGranted;

  /// Asks the phone for the permission. Once the user has said "don't ask
  /// again", Android will not show the prompt, so the app settings open
  /// instead. Returns whether it is granted afterwards.
  Future<bool> request() async {
    final status = await _permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return _permission.isGranted;
    }
    return (await _permission.request()).isGranted;
  }
}

Future<void> openPhoneAppSettings() => openAppSettings();
