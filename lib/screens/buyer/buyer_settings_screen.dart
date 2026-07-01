import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class BuyerSettingsScreen extends ConsumerStatefulWidget {
  const BuyerSettingsScreen({super.key});

  @override
  ConsumerState<BuyerSettingsScreen> createState() => _BuyerSettingsScreenState();
}

class _BuyerSettingsScreenState extends ConsumerState<BuyerSettingsScreen> {
  Future<void> _showAddVehicleDialog(String uid) async {
    String? vehicleType = AppConstants.vehicleTypes.first;
    final modelCtrl = TextEditingController();
    final plateCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: vehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle Type'),
              items: AppConstants.vehicleTypes.map((t) =>
                  DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => vehicleType = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(labelText: 'Model (e.g. Honda TMX 125)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              decoration: const InputDecoration(labelText: 'Plate Number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (modelCtrl.text.isNotEmpty && plateCtrl.text.isNotEmpty) {
                final vehicle = VehicleInfo(
                  type: vehicleType!,
                  model: modelCtrl.text,
                  plateNumber: plateCtrl.text,
                );
                await ref.read(firestoreServiceProvider).addVehicle(uid, vehicle);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Profile Card with Verified badge
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.displayName ?? 'Mang Pedro',
                              style: AppTextStyles.titleLarge,
                            ),
                            const SizedBox(width: 8),
                            if (user?.isVerified ?? true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.sellerGreenSurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, size: 12, color: AppColors.sellerGreen),
                                    const SizedBox(width: 3),
                                    Text('Verified',
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.sellerGreen)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Text(
                          user?.phone ?? '+63 917 xxx xxxx',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Digital ID Card
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: AppColors.pureWhite, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('View Digital ID',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.pureWhite)),
                          Text('Show to verify your identity',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.pureWhite),
                  ],
                ),
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
                _infoRow(Icons.person_outline, 'Full Name', user?.displayName ?? 'Mang Pedro'),
                _infoRow(Icons.mail_outline, 'Email', user?.email ?? 'pedro@email.com'),
                _infoRow(Icons.phone_outlined, 'Phone Number', user?.phone ?? '+63 917 xxx xxxx'),
                _infoRow(Icons.map_outlined, 'Area of Operation',
                    user?.areaOfOperation ?? 'Quezon City, Metro Manila'),
              ],
            ),
            const SizedBox(height: 20),

            // My Vehicles
            _buildSection(
              title: 'My Vehicles',
              action: TextButton.icon(
                onPressed: () => _showAddVehicleDialog(user?.uid ?? ''),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
              children: [
                if ((user?.vehicles ?? []).isEmpty)
                  _buildVehicleRow(
                    Icons.local_shipping_rounded,
                    'Tricycle',
                    'Honda TMX 125 · ABC 1234',
                    onDelete: () {},
                  )
                else
                  ...((user?.vehicles ?? []).map((v) => _buildVehicleRow(
                        Icons.local_shipping_rounded,
                        v.type,
                        '${v.model} · ${v.plateNumber}',
                        onDelete: () async {
                          await ref.read(firestoreServiceProvider).removeVehicle(user!.uid, v);
                        },
                      ))),
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
        selectedItemColor: AppColors.buyerBlue,
        unselectedItemColor: AppColors.navInactive,
        onTap: (i) {
          if (i == 0) context.go('/buyer-home');
          if (i == 1) context.push('/buyer-history');
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 6),
        const Divider(height: 1),
      ]),
    );
  }

  Widget _buildVehicleRow(IconData icon, String type, String detail, {required VoidCallback onDelete}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.sellerGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(type, style: AppTextStyles.labelLarge),
              Text(detail, style: AppTextStyles.bodySmall),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
