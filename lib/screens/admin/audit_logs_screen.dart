import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
            child: ListView(
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
                        children: const [
                          Text('SECURITY AUDIT LOGS',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2)),
                          SizedBox(height: 20),
                          _Audit(
                            logId: 'LOG-8911',
                            actorId: 'UID-4921 (Pedro Reyes)',
                            action: 'BOOKING_ACCEPTED',
                            targetId: '#PKP-0042',
                            description:
                                'Collector accepted pickup request from Maria Santos.',
                            createdAt: '2026-07-28 16:15:00',
                            ipAddress: '112.201.34.12',
                          ),
                          Divider(height: 24, color: Color(0xFFF3F4F6)),
                          _Audit(
                            logId: 'LOG-8910',
                            actorId: 'admin@kilotap',
                            action: 'COLLECTOR_VERIFIED',
                            targetId: 'UID-4921 (Pedro Reyes)',
                            description:
                                'Admin verified collector Pedro Reyes and activated account.',
                            createdAt: '2026-07-28 14:30:00',
                            ipAddress: '192.168.1.42',
                          ),
                          Divider(height: 24, color: Color(0xFFF3F4F6)),
                          _Audit(
                            logId: 'LOG-8909',
                            actorId: 'admin@kilotap',
                            action: 'DISPUTE_RESOLVED',
                            targetId: '#RPT-0017',
                            description:
                                'Investigated and resolved report #RPT-0017 (wrong items).',
                            createdAt: '2026-07-27 09:15:22',
                            ipAddress: '192.168.1.42',
                          ),
                          Divider(height: 24, color: Color(0xFFF3F4F6)),
                          _Audit(
                            logId: 'LOG-8908',
                            actorId: 'SYSTEM',
                            action: 'USER_SUSPENDED',
                            targetId: 'User #A3X92',
                            description:
                                'Automated suspension due to 3 consecutive no-show violations.',
                            createdAt: '2026-07-26 23:59:59',
                            ipAddress: '127.0.0.1',
                          ),
                        ])),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(current: 3),
    );
  }
}

class _Audit extends StatelessWidget {
  final String logId,
      actorId,
      action,
      targetId,
      description,
      createdAt,
      ipAddress;

  const _Audit(
      {required this.logId,
      required this.actorId,
      required this.action,
      required this.targetId,
      required this.description,
      required this.createdAt,
      required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Log ID: $logId',
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700)),
            Text(createdAt,
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
                  Text('$actorId · ${action.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text('Target: $targetId',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563))),
                  const SizedBox(height: 2),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Text('IP: $ipAddress',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic)),
                ])),
          ])
        ]));
  }
}
