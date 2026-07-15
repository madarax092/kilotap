import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 15: Notification
class AppNotification {
  final String notificationId;
  final String recipientId;
  final String bookingId;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final DateTime timestamp;

  const AppNotification({
    required this.notificationId,
    required this.recipientId,
    this.bookingId = '',
    required this.title,
    required this.message,
    this.isRead = false,
    this.type = 'booking_request',
    required this.timestamp,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
    notificationId: m['Notification_ID'] ?? id,
    recipientId: m['Recipient_ID'] ?? '',
    bookingId: m['Booking_ID'] ?? '',
    title: m['Title'] ?? '',
    message: m['Message'] ?? '',
    isRead: m['IsRead'] ?? false,
    type: m['Type'] ?? 'booking_request',
    timestamp: (m['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
