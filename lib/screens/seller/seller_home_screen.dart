import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/market_price_model.dart';
import '../../models/pickup_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/common/market_price_card.dart';
import '../../widgets/seller/pickup_card.dart';

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final marketPrices = ref.watch(marketPricesProvider);
    final recentPickups = ref.watch(sellerPickupsProvider);

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Green header card
            _buildHeader(context, greeting, user?.displayName ?? 'Seller', user?.address ?? ''),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Market Prices
                    _buildMarketPricesSection(marketPrices),
                    const SizedBox(height: 24),
                    // Recent Pickups
                    _buildRecentPickupsSection(recentPickups),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader(BuildContext context, String greeting, String name, String address) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.sellerGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sellerGreenDark,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.pureWhite, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    Text(name,
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.pureWhite)),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.pureWhite),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.sellerGreenDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  address.isEmpty ? 'Tap to set location' : address,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Book a Pickup button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/book-pickup'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('BOOK A PICKUP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreenDark,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: AppTextStyles.buttonText.copyWith(letterSpacing: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMarketPricesSection(AsyncValue<List<MarketPriceModel>> marketPrices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Today's Market Prices", style: AppTextStyles.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sellerGreenSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: AppColors.sellerGreen, size: 14),
                  const SizedBox(width: 4),
                  Text('Live',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.sellerGreen)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        marketPrices.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildDefaultPricesGrid(),
          data: (prices) => prices.isEmpty
              ? _buildDefaultPricesGrid()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: prices.take(4).length,
                  itemBuilder: (_, i) => MarketPriceCard(price: prices[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildDefaultPricesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: MarketPriceModel.defaults.length,
      itemBuilder: (_, i) => MarketPriceCard(price: MarketPriceModel.defaults[i]),
    );
  }

  Widget _buildRecentPickupsSection(AsyncValue<List<PickupModel>> recentPickups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Pickups', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        recentPickups.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _buildEmptyPickups(),
          data: (pickups) => pickups.isEmpty
              ? _buildEmptyPickups()
              : Column(children: pickups.map((p) => PickupCard(pickup: p)).toList()),
        ),
      ],
    );
  }

  Widget _buildEmptyPickups() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(
            'No pickups yet. Book your first one!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.sellerGreen,
      unselectedItemColor: AppColors.navInactive,
      onTap: (i) {
        if (i == 1) context.push('/seller-history');
        if (i == 2) context.push('/seller-settings');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    );
  }
}
