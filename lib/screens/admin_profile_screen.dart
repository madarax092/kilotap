import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import 'help_support_screen.dart';
import 'terms_service_screen.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(children: [
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.only(top: top + 24, left: 24, right: 24, bottom: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border:
                Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB), shape: BoxShape.circle),
                child: const Center(
                    child:
                        Icon(Icons.admin_panel_settings, color: AppColors.adminRed, size: 33)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Super Admin',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    SizedBox(height: 2),
                    Text('admin@kilotap.com',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              const Text('System Management',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Manage platform settings and users',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              _MenuCard(items: [
                _MenuItem(
                  icon: Icons.people_outline,
                  label: 'User Management',
                  subtitle: 'Manage all accounts',
                  onTap: () => Navigator.pushNamed(context, '/users'),
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'System Settings',
                  subtitle: 'Global configurations',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 28),
              const Text('Support & Session',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Help resources and account actions',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              _MenuCard(items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  subtitle: 'FAQs and contact',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen(isCollector: false))),
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  subtitle: 'View our terms',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsServiceScreen())),
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
      ]),
      bottomNavigationBar: const AdminBottomNav(current: 4),
    );
  }
}

void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
      content: const Text('Are you sure you want to log out?', style: TextStyle(color: Color(0xFF4B5563))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280)))
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          onPressed: () {
            AuthService.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
          },
          child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700))
        ),
      ],
    )
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
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: item.isDestructive
                        ? AppColors.error
                        : AppColors.textSecondary,
                    size: 22),
                title: Text(item.label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary)),
                subtitle: item.subtitle.isNotEmpty
                    ? Text(item.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))
                    : null,
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 20),
                onTap: item.onTap,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
