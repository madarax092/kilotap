import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        title: const Text('Admin Panel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary), tooltip: 'Log Out', onPressed: () => _confirmLogout(context)),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: const Text('ADMIN', style: TextStyle(fontSize: 9, color: AppColors.error, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 8),
        Row(children: [
          _StatCard(label: 'Total Users', value: '342', warn: false),
          const SizedBox(width: 10),
          _StatCard(label: 'Active Pickups', value: '18', warn: false),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatCard(label: 'Today', value: '47', warn: false),
          const SizedBox(width: 10),
          _StatCard(label: 'Pending Verify', value: '5', warn: true),
        ]),
        const SizedBox(height: 20),
        // Quick stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LAST 7 DAYS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 10),
            _Bar(label: 'Pickups', value: '47/day', pct: 0.82, color: AppColors.buyerBlue),
            _Bar(label: 'New Users', value: '12/day', pct: 0.45, color: AppColors.buyerBlue),
            _Bar(label: 'Reports', value: '3/week', pct: 0.18, color: AppColors.buyerBlue),
            _Bar(label: 'Avg Rating', value: '4.6 ★', pct: 0.92, color: AppColors.star),
          ]),
        ),
        const SizedBox(height: 20),
        // Pending verifications
        Row(children: [
          const Text('PENDING VERIFICATIONS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(10)), child: const Text('5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
        ]),
        const SizedBox(height: 8),
        _PendingCard(name: 'Pedro Reyes', time: '2h ago', info: 'Tricycle · Barangay Maa'),
        _PendingCard(name: 'Ana Lopez', time: '5h ago', info: 'Kariton · Barangay Ecoland'),
        const SizedBox(height: 20),
        const Text('RECENT REPORTS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        _ReportCard(id: '#RPT-0018', desc: 'Collector no-show for #PKP-0035', meta: 'Maria S. · June 29', status: 'INVESTIGATE', urgent: true),
        _ReportCard(id: '#RPT-0017', desc: 'Wrong items in #PKP-0032', meta: 'Jose R. · June 28', status: 'RESOLVED', urgent: false),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final bool warn;
  const _StatCard({required this.label, required this.value, required this.warn});
  @override Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: warn ? AppColors.warning : AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label, value; final double pct; final Color color;
  const _Bar({required this.label, required this.value, required this.pct, required this.color});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.inputGrey, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6)),
      ]),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final String name, time, info;
  const _PendingCard({required this.name, required this.time, required this.info});
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 4),
        Text(info, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('APPROVE', style: TextStyle(fontSize: 11)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('REJECT', style: TextStyle(fontSize: 11)))),
        ]),
      ]),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String id, desc, meta, status; final bool urgent;
  const _ReportCard({required this.id, required this.desc, required this.meta, required this.status, required this.urgent});
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: urgent ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: urgent ? AppColors.warning : AppColors.success))),
 ]),
 );
 }
 }

 void _confirmLogout(BuildContext context) {
 showDialog(context: context, builder: (ctx) => AlertDialog(
 title: const Text('Log Out'),
 content: const Text('Are you sure you want to log out?'),
 actions: [
 TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
 TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false), child: const Text('Log Out', style: TextStyle(color: AppColors.error))),
 ],
 ));
 }
