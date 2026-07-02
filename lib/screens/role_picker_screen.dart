import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Create Account', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.person_add, size: 36, color: AppColors.sellerGreen),
            ),
            const SizedBox(height: 20),
            const Text('How will you use KiloTap?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Choose your role to get started', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 36),
            // Household card
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register-household'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.3), width: 2)),
                child: Row(children: [
                  Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.home, color: AppColors.sellerGreen, size: 28)),
                  const SizedBox(width: 16),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('I want to sell scrap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Household — list recyclables for pickup', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                  const Icon(Icons.chevron_right, color: AppColors.sellerGreen),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            // Collector card
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register-collector'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.3), width: 2)),
                child: Row(children: [
                  Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.delivery_dining, color: AppColors.buyerBlue, size: 28)),
                  const SizedBox(width: 16),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('I want to collect scrap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Collector — pick up scrap and earn', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                  const Icon(Icons.chevron_right, color: AppColors.buyerBlue),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
