import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CollectorProfileScreen extends StatelessWidget {
  const CollectorProfileScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 30),
        // Profile header
        const Center(child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: AppColors.buyerBlue, child: Text('JD', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900))),
          SizedBox(height: 8),
          Text('Juan Dela Cruz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          _Badge('VERIFIED since June 2026'),
          SizedBox(height: 4),
          Text('★★★★☆ 4.8 (42 ratings)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.star)),
        ])),
        const SizedBox(height: 30),
        // Personal Info
        _Section('PERSONAL INFO', [
          ('Phone', '+63927XXXXXXX'),
          ('Vehicle', 'Tricycle'),
          ('Years Collecting', '5'),
          ('Areas', 'Maa, Matina, Ecoland'),
          ('Languages', 'Bisaya, Tagalog'),
        ]),
        // Verification Documents
        const Text('VERIFICATION DOCUMENTS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: const Column(children: [
            _DocRow('Barangay Clearance'),
            _DocRow('Valid Government ID'),
            _DocRow('Vehicle Photo'),
            _DocRow('Profile Photo Match'),
          ]),
        ),
        const SizedBox(height: 16),
        // Statistics
        _Section('STATISTICS', [
          ('Total Pickups', '184'),
          ('Total Weight', '2,145 kg'),
          ('Avg. Rating', '★ 4.8'),
          ('Response Rate', '94%'),
          ('Cancellation Rate', '2%'),
        ]),
        const SizedBox(height: 16),
        // Availability
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('AVAILABILITY', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Container(width: 48, height: 26, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(13)), child: Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.only(right: 2), width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))),
            ]),
            const SizedBox(height: 12),
            _AvailRow('Status', '● ONLINE', Colors.green),
            _AvailRow('Active Hours', '7AM - 5PM', null),
            _AvailRow('Max Distance', '5 km', null),
            _AvailRow('Max Load/Day', '200 kg', null),
          ]),
        ),
        const SizedBox(height: 20),
        // Log Out — neutral, at bottom
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () => _confirmLogout(context),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, size: 16), SizedBox(width: 8), Text('Log Out')]),
        ),
        const SizedBox(height: 8),
        // Delete
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {},
          child: const Text('Delete Account'),
        ),
        const SizedBox(height: 30),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, selectedItemColor: AppColors.buyerBlue, unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID Card'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Earn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
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

class _Badge extends StatelessWidget {
  final String text; const _Badge(this.text);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)));
}

class _Section extends StatelessWidget {
  final String title; final List<(String, String)> rows;
  const _Section(this.title, this.rows);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Column(children: rows.asMap().entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: e.key < rows.length - 1 ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))) : null,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.value.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(e.value.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
        )).toList()),
      ),
    ]),
  );
}

class _DocRow extends StatelessWidget {
  final String label; const _DocRow(this.label);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
    child: Row(children: [
      Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(Icons.check, size: 12, color: Colors.white)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary))),
      const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.buyerBlue)),
    ]),
  );
}

class _AvailRow extends StatelessWidget {
  final String label, value; final Color? valueColor;
  const _AvailRow(this.label, this.value, this.valueColor);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
    ]),
  );
}
