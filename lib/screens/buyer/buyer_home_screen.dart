import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/buyer_provider.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(buyerIsOnlineProvider);
    final todayEarnings = ref.watch(buyerTodayEarningsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Dark header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2B35),
              ),
              child: Row(
                children: [
                  // Earnings
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Earnings",
                              style: AppTextStyles.caption.copyWith(color: Colors.white54),
                            ),
                            todayEarnings.when(
                              loading: () => Text('₱0.00',
                                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                              error: (_, __) => Text('₱0.00',
                                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                              data: (amount) => Text(
                                '₱${amount.toStringAsFixed(2)}',
                                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Online / Offline toggle
                  GestureDetector(
                    onTap: () => ref.read(buyerIsOnlineProvider.notifier).state = !isOnline,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.buyerBlue.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOnline ? AppColors.buyerBlue : Colors.white30,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline ? AppColors.sellerGreen : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isOnline ? AppColors.buyerBlue : Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Map area / empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sellerGreenSurface,
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.sellerGreen,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isOnline
                          ? 'Waiting for pickup requests...'
                          : 'Go online to start receiving\npickup requests',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isOnline) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () =>
                              ref.read(buyerIsOnlineProvider.notifier).state = true,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buyerBlue,
                            foregroundColor: AppColors.pureWhite,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Go Online', style: AppTextStyles.buttonText),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Location status
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    user?.areaOfOperation ?? 'Quezon City, Metro Manila',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.buyerBlue,
        unselectedItemColor: AppColors.navInactive,
        onTap: (i) {
          if (i == 1) context.push('/buyer-history');
          if (i == 2) context.push('/buyer-settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
