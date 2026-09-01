import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../services/scrap_weight_service.dart';
import '../../services/ml/capacity_matcher.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_state.dart';
import 'booking_summary_screen.dart';
import 'camera_prototype_screen.dart';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});
  @override
  State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  XFile? _photo;

  // scrapClass -> quantity. No trained detection model yet, so items are
  // entered manually (see MOLO Training Plan in .claude plan history).
  final Map<String, int> _selectedItems = {};
  String _pendingClass = ScrapWeightService.supportedClasses.first;

  String? _vehicleOverride;
  bool _isAsap = true;
  DateTime? _scheduledDate;
  bool _submitting = false;

  double get _totalWeight {
    double total = 0;
    _selectedItems.forEach((className, qty) {
      total += (ScrapWeightService.instance.getWeight(className) ?? 0) * qty;
    });
    return double.parse(total.toStringAsFixed(2));
  }

  List<String> get _sizeClasses => _selectedItems.keys
      .map((c) => ScrapWeightService.instance.getSizeClass(c))
      .toList();

  String get _recommendedVehicle =>
      CapacityMatcher.match(totalKg: _totalWeight, sizeClasses: _sizeClasses)
          .label;

  String get _selectedVehicle => _vehicleOverride ?? _recommendedVehicle;

  String _humanize(String key) {
    return key.split('_').map((w) {
      if (w.isEmpty) return w;
      if (w.contains(RegExp(r'[0-9]'))) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  Future<void> _pickPhoto() async {
    final result = await Navigator.push<XFile?>(context,
        MaterialPageRoute(builder: (_) => const CameraPrototypeScreen()));
    if (result != null) {
      setState(() => _photo = result);
    }
  }

  Future<Position> _getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission is required to submit a pickup request.');
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Please enable location services and try again.');
    }
    return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<void> _submit() async {
    if (_selectedItems.isEmpty || _submitting) return;
    setState(() => _submitting = true);

    try {
      final position = await _getCurrentPosition();
      final firestoreService = FirestoreService();
      final auth = AuthState.instance;

      final bookingId = await firestoreService.createBooking({
        'Seller_ID': auth.uid,
        'Collector_ID': '',
        'Status': 'Pending',
        'VehicleRequirement': _selectedVehicle,
        // Placeholder — real value needs YOLO bounding-box coverage from a
        // trained MOLO model (see MOLO Training Plan).
        'SpatialAreaRatio': 0.0,
        'PickupGPS': GeoPoint(position.latitude, position.longitude),
        'PickupAddress': auth.address,
      });

      for (final entry in _selectedItems.entries) {
        final className = entry.key;
        final qty = entry.value;
        final unitWeight = ScrapWeightService.instance.getWeight(className) ?? 0;
        await firestoreService.createBookingItem({
          'Booking_ID': bookingId,
          'ItemName': _humanize(className),
          'Quantity': qty,
          'SizeClass': ScrapWeightService.instance.getSizeClass(className),
          'EstimatedWeightKg': double.parse((unitWeight * qty).toStringAsFixed(2)),
          'ScrapClass': className,
        });
      }

      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BookingSummaryScreen(
                  bookingId: bookingId, photoPath: _photo?.path)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not submit pickup request: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                const Text('Take a photo, then add the items you\'re selling',
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
                    onTap: _pickPhoto,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.5),
                        child: _photo == null
                            ? Column(
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
                                          color: AppColors.sellerGreen,
                                          size: 32)),
                                  const SizedBox(height: 16),
                                  const Text('Take a Photo',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827))),
                                  const SizedBox(height: 4),
                                  const Text('Point camera at your scrap items',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                ])
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(File(_photo!.path),
                                      fit: BoxFit.cover),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.refresh,
                                              color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text('Retake',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
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
                    child: const Row(
                      children: [
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

                  _Card(children: [
                    Row(
                      children: [
                        Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color:
                                    AppColors.sellerGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.inventory_2_outlined,
                                color: AppColors.sellerGreen, size: 16)),
                        const SizedBox(width: 10),
                        const Text('SELECTED ITEMS',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _pendingClass,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Color(0xFF9CA3AF)),
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF111827)),
                                items: ScrapWeightService.supportedClasses
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(_humanize(c),
                                            overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _pendingClass = v!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _selectedItems[_pendingClass] =
                                (_selectedItems[_pendingClass] ?? 0) + 1;
                          }),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sellerGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    if (_selectedItems.isNotEmpty) ...[
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF3F4F6), height: 1)),
                      ..._buildItemRows(),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF3F4F6), height: 1)),
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
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                            'No items added yet — pick a class above and tap +.',
                            style: TextStyle(
                                color: Color(0xFF6B7280), fontSize: 13)),
                      ),
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
                            items: ScrapWeightService.vehicleTypes
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _vehicleOverride = v),
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
                      onPressed: () =>
                          setState(() => _vehicleOverride = null),
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
                          onPressed: _selectedItems.isEmpty || _submitting
                              ? null
                              : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('SUBMIT PICKUP REQUEST',
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
              if (i == 3) {
                Navigator.pushReplacementNamed(context, '/chat_collector');
              }
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

  List<Widget> _buildItemRows() {
    final rows = <Widget>[];
    for (final className in _selectedItems.keys.toList()) {
      final qty = _selectedItems[className]!;
      final sizeClass = ScrapWeightService.instance.getSizeClass(className);
      final unitWeight = ScrapWeightService.instance.getWeight(className) ?? 0;

      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_humanize(className),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text('$sizeClass · ${(unitWeight * qty).toStringAsFixed(2)} kg',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ])),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  size: 20, color: Color(0xFF9CA3AF)),
              onPressed: () => setState(() {
                if (qty > 1) {
                  _selectedItems[className] = qty - 1;
                } else {
                  _selectedItems.remove(className);
                }
              }),
            ),
            Text('$qty',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.sellerGreen),
              onPressed: () =>
                  setState(() => _selectedItems[className] = qty + 1),
            ),
          ],
        ),
      ));
    }
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
