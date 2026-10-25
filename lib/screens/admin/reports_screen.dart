import 'package:flutter/material.dart';
import '../../core/account_status.dart';
import '../../core/constants/app_constants.dart';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../models/report.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';
import 'user_management_screen.dart' show confirmAccountStatusChange;

// Reports filed by households and collectors about the other party of a
// booking (widgets/report_problem_sheet.dart). The admin investigates, then
// resolves, dismisses, warns the reported user or suspends their account.
// Every decision is written to the audit log and the reporter is told.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filter = 'Open';

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final svc = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder<List<Report>>(
        stream: svc.allReports(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Report>[];
          final open = all.where((r) => !r.isClosed).length;
          final shown = all.where((r) {
            if (_filter == 'Open') return !r.isClosed;
            if (_filter == 'Closed') return r.isClosed;
            return true;
          }).toList();
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: top + 16, left: 24, right: 24, bottom: 16),
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
                        const Text('Reports & Disputes',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$open open of ${all.length} reports',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(children: [
                  for (final f in const ['Open', 'Closed', 'All'])
                    _FilterChip(f, _filter == f,
                        () => setState(() => _filter = f)),
                ]),
              ),
              Expanded(
                child: snapshot.hasError
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Could not load reports: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF6B7280))),
                      ))
                    : !snapshot.hasData
                        ? const Center(child: CircularProgressIndicator())
                        : shown.isEmpty
                            ? Center(
                                child: Text(
                                    _filter == 'Open'
                                        ? 'No open reports.'
                                        : 'No reports here.',
                                    style: const TextStyle(
                                        color: Color(0xFF6B7280))))
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                                children: [
                                  for (final r in shown)
                                    _ReportCard(report: r, svc: svc),
                                ],
                              ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(current: 2),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: active ? AppColors.adminRed : AppColors.inputGrey,
            borderRadius: BorderRadius.circular(16)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _Parties {
  final String reporterName, targetName, targetStatus;
  const _Parties(this.reporterName, this.targetName, this.targetStatus);
}

class _ReportCard extends StatefulWidget {
  final Report report;
  final FirestoreService svc;
  const _ReportCard({required this.report, required this.svc});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  late Future<_Parties> _parties;
  bool _busy = false;

  Report get r => widget.report;

  @override
  void initState() {
    super.initState();
    _parties = _loadParties();
  }

  @override
  void didUpdateWidget(covariant _ReportCard old) {
    super.didUpdateWidget(old);
    if (old.report.updatedAt != r.updatedAt) _parties = _loadParties();
  }

  Future<_Parties> _loadParties() async {
    final accounts = await Future.wait([
      widget.svc.userAccount(r.reporterId),
      widget.svc.userAccount(r.targetId),
    ]);
    String name(Map<String, dynamic>? a) =>
        (a?['Display_Name'] as String?) ?? 'Unknown';
    return _Parties(
        name(accounts[0]), name(accounts[1]), accountStatusOf(accounts[1]));
  }

  String get _shortReport =>
      r.reportId.length >= 6 ? r.reportId.substring(0, 6).toUpperCase() : r.reportId;
  String get _shortBooking => r.bookingId.length >= 6
      ? r.bookingId.substring(0, 6).toUpperCase()
      : r.bookingId.toUpperCase();

  Color get _statusColor {
    switch (r.status) {
      case 'Investigating':
        return AppColors.buyerBlue;
      case 'Resolved':
        return AppColors.success;
      case 'Dismissed':
        return AppColors.textSecondary;
      default:
        return AppColors.warning;
    }
  }

