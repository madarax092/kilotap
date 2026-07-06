import 'package:cloud_firestore/cloud_firestore.dart';

/// Table 13: Notification
class AppNotification {
  final String notificationId;
  final String recipientId;
  final String bookingId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  const AppNotification({required this.notificationId, required this.recipientId,
      this.bookingId = '', required this.title, required this.message,
      this.isRead = false, required this.timestamp});

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
    notificationId: m['Notification_ID'] ?? id,
    recipientId: m['Recipient_ID'] ?? '',
    bookingId: m['Booking_ID'] ?? '',
    title: m['Title'] ?? '',
    message: m['Message'] ?? '',
    isRead: m['IsRead'] ?? false,
    timestamp: (m['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
