import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_state.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

class ChatThreadView extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final Color accentColor;

  const ChatThreadView({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.accentColor,
  });

  @override
  State<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<ChatThreadView> {
  final _controller = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final uid = AuthState.instance.uid;
    if (uid == null) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _firestoreService.sendMessage({
        'Sender_ID': uid,
        'Recipient_ID': widget.otherUserId,
        'Text': text,
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthState.instance.uid ?? '';
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.otherUserName,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream:
                  _firestoreService.messagesBetween(uid, widget.otherUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                      child: Text('No messages yet — say hello.',
                          style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    return _Bubble(
                        text: m.text,
                        outgoing: m.senderId == uid,
                        accentColor: widget.accentColor);
                  },
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
                  GestureDetector(
                    onTap: _send,
                    child: CircleAvatar(
                      backgroundColor: widget.accentColor,
                      child: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send,
                              color: Colors.white, size: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool outgoing;
  final Color accentColor;

  const _Bubble(
      {required this.text, required this.outgoing, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: outgoing ? accentColor : AppColors.pureWhite,
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
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                color: outgoing ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}
