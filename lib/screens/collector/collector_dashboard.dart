import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import 'chat_households_screen.dart';
import 'documents_page.dart';

class CollectorDashboard extends StatelessWidget {
  const CollectorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
    final displayName = AuthState.instance.displayName;
    final firstName =
        displayName.trim().isEmpty ? 'Collector' : displayName.trim().split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: AppColors.buyerBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  color: AppColors.buyerBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, $firstName',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        const Text('Ready for pickups today?',
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
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Booking>>(
            stream:
                firestoreService.collectorBookings(AuthState.instance.uid ?? ''),
            builder: (context, snapshot) {
              final bookings = snapshot.data ?? const <Booking>[];
              final active =
                  bookings.where((b) => b.status == 'Accepted').toList();
              final completed =
                  bookings.where((b) => b.status == 'Completed').toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StatCard(
                            label: 'Active',
                            value: '${active.length}',
                            icon: Icons.access_time,
                            iconColor: Colors.orange,
                            iconBg: Colors.orange.withValues(alpha: 0.1)),
                        const SizedBox(width: 12),
                        _StatCard(
                            label: 'Completed',
                            value: '${completed.length}',
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green,
                            iconBg: Colors.green.withValues(alpha: 0.1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!AuthState.instance.hasPermission('accept_pickup'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DocumentsPage())),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Action Required',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    SizedBox(height: 2),
                                    Text('Verify profile to accept pickups',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/idcard'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.buyerBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.badge_outlined,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Digital ID Card',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                  SizedBox(height: 2),
                                  Text('Show your collector ID',
                                      style: TextStyle(
                                          color: Color(0xFFE1F5FE),
                                          fontSize: 12)),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assigned Route',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C2C2C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (active.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('No assigned pickups yet — find one nearby.',
                          style: TextStyle(color: Color(0xFF6B7280))),
                    )
                  else
                    ...active.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AssignedRouteCard(booking: b),
                        )),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Collections',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C2C2C))),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/earnings');
                          },
                          child: const Text('View All',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buyerBlue)),
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
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 10,
                                offset: Offset(0, 4))
                          ]),
                      child: completed.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No completed pickups yet.',
                                  style: TextStyle(color: Color(0xFF6B7280))),
                            )
                          : _RecentCollections(
                              svc: firestoreService,
                              bookings: (completed..sort((a, b) =>
                                      (b.completedAt ?? b.createdAt)
                                          .compareTo(a.completedAt ?? a.createdAt)))
                                  .take(3)
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(current: 0),
    );
  }
}

class _RecentCollections extends StatelessWidget {
  final FirestoreService svc;
  final List<Booking> bookings;
  const _RecentCollections({required this.svc, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ActivityData>>(
      future: Future.wait(bookings.map((b) async {
        final items = await svc.bookingItems(b.bookingId).first;
        final kg = items.fold<double>(0, (s, i) => s + i.estimatedWeightKg);
        final label = items.isEmpty ? 'Mixed scrap' : items.first.itemName;
        return _ActivityData(
            label: label, kg: kg, date: b.completedAt ?? b.createdAt);
      })),
      builder: (context, snapshot) {
        final data = snapshot.data ?? const <_ActivityData>[];
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < data.length; i++) {
          if (i > 0) rows.add(const Divider(height: 24, color: Color(0xFFF3F4F6)));
          rows.add(_ActivityItem(data: data[i]));
        }
        return Column(children: rows);
      },
    );
  }
}

class _ActivityData {
  final String label;
  final double kg;
  final DateTime date;
  const _ActivityData({required this.label, required this.kg, required this.date});
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
  final _ActivityData data;
  const _ActivityItem({required this.data});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return Row(
      children: [
        const Icon(Icons.circle, color: AppColors.buyerBlue, size: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.label,
                  style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${months[data.date.month - 1]} ${data.date.day}',
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            ],
          ),
        ),
        Text('+${data.kg.toStringAsFixed(1)} kg',
            style: const TextStyle(
                color: AppColors.buyerBlue,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: BottomNavigationBar(
              currentIndex: current,
              selectedItemColor: AppColors.buyerBlue,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (i) {
                if (i == 0 && current != 0) {
                  Navigator.pushReplacementNamed(c, '/collector');
                }
                if (i == 1 && current != 1) {
                  Navigator.pushReplacementNamed(c, '/find');
                }
                if (i == 2 && current != 2) {
                  Navigator.pushReplacementNamed(c, '/chat');
                }
                if (i == 3 && current != 3) {
                  Navigator.pushReplacementNamed(c, '/earnings');
                }
                if (i == 4 && current != 4) {
                  Navigator.pushReplacementNamed(c, '/collector_profile');
                }
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
                    icon: Icon(Icons.scale_rounded), label: 'Stats'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded), label: 'Profile')
              ],
            ),
          ),
        ),
      );
}

class _AssignedRouteCard extends StatelessWidget {
  final Booking booking;
  const _AssignedRouteCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          firestoreService.displayNameFor(booking.sellerId),
          firestoreService.bookingItems(booking.bookingId).first,
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            );
          }
          final name = snapshot.data![0] as String;
          final items = snapshot.data![1] as List;
          final weight = items.fold<double>(
              0, (s, i) => s + (i.estimatedWeightKg as double));
          final initials = name.trim().isNotEmpty
              ? name.trim().split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase()
              : '?';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.buyerBlue, width: 1.5),
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
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.buyerBlue, shape: BoxShape.circle),
                      child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF111827))),
                          Text(
                              booking.pickupAddress.isEmpty
                                  ? 'Address not provided'
                                  : booking.pickupAddress,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
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
                        children: [
                          const Icon(Icons.scale_outlined,
                              color: AppColors.textSecondary, size: 14),
                          const SizedBox(width: 4),
                          Text('${weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
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
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation_outlined, size: 18),
                        label: const Text('Open Map',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buyerBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/collector_nav',
                              arguments: {
                                'bookingId': booking.bookingId,
                                'initials': initials,
                                'name': name,
                                'material': booking.vehicleRequirement,
                                'location': booking.pickupAddress,
                                'lat': booking.pickupGps.latitude,
                                'lon': booking.pickupGps.longitude,
                              });
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
                                builder: (_) => ChatHouseholdsScreen(
                                    otherUserId: booking.sellerId,
                                    otherUserName: name),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
