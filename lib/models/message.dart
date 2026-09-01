// ─── Message (chat — not one of the paper's numbered Tables 7-15) ───
class ChatMessage {
  final String messageId;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final List<String> participants;

  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    this.participants = const [],
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        messageId: m['Message_ID'] ?? id,
        senderId: m['Sender_ID'] ?? '',
        recipientId: m['Recipient_ID'] ?? '',
        text: m['Text'] ?? '',
        timestamp: (m['Timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
        participants: List<String>.from(m['Participants'] ?? const []),
      );
}
