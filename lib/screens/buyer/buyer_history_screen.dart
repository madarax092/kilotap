import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/buyer_provider.dart';
import '../../widgets/buyer/earnings_card.dart';
import '../../widgets/common/market_price_card.dart';

class BuyerHistoryScreen extends ConsumerWidget {
  const BuyerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(buyerEarningsHistoryProvider);
    final totalEarnings = ref.watch(buyerTotalEarningsProvider);

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      appBar: AppBar(
        title: const Text('Earnings History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Total earnings banner (dark)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Earnings',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
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
                      itemBuilder: (_, i) => EarningsCard(
                        pickup: pickups[i],
                        distanceKm: [0.8, 2.1, 0.5][i % 3],
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.buyerBlue,
        unselectedItemColor: AppColors.navInactive,
        onTap: (i) {
          if (i == 0) context.go('/buyer-home');
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

  Widget _buildMockHistory() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: const [
        _MockEarningsCard(
          date: 'Mar 15, 2026',
          scrap: 'Plastic, Metal',
          icon: '♻️',
          weight: '7.5 kg',
          seller: 'Juan D.',
          amount: '₱185.00',
          rating: 5,
          distanceKm: 0.8,
        ),
        _MockEarningsCard(
          date: 'Mar 14, 2026',
          scrap: 'Appliances',
          icon: '🔌',
          weight: '12 kg',
          seller: 'Maria S.',
          amount: '₱320.00',
          rating: 4,
          distanceKm: 2.1,
        ),
        _MockEarningsCard(
          date: 'Mar 13, 2026',
          scrap: 'Mixed Scrap',
          icon: '📦',
          weight: '3 kg',
          seller: 'Pedro R.',
          amount: '₱45.00',
          rating: 5,
          distanceKm: 0.5,
        ),
      ],
    );
  }
}

class _MockEarningsCard extends StatelessWidget {
  final String date;
  final String scrap;
  final String icon;
  final String weight;
  final String seller;
  final String amount;
  final int rating;
  final double distanceKm;

  const _MockEarningsCard({
    required this.date,
    required this.scrap,
    required this.icon,
    required this.weight,
    required this.seller,
    required this.amount,
    required this.rating,
    required this.distanceKm,
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
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(date, style: AppTextStyles.caption),
              const Spacer(),
              Text('${distanceKm.toStringAsFixed(1)} km', style: AppTextStyles.caption),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(scrap, style: AppTextStyles.titleMedium),
                  Text('$weight · $seller', style: AppTextStyles.caption),
                ]),
              ),
              Text(amount, style: AppTextStyles.priceSmall),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < rating ? AppColors.starActive : AppColors.starInactive,
            size: 16,
          ))),
        ],
      ),
    );
  }
}
