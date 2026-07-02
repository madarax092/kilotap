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
          // Role badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.delivery_dining, color: AppColors.buyerBlue, size: 20),
              SizedBox(width: 8),
              Text('Collector — Pick up and earn', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 24),
          _Step('STEP 1 OF 3 — IDENTITY', AppColors.buyerBlue),
          _Field('Full Name', 'Juan Dela Cruz'),
          _Field('Phone Number', '+63 9XX XXX XXXX'),
          _Field('Vehicle Type', 'Select Vehicle'),
          _Field('Years Collecting', 'e.g. 5 years'),
          _Field('Usual Route Areas', 'Select Barangays'),
          const SizedBox(height: 20),
          _Step('STEP 2 OF 3 — DOCUMENTS', AppColors.buyerBlue),
          _UploadBox('Upload Barangay Clearance', 'Photo or scan · Required for verification'),
          _UploadBox('Upload Valid ID', 'Government-issued ID'),
          _UploadBox('Profile Photo', 'Clear face photo for ID card'),
          _UploadBox('Vehicle Photo', 'Photo of your vehicle'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withOpacity(0.2))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PENDING APPROVAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warning)),
              SizedBox(height: 2),
              Text('Your account will be reviewed by KiloTap Admin. You\'ll receive your Verified ID Card after approval (usually within 24 hours).', style: TextStyle(fontSize: 11, color: AppColors.warning)),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/collector', (r) => false),
              child: const Text('SUBMIT FOR VERIFICATION', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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

class _UploadBox extends StatelessWidget {
  final String title, subtitle;
  const _UploadBox(this.title, this.subtitle);
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider, strokeAlign: BorderSide.strokeAlignInside)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        const Icon(Icons.add_photo_alternate_outlined, color: AppColors.buyerBlue, size: 22),
      ]),
    );
  }
}
