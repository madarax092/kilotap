import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});
  @override State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  String _selectedVehicle = 'Multicab';
  final _recommendedVehicle = 'Multicab';
  final _vehicles = ['Pushcart', 'Tricycle', 'Multicab', 'Truck'];

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(automaticallyImplyLeading: false, backgroundColor: AppColors.canvas, elevation: 0, title: const Text('Sell Scrap', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
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
          _MetaRow('Device', 'Samsung A54 · Android 14'),
        ]),
        const SizedBox(height: 12),
        // AI Analysis
        _Card(children: [
          const Text('AI ANALYSIS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          _AnalysisRow('Plastic', '12 pcs (Small)'),
          _AnalysisRow('E-Waste', '3 pcs (Medium)'),
          _AnalysisRow('Metal', '5 pcs (Large)'),
          const Divider(),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Volume', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)), Text('Large', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.sellerGreen))]),
          const SizedBox(height: 10),
          // Recommended vehicle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.15))),
            child: const Row(children: [
              Icon(Icons.local_shipping, size: 18, color: AppColors.sellerGreen),
              SizedBox(width: 8),
              Text('Recommended Vehicle:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(width: 6),
              Text('Multicab', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sellerGreen)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        // Pickup options
        const Text('PICKUP TYPE', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(children: [_Chip('ASAP', true), const SizedBox(width: 8), _Chip('Schedule', false)]),
        const SizedBox(height: 16),
        // Vehicle dropdown with Recommended button
        const Text('VEHICLE', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVehicle,
                  isExpanded: true,
                  dropdownColor: AppColors.pureWhite,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _selectedVehicle = v!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellerGreen.withOpacity(0.08),
              foregroundColor: AppColors.sellerGreen,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: AppColors.sellerGreen.withOpacity(0.3))),
            ),
            onPressed: () => setState(() => _selectedVehicle = _recommendedVehicle),
            child: const Text('Recommended', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(decoration: InputDecoration(hintText: 'Notes: Gate code, instructions...', filled: true, fillColor: AppColors.inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider))), maxLines: 2),
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
