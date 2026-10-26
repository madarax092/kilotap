import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/register_form.dart';

class CollectorRegisterScreen extends StatelessWidget {
  final String? googleUid;
  final String? googleEmail;
  final String? googleDisplayName;

  const CollectorRegisterScreen({
    super.key,
    this.googleUid,
    this.googleEmail,
    this.googleDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Register as Collector',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
      body: RegisterForm(
        role: 'Collector',
        accent: AppColors.buyerBlue,
        emailHint: 'collector@email.com',
        addressHint: 'Barangay, City',
        addressRequired: false,
        fallbackAddress: 'Davao City',
        homeRoute: '/collector',
        googleUid: googleUid,
        googleEmail: googleEmail,
        googleDisplayName: googleDisplayName,
        footer: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
                color: AppColors.buyerBlue.withValues(alpha: 0.3), width: 1),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.buyerBlue.withValues(alpha: 0.05),
          ),
          child: const Text(
            'Vehicle details and documents can be set up\nin your Profile after registration.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ),
    );
  }
}
