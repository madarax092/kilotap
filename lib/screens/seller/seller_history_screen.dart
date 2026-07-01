import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/pickup_model.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/seller/pickup_card.dart';
import '../../widgets/common/market_price_card.dart';

class SellerHistoryScreen extends ConsumerWidget {
  const SellerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(sellerPickupHistoryProvider);
    final totalEarnings = ref.watch(sellerTotalEarningsProvider);

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      appBar: AppBar(
        title: const Text('Booking History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Total earnings banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sellerGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.pureWhite),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Earnings',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    Text(
                      '₱${totalEarnings.toStringAsFixed(2)}',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.pureWhite),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildMockHistory(),
              data: (pickups) => pickups.isEmpty
                  ? _buildMockHistory()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: pickups.length,
                      itemBuilder: (_, i) => PickupCard(pickup: pickups[i]),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: AppColors.navInactive,
        onTap: (i) {
          if (i == 0) context.go('/seller-home');
          if (i == 2) context.push('/seller-settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMockHistory() {
    // Demo data for prototype
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: const [
        _MockPickupCard(
          date: 'Mar 15, 2026',
          scrap: 'Plastic, Metal',
          icon: '♻️',
          weight: '7.5 kg',
          buyer: 'Mang Pedro',
          amount: '₱185.00',
          rating: 5,
        ),
        _MockPickupCard(
          date: 'Mar 10, 2026',
          scrap: 'Appliances',
          icon: '🔌',
          weight: '12 kg',
          buyer: 'Kuya Roel',
          amount: '₱320.00',
          rating: 4,
        ),
        _MockPickupCard(
          date: 'Mar 5, 2026',
          scrap: 'Mixed Scrap',
          icon: '📦',
          weight: '3 kg',
          buyer: 'Mang Enteng',
          amount: '₱45.00',
          rating: 5,
        ),
      ],
    );
  }
}

class _MockPickupCard extends StatelessWidget {
  final String date;
  final String scrap;
  final String icon;
  final String weight;
  final String buyer;
  final String amount;
  final int rating;

  const _MockPickupCard({
    required this.date,
    required this.scrap,
    required this.icon,
    required this.weight,
    required this.buyer,
    required this.amount,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(date, style: AppTextStyles.caption),
              const Spacer(),
              StatusBadge.completed(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.sellerGreenSurface, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scrap, style: AppTextStyles.titleMedium),
                    Text('$weight · $buyer', style: AppTextStyles.caption),
                  ],
                ),
              ),
              Text(amount, style: AppTextStyles.priceSmall),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < rating ? AppColors.starActive : AppColors.starInactive,
              size: 16,
            )),
          ),
        ],
      ),
    );
  }
}
