import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('Admin Panel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, size: 20, color: AppColors.textSecondary), tooltip: 'Log Out', onPressed: () => _confirmLogout(context)),
          const SizedBox(width: 4),
          Container(margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.adminRed.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.adminRed, letterSpacing: 1))),
        ],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        const SizedBox(height: 12),
        // Stat cards
        Row(children: [
          _Stat('342', 'Total Users', AppColors.textPrimary, onTap: () => Navigator.pushNamed(context, '/users')),
          const SizedBox(width: 10),
          _Stat('18', 'Active Pickups', AppColors.textPrimary),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _Stat('47', 'Today', AppColors.textPrimary),
          const SizedBox(width: 10),
          _Stat('5', 'Pending Verify', AppColors.adminRed, onTap: () => Navigator.pushNamed(context, '/verify')),
        ]),
        const SizedBox(height: 20),
        // Last 7 Days
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('LAST 7 DAYS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 14),
          _Bar('Pickups', 47, 50, '47/day', AppColors.buyerBlue),
          _Bar('New Users', 12, 30, '12/day', AppColors.buyerBlue),
          _Bar('Reports', 3, 20, '3/week', AppColors.buyerBlue),
          _Bar('Avg Rating', 4.6, 5.0, '4.6 ★', AppColors.star),
        ])),
        const SizedBox(height: 20),
        // Pending Verifications
        Row(children: [
          const Text('PENDING VERIFICATIONS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: const BoxDecoration(color: AppColors.adminRed, shape: BoxShape.circle), child: const Text('5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
        ]),
        const SizedBox(height: 10),
        _VerifyCard('Pedro Reyes', 'Tricycle · Barangay Maa', '2h ago'),
        _VerifyCard('Ana Lopez', 'Kariton · Barangay Ecoland', '5h ago'),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pushNamed(context, '/verify'), child: const Text('View all →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.buyerBlue))),
        ]),
        const SizedBox(height: 20),
        // User Complaints
        const Text('USER COMPLAINTS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 10),
        _ReportCard('#RPT-0018', 'Investigate', AppColors.warning, 'Collector no-show for #PKP-0035', 'Maria S. · June 29'),
        _ReportCard('#RPT-0017', 'Resolved', AppColors.success, 'Wrong items collected', 'Jose R. · June 28'),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pushNamed(context, '/reports'), child: const Text('View all →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.buyerBlue))),
        ]),
        const SizedBox(height: 20),
        // Transaction Monitoring
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TRANSACTION MONITORING', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 10),
          _Audit('admin@kilotap', 'verify_collector', 'Pedro Reyes', 'pending → verified', '2h ago'),
          const Divider(height: 12),
          _Audit('admin@kilotap', 'resolve_dispute', '#RPT-0017', 'investigate → resolved', '1d ago'),
          const Divider(height: 12),
          _Audit('system', 'suspend_user', 'User #A3X92', 'active → suspended', '2d ago'),
        ])),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String val, label;
  final Color color;
  final VoidCallback? onTap;
  const _Stat(this.val, this.label, this.color, {this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))]))));
}

class _Bar extends StatelessWidget {
  final String label, right;
  final double val, max;
  final Color color;
  const _Bar(this.label, this.val, this.max, this.right, this.color);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)), Text(right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))]), const SizedBox(height: 4), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val / max, backgroundColor: AppColors.inputGrey, valueColor: AlwaysStoppedAnimation(color), minHeight: 8))]));
}

class _VerifyCard extends StatelessWidget {
  final String name, detail, time;
  const _VerifyCard(this.name, this.detail, this.time);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)), const Spacer(), Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))]), Text(detail, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])),
    const SizedBox(width: 8),
    SizedBox(width: 70, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('APPROVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
    const SizedBox(width: 6),
    SizedBox(width: 70, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('REJECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
  ]));
}

class _ReportCard extends StatelessWidget {
  final String id, status, issue, detail;
  final Color color;
  const _ReportCard(this.id, this.status, this.color, this.issue, this.detail);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text(id, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)), child: Text(status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color)))]),
    const SizedBox(height: 4),
    Text(issue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    Text(detail, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
  ]));
}

class _Audit extends StatelessWidget {
  final String admin, action, target, change, time;
  const _Audit(this.admin, this.action, this.target, this.change, this.time);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$admin · $action', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      Text('$target: $change', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
    ])),
    Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
  ]));
}

void _confirmLogout(BuildContext context) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Log Out'),
    content: const Text('Are you sure you want to log out?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      TextButton(onPressed: () { AuthService.instance.signOut(); Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }, child: const Text('Log Out', style: TextStyle(color: AppColors.error))),
    ],
  ));
}
