import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CollectorIDCard extends StatelessWidget {
  const CollectorIDCard({super.key});

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('My KiloTap ID', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        // ID Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A85C8), Color(0xFF0D5F8A), Color(0xFF1A85C8)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('KILOTAP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 2)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)), child: const Text('VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1))),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white30)), child: const Center(child: Text('JD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)))),
              const SizedBox(width: 16),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Juan Dela Cruz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Tricycle Operator', style: TextStyle(fontSize: 11, color: Colors.white60)),
                Text('Maa, Davao City', style: TextStyle(fontSize: 11, color: Colors.white60)),
                SizedBox(height: 8),
                Text('★★★★☆  4.8  (42)', style: TextStyle(fontSize: 14, color: AppColors.star)),
                Text('✓ Verified since June 15, 2026', style: TextStyle(fontSize: 10, color: AppColors.success)),
              ])),
            ]),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.qr_code, size: 50, color: AppColors.textPrimary),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Scan to Verify', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('kilotap.app/v/jd123', style: TextStyle(fontSize: 10, color: AppColors.buyerBlue)),
                  Text('Valid until Dec 15, 2026', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                ])),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        // View modes
        Row(children: [
          _ModeButton(label: '2D View', active: true),
          const SizedBox(width: 8),
          _ModeButton(label: '3D Rotate', active: false),
          const SizedBox(width: 8),
          _ModeButton(label: 'Share Card', active: false),
        ]),
        const SizedBox(height: 20),
        // Verification checks
        _SectionTitle('VERIFICATION STATUS'),
        _VerifyItem('Barangay Clearance', true),
        _VerifyItem('Valid Government ID', true),
        _VerifyItem('Vehicle Photo', true),
        _VerifyItem('Profile Photo Match', true),
        const SizedBox(height: 20),
        _SectionTitle('SHOW THIS CARD TO'),
        _ShowToItem('Subdivision Guards'),
        _ShowToItem('Households Before Entry'),
        _ShowToItem('Business Owners'),
        _ShowToItem('Barangay Officials'),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label; final bool active;
  const _ModeButton({required this.label, required this.active});
  @override Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: active ? AppColors.buyerBlue : AppColors.inputGrey, borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)));
  }
}

class _VerifyItem extends StatelessWidget {
  final String label; final bool ok;
  const _VerifyItem(this.label, this.ok);
  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Center(child: Icon(Icons.check, size: 12, color: Colors.white))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary))),
        const Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
      ]),
    );
  }
}

class _ShowToItem extends StatelessWidget {
  final String text;
  const _ShowToItem(this.text);
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.buyerBlue, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
      ]),
    );
  }
}
