import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/message.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String collectorName;
  final String collectorUid;
  const ChatDetailScreen({
    super.key,
    required this.collectorName,
    required this.collectorUid,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _service = FirestoreService();

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _service.sendMessage(AuthState.instance.uid, widget.collectorUid, text);
  }

  String _fmt(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day && t.month == now.month && t.year == now.year) {
      final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final m = t.minute.toString().padLeft(2, '0');
      final ap = t.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ap';
    }
    return '${t.month}/${t.day}/${t.year}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.collectorName,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _service.messagesBetween(
                  AuthState.instance.uid, widget.collectorUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.sellerGreen));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                      child: Text('No messages yet. Say hi!',
                          style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final m in messages)
                      _Msg(
                        m.text,
                        m.senderId == AuthState.instance.uid,
                        _fmt(m.timestamp),
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(top: BorderSide(color: AppColors.divider))),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        filled: true,
                        fillColor: AppColors.inputGrey,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.sellerGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg extends StatelessWidget {
  final String text;
  final bool outgoing;
  final String time;
  const _Msg(this.text, this.outgoing, this.time);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: outgoing ? AppColors.sellerGreen : AppColors.pureWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                outgoing ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                outgoing ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: outgoing ? null : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: outgoing ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(time,
                style: TextStyle(
                    fontSize: 9,
                    color: outgoing
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
