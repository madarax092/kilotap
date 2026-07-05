import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class VerifyCollectorScreen extends StatefulWidget {
  const VerifyCollectorScreen({super.key});
  @override State<VerifyCollectorScreen> createState() => _VerifyCollectorScreenState();
}

class _VerifyCollectorScreenState extends State<VerifyCollectorScreen> {
  final _pending = [
    {'name': 'Pedro Reyes', 'vehicle': 'Tricycle', 'area': 'Matina, Ecoland, Maa', 'exp': '3 years', 'phone': '+63928XXXXXXX', 'submitted': 'June 28, 2026', 'docs': ['Profile Photo', 'Valid ID', 'Vehicle Photo']},
    {'name': 'Ana Lopez', 'vehicle': 'Kariton', 'area': 'Ecoland', 'exp': '1 year', 'phone': '+63917XXXXXXX', 'submitted': 'June 29, 2026', 'docs': ['Profile Photo', 'Valid ID', 'Vehicle Photo']},
  ];

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: const Text('Verify Collectors', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        const SizedBox(height: 4),
        Row(children: [
          const Text('PENDING VERIFICATION', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: const BoxDecoration(color: AppColors.adminRed, shape: BoxShape.circle), child: Text('${_pending.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
        ]),
        const SizedBox(height: 12),
        ..._pending.map((c) => _VerifyTile(
          c['name'] as String, c['vehicle'] as String, c['area'] as String, c['exp'] as String,
          c['phone'] as String, c['submitted'] as String,
          List<String>.from(c['docs'] as List),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => _VerifyDetail(data: c))),
        )),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _VerifyTile extends StatelessWidget {
  final String name, vehicle, area, exp, phone, submitted;
  final List<String> docs;
  final VoidCallback onTap;
  const _VerifyTile(this.name, this.vehicle, this.area, this.exp, this.phone, this.submitted, this.docs, this.onTap);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_outline, color: AppColors.buyerBlue)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)), const Spacer(), Text(submitted, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))]),
        Text('$vehicle · $area', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
      const SizedBox(width: 8),
      const Icon(Icons.chevron_right, color: AppColors.divider),
    ]))),
  );
}

class _VerifyDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  const _VerifyDetail({required this.data});

  @override Widget build(BuildContext context) {
    final docs = List<String>.from(data['docs'] as List);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: Text('Verify: ${data['name']}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 8),
        // Document grid — 3 docs only
        Row(children: docs.map((d) => Expanded(child: _DTile(_docIcon(d), d))).toList()),
        const SizedBox(height: 16),
        _VSec('COLLECTOR DETAILS', [('Name', data['name'] as String), ('Phone', data['phone'] as String), ('Vehicle', data['vehicle'] as String), ('Experience', data['exp'] as String), ('Areas', data['area'] as String), ('Submitted', data['submitted'] as String)]),
        _VSec('VERIFICATION CHECKLIST', [('✓', 'Profile photo matches ID photo'), ('✓', 'Valid ID is government-issued'), ('✓', 'Vehicle photo matches stated type')], check: true),
        Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(decoration: InputDecoration(hintText: 'Admin notes...', filled: true, fillColor: AppColors.inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider))), maxLines: 2)),
        Row(children: [
          Expanded(flex: 4, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const FittedBox(fit: BoxFit.scaleDown, child: Text('APPROVE & ISSUE ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const Text('REJECT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.inputGrey, foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: const Text('REQUEST MORE INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(height: 30),
      ]),
    );
  }

  String _docIcon(String label) {
    if (label.contains('Profile')) return '🪪';
    if (label.contains('ID')) return '🆔';
    return '🛵';
  }
}

class _VSec extends StatelessWidget {
  final String title; final List<(String, String)> rows; final bool check;
  const _VSec(this.title, this.rows, {this.check = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: Column(children: rows.asMap().entries.map((e) {
      final isCheck = e.value.$1 == '✓'; final isUncheck = e.value.$1 == '○';
      return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: e.key < rows.length - 1 ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))) : null, child: Row(children: [
        if (check) ...[Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: isCheck ? AppColors.success : null, border: isUncheck ? Border.all(color: AppColors.divider) : null), child: isCheck ? const Icon(Icons.check, size: 9, color: Colors.white) : null), const SizedBox(width: 8)],
        Expanded(child: Text(e.value.$2, style: TextStyle(fontSize: 11, color: isUncheck ? AppColors.textMuted : AppColors.textPrimary))),
      ]));
    }).toList())),
  ]));
}

class _DTile extends StatelessWidget {
  final String icon, label;
  const _DTile(this.icon, this.label);
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), height: 110, decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: Stack(children: [
    Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(icon, style: const TextStyle(fontSize: 24)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600), textAlign: TextAlign.center)])),
    const Positioned(top: 6, right: 6, child: _Check()),
  ]));
}

class _Check extends StatelessWidget {
  const _Check();
  @override Widget build(BuildContext context) => Container(width: 18, height: 18, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(Icons.check, size: 9, color: Colors.white));
}
