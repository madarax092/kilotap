import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Primary branded button for KiloTap
class KiloTapButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final String? subtitle;
  final bool isLoading;
  final double height;
  final bool outlined;

  const KiloTapButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.subtitle,
    this.isLoading = false,
    this.height = 52,
    this.outlined = false,
  });

  const KiloTapButton.seller({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.subtitle,
    this.isLoading = false,
    this.height = 64,
  })  : backgroundColor = AppColors.sellerGreen,
        foregroundColor = AppColors.pureWhite,
        outlined = false;

  const KiloTapButton.buyer({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.subtitle,
    this.isLoading = false,
    this.height = 64,
  })  : backgroundColor = AppColors.buyerBlue,
        foregroundColor = AppColors.pureWhite,
        outlined = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.sellerGreen;
    final fgColor = foregroundColor ?? AppColors.pureWhite;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: bgColor,
                side: BorderSide(color: bgColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _buildContent(bgColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _buildContent(fgColor),
            ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: outlined ? color : AppColors.pureWhite,
        ),
      );
    }

    if (subtitle != null) {
      return Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: AppColors.pureWhite),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(fontSize: 15),
                ),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.pureWhite.withOpacity(0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.pureWhite, size: 20),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTextStyles.buttonText),
      ],
    );
  }
}

/// Social login button (Google / Facebook)
class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 20),
        label: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// Divider with centered text (used for "or continue with")
class LabeledDivider extends StatelessWidget {
  final String label;

  const LabeledDivider({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTextStyles.caption,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
