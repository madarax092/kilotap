import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'impact_page.dart';
import 'chat_detail_screen.dart';
import 'tracking_screen.dart';

class HouseholdDashboard extends StatelessWidget {
  const HouseholdDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: AppColors.sellerGreen.withOpacity(0.15),
                              shape: BoxShape.circle),
                          child: const Center(
                              child: Text('M',
                                  style: TextStyle(
                                      color: AppColors.sellerGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Hello, Maria',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827))),
                            Text('Ready to recycle today?',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none,
                          color: Color(0xFF4B5563), size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(
                    label: 'Pending',
                    value: '2',
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                    iconBg: Colors.orange.withOpacity(0.1)),
                const SizedBox(width: 12),
                _StatCard(
                    label: 'Completed',
                    value: '14',
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    iconBg: Colors.green.withOpacity(0.1)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ImpactPage()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.recycling,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Your Eco Impact',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text("You're in the top 15% of recyclers in Davao",
                              style: TextStyle(
                                  color: Color(0xFFD0EEDB), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Pickup',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C2C2C))),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/pickups'),
                  child: const Text('View All',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sellerGreen)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: AppColors.sellerGreen, size: 8),
                      SizedBox(width: 6),
                      Text('ON THE WAY',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.sellerGreen,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                      Spacer(),
                      Text('#PKP-0042',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFA0A0A0))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle),
                              child: const Center(
                                  child: Text('JD',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)))),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: AppColors.sellerGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2))),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Juan Dela Cruz',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Tricycle · ETA 5 min',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.orange, size: 14),
                            SizedBox(width: 4),
                            Text('4.8',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF2C2C2C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Pickup progress',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                      Text('75%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sellerGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.sellerGreen),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.near_me_outlined, size: 18),
                          label: const Text('Track Pickup',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sellerGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackingScreen(
                                        collectorName: 'Juan Dela Cruz',
                                        bookingId: '#PKP-0042')));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Message',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C2C2C),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChatDetailScreen(
                                      collectorName: 'Juan Dela Cruz',
                                      bookingId: '#PKP-0042'),
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C2C2C))),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/pickups'),
                  child: const Text('View All',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sellerGreen)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ]),
              child: Column(
                children: const [
                  _ActivityItem(
                      color: Colors.orange,
                      title: 'Cardboard',
                      weight: '8.5 kg',
                      date: 'Jul 22',
                      amount: '+₱34.00'),
                  Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _ActivityItem(
                      color: Colors.blue,
                      title: 'Plastic Bottles',
                      weight: '3.2 kg',
                      date: 'Jul 19',
                      amount: '+₱16.00'),
                  Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _ActivityItem(
                      color: Colors.grey,
                      title: 'Metal Cans',
                      weight: '5.1 kg',
                      date: 'Jul 15',
                      amount: '+₱51.00'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: const _BottomNav(current: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, iconBg;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.iconColor,
      required this.iconBg});
  @override
  Widget build(BuildContext c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration:
                      BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFFD1D5DB), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Color color;
  final String title, weight, date, amount;
  const _ActivityItem(
      {required this.color,
      required this.title,
      required this.weight,
      required this.date,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      children: [
                    TextSpan(text: title),
                    const TextSpan(
                        text: ' · ',
                        style: TextStyle(color: Color(0xFF6B7280))),
                    TextSpan(text: weight),
                  ])),
              const SizedBox(height: 4),
              Text(date,
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            ],
          ),
        ),
        Text(amount,
            style: const TextStyle(
                color: AppColors.sellerGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  const _BottomNav({required this.current});
  @override
  Widget build(BuildContext c) => Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
      ]),
      child: SafeArea(
          child: BottomNavigationBar(
        currentIndex: current,
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: const Color(0xFFBBBBBB),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0 && current != 0)
            Navigator.pushReplacementNamed(c, '/household');
          if (i == 1 && current != 1)
            Navigator.pushReplacementNamed(c, '/sell');
          if (i == 2 && current != 2)
            Navigator.pushReplacementNamed(c, '/pickups');
          if (i == 3 && current != 3)
            Navigator.pushReplacementNamed(c, '/chat');
          if (i == 4 && current != 4)
            Navigator.pushReplacementNamed(c, '/profile');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'Pickups'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile')
        ],
      )));
}
