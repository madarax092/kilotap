import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_state.dart';

// Lets a push tap navigate even when it's opened from outside the widget
// tree (app backgrounded or fully closed) — handed to MaterialApp in
// main.dart. Lives here rather than in main.dart to avoid a circular import,
// since this service is the only thing that needs to drive navigation from
// a push.
final navigatorKey = GlobalKey<NavigatorState>();

// Runs in a separate background isolate when a push arrives while the app is
// backgrounded/terminated — must stay top-level (not a class method) per the
// firebase_messaging contract. System tray / lock screen display for this
// case is handled automatically by Android from the FCM "notification"
// payload (see functions/index.js); this handler exists only so the plugin
// has a registered entry point and future data-only handling has a home.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  // Keep these ids in sync with functions/index.js's CHANNEL_BY_TYPE — that's
  // what controls which channel a background/terminated push lands in.
  static const _defaultChannel = AndroidNotificationChannel(
    'kilotap_default_channel',
    'KiloTap Notifications',
    description: 'General alerts',
    importance: Importance.high,
  );
  static const _bookingsChannel = AndroidNotificationChannel(
    'kilotap_bookings',
    'Bookings',
    description: 'New, accepted, completed, and cancelled pickups',
    importance: Importance.high,
  );
  static const _chatChannel = AndroidNotificationChannel(
    'kilotap_chat',
    'Chat',
    description: 'New messages',
    importance: Importance.high,
  );
  static const _verificationChannel = AndroidNotificationChannel(
    'kilotap_verification',
    'Verification',
    description: 'Collector verification updates',
    importance: Importance.high,
  );

  static const Map<String, AndroidNotificationChannel> _channelsByType = {
    'booking_confirmed': _bookingsChannel,
    'completed': _bookingsChannel,
    'booking_cancelled': _bookingsChannel,
    'new_booking': _bookingsChannel,
    'booking_reopened': _bookingsChannel,
    'chat_message': _chatChannel,
    'verification_approved': _verificationChannel,
    'verification_rejected': _verificationChannel,
  };

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Called once at app startup, before login — sets up the notification
  // channels and the foreground/background/terminated message listeners.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    for (final channel in {
      _defaultChannel,
      _bookingsChannel,
      _chatChannel,
      _verificationChannel,
    }) {
      await androidPlugin?.createNotificationChannel(channel);
    }

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) => _route(response.payload),
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android only auto-displays FCM pushes when the app is backgrounded or
    // closed — in the foreground it delivers silently, so we show it
    // ourselves via the local-notifications plugin to match that behavior.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      final type = message.data['type'] as String?;
      final channel = _channelsByType[type] ?? _defaultChannel;
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        payload: type,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    // Tapped a push that opened the app from backgrounded...
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => _route(message.data['type'] as String?));

    // ...or from fully closed (checked once at startup).
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _route(initial.data['type'] as String?);
  }

  // Routes to the relevant screen for a tapped notification. Booking events
  // go to the signed-in user's own pickups/jobs list rather than the exact
  // booking, and chat events go to the chat list rather than the exact
  // thread — both intentionally kept at list-level to avoid refetch plumbing
  // into every target screen for what's otherwise a convenience shortcut.
  void _route(String? type) {
    final nav = navigatorKey.currentState;
    if (nav == null || type == null) return;
    final isCollector = AuthState.instance.isCollector;
    switch (type) {
      case 'booking_confirmed':
      case 'completed':
      case 'booking_cancelled':
      case 'new_booking':
      case 'booking_reopened':
        nav.pushNamed(isCollector ? '/find' : '/pickups');
        break;
      case 'chat_message':
        nav.pushNamed(isCollector ? '/chat' : '/chat_collector');
        break;
      case 'verification_approved':
      case 'verification_rejected':
        nav.pushNamed('/documents');
        break;
    }
  }

  // Called after a successful login/session-restore — requests permission
  // (triggers the Android 13+ POST_NOTIFICATIONS prompt) and stores this
  // device's FCM token on the account so the Cloud Function knows where to
  // send pushes for that user. Keeps the token fresh via onTokenRefresh.
  Future<void> registerDeviceToken(String uid) async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(uid, token);
      FirebaseMessaging.instance.onTokenRefresh
          .listen((newToken) => _saveToken(uid, newToken));
    } catch (_) {
      // No-op: push is a convenience layer, never block login on it.
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    await FirebaseFirestore.instance
        .collection('UserAccount')
        .doc(uid)
        .update({'Fcm_Token': token});
  }

  // Called on sign-out so a stale token doesn't keep receiving pushes meant
  // for whichever account logs into this device next.
  Future<void> clearDeviceToken(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('UserAccount')
          .doc(uid)
          .update({'Fcm_Token': ''});
    } catch (_) {
      // Best-effort — don't block sign-out on it.
    }
  }
}
