import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SellerSettingsScreen extends ConsumerWidget {
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.sellerGreenSurface,
                        child: const Icon(Icons.person_rounded, size: 36, color: AppColors.sellerGreen),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.sellerGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 13, color: AppColors.pureWhite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Juan Dela Cruz',
                        style: AppTextStyles.titleLarge,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            user?.accountTypeLabel ?? 'Individual / Household',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Personal Information
            _buildSection(
              title: 'Personal Information',
              action: TextButton(
                onPressed: () {},
                child: Text('Edit', style: AppTextStyles.labelMedium.copyWith(color: AppColors.sellerGreen)),
              ),
              children: [
                _buildInfoRow(Icons.person_outline, 'Full Name', user?.displayName ?? 'Juan Dela Cruz'),
                _buildInfoRow(Icons.mail_outline, 'Email', user?.email ?? 'juan@email.com'),
                _buildInfoRow(Icons.phone_outlined, 'Phone Number', user?.phone ?? '+63 917 xxx xxxx'),
                _buildInfoRow(Icons.location_on_outlined, 'Address', user?.address ?? '123 Rizal Ave, Quezon City'),
              ],
            ),
            const SizedBox(height: 20),

            // Preferences
            _buildSection(
              title: 'Preferences',
              children: [
                _buildNavRow(Icons.notifications_outlined, 'Notifications', () {}),
                _buildNavRow(Icons.language_rounded, 'Language', () {}, trailing: 'English'),
              ],
            ),
            const SizedBox(height: 20),

            // Log Out
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Log Out', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go('/');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text('Log Out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: AppColors.navInactive,
        onTap: (i) {
          if (i == 0) context.go('/seller-home');
          if (i == 1) context.push('/seller-history');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, Widget? action, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const Spacer(),
                if (action != null) action,
              ],
            ),
          ),
          const Divider(height: 16),
          ...children.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: c)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String label, VoidCallback onTap, {String? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            if (trailing != null)
              Text(trailing, style: AppTextStyles.bodySmall),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