  Future<String?> _askText(String title, String label,
      {bool required = false, String initial = ''}) async {
    final ctrl = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  errorText: error),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  if (required && ctrl.text.trim().length < 5) {
                    setLocal(() => error = 'Write a short message.');
                    return;
                  }
                  Navigator.pop(ctx, ctrl.text.trim());
                },
                child: const Text('Confirm',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        });
      },
    );
    ctrl.dispose();
    return result;
  }

  // Records the decision on the report, in the audit log, and tells the
  // person who filed it.
  Future<void> _close(String status, String adminAction, String note,
      String auditAction, String outcome) async {
    await widget.svc.updateReport(r.reportId, {
      'Status': status,
      'Admin_Action': adminAction,
      'Admin_Note': note,
      'Resolved_By': AuthState.instance.uid ?? '',
    });
    await widget.svc.logAction({
      'Actor_ID': AuthState.instance.uid ?? '',
      'Action': auditAction,
      'Target_ID': r.reportId,
      'Description': 'Report #$_shortReport (${r.category}) on pickup '
          '#$_shortBooking: $outcome${note.isEmpty ? '' : ' Note: $note'}',
    });
    await widget.svc.sendNotification({
      'Recipient_ID': r.reporterId,
      'Booking_ID': r.bookingId,
      'Title': 'Your report was reviewed',
      'Message': 'We reviewed your report about pickup #$_shortBooking. '
          '$outcome',
      'Type': 'report_update',
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _investigate() => _run(() async {
        await widget.svc.updateReport(r.reportId, {'Status': 'Investigating'});
        await widget.svc.logAction({
          'Actor_ID': AuthState.instance.uid ?? '',
          'Action': AppConstants.auditInvestigateReport,
          'Target_ID': r.reportId,
          'Description': 'Report #$_shortReport (${r.category}) on pickup '
              '#$_shortBooking is under investigation.',
        });
      });

  Future<void> _resolve() async {
    final note = await _askText('Resolve report', 'What was done (optional)');
    if (note == null) return;
    await _run(() => _close('Resolved', 'None', note,
        AppConstants.auditResolveReport, 'It has been resolved.'));
  }

  Future<void> _dismiss() async {
    final note = await _askText('Dismiss report', 'Why (optional)');
    if (note == null) return;
    await _run(() => _close('Dismissed', 'None', note,
        AppConstants.auditDismissReport, 'No action was needed.'));
  }

  Future<void> _warn(String targetName) async {
    final msg = await _askText('Warn $targetName',
        'Message to the user (shown to them)',
        required: true);
    if (msg == null) return;
    await _run(() async {
      await widget.svc.sendNotification({
        'Recipient_ID': r.targetId,
        'Booking_ID': r.bookingId,
        'Title': 'Warning from KiloTap',
        'Message': msg,
        'Type': 'account_warning',
      });
      await widget.svc.logAction({
        'Actor_ID': AuthState.instance.uid ?? '',
        'Action': AppConstants.auditWarnUser,
        'Target_ID': r.targetId,
        'Description': 'Warned after report #$_shortReport: $msg',
      });
      await _close('Resolved', 'Warned', msg, AppConstants.auditResolveReport,
          'The other user was given a warning.');
    });
  }

  Future<void> _suspend(String targetName) async {
    final done = await confirmAccountStatusChange(context,
        uid: r.targetId,
        role: r.targetRole,
        name: targetName,
        newStatus: accountSuspended,
        initialReason: '${r.category} (report #$_shortReport)');
    if (!done || !mounted) return;
    await _run(() => _close('Resolved', 'Suspended', 'Account suspended',
        AppConstants.auditResolveReport,
        'The other user\'s account was suspended.'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Parties>(
      future: _parties,
      builder: (context, snap) {
        final p = snap.data;
        final reporter = p?.reporterName ?? '...';
        final target = p?.targetName ?? '...';
        final targetBlocked = p != null && isAccountBlocked(p.targetStatus);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#RPT-$_shortReport',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(r.status.toUpperCase(),
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: _statusColor)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.category,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _line('Reported by: $reporter (${r.reporterRole})'),
                    _line('Against: $target (${r.targetRole})'
                        '${targetBlocked ? ' - account ${p.targetStatus.toLowerCase()}' : ''}'),
                    _line('Pickup: #$_shortBooking · ${formatDateTime(r.createdAt)}'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(r.description,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textPrimary)),
                    ),
                    if (r.isClosed) ...[
                      const SizedBox(height: 8),
                      _line('Outcome: ${r.adminAction == 'None' ? r.status : r.adminAction}'
                          '${r.adminNote.isEmpty ? '' : ' - ${r.adminNote}'}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!r.isClosed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (r.status == 'Open')
                        _btn('INVESTIGATE', AppColors.buyerBlue, _investigate),
                      _btn('RESOLVE', AppColors.success, _resolve, primary: true),
                      _btn('WARN', AppColors.warning, () => _warn(target)),
                      if (!targetBlocked)
                        _btn('SUSPEND', AppColors.error, () => _suspend(target)),
                      _btn('DISMISS', AppColors.textSecondary, _dismiss),
                    ],
                  ),
                )
              else
                const SizedBox(height: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      );

  Widget _btn(String label, Color color, VoidCallback onTap,
      {bool primary = false}) {
    final style = primary
        ? ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
        : ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.08),
            foregroundColor: color,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
    return ElevatedButton(
      style: style,
      onPressed: _busy ? null : onTap,
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
