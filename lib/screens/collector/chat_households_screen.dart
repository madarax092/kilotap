import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/chat_thread_view.dart';

class ChatHouseholdsScreen extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatHouseholdsScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    return ChatThreadView(
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      accentColor: AppColors.buyerBlue,
    );
  }
}
