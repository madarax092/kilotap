import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../chat_households_screen.dart';
import 'documents_page.dart';

class CollectorDashboard extends StatelessWidget {
  const CollectorDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Center(child: Text('J', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.bold, fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Hello, Juan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                            Text('Ready for pickups today?', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none, color: Color(0xFF4B5563), size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Pending / Completed Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(label: 'Pending', value: '7', icon: Icons.access_time, iconColor: Colors.orange, iconBg: Colors.orange.withOpacity(0.1)),
                const SizedBox(width: 12),
                _StatCard(label: 'Completed', value: '32', icon: Icons.check_circle_outline, iconColor: Colors.green, iconBg: Colors.green.withOpacity(0.1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Middle Banner (Verification)
          if (!AuthState.instance.hasPermission('accept_pickup'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsPage())),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Action Required', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Verify profile to accept pickups', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          
          // Digital ID Card Shortcut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/idcard'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.buyerBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.badge_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Digital ID Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Show your collector ID', style: TextStyle(color: Color(0xFFE1F5FE), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Nearby Requests / Map Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Assigned Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2C2C2C))),
                Text('Open Map', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.buyerBlue)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: AppColors.buyerBlue, size: 8),
                      SizedBox(width: 6),
                      Text('EN ROUTE', style: TextStyle(fontSize: 11, color: AppColors.buyerBlue, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      Spacer(),
                      Text('#PKP-0042', style: TextStyle(fontSize: 12, color: Color(0xFFA0A0A0))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/davao_map.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(width: 46, height: 46, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Center(child: Text('MS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Maria Santos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Maa · 0.3 km away', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.scale_outlined, color: AppColors.textSecondary, size: 14),
                            SizedBox(width: 4),
                            Text('15 kg', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF2C2C2C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Arrived', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buyerBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2C2C2C),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const ChatHouseholdsScreen(householdName: 'Maria Santos', bookingId: '#PKP-0042'),
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
          
          // Recent Earnings Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recent Earnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2C2C2C))),
                Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.buyerBlue)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                children: const [
                  _ActivityItem(color: Colors.orange, title: 'Cardboard & Paper', area: 'Matina', date: 'Today, 10:30 AM', amount: '5.2 kg'),
                  Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _ActivityItem(color: Colors.blue, title: 'Mixed Plastics', area: 'Buhangin', date: 'Yesterday, 3:15 PM', amount: '3.8 kg'),
                  Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _ActivityItem(color: Colors.grey, title: 'Scrap Metal', area: 'Maa', date: 'Jul 25, 9:00 AM', amount: '22.5 kg'),
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
  const _StatCard({required this.label, required this.value, required this.icon, required this.iconColor, required this.iconBg});
  
  @override Widget build(BuildContext c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Color color;
  final String title, area, date, amount;
  const _ActivityItem({required this.color, required this.title, required this.area, required this.date, required this.amount});
  
  @override Widget build(BuildContext context) {
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
                  style: const TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w600),
                  children: [
                    TextSpan(text: title),
                    const TextSpan(text: ' · ', style: TextStyle(color: Color(0xFF6B7280))),
                    TextSpan(text: area),
                  ]
                )
              ),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            ],
          ),
        ),
        Text(amount, style: const TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current; const _BottomNav({required this.current});
  @override Widget build(BuildContext c) => Container(
    decoration: const BoxDecoration(
      color: Colors.white, 
      boxShadow: [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))]
    ), 
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: BottomNavigationBar(
          currentIndex: current, selectedItemColor: AppColors.buyerBlue, unselectedItemColor: const Color(0xFFBBBBBB), backgroundColor: Colors.transparent, elevation: 0, type: BottomNavigationBarType.fixed,
          onTap: (i) { 
            if (i==0 && current != 0) Navigator.pushReplacementNamed(c, '/collector');
            if (i==1 && current != 1) Navigator.pushReplacementNamed(c, '/find'); 
            if (i==2 && current != 2) Navigator.pushReplacementNamed(c, '/chat_collector'); 
            if (i==3 && current != 3) Navigator.pushReplacementNamed(c, '/earnings'); 
            if (i==4 && current != 4) Navigator.pushReplacementNamed(c, '/collector_profile'); 
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'), 
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Find'), 
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'), 
            BottomNavigationBarItem(icon: Icon(Icons.scale_rounded, size: 22), label: 'Collections'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile')
          ],
        ),
      ),
    ),
  );
}
