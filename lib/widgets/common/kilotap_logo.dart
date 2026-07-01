import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// KiloTap logo widget — circular green recycling icon
class KiloTapLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const KiloTapLogo({
    super.key,
    this.size = 80,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sellerGreenSurface,
            border: Border.all(color: AppColors.sellerGreen.withOpacity(0.2), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Recycling arrows ring
              Icon(
                Icons.autorenew_rounded,
                color: AppColors.sellerGreen,
                size: size * 0.55,
              ),
              // House/building in center
              Icon(
                Icons.home_rounded,
                color: AppColors.sellerGreen,
                size: size * 0.28,
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'KiloTap',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ],
    );
  }
}
