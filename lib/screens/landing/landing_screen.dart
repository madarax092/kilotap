import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/kilotap_logo.dart';
import '../../widgets/common/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo + Branding
              const KiloTapLogo(size: 96),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: AppTextStyles.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Sell Scrap CTA
              KiloTapButton.seller(
                label: 'I want to sell scrap',
                subtitle: 'Households & Small Businesses',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/seller-auth'),
              ),
              const SizedBox(height: 16),
              // Buy Scrap CTA
              KiloTapButton.buyer(
                label: 'I want to buy scrap',
                subtitle: 'Junk Buyers & Collectors',
                icon: Icons.local_shipping_rounded,
                onPressed: () => context.go('/buyer-auth'),
              ),
              const Spacer(flex: 2),
              // Terms of Service footer
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.caption,
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.sellerGreen,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.sellerGreen,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final uri = Uri.parse(AppConstants.termsOfServiceUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
