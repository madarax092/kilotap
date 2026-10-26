import 'package:flutter/material.dart';
import '../../widgets/empty_section_text.dart';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../models/audit_log.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

// Plain-language label, group and colour for each audit action code. An
// unknown code falls back to the code itself in the "Other" group.
const Map<String, (String, String)> _actionInfo = {
  'VERIFY_COLLECTOR': ('Verified a collector', 'Verification'),
  'REJECT_COLLECTOR': ('Rejected a collector', 'Verification'),
  'APPROVE_VEHICLE': ('Approved a vehicle', 'Verification'),
  'REJECT_VEHICLE': ('Rejected a vehicle', 'Verification'),
  'APPROVE_DOCUMENT': ('Approved a document', 'Verification'),
  'REJECT_DOCUMENT': ('Rejected a document', 'Verification'),
  'SUSPEND_USER': ('Suspended an account', 'Accounts'),
  'CLOSE_ACCOUNT': ('Closed an account', 'Accounts'),
  'REACTIVATE_USER': ('Reactivated an account', 'Accounts'),
  'WARN_USER': ('Warned a user', 'Accounts'),
  'INVESTIGATE_REPORT': ('Started investigating a report', 'Reports'),
  'RESOLVE_REPORT': ('Resolved a report', 'Reports'),
  'DISMISS_REPORT': ('Dismissed a report', 'Reports'),
  'BOOKING_ACCEPTED': ('Pickup accepted', 'Bookings'),
  'BOOKING_COMPLETED': ('Pickup completed', 'Bookings'),
  'BOOKING_CANCELLED': ('Pickup cancelled', 'Bookings'),
  'UPDATE_SETTINGS': ('Changed system settings', 'Settings'),
};

const _groups = [
  'All',
  'Accounts',
  'Verification',
  'Reports',
  'Bookings',
  'Settings',
];

Color _groupColor(String group) {
  switch (group) {
    case 'Accounts':
      return AppColors.adminRed;
    case 'Verification':
      return AppColors.buyerBlue;
    case 'Reports':
      return const Color(0xFFD97706);
    case 'Bookings':
      return AppColors.sellerGreen;
    case 'Settings':
      return const Color(0xFF7C3AED);
    default:
      return AppColors.textSecondary;
  }
}

(String, String) _infoFor(String action) {
  final code = action.toUpperCase();
  return _actionInfo[code] ?? (code, 'Other');
}

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final _svc = FirestoreService();
  String _group = 'All';
  // uid -> display name, shared by every row so each person is looked up once.
  final Map<String, Future<String>> _names = {};

  Future<String> _nameOf(String id) {
    if (id.isEmpty) return Future.value('');
    if (id == 'server' || id == 'system') return Future.value('System');
    return _names.putIfAbsent(id, () async {
      final account = await _svc.userAccount(id);
      return (account?['Display_Name'] as String?) ?? '';
    });
  }

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
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF6B7280), size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Security Audit Logs',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Who did what, to whom, and when',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final g in _groups)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: _group == g,
                          onSelected: (_) => setState(() => _group = g),
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AuditLog>>(
              stream: _svc.recentLogs(limit: 100),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = snapshot.data!
                    .where((l) =>
                        _group == 'All' || _infoFor(l.action).$2 == _group)
                    .toList();
                if (logs.isEmpty) {
                  return const EmptySectionText(
                      'No audit log entries here yet.',
                      centered: true);
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _AuditCard(log: logs[i], nameOf: _nameOf),
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

class _AuditCard extends StatelessWidget {
  final AuditLog log;
  final Future<String> Function(String id) nameOf;
  const _AuditCard({required this.log, required this.nameOf});

  Future<(String, String)> _names() async {
    final r = await Future.wait([nameOf(log.actorId), nameOf(log.targetId)]);
    return (r[0], r[1]);
  }

  // A target that isn't a person: a booking, a report or the settings.
  String _targetFallback() {
    final id = log.targetId;
    if (id.isEmpty) return '';
    if (id.startsWith('systemSettings')) return 'System settings';
    final short = id.length > 6 ? id.substring(0, 6).toUpperCase() : id;
    return log.action.toUpperCase().startsWith('BOOKING')
        ? 'Booking #$short'
        : '#$short';
  }

  @override
  Widget build(BuildContext context) {
    final (label, group) = _infoFor(log.action);
    final color = _groupColor(group);
    return FutureBuilder<(String, String)>(
      future: _names(),
      builder: (context, snap) {
        final actor = snap.data?.$1 ?? '';
        final target = snap.data?.$2 ?? '';
        final who = actor.isNotEmpty ? actor : 'Unknown user';
        final whom = target.isNotEmpty ? target : _targetFallback();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(group.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: color)),
                ),
                const Spacer(),
                Text(formatDateTime(log.createAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              _Line('By', who),
              if (whom.isNotEmpty) _Line('Affected', whom),
              if (log.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(log.description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.4)),
              ],
              if (log.ipAddress.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                    log.ipAddress == 'server'
                        ? 'Recorded by the server'
                        : 'IP address ${log.ipAddress}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  final String label, value;
  const _Line(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ]),
    );
  }
}
