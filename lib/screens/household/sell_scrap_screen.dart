import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/scrap_weight_service.dart';
import '../../core/volume_classifier.dart';
import '../../models/booking_item.dart';
import 'booking_summary_screen.dart';
import 'camera_screen.dart';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});
  @override
  State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  late String _selectedVehicle;
  bool _isAsap = true;
  DateTime? _scheduledDate;

  List<String> _detections = [];

  String get _totalVolume => VolumeClassifier.getTotalVolume(_detections);
  double get _totalWeight => VolumeClassifier.getTotalWeight(_detections);
  String get _recommendedVehicle =>
      VolumeClassifier.getRecommendedVehicle(_totalVolume);
  List<String> get _availableVehicles =>
      VolumeClassifier.getAvailableVehicles(_totalVolume);

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _recommendedVehicle;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(top: top + 16, left: 24, right: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sell Scrap',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827))),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.camera_alt,
                          color: Color(0xFF6B7280), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Snap a photo and get instant AI estimates',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),

          Expanded(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CameraScreen()));
                      if (result != null && result is List<String>) {
                        setState(() {
                          _detections = result;
                          _selectedVehicle = _recommendedVehicle;
                        });
                      }
                    },
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 10,
                                offset: Offset(0, 4))
                          ]),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.sellerGreen
                                        .withValues(alpha: 0.08)),
                                child: const Icon(Icons.camera_rounded,
                                    color: AppColors.sellerGreen, size: 32)),
                            const SizedBox(height: 16),
                            const Text('Take a Photo',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            const Text('Point camera at your scrap items',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280))),
                          ]),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5))),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline,
                            size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                'Gallery disabled for security verification. Please use live camera.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB91C1C)))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_detections.isEmpty)
                    _Card(children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('Take a photo to generate AI analysis.',
                              style: TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 13)),
                        ),
                      )
                    ])
                  else
                    _Card(children: [
                      Row(
                        children: [
                          Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: AppColors.sellerGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.auto_awesome,
                                  color: AppColors.sellerGreen, size: 16)),
                          const SizedBox(width: 10),
                          const Text('AI ANALYSIS',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._buildAnalysisRows(),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF3F4F6), height: 1)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Volume',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                    fontSize: 13)),
                            Text(_totalVolume,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.sellerGreen,
                                    fontSize: 14)),
                          ]),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Est. Weight',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                    fontSize: 13)),
                            Text('${_totalWeight.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    fontSize: 14)),
                          ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: Row(children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 20, color: AppColors.sellerGreen),
                          const SizedBox(width: 10),
                          const Text('Recommended:',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF166534))),
                          const SizedBox(width: 6),
                          Text(_recommendedVehicle,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sellerGreen)),
                        ]),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  _Card(children: [
                    Row(
                      children: [
                        Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.info_outline,
                                color: Color(0xFF6B7280), size: 16)),
                        const SizedBox(width: 10),
                        const Text('AUTO-ARCHIVED METADATA',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                                letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _MetaRow('GPS', '7.0712, 125.6089 (Maa)'),
                    const _MetaRow('Timestamp', '2026-07-01 14:30:52'),
                    const _MetaRow('Device', 'Samsung A54 · Android 14'),
                  ]),

                  const SizedBox(height: 24),

                  const Text('PICKUP DETAILS',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAsap = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isAsap
                                ? const Color(0xFFF0FDF4)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isAsap
                                    ? AppColors.sellerGreen
                                    : const Color(0xFFE5E7EB),
                                width: _isAsap ? 2 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.flash_on,
                                  color: _isAsap
                                      ? AppColors.sellerGreen
                                      : const Color(0xFF9CA3AF),
                                  size: 20),
                              const SizedBox(height: 6),
                              Text('ASAP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _isAsap
                                          ? AppColors.sellerGreen
                                          : const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            setState(() {
                              _isAsap = false;
                              _scheduledDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isAsap
                                ? const Color(0xFFF0FDF4)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: !_isAsap
                                    ? AppColors.sellerGreen
                                    : const Color(0xFFE5E7EB),
                                width: !_isAsap ? 2 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_month,
                                  color: !_isAsap
                                      ? AppColors.sellerGreen
                                      : const Color(0xFF9CA3AF),
                                  size: 20),
                              const SizedBox(height: 6),
                              Text(
                                  _scheduledDate != null
                                      ? '${_scheduledDate!.month}/${_scheduledDate!.day}'
                                      : 'Schedule',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: !_isAsap
                                          ? AppColors.sellerGreen
                                          : const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVehicle,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFF9CA3AF)),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827)),
                            items: _availableVehicles
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedVehicle = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0FDF4),
                        foregroundColor: AppColors.sellerGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(
                          () => _selectedVehicle = _recommendedVehicle),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  TextField(
                      decoration: InputDecoration(
                          hintText: 'Notes: Gate code, instructions...',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Color(0xFF9CA3AF)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.sellerGreen, width: 1.5))),
                      maxLines: 2),

                  const SizedBox(height: 32),

                  SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sellerGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.sellerGreen.withValues(alpha: 0.3),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: _detections.isEmpty
                              ? null
                              : () {
                                  final items = <BookingItem>[
                                    BookingItem(
                                      itemId: 'ITM-001',
                                      bookingId: 'BKG-001',
                                      itemName: 'Standard Refrigerator',
                                      quantity: 1,
                                      sizeClass: 'Heavy Override',
                                      estimatedWeightKg: 100,
                                      scrapClass: 'refrigerator_standard',
                                    ),
                                    BookingItem(
                                      itemId: 'ITM-002',
                                      bookingId: 'BKG-001',
                                      itemName: 'Plastic Bottles',
                                      quantity: 3,
                                      sizeClass: 'Small',
                                      estimatedWeightKg: 0.12,
                                      scrapClass: 'plastic_bottle_1L',
                                    ),
                                    BookingItem(
                                      itemId: 'ITM-003',
                                      bookingId: 'BKG-001',
                                      itemName: 'Metal Pipe',
                                      quantity: 1,
                                      sizeClass: 'Large',
                                      estimatedWeightKg: 68,
                                      scrapClass: 'metal_pipe_1m',
                                    ),
                                  ];

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => BookingSummaryScreen(
                                                totalVolume: _totalVolume,
                                                totalWeight: _totalWeight,
                                                selectedVehicle:
                                                    _selectedVehicle,
                                                items: items,
                                              )));
                                },
                          child: const Text('SUBMIT PICKUP REQUEST',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5)))),
                  const SizedBox(height: 30),
                ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 8, offset: Offset(0, -2))
          ]),
          child: SafeArea(
              child: BottomNavigationBar(
            currentIndex: 1,
            selectedItemColor: AppColors.sellerGreen,
            unselectedItemColor: const Color(0xFFBBBBBB),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 0) Navigator.pushReplacementNamed(context, '/household');
              if (i == 2) Navigator.pushReplacementNamed(context, '/pickups');
              if (i == 3) Navigator.pushReplacementNamed(context, '/chat');
              if (i == 4) Navigator.pushReplacementNamed(context, '/profile');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined), label: 'Sell'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded), label: 'Pickups'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Messages'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ))),
    );
  }

  List<Widget> _buildAnalysisRows() {
    if (_detections.isEmpty) return [];

    final counts = <String, int>{};
    for (var d in _detections) {
      counts[d] = (counts[d] ?? 0) + 1;
    }

    final rows = <Widget>[];
    counts.forEach((key, count) {
      String label = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      if (key.contains('plastic_bottle')) label = 'Plastic Bottles';
      if (key.contains('refrigerator')) label = 'Refrigerator';
      if (key.contains('metal_pipe')) label = 'Metal Pipe';

      final sizeClass = ScrapWeightService.instance.getSizeClass(key);
      final weightPerItem = ScrapWeightService.instance.getWeight(key) ?? 0;
      final totalWeight = weightPerItem * count;

      rows.add(_AnalysisRow(label, '$count pc${count > 1 ? 's' : ''}',
          '$sizeClass · $totalWeight kg'));
    });

    return rows;
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))
          ]),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children));
}

class _MetaRow extends StatelessWidget {
  final String k, v;
  const _MetaRow(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        Text(v,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827)))
      ]));
}

class _AnalysisRow extends StatelessWidget {
  final String label, qty, details;
  const _AnalysisRow(this.label, this.qty, this.details);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const SizedBox(height: 2),
          Text(details,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6)),
            child: Text(qty,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563)))),
      ]));
}
