import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      title: const Text('Juan Dela Cruz', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: const Text('#PKP-0042', style: TextStyle(fontSize: 9, color: AppColors.buyerBlue, fontWeight: FontWeight.w600))))],
    ),
    body: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: const [_Msg("Hello ma'am! On my way po, mga 5 minutes na lang.", false), _Msg('Sige po, gate code is #1234. Blue ang gate.', true), _Msg('Copy po. Tricycle color blue ako.', false), _Msg('Nandito na po ako sa labas.', false)])),
      Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppColors.pureWhite, border: Border(top: BorderSide(color: AppColors.divider))), child: Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type message...', filled: true, fillColor: AppColors.inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.divider)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))), const SizedBox(width: 8), CircleAvatar(backgroundColor: AppColors.sellerGreen, child: const Icon(Icons.send, color: Colors.white, size: 18))])),
    ]),
  );
}

class _Msg extends StatelessWidget {
  final String text; final bool outgoing;
  const _Msg(this.text, this.outgoing);
  @override Widget build(BuildContext context) => Align(alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: const BoxConstraints(maxWidth: 280), decoration: BoxDecoration(color: outgoing ? AppColors.sellerGreen : AppColors.pureWhite, borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: outgoing ? const Radius.circular(16) : const Radius.circular(4), bottomRight: outgoing ? const Radius.circular(4) : const Radius.circular(16)), border: outgoing ? null : Border.all(color: AppColors.divider)), child: Text(text, style: TextStyle(fontSize: 13, color: outgoing ? Colors.white : AppColors.textPrimary))));
}
