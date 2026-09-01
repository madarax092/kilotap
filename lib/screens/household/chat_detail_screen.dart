import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/chat_thread_view.dart';

class ChatDetailScreen extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    return ChatThreadView(
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      accentColor: AppColors.sellerGreen,
    );
  }
}
