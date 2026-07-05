import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SellScrapScreen extends StatelessWidget {
  const SellScrapScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: automaticallyImplyLeading: false, AppBar(backgroundColor: AppColors.canvas, elevation: 0, title: const Text('Sell Scrap', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 8),
        // Camera area
        Container(
          height: 260, decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider, width: 2, strokeAlign: BorderSide.strokeAlignInside)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.sellerGreen, width: 3)), child: Center(child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sellerGreen.withOpacity(0.08))))),
            const SizedBox(height: 16),
            const Text('Take a Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const Text('Point camera at your scrap items', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 12),
        // Disabled gallery badge
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withOpacity(0.2))), child: const Row(children: [Icon(Icons.lock, size: 16, color: AppColors.error), SizedBox(width: 8), Expanded(child: Text('Gallery upload disabled — real-time camera only for security verification', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)))])),
        const SizedBox(height: 16),
        // Metadata preview
        _Card(children: [
          const Text('AUTO-ARCHIVE METADATA', style: TextStyle(fontSize: 10, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 8),
          _MetaRow('GPS', '7.0712, 125.6089 (Maa)'),
          _MetaRow('Timestamp', '2026-07-01 14:30:52'),
          _MetaRow('Device', 'Samsung A54 \u00b7 Android 14'),
          _MetaRow('SHA-256', 'a7f3b9c2...'),
        ]),
        const SizedBox(height: 12),
        // AI Analysis
        _Card(children: [
          const Text('AI ANALYSIS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          _AnalysisRow('Plastic Bottles', '12 pcs'),
          _AnalysisRow('Cardboard Boxes', '3 pcs'),
          _AnalysisRow('Scrap Iron', '2 pcs'),
          const Divider(),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Est. Total', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)), Text('~8.5 kg \u00b7 \u03A9 0.35', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success))]),
        ]),
        const SizedBox(height: 16),
        // Pickup options
        const Text('PICKUP TYPE', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(children: [_Chip('ASAP', true), const SizedBox(width: 8), _Chip('Schedule', false)]),
        const SizedBox(height: 12),
        const Text('TIME WINDOW', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(children: [_Chip('Morning 8-12', true), const SizedBox(width: 8), _Chip('Afternoon 1-5', false)]),
        const SizedBox(height: 12),
        TextField(decoration: InputDecoration(hintText: 'Notes: Gate code, instructions...', filled: true, fillColor: AppColors.inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider))), maxLines: 2),
        const SizedBox(height: 16),
        const Text('SELECT COLLECTOR', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        _CollectorOpt('Auto-match nearest', 'Best available collector', true),
        _CollectorOpt('Juan D. \u26054.8', '0.3 km \u00b7 Tricycle', false),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {}, child: const Text('SUBMIT PICKUP REQUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 30),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.sellerGreen,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.canvas,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/household');
          if (i == 2) Navigator.pushNamed(context, '/pickups');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pickups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children; const _Card({required this.children});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
}

class _MetaRow extends StatelessWidget {
  final String k, v; const _MetaRow(this.k, this.v);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)), Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]));
}

class _AnalysisRow extends StatelessWidget {
  final String label, count; const _AnalysisRow(this.label, this.count);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)), Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.sellerGreen))]));
}

class _Chip extends StatelessWidget {
  final String label; final bool active; const _Chip(this.label, this.active);
  @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? AppColors.sellerGreen.withOpacity(0.08) : AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: active ? AppColors.sellerGreen : AppColors.divider)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.sellerGreen : AppColors.textSecondary))));
}

class _CollectorOpt extends StatelessWidget {
  final String name, sub; final bool selected; const _CollectorOpt(this.name, this.sub, this.selected);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: selected ? AppColors.sellerGreen.withOpacity(0.04) : AppColors.pureWhite, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? AppColors.sellerGreen : AppColors.divider)),
    child: Row(children: [
      Radio<bool>(value: selected, groupValue: true, activeColor: AppColors.sellerGreen, onChanged: (_) {}),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)), Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))])),
    ]),
  );
}
