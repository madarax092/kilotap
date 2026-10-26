import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/register_form.dart';

class HouseholdRegisterScreen extends StatelessWidget {
  final String? googleUid;
  final String? googleEmail;
  final String? googleDisplayName;

  const HouseholdRegisterScreen({
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
        title: const Text('Register as Household',
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
        role: 'Household',
        accent: AppColors.sellerGreen,
        emailHint: 'household@email.com',
        addressHint: 'Block/Lot/Street, Barangay, City',
        addressRequired: true,
        fallbackAddress: '',
        homeRoute: '/household',
        googleUid: googleUid,
        googleEmail: googleEmail,
        googleDisplayName: googleDisplayName,
      ),
    );
  }
}
