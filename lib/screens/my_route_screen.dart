import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MyRouteScreen extends StatelessWidget {
  const MyRouteScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: automaticallyImplyLeading: false, AppBar(backgroundColor: AppColors.canvas, elevation: 0, title: const Text('Today\'s Route', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
      const SizedBox(height: 8),
      // Route map
      Container(height: 220, decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _RGridPainter())),
        Positioned(top: 90, left: 140, child: _RStop('1', AppColors.success, done: true)),
        Positioned(top: 60, left: 200, child: _RStop('2', AppColors.buyerBlue, current: true)),
        Positioned(top: 140, left: 180, child: _RStop('3', AppColors.buyerBlue)),
        Positioned(top: 30, left: 260, child: _RStop('4', AppColors.buyerBlue)),
      ])),
      const SizedBox(height: 16),
      // Summary
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Column(children: [
        Row(children: [_Sum('4.7 km', 'Distance'), _Sum('2.5 hrs', 'Est. Time')]),
        const SizedBox(height: 10),
        Row(children: [_Sum('~30 kg', 'Total Load', accent: true), _Sum('₱85', 'Est. Fuel')]),
      ])),
      const SizedBox(height: 16),
      // Stops
      _StopCard('1', 'Maria S.', 'Maa · 3.2 kg · Plastic/Cardboard', 'DONE', done: true),
      _StopCard('2', 'Jose R.', 'Matina · 25 kg · Scrap Iron/Appliance', 'NOW', current: true),
      _StopCard('3', 'Ana L.', 'Ecoland · 1.8 kg · Cardboard', ''),
      _StopCard('4', 'Carlos M.', 'Cabantian · 3.5 kg · Mixed', ''),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const Text('OPTIMIZE ROUTE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 30),
    ]),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: AppColors.buyerBlue,
      unselectedItemColor: AppColors.textMuted,
      backgroundColor: AppColors.canvas,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, '/collector');
        if (i == 1) Navigator.pushNamed(context, '/find');
        if (i == 2) Navigator.pushNamed(context, '/idcard');
        if (i == 4) Navigator.pushNamed(context, '/collector_profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'ID'),
        BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Route'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

class _RStop extends StatelessWidget { final String num; final Color color; final bool done, current; const _RStop(this.num, this.color, {this.done = false, this.current = false}); @override Widget build(BuildContext context) => Container(width: current ? 26 : 22, height: current ? 26 : 22, decoration: BoxDecoration(color: done ? AppColors.success : color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: current ? 12 : 6)]), child: Center(child: Text(num, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)))); }
class _RGridPainter extends CustomPainter { @override void paint(Canvas c, Size s) { final paint = Paint()..color = AppColors.divider..strokeWidth = 0.5; for (double x = 0; x < s.width; x += 40) c.drawLine(Offset(x, 0), Offset(x, s.height), paint); for (double y = 0; y < s.height; y += 40) c.drawLine(Offset(0, y), Offset(s.width, y), paint); } @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false; }
class _Sum extends StatelessWidget { final String val, label; final bool accent; const _Sum(this.val, this.label, {this.accent = false}); @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(10), child: Column(children: [Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accent ? AppColors.buyerBlue : AppColors.textPrimary)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary))]))); }
class _StopCard extends StatelessWidget { final String num, name, detail, status; final bool done, current; const _StopCard(this.num, this.name, this.detail, this.status, {this.done = false, this.current = false}); @override Widget build(BuildContext context) => Container(
  margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: done ? AppColors.pureWhite.withOpacity(0.6) : AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: current ? AppColors.buyerBlue : AppColors.divider)),
  child: Row(children: [
    Container(width: 28, height: 28, decoration: BoxDecoration(color: done ? AppColors.success : current ? AppColors.buyerBlue : AppColors.inputGrey, shape: BoxShape.circle), child: Center(child: Text(num, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: (done || current) ? Colors.white : AppColors.textSecondary)))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), Text(detail, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))])),
    if (status.isNotEmpty) Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: done ? AppColors.success : AppColors.buyerBlue)),
  ]),
); }
