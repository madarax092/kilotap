import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/audit_log.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Admin Panel',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestoreService.listUsers(),
              builder: (context, usersSnap) {
                final users = usersSnap.data ?? const <Map<String, dynamic>>[];
                final collectors = users
                    .where((u) => u['Role'] == 'Collector' || u['Role'] == 'VerifiedCollector')
                    .toList();

                return StreamBuilder<List<Booking>>(
                  stream: firestoreService.allBookings(),
                  builder: (context, bookingsSnap) {
                    final bookings = bookingsSnap.data ?? const <Booking>[];
                    final active = bookings.where((b) => b.status == 'Accepted').length;
                    final now = DateTime.now();
                    final today = bookings
                        .where((b) =>
                            b.createdAt.year == now.year &&
                            b.createdAt.month == now.month &&
                            b.createdAt.day == now.day)
                        .length;

                    return FutureBuilder<int>(
                      future: _pendingCount(firestoreService, collectors),
                      builder: (context, pendingSnap) {
                        final pendingCount = pendingSnap.data ?? 0;
                        return ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 24),
                          children: [
                            Row(children: [
                              _Stat(
                                  val: '${users.length}',
                                  label: 'Total Users',
                                  color: const Color(0xFF111827),
                                  icon: Icons.people_outline,
                                  onTap: () => Navigator.pushNamed(context, '/users')),
                              const SizedBox(width: 12),
                              _Stat(
                                val: '$active',
                                label: 'Active Pickups',
                                color: const Color(0xFF111827),
                                icon: Icons.local_shipping_outlined,
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              _Stat(
                                val: '$today',
                                label: 'Pickups Today',
                                color: const Color(0xFF111827),
                                icon: Icons.today_outlined,
                              ),
                              const SizedBox(width: 12),
                              _Stat(
                                  val: '$pendingCount',
                                  label: 'Pending Verify',
                                  color: AppColors.adminRed,
                                  icon: Icons.verified_user_outlined,
                                  onTap: () => Navigator.pushNamed(context, '/verify')),
                            ]),
                            const SizedBox(height: 32),
                            Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB), width: 1.5),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('RECENT AUDIT ACTIVITY',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6B7280),
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.2)),
                                            GestureDetector(
                                                onTap: () => Navigator.pushNamed(
                                                    context, '/audit'),
                                                child: const Text('View all →',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.buyerBlue))),
                                          ]),
                                      const SizedBox(height: 16),
                                      StreamBuilder<List<AuditLog>>(
                                        stream: firestoreService.recentLogs(limit: 3),
                                        builder: (context, logsSnap) {
                                          final logs = logsSnap.data ?? const <AuditLog>[];
                                          if (logs.isEmpty) {
                                            return const Text(
                                                'No admin activity recorded yet.',
                                                style: TextStyle(
                                                    color: Color(0xFF6B7280)));
                                          }
                                          final rows = <Widget>[];
                                          for (var i = 0; i < logs.length; i++) {
                                            if (i > 0) {
                                              rows.add(const Divider(
                                                  height: 20, color: Color(0xFFF3F4F6)));
                                            }
                                            rows.add(Text(
                                                '${logs[i].action.replaceAll('_', ' ')} — ${logs[i].description}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF4B5563))));
                                          }
                                          return Column(children: rows);
                                        },
                                      ),
                                    ])),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 0),
    );
  }

  Future<int> _pendingCount(
      FirestoreService svc, List<Map<String, dynamic>> collectors) async {
    final profiles =
        await Future.wait(collectors.map((u) => svc.collectorProfile(u['uid'] as String)));
    return profiles
        .where((p) => (p?['Verification_Status'] as String?) == 'Pending')
        .length;
  }
}

class _Stat extends StatelessWidget {
  final String val, label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _Stat(
      {required this.val,
      required this.label,
      required this.color,
      required this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            onTap: onTap,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(val,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  height: 1)),
                          Icon(icon, color: color.withValues(alpha: 0.5), size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600))
                    ]))));
  }
}
