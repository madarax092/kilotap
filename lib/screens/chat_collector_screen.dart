import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'chat_households_screen.dart';

class ChatCollectorScreen extends StatelessWidget {
  const ChatCollectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Messages',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.chat_bubble_outline,
                          color: Color(0xFF6B7280), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Chat with your households',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: const [
                _ChatPreviewCard(
                  name: 'Ana Lim',
                  message: 'Dito po sa gate 2, pakisabi sa guard.',
                  time: 'Just now',
                  unread: 2,
                  initials: 'AL',
                  bookingId: '#PKP-0042',
                ),
                _ChatPreviewCard(
                  name: 'Roberto Cruz',
                  message: 'Nalabas ko na po yung mga karton.',
                  time: '2 hours ago',
                  unread: 0,
                  initials: 'RC',
                  bookingId: '#PKP-0041',
                ),
                _ChatPreviewCard(
                  name: 'Elena Gomez',
                  message: 'Salamat po kuya! Next time ulit.',
                  time: 'Jun 28',
                  unread: 0,
                  initials: 'EG',
                  bookingId: '#PKP-0040',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ]),
          child: SafeArea(
              child: BottomNavigationBar(
            currentIndex: 2,
            selectedItemColor: AppColors.buyerBlue,
            unselectedItemColor: const Color(0xFFBBBBBB),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
              if (i == 1) Navigator.pushReplacementNamed(context, '/find');
              if (i == 3) Navigator.pushReplacementNamed(context, '/earnings');
              if (i == 4)
                Navigator.pushReplacementNamed(context, '/collector_profile');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded), label: 'Find'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Messages'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.payments_rounded), label: 'Earn'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ))),
    );
  }
}

class _ChatPreviewCard extends StatelessWidget {
  final String name, message, time, initials, bookingId;
  final int unread;
  const _ChatPreviewCard(
      {required this.name,
      required this.message,
      required this.time,
      required this.initials,
      required this.unread,
      required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatHouseholdsScreen(
                  householdName: name, bookingId: bookingId))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: unread > 0
              ? Border.all(
                  color: AppColors.buyerBlue.withOpacity(0.3), width: 1.5)
              : Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: unread > 0
              ? [
                  BoxShadow(
                      color: AppColors.buyerBlue.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: AppColors.sellerGreen.withOpacity(0.15),
                      shape: BoxShape.circle),
                  child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.sellerGreen,
                              fontSize: 16))),
                ),
                if (unread > 0)
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)),
                      ))
              ],
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
                          style: TextStyle(
                              fontWeight: unread > 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: const Color(0xFF111827))),
                      Text(time,
                          style: TextStyle(
                              fontSize: 11,
                              color: unread > 0
                                  ? AppColors.buyerBlue
                                  : const Color(0xFF9CA3AF),
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(bookingId,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280))),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: unread > 0
                                      ? const Color(0xFF374151)
                                      : const Color(0xFF6B7280),
                                  fontWeight: unread > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal))),
                    ],
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: AppColors.buyerBlue, shape: BoxShape.circle),
                child: Text(unread.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              )
          ],
        ),
      ),
    );
  }
}
