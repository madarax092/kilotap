import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'household/personal_info_page.dart';
import 'household/pickup_prefs_page.dart';
import 'household/impact_page.dart';

class HouseholdProfileScreen extends StatelessWidget {
  const HouseholdProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          // Account section
          const Text('Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Update your info to keep your account secure',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _MenuCard(items: [
            const _MenuItem(
              icon: Icons.person_outline,
              label: 'Personal Info',
              onTap: null,
              navigateTo: HouseholdPersonalInfoPage(),
            ),
            const _MenuItem(
              icon: Icons.schedule_outlined,
              label: 'Pickup Preferences',
              onTap: null,
              navigateTo: PickupPrefsPage(),
            ),
            const _MenuItem(
              icon: Icons.eco_outlined,
              label: 'Recycling Impact',
              onTap: null,
              navigateTo: ImpactPage(),
            ),
          ]),
          const SizedBox(height: 28),
          // Support section
          const Text('Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Help resources and account actions',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _MenuCard(items: [
            const _MenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              subtitle: 'FAQs and contact',
            ),
            const _MenuItem(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              subtitle: 'View our terms',
            ),
            _MenuItem(
              icon: Icons.logout,
              label: 'Log Out',
              isDestructive: true,
              onTap: () => HouseholdProfileScreen.confirmLogout(context),
            ),
          ]),
          const SizedBox(height: 40),
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
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
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
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? navigateTo;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle = '',
    this.onTap,
    this.navigateTo,
    this.isDestructive = false,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(14),
      child: Column(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Icon(item.icon,
                      color: item.isDestructive ? AppColors.error : AppColors.textSecondary, size: 22),
                  title: Text(item.label,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: item.isDestructive ? AppColors.error : AppColors.textPrimary)),
                  subtitle: item.subtitle.isNotEmpty
                      ? Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                      : null,
                  trailing: Icon(Icons.chevron_right,
                      color: item.isDestructive ? AppColors.error : AppColors.textMuted, size: 20),
                  onTap: item.onTap ?? (item.navigateTo != null
                      ? () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => item.navigateTo!))
                      : null),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16),
              ],
            );
          }).toList(),
      ),
    );
  }
}
