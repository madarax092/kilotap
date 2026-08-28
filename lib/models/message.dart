import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;

  const Message({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(String id, Map<String, dynamic> m) => Message(
        messageId: m['Message_ID'] ?? id,
        senderId: m['Sender_ID'] ?? '',
        recipientId: m['Recipient_ID'] ?? '',
        text: m['Text'] ?? '',
        timestamp:
            (m['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
