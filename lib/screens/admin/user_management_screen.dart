import 'package:flutter/material.dart';
import '../../widgets/empty_section_text.dart';
import '../../core/account_status.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.listUsers(),
        builder: (context, snapshot) {
          final allUsers = snapshot.data ?? const <Map<String, dynamic>>[];
          final filtered = allUsers.where((u) {
            final role = u['Role'] as String? ?? '';
            if (_filter == 'Households') return role == 'Household';
            if (_filter == 'Collectors') {
              return role == 'Collector' || role == 'VerifiedCollector';
            }
            if (_filter == 'Restricted') {
              return isAccountBlocked(accountStatusOf(u));
            }
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
                        Text('Users (${allUsers.length})',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Tap a user to suspend, close or reactivate',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _Chip('All', _filter == 'All', AppColors.buyerBlue,
                            () => setState(() => _filter = 'All')),
                        _Chip('Households', _filter == 'Households',
                            AppColors.sellerGreen,
                            () => setState(() => _filter = 'Households')),
                        _Chip('Collectors', _filter == 'Collectors',
                            AppColors.buyerBlue,
                            () => setState(() => _filter = 'Collectors')),
                        _Chip('Restricted', _filter == 'Restricted',
                            AppColors.error,
                            () => setState(() => _filter = 'Restricted')),
                      ]))),
              Expanded(
                child: !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const EmptySectionText('No users found.',
                            centered: true)
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: [
                              ...filtered.map((u) => _URow(
                                  user: u,
                                  svc: firestoreService,
                                  onTap: () => _openActions(u))),
                              const SizedBox(height: 30),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(current: 4),
    );
  }

  // Suspend / close / reactivate. Admin accounts (including your own) are
  // never offered here.
  Future<void> _openActions(Map<String, dynamic> u) async {
    final uid = u['uid'] as String;
    final role = _baseRole(u['Role'] as String? ?? '');
    final name = (u['Display_Name'] as String?) ?? 'Unknown';
    if (role == AppConstants.roleAdmin || uid == AuthState.instance.uid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Admin accounts cannot be suspended or closed here.')));
      return;
    }
    final status = accountStatusOf(u);
    final reason = (u['Status_Reason'] as String?) ?? '';

    final chosen = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$role · account ${status.toLowerCase()}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (isAccountBlocked(status) && reason.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Reason: $reason',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: Column(children: [
                    if (status != accountActive)
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline,
                            color: AppColors.success),
                        title: const Text('Reactivate account'),
                        subtitle: const Text('The user can sign in again.'),
                        onTap: () => Navigator.pop(sheet, accountActive),
                      ),
                    if (status == accountActive)
                      ListTile(
                        leading: const Icon(Icons.pause_circle_outline,
                            color: AppColors.warning),
                        title: const Text('Suspend account'),
                        subtitle: const Text(
                            'Temporary. Blocks sign-in and all activity.'),
                        onTap: () => Navigator.pop(sheet, accountSuspended),
                      ),
                    if (status != accountClosed)
                      ListTile(
                        leading: const Icon(Icons.block, color: AppColors.error),
                        title: const Text('Close account'),
                        subtitle: const Text(
                            'Ends the account. History is kept; it can be '
                            'reactivated later.'),
                        onTap: () => Navigator.pop(sheet, accountClosed),
                      ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    await confirmAccountStatusChange(context,
        uid: uid, role: role, name: name, newStatus: chosen);
  }

  String _baseRole(String role) =>
      role == 'VerifiedCollector' ? AppConstants.roleCollector : role;
}

