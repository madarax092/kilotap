import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class HouseholdRegisterScreen extends StatelessWidget {
  const HouseholdRegisterScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Register as Household', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          // Role badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.home, color: AppColors.sellerGreen, size: 20),
              SizedBox(width: 8),
              Text('Household — Sell your scrap', style: TextStyle(color: AppColors.sellerGreen, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 24),
          _Step('STEP 1 OF 2 — VERIFY PHONE', AppColors.sellerGreen),
          _Field('Phone Number', '+63 9XX XXX XXXX', action: 'SEND OTP'),
          _Field('OTP Code', 'Enter 6-digit code'),
          const SizedBox(height: 20),
          _Step('STEP 2 OF 2 — PROFILE', AppColors.sellerGreen),
          _Field('Full Name', 'Juan Dela Cruz'),
          _Field('Barangay', 'Select Barangay'),
          _Field('Address', 'Block/Lot/Street'),
          _Field('Housing Type', 'House'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/household', (r) => false),
              child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final Color color;
  const _Step(this.label, this.color);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)));
}

class _Field extends StatelessWidget {
  final String label, hint;
  final String? action;
  const _Field(this.label, this.hint, {this.action});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        action != null
            ? Row(children: [
                Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)))),
                const SizedBox(width: 8),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: Text(action!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
              ])
            : Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.textMuted))),
      ]),
    );
  }
}
