import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../household/chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
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
                const Text('Chat with your collectors',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: const [
                _ChatPreviewCard(
                  name: 'Juan Dela Cruz',
                  message: 'Nandito na po ako sa labas.',
                  time: 'Just now',
                  unread: 2,
                  initials: 'JD',
                  bookingId: '#PKP-0042',
                ),
                _ChatPreviewCard(
                  name: 'Maria Santos',
                  message: 'Ok po, will arrive at 9 AM tomorrow.',
                  time: '2 hours ago',
                  unread: 0,
                  initials: 'MS',
                  bookingId: '#PKP-0041',
                ),
                _ChatPreviewCard(
                  name: 'Pedro Reyes',
                  message: 'Salamat po sa business!',
                  time: 'Jun 28',
                  unread: 0,
                  initials: 'PR',
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
            currentIndex: 3,
            selectedItemColor: AppColors.sellerGreen,
            unselectedItemColor: const Color(0xFFBBBBBB),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 0) Navigator.pushReplacementNamed(context, '/household');
              if (i == 1) Navigator.pushReplacementNamed(context, '/sell');
              if (i == 2) Navigator.pushReplacementNamed(context, '/pickups');
              if (i == 4) Navigator.pushReplacementNamed(context, '/profile');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded), label: 'Pickups'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Messages'),
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

  const _ChatPreviewCard({
    required this.name,
    required this.message,
    required this.time,
    required this.initials,
    required this.bookingId,
    this.unread = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatDetailScreen(collectorName: name, bookingId: bookingId),
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  color: Colors.blueAccent, shape: BoxShape.circle),
              child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF111827))),
                      Text(time,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: unread > 0
                                  ? AppColors.sellerGreen
                                  : const Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(bookingId,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.buyerBlue,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: unread > 0
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF6B7280),
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.sellerGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(unread.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
