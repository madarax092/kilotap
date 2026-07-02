import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class HouseholdProfileScreen extends StatelessWidget {
  const HouseholdProfileScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
      const SizedBox(height: 30),
      const Center(child: Column(children: [CircleAvatar(radius: 40, backgroundColor: AppColors.sellerGreen, child: Text('MS', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900))), SizedBox(height: 12), Text('Maria Santos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), Text('Barangay Maa, Davao City \u00b7 Member since Feb 2026', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))])),
      const SizedBox(height: 30),
      _Section('PERSONAL INFO', [('Full Name', 'Maria Santos'), ('Phone', '+63917XXXXXXX'), ('Email', 'maria@email.com'), ('Address', 'Block 5, Lot 12, Maa'), ('Housing', 'House')]),
      _Section('PREFERENCES', [('Default Pickup', 'ASAP'), ('Preferred Time', 'Morning 8-12PM'), ('Notifications', 'Push + SMS'), ('Language', 'Bisaya / English')]),
      _Section('STATISTICS', [('Total Pickups', '16', accent: true), ('Total Weight', '87.3 kg', accent: true), ('Favorite Collector', 'Juan (6 pickups)'), ('Carbon Saved', '~42 kg CO2e')]),
      const SizedBox(height: 20),
      OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () {}, child: const Text('Delete Account')),
      const SizedBox(height: 30),
    ]),
    bottomNavigationBar: BottomNavigationBar(currentIndex: 3, selectedItemColor: AppColors.sellerGreen, unselectedItemColor: AppColors.textMuted, backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sell'), BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pickups'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')]),
  );
}

class _Section extends StatelessWidget {
  final String title; final List<(String, String, {bool accent})> rows;
  _Section(this.title, List<(String, String)> r) : rows = r.map((e) => (e.$1, e.$2, accent: false)).toList();
  _Section.accent(this.title, this.rows);
  const _Section(String t, List fields, {bool accent = false}) : title = t, rows = fields is List<(String, String, {bool accent})> ? fields : [];
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 8),
      Container(decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Column(children: rows.asMap().entries.map((e) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: e.key < rows.length - 1 ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))) : null, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.value.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)), Text(e.value.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: (e.value is ({bool accent}) && (e.value as dynamic).accent == true) ? AppColors.sellerGreen : AppColors.textPrimary))]))).toList())),
    ]),
  );
}
