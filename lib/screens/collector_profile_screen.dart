import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'collector/personal_info_page.dart';
import 'collector/vehicle_details_page.dart';
import 'collector/preferences_page.dart';
import 'collector/documents_page.dart';

class CollectorProfileScreen extends StatelessWidget {
  const CollectorProfileScreen({super.key});

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
          const Text('Manage your collector profile and vehicle details',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Personal Info',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CollectorPersonalInfoPage())),
            ),
            _MenuItem(
              icon: Icons.local_shipping_outlined,
              label: 'Vehicle Details',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VehicleDetailsPage())),
            ),
            _MenuItem(
              icon: Icons.category_outlined,
              label: 'Material Preferences',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PreferencesPage())),
            ),
            _MenuItem(
              icon: Icons.verified_outlined,
              label: 'Verification Documents',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DocumentsPage())),
            ),
            _MenuItem(
              icon: Icons.badge_outlined,
              label: 'Digital ID Card',
              onTap: () => Navigator.pushNamed(context, '/idcard'),
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
            _MenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              subtitle: 'FAQs and contact',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              subtitle: 'View our terms',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.logout,
              label: 'Log Out',
              isDestructive: true,
              onTap: () => _confirmLogout(context),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
          if (i == 1) Navigator.pushNamed(context, '/find');
          if (i == 2) Navigator.pushNamed(context, '/idcard');
          if (i == 3) Navigator.pushNamed(context, '/earnings');
        },
        selectedItemColor: AppColors.buyerBlue,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: 'ID'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Earn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

void _confirmLogout(BuildContext context) {
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

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle = '',
    this.onTap,
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
                  onTap: item.onTap,
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
