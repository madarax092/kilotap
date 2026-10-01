import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_state.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

class ConversationListView extends StatelessWidget {
  final Color accentColor;
  final void Function(String otherUserId, String otherUserName) onOpenChat;

  const ConversationListView({
    super.key,
    required this.accentColor,
    required this.onOpenChat,
  });

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${t.month}/${t.day}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthState.instance.uid ?? '';
    final firestoreService = FirestoreService();
    return StreamBuilder<List<ChatMessage>>(
      stream: firestoreService.userConversations(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final latestByOther = <String, ChatMessage>{};
        for (final m in snapshot.data!) {
          final other = m.senderId == uid ? m.recipientId : m.senderId;
          if (other.isEmpty) continue;
          latestByOther.putIfAbsent(other, () => m);
        }
        if (latestByOther.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No conversations yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          );
        }
        final entries = latestByOther.entries.toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final otherId = entries[i].key;
            final lastMessage = entries[i].value;
            return FutureBuilder<String>(
              future: firestoreService.displayNameFor(otherId),
              builder: (context, nameSnap) {
                final name = nameSnap.data ?? '...';
                return _ConversationCard(
                  name: name,
                  message: lastMessage.text,
                  time: _formatTime(lastMessage.timestamp),
                  accentColor: accentColor,
                  onTap: () => onOpenChat(otherId, name),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final String name, message, time;
  final Color accentColor;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.name,
    required this.message,
    required this.time,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase()
        : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: Center(
                  child: Text(initials,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          fontSize: 16))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF111827))),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
