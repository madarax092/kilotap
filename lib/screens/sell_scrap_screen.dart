import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/scrap_weight_service.dart';
import '../core/volume_classifier.dart';
import 'booking_summary_screen.dart';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});
  @override State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  late String _selectedVehicle;
  bool _isAsap = true;
  DateTime? _scheduledDate;

  // Hardcoded demo detections (replace with YOLO output later)
  static const _detections = [
    'refrigerator_standard',
    'plastic_bottle_1L',
    'plastic_bottle_1L',
    'plastic_bottle_1L',
    'metal_pipe_1m',
  ];

  String get _totalVolume => VolumeClassifier.getTotalVolume(_detections);
  double get _totalWeight => VolumeClassifier.getTotalWeight(_detections);
  String get _recommendedVehicle => VolumeClassifier.getRecommendedVehicle(_totalVolume);
  List<String> get _availableVehicles => VolumeClassifier.getAvailableVehicles(_totalVolume);

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _recommendedVehicle;
  }

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
          _AnalysisRow('Refrigerator', '1 pc (${ScrapWeightService.instance.getSizeClass("refrigerator_standard")}, ${ScrapWeightService.instance.getWeight("refrigerator_standard")} kg)'),
          _AnalysisRow('Plastic Bottles', '3 pcs (${ScrapWeightService.instance.getSizeClass("plastic_bottle_1L")}, ${(ScrapWeightService.instance.getWeight("plastic_bottle_1L") ?? 0) * 3} kg)'),
          _AnalysisRow('Metal Pipe', '1 pc (${ScrapWeightService.instance.getSizeClass("metal_pipe_1m")}, ${ScrapWeightService.instance.getWeight("metal_pipe_1m")} kg)'),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Volume', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(_totalVolume, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.sellerGreen)),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Est. Weight', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${_totalWeight.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          // Recommended vehicle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.15))),
            child: Row(children: [
              Icon(Icons.local_shipping, size: 18, color: AppColors.sellerGreen),
              SizedBox(width: 8),
              Text('Recommended Vehicle:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(width: 6),
              Text(_recommendedVehicle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sellerGreen)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        // Pickup options
        const Text('PICKUP TYPE', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAsap = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isAsap ? AppColors.sellerGreen.withOpacity(0.08) : AppColors.inputGrey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _isAsap ? AppColors.sellerGreen : AppColors.divider),
                ),
                child: const Text('ASAP', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.sellerGreen)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() { _isAsap = false; _scheduledDate = picked; });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isAsap ? AppColors.sellerGreen.withOpacity(0.08) : AppColors.inputGrey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: !_isAsap ? AppColors.sellerGreen : AppColors.divider),
                ),
                child: Text(
                  _scheduledDate != null
                      ? '${_scheduledDate!.day}/${_scheduledDate!.month}'
                      : 'Schedule',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: !_isAsap ? AppColors.sellerGreen : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ]),
        if (_scheduledDate != null) ...[
          const SizedBox(height: 6),
          Text('Scheduled: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
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
                  items: _availableVehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
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
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingSummaryScreen(
            totalVolume: _totalVolume,
            totalWeight: _totalWeight,
            selectedVehicle: _selectedVehicle,
          )));
        }, child: const Text('SUBMIT PICKUP REQUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
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
