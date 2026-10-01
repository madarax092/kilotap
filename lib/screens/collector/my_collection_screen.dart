import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

class MyCollectionScreen extends StatelessWidget {
  const MyCollectionScreen({super.key});

  Future<_CollectionStats> _loadStats(
      FirestoreService svc, List<Booking> completed) async {
    double totalKg = 0;
    final txns = <_TxnData>[];
    for (final b in completed) {
      final items = await svc.bookingItems(b.bookingId).first;
      final kg = items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
      totalKg += kg;
      final sellerName = await svc.displayNameFor(b.sellerId);
      txns.add(_TxnData(name: sellerName, kg: kg, date: b.completedAt ?? b.createdAt));
    }
    txns.sort((a, b) => b.date.compareTo(a.date));
    return _CollectionStats(totalKg: totalKg, recent: txns.take(5).toList());
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
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
                    const Text('My Collections',
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
                      child: const Icon(Icons.scale_outlined,
                          color: Color(0xFF4B5563), size: 22),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Track your completed pickups and total weight',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream:
                  firestoreService.collectorBookings(AuthState.instance.uid ?? ''),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final completed = snapshot.data!
                    .where((b) => b.status == 'Completed')
                    .toList();
                return FutureBuilder<_CollectionStats>(
                  future: _loadStats(firestoreService, completed),
                  builder: (context, statsSnap) {
                    if (!statsSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final stats = statsSnap.data!;
                    return ListView(
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.buyerBlue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.buyerBlue.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Weight Collected',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFE1F5FE),
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(stats.totalKg.toStringAsFixed(1),
                                        style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                    const Text(' kg',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x06000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 4))
                                ]),
                            child: Row(children: [
                              _StatBox('${completed.length}', 'Pickups Completed',
                                  Icons.local_shipping_outlined),
                              const SizedBox(width: 12),
                              _StatBox(
                                  AuthState.instance.avgRating.toStringAsFixed(1),
                                  'Avg Rating',
                                  Icons.star_outline),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('RECENT TRANSACTIONS',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2)),
                        ),
                        const SizedBox(height: 12),
                        if (stats.recent.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text('No completed pickups yet.',
                                style: TextStyle(color: Color(0xFF6B7280))),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: stats.recent
                                  .map((t) => _Txn(t.name, t.kg, t.date))
                                  .toList(),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              currentIndex: 3,
              onTap: (i) {
                if (i == 0) {
                  Navigator.pushReplacementNamed(context, '/collector');
                }
                if (i == 1) Navigator.pushReplacementNamed(context, '/find');
                if (i == 2) {
                  Navigator.pushReplacementNamed(context, '/chat');
                }
                if (i == 3) {
                  Navigator.pushReplacementNamed(context, '/earnings');
                }
                if (i == 4) {
                  Navigator.pushReplacementNamed(context, '/collector_profile');
                }
              },
              selectedItemColor: AppColors.buyerBlue,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded), label: 'Find'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    label: 'Messages'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.scale_rounded), label: 'Stats'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionStats {
  final double totalKg;
  final List<_TxnData> recent;
  const _CollectionStats({required this.totalKg, required this.recent});
}

class _TxnData {
  final String name;
  final double kg;
  final DateTime date;
  const _TxnData({required this.name, required this.kg, required this.date});
}

class _StatBox extends StatelessWidget {
  final String val, label;
  final IconData icon;
  const _StatBox(this.val, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text(val,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Txn extends StatelessWidget {
  final String name;
  final double kg;
  final DateTime date;
  const _Txn(this.name, this.kg, this.date);

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.scale_outlined,
                color: Color(0xFF6B7280), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)))),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${kg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.buyerBlue)),
            const SizedBox(height: 2),
            Text('${months[date.month - 1]} ${date.day}',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }
}
