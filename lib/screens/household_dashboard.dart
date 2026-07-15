import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/impact_tracker.dart';

class HouseholdDashboard extends StatelessWidget {
  const HouseholdDashboard({super.key});
  static const double _demoKg = 245.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + 160),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 24, right: 24, bottom: 20),
          decoration: const BoxDecoration(
            color: AppColors.sellerGreen,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kumusta, Maria',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Barangay Maa, Davao City',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB9E4C0))),
              const SizedBox(height: 16),
              // Impact card inside header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.eco, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${RecyclingImpactTracker.getImpactSummary(_demoKg)} Trees Saved',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('${_demoKg.toStringAsFixed(1)} kg recycled this month',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB9E4C0))),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          // Stats
          Row(children: [
            _StatCard(label: 'Pending', value: '2'),
            const SizedBox(width: 12),
            _StatCard(label: 'Completed', value: '14', accent: true),
          ]),
          const SizedBox(height: 22),

          // Active pickup header
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Active Pickup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C2C2C))),
          ),

          // Active card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('ON THE WAY',
                    style: TextStyle(fontSize: 10, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const Spacer(),
                const Text('#PKP-0042',
                    style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.buyerBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
                  child: const Center(
                      child: Text('JD', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w700, fontSize: 16))),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Juan Dela Cruz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Tricycle · ETA 5 min', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10)),
                  child: const Text('★ 4.8',
                      style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {},
                  child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C2C2C),
                      side: const BorderSide(color: Color(0xFFE8E8E8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {},
                  child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                )),
              ]),
            ]),
          ),
          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: _BottomNav(current: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final bool accent;
  const _StatCard({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
            color: accent ? AppColors.sellerGreen : const Color(0xFF2C2C2C))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
      ]),
    ));
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  const _BottomNav({required this.current});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(child: BottomNavigationBar(
        currentIndex: current, selectedItemColor: AppColors.sellerGreen, unselectedItemColor: const Color(0xFFBBBBBB),
        backgroundColor: Colors.transparent, elevation: 0, type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/sell');
          if (i == 2) Navigator.pushNamed(context, '/pickups');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Pickups'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      )),
    );
  }
}
