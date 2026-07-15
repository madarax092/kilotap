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
      backgroundColor: AppColors.canvas,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            // ── Blue header band ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.buyerBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Juan Dela Cruz · Tricycle Operator',
                      style: TextStyle(fontSize: 13, color: Color(0xFF90CAF9))),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
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
                      onTap: () => _confirmLogout(context),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -1))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              currentIndex: 4,
              onTap: (i) {
                if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
                if (i == 1) Navigator.pushNamed(context, '/find');
                if (i == 2) Navigator.pushNamed(context, '/idcard');
                if (i == 3) Navigator.pushNamed(context, '/earnings');
              },
              selectedItemColor: AppColors.buyerBlue,
              unselectedItemColor: const Color(0xFFBBBBBB),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Find'),
                BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'ID'),
                BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Earn'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
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
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
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
