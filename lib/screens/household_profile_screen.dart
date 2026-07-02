import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class HouseholdProfileScreen extends StatelessWidget {
  const HouseholdProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 30),
          const Center(
            child: Column(children: [
              CircleAvatar(radius: 40, backgroundColor: AppColors.sellerGreen, child: Text('MS', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900))),
              SizedBox(height: 12),
              Text('Maria Santos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Barangay Maa, Davao City \u00b7 Member since Feb 2026', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 30),
          _buildSection('PERSONAL INFO', [('Full Name', 'Maria Santos'), ('Phone', '+63917XXXXXXX'), ('Email', 'maria@email.com'), ('Address', 'Block 5, Lot 12, Maa'), ('Housing', 'House')]),
          _buildSection('PREFERENCES', [('Default Pickup', 'ASAP'), ('Preferred Time', 'Morning 8-12PM'), ('Notifications', 'Push + SMS'), ('Language', 'Bisaya / English')]),
          _buildSection('STATISTICS', [('Total Pickups', '16'), ('Total Weight', '87.3 kg'), ('Favorite Collector', 'Juan (6 pickups)'), ('Carbon Saved', '~42 kg CO2e')]),
          const SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => HouseholdProfileScreen.confirmLogout(context),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, size: 16), SizedBox(width: 8), Text('Log Out')]),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {},
            child: const Text('Delete Account'),
          ),
          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/household');
          if (i == 1) Navigator.pushNamed(context, '/sell');
          if (i == 2) Navigator.pushNamed(context, '/pickups');
        },
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pickups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  static void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              AuthService.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  static Widget _buildSection(String title, List<(String, String)> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: Column(
            children: rows.asMap().entries.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: e.key < rows.length - 1 ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))) : null,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.value.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(e.value.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ]),
            )).toList(),
          ),
        ),
      ]),
    );
  }
}
