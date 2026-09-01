import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/audit_log.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

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
                    const Text('Security Audit Logs',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.close,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Monitor system events and administrative actions',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AuditLog>>(
              stream: FirestoreService().recentLogs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = snapshot.data!;
                if (logs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No audit log entries yet.',
                          style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
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
                              const Text('SECURITY AUDIT LOGS',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 20),
                              for (var i = 0; i < logs.length; i++) ...[
                                if (i > 0)
                                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                                _Audit(log: logs[i]),
                              ],
                            ])),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 3),
    );
  }
}

class _Audit extends StatelessWidget {
  final AuditLog log;
  const _Audit({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Log ID: ${log.logId}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700)),
            Text(log.createAt.toString().split('.').first,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(top: 4, right: 10),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.adminRed, shape: BoxShape.circle),
            ),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${log.actorId} · ${log.action.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text('Target: ${log.targetId}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563))),
                  const SizedBox(height: 2),
                  Text(log.description,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                ])),
          ])
        ]));
  }
}
