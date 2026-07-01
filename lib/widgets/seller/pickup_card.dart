import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/pickup_model.dart';
import '../common/market_price_card.dart';

/// Pickup history card for Seller's booking history screen
class PickupCard extends StatelessWidget {
  final PickupModel pickup;
  final VoidCallback? onTap;

  const PickupCard({super.key, required this.pickup, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Top row: date + status badge
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
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 10),
            // Middle row: scrap icon + name + buyer + price
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
                      Text(
                        pickup.scrapType,
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        '${pickup.weightDisplay} · ${pickup.buyerName ?? 'Unassigned'}',
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
            // Rating if available
            if (pickup.rating != null) ...[
              const SizedBox(height: 10),
              StarRating(rating: pickup.rating!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (pickup.status) {
      case PickupStatus.completed:
        return StatusBadge.completed();
      case PickupStatus.pending:
        return StatusBadge.pending();
      case PickupStatus.cancelled:
        return StatusBadge.cancelled();
      default:
        return StatusBadge(
          label: pickup.statusLabel,
          color: AppColors.buyerBlue,
          bgColor: AppColors.buyerBlueSurface,
        );
    }
  }
}