/// Asks for a reason (required to suspend or close), applies the change and
/// reports what happened. Shared with the Reports screen.
Future<bool> confirmAccountStatusChange(
  BuildContext context, {
  required String uid,
  required String role,
  required String name,
  required String newStatus,
  String initialReason = '',
}) async {
  final reasonCtrl = TextEditingController(text: initialReason);
  final needsReason = newStatus != accountActive;
  final title = newStatus == accountActive
      ? 'Reactivate $name?'
      : newStatus == accountClosed
          ? 'Close $name\'s account?'
          : 'Suspend $name?';
  final consequence = newStatus == accountActive
      ? 'They will be able to sign in and use KiloTap again.'
      : role == AppConstants.roleCollector
          ? 'They are signed out at once and cannot sign in. Pickups they '
              'accepted go back to Pending for other collectors.'
          : 'They are signed out at once and cannot sign in. Their open '
              'pickup requests are cancelled.';
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      String? error;
      return StatefulBuilder(builder: (ctx, setLocal) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(consequence, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: needsReason ? 'Reason (shown to the user)' : 'Note (optional)',
                  border: const OutlineInputBorder(),
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (needsReason && reasonCtrl.text.trim().length < 5) {
                  setLocal(() => error = 'Give a short reason.');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: Text(
                  newStatus == accountActive
                      ? 'Reactivate'
                      : newStatus == accountClosed
                          ? 'Close account'
                          : 'Suspend',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: newStatus == accountActive
                          ? AppColors.success
                          : AppColors.error)),
            ),
          ],
        );
      });
    },
  );
  if (ok != true || !context.mounted) {
    reasonCtrl.dispose();
    return false;
  }
  final messenger = ScaffoldMessenger.of(context);
  try {
    final summary = await FirestoreService().setAccountStatus(
        uid: uid, role: role, status: newStatus, reason: reasonCtrl.text);
    messenger.showSnackBar(SnackBar(content: Text(summary)));
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
    return false;
  } finally {
    reasonCtrl.dispose();
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip(this.label, this.active, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: active ? color : AppColors.inputGrey,
              borderRadius: BorderRadius.circular(16)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textSecondary))));
}

class _URow extends StatelessWidget {
  final Map<String, dynamic> user;
  final FirestoreService svc;
  final VoidCallback onTap;
  const _URow({required this.user, required this.svc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uid = user['uid'] as String;
    final name = (user['Display_Name'] as String?) ?? 'Unknown';
    final role = (user['Role'] as String?) ?? '';
    final isCollector = role == 'Collector' || role == 'VerifiedCollector';
    final isAdmin = role == AppConstants.roleAdmin;
    final status = accountStatusOf(user);
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase()
        : '?';
    final avatarColor = isAdmin
        ? AppColors.adminRed
        : isCollector
            ? AppColors.buyerBlue
            : AppColors.sellerGreen;

    Widget row({String badge = 'ACTIVE', Color badgeColor = AppColors.success, String? stars}) {
      // A suspended or closed account shows that instead of its usual badge.
      if (status == accountSuspended) {
        badge = 'SUSPENDED';
        badgeColor = AppColors.error;
      } else if (status == accountClosed) {
        badge = 'CLOSED';
        badgeColor = AppColors.textSecondary;
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider)),
            child: Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
                  child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(isAdmin ? 'Admin' : (isCollector ? 'Collector' : 'Household'),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ])),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(badge,
                      style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w700, color: badgeColor))),
              if (stars != null) ...[
                const SizedBox(width: 8),
                Text(stars,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.star)),
              ],
            ]),
          ),
        ),
      );
    }

    if (!isCollector) return row();

    return FutureBuilder<Map<String, dynamic>?>(
      future: svc.collectorProfile(uid),
      builder: (context, snapshot) {
        final vStatus = (snapshot.data?['Verification_Status'] as String?) ?? 'Pending';
        final rating = (snapshot.data?['Avg_Rating'] as num?)?.toDouble() ?? 0;
        final badgeColor = vStatus == 'Verified'
            ? AppColors.success
            : vStatus == 'Rejected'
                ? AppColors.error
                : AppColors.warning;
        return row(
            badge: vStatus.toUpperCase(),
            badgeColor: badgeColor,
            stars: rating > 0 ? '★${rating.toStringAsFixed(1)}' : null);
      },
    );
  }
}
