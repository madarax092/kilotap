import 'package:cloud_firestore/cloud_firestore.dart';

/// tblNotification — Push notification queue
/// Firestore: 'notifications' collection
class NotificationModel {
  final String notificationId;
  final String recipientId; // FK → tblScrapSeller
  final String? bookingId;  // FK → tblBooking
  final String title;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  const NotificationModel({
    required this.notificationId,
    required this.recipientId,
    this.bookingId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      recipientId: data['Recipient_ID'] ?? '',
      bookingId: data['Booking_ID'],
      title: data['Title'] ?? '',
      message: data['Message'] ?? '',
      isRead: data['IsRead'] ?? false,
      timestamp: (data['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Recipient_ID': recipientId,
    'Booking_ID': bookingId,
    'Title': title,
    'Message': message,
    'IsRead': isRead,
    'Timestamp': Timestamp.fromDate(timestamp),
  };
}
