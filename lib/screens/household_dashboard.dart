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
        child: Column(
          children: [
            // ── Green header band (Grab-style) ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
              decoration: const BoxDecoration(
                color: AppColors.sellerGreen,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kumusta, Maria',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 2),
                          Text('📍 Barangay Maa, Davao City',
                              style: TextStyle(fontSize: 12, color: Color(0xFFB9E4C0))),
                        ],
                      ),
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                        ),
                        child: const Center(
                          child: Text('MS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Search bar style quick-action
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search, color: Color(0xFF999999), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Find scrap pickup...',
                              style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
                        ),
                        Container(width: 1, height: 24, color: const Color(0xFFE8E8E8)),
                        const SizedBox(width: 10),
                        const Icon(Icons.qr_code_scanner, color: AppColors.sellerGreen, size: 20),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Impact card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.sellerGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco, color: AppColors.sellerGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${RecyclingImpactTracker.getImpactSummary(_demoTotalKg)} Trees Saved',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${_demoTotalKg.toStringAsFixed(1)} kg recycled this month',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                        ]),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Stat cards
                  Row(children: [
                    _StatCard(label: 'Pending', value: '2'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Completed', value: '14', highlight: true),
                  ]),
                  const SizedBox(height: 16),

                  // Active pickup
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
                      border: Border.all(color: AppColors.sellerGreen.withOpacity(0.15)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('ACTIVE PICKUP',
                            style: TextStyle(fontSize: 10, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.buyerBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('JD', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Juan Dela Cruz', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text('Tricycle · #PKP-0042', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          ]),
                        ),
                        const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('★ 4.8', style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.w700, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('ETA 5 min', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sellerGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {},
                            child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F5),
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {},
                            child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ]),
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
          boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
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
  final bool highlight;
  const _StatCard({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.sellerGreen : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
        ]),
      ),
    );
  }
}
