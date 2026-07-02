import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _role; // null = not selected yet, 'Household' or 'Collector'

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Create Account', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: _role == null ? _buildRolePicker() : _buildForm(),
    );
  }

  Widget _buildRolePicker() {
    return Center(
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
            onTap: () => setState(() => _role = 'Household'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sellerGreen.withOpacity(0.3), width: 2),
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.home, color: AppColors.sellerGreen, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('I want to sell scrap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Household — list your recyclables for pickup', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.sellerGreen),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // Collector card
          GestureDetector(
            onTap: () => setState(() => _role = 'Collector'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.buyerBlue.withOpacity(0.3), width: 2),
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delivery_dining, color: AppColors.buyerBlue, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('I want to collect scrap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Collector — pick up scrap and earn from recyclables', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.buyerBlue),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildForm() {
    final isHousehold = _role == 'Household';
    final accent = isHousehold ? AppColors.sellerGreen : AppColors.buyerBlue;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        // Role indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withOpacity(0.2))),
            child: Row(children: [
              Icon(isHousehold ? Icons.home : Icons.delivery_dining, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(isHousehold ? 'Registering as Household' : 'Registering as Collector', style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _role = null), child: Text('Change', style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 12))),
            ]),
          ),
        ),
        // Step 1
        _Step('STEP 1 — VERIFY PHONE', accent),
        _Field('Phone Number', '+63 9XX XXX XXXX', action: 'SEND OTP'),
        _Field('OTP Code', 'Enter 6-digit code'),
        const SizedBox(height: 20),
        // Step 2
        _Step('STEP 2 — PROFILE', accent),
        _Field('Full Name', 'Juan Dela Cruz'),
        _Field('Email', 'juan@email.com'),
        _Field('Password', 'Create password'),
        // Role-specific fields
        if (isHousehold) ...[
          _Field('Barangay', 'Select Barangay'),
          _Field('Address', 'Block/Lot/Street'),
          _Field('Housing Type', 'House'),
        ] else ...[
          _Field('Vehicle Type', 'Tricycle / Sidecar'),
          _Field('Years Collecting', 'e.g. 5 years'),
          _Field('Usual Route Areas', 'Select Barangays'),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, isHousehold ? '/household' : '/collector', (r) => false),
            child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 30),
      ],
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
