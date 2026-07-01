import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/pickup_model.dart';
import '../common/market_price_card.dart';

/// Earnings transaction card for Buyer's history screen
class EarningsCard extends StatelessWidget {
  final PickupModel pickup;
  final double? distanceKm;

  const EarningsCard({super.key, required this.pickup, this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: date + distance
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy').format(pickup.scheduledAt),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              if (distanceKm != null)
                Text(
                  '${distanceKm!.toStringAsFixed(1)} km',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Middle: icon + scrap info + earnings
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sellerGreenSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    pickup.scrapTypeIcon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pickup.scrapType, style: AppTextStyles.titleMedium),
                    Text(
                      '${pickup.weightDisplay} · ${pickup.sellerName}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                pickup.valueDisplay,
                style: AppTextStyles.priceSmall,
              ),
            ],
          ),
          if (pickup.rating != null) ...[
            const SizedBox(height: 10),
            StarRating(rating: pickup.rating!),
          ],
        ],
      ),
    );
  }
}
