import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FindScrapScreen extends StatelessWidget {
  const FindScrapScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: const Text('Find Scrap', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
    body: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_Filt('All', true), _Filt('<1 km', false), _Filt('<3 km', false), _Filt('Heavy', false), _Filt('ASAP', false), _Filt('Metal', false)]))),
      const SizedBox(height: 12),
      // Map
      Container(height: 260, margin: const EdgeInsets.symmetric(horizontal: 28), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(top: 90, left: 175, child: _Pin(18, AppColors.success, 'You')),
        const Positioned(top: 50, left: 185, child: _Pin(14, AppColors.error, '25kg')),
        const Positioned(top: 110, left: 210, child: _Pin(14, AppColors.buyerBlue, '3.2kg')),
        const Positioned(top: 165, left: 130, child: _Pin(14, AppColors.star, '12kg')),
        const Positioned(top: 40, left: 260, child: _Pin(14, AppColors.buyerBlue, '1.8kg')),
        const Positioned(top: 140, left: 60, child: _Pin(14, AppColors.star, '8kg')),
        Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(6)), child: const Text('● Heavy  ● Med  ● Light  🟢 You', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.w600)))),
      ])),
      const SizedBox(height: 12),
      // Request preview
      Container(margin: const EdgeInsets.symmetric(horizontal: 28), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.3), width: 1.5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Maria Santos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)), const Text('Maa · 0.3 km', style: TextStyle(fontSize: 10, color: AppColors.textSecondary))]),
        const SizedBox(height: 8),
        Row(children: [const _Det('3.2 kg', 'Load'), const _Det('Ω 0.35', 'Volume'), const _Det('ASAP', '')].map((d) => Padding(padding: const EdgeInsets.only(right: 16), child: d)).toList()),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(8)), child: const Text('"Gate code #1234, ring bell"', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('ACCEPT'))), const SizedBox(width: 8), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('DECLINE')))])
      ])),
    ]),
    bottomNavigationBar: BottomNavigationBar(currentIndex: 1, selectedItemColor: AppColors.buyerBlue, unselectedItemColor: AppColors.textMuted, backgroundColor: AppColors.canvas, type: BottomNavigationBarType.fixed, onTap: (i) { if (i == 0) Navigator.pushReplacementNamed(context, '/collector'); if (i == 2) Navigator.pushNamed(context, '/idcard'); if (i == 3) Navigator.pushNamed(context, '/earnings'); if (i == 4) Navigator.pushNamed(context, '/collector_profile'); }, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'), BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID Card'), BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Earn'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')]),
  );
}

class _Filt extends StatelessWidget { final String label; final bool active; const _Filt(this.label, this.active); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: active ? AppColors.buyerBlue : AppColors.inputGrey, borderRadius: BorderRadius.circular(16)), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary))); }
class _Pin extends StatelessWidget { final double size; final Color color; final String label; const _Pin(this.size, this.color, this.label); @override Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppColors.textPrimary, backgroundColor: AppColors.pureWhite)), Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]))]); }
class _Det extends StatelessWidget { final String val, label; const _Det(this.val, this.label); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary))]); }
class _GridPainter extends CustomPainter { @override void paint(Canvas c, Size s) { final paint = Paint()..color = AppColors.divider..strokeWidth = 0.5; for (double x = 0; x < s.width; x += 40) { c.drawLine(Offset(x, 0), Offset(x, s.height), paint); } for (double y = 0; y < s.height; y += 40) { c.drawLine(Offset(0, y), Offset(s.width, y), paint); } } @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false; }
