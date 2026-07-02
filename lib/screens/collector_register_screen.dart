import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CollectorRegisterScreen extends StatelessWidget {
  const CollectorRegisterScreen({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Register as Collector', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.delivery_dining, color: AppColors.buyerBlue, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Collector — Sign up now. Verify later to start accepting pickups.', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w600, fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 24),
          _Field('Full Name', 'Juan Dela Cruz'),
          _Field('Phone Number', '+63 9XX XXX XXXX'),
          _Field('Email', 'juan@email.com'),
          _Field('Password', 'Create password'),
          const SizedBox(height: 20),
          _Field('Vehicle Type', 'Select Vehicle'),
          _Field('Years Collecting', 'e.g. 5 years'),
          _Field('Usual Route Areas', 'Select Barangays'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/collector', (r) => false),
              child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('Documents can be submitted later\nin your Profile to unlock full access.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  const _Field(this.label, this.hint);
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.textMuted))),
      ]),
    );
  }
}
