import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/impact_tracker.dart';

class HouseholdDashboard extends StatelessWidget {
  const HouseholdDashboard({super.key});

  static const double _demoTotalKg = 245.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        top: true, bottom: false, left: false, right: false,
        child: Column(
          children: [
            // ── Green header ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.sellerGreen,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kumusta, Maria',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Barangay Maa, Davao City',
                            style: TextStyle(fontSize: 13, color: Color(0xFFA5D6A7))),
                      ],
                    ),
                  ),
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('MS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  // Impact banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.sellerGreen.withOpacity(0.06), AppColors.sellerGreen.withOpacity(0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sellerGreen.withOpacity(0.1)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.sellerGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco_outlined, color: AppColors.sellerGreen, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${RecyclingImpactTracker.getImpactSummary(_demoTotalKg)} Trees Saved',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${_demoTotalKg.toStringAsFixed(1)} kg recycled this month',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                        ]),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFCCCCCC), size: 16),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(children: [
                    _StatCard(label: 'Pending', value: '2'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Completed', value: '14', accent: true),
                  ]),
                  const SizedBox(height: 18),

                  // Active section title
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.sellerGreen),
                      SizedBox(width: 6),
                      Text('Active Pickup',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ]),
                  ),

                  // Active pickup card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('ON THE WAY',
                              style: TextStyle(fontSize: 10, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const Spacer(),
                          const Text('#PKP-0042',
                              style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.buyerBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('JD',
                                  style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Juan Dela Cruz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              SizedBox(height: 2),
                              Text('Tricycle · ETA 5 min', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                            ]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('★ 4.8',
                                style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sellerGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {},
                              child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {},
                              child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -1))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: AppColors.sellerGreen,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final bool accent;
  const _StatCard({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800,
                  color: accent ? AppColors.sellerGreen : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
