import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/material_preferences.dart';
import '../../core/date_format.dart';
import '../../core/theme/app_colors.dart';
import '../../services/scrap_weight_service.dart';
import '../../services/ml/capacity_matcher.dart';
import '../../services/ml/pipeline.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';
import '../../services/booking_outbox.dart';
import '../../services/sell_draft_store.dart';
import '../../widgets/address_entry_page.dart';
import '../../widgets/pickup_map_preview.dart';
import '../../widgets/pin_location_page.dart';
import 'booking_summary_screen.dart';
import 'camera_prototype_screen.dart';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});
  @override
  State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellItem {
  final String className;
  final bool isCustom;
  // Seller-chosen material for a custom item (one of
  // MaterialPreferences.customItemCategories) — saved as its ScrapClass so
  // collector preference matching still works. Always null for known classes.
  String? category;
  int quantity;
  final TextEditingController weightCtrl;
  final TextEditingController notesCtrl;
  _SellItem({
    required this.className,
    required this.isCustom,
    required this.quantity,
    required this.weightCtrl,
    required this.notesCtrl,
  });
}

// A row in the item suggestions: a category header, a known item (text is
// its class key), or the "add as a new item" row for the typed text.
class _PickerRow {
  final String text;
  final bool isHeader;
  final bool isNewItem;
  const _PickerRow(this.text, {this.isHeader = false, this.isNewItem = false});
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  XFile? _photo;
  late String _address = AuthState.instance.address;
  // Last-used pin, restored from the profile so a returning household only
  // has to confirm or move it. Required before a request can be submitted.
  late LatLng? _pin = _savedPin();
  bool _detecting = false;
  String? _detectionError;
  double _spatialAreaRatio = 0.0;

  // scrapClass -> quantity, with a user-editable weight (kg) and optional
  // detail annotation per item. Pre-filled from on-device detection when
  // available; always user-editable/addable regardless (human-in-the-loop
  // confirmation, per the paper's 2.1.3.1.3).
  final List<_SellItem> _selectedItems = [];
  final MoloPipeline _pipeline = MoloPipeline();
  final _itemInputCtrl = TextEditingController();
  final _itemInputFocus = FocusNode();
  final _bookingNotesCtrl = TextEditingController();

  String? _vehicleOverride;
  bool _isAsap = true;
  DateTime? _scheduledDate;
  bool _submitting = false;

  // ─── Draft autosave: the form survives the app being closed ───
  Timer? _draftTimer;
  String? _draftPhotoPath;
  // False until any saved draft is restored, and again once the request is
  // sent, so neither moment overwrites the draft store.
  bool _draftReady = false;

  @override
  void initState() {
    super.initState();
    _bookingNotesCtrl.addListener(_scheduleDraftSave);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
  }

  // Every form change goes through setState, so this is the single place
  // that queues an autosave.
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _scheduleDraftSave();
  }

  _SellItem _newItem(String className,
      {required bool isCustom,
      int quantity = 1,
      String? category,
      String weight = '',
      String notes = ''}) {
    final item = _SellItem(
      className: className,
      isCustom: isCustom,
      quantity: quantity,
      weightCtrl: TextEditingController(text: weight),
      notesCtrl: TextEditingController(text: notes),
    )..category = category;
    item.weightCtrl.addListener(_scheduleDraftSave);
    item.notesCtrl.addListener(_scheduleDraftSave);
    return item;
  }

  void _scheduleDraftSave() {
    if (!_draftReady || kIsWeb) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 800), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final uid = AuthState.instance.uid;
    if (uid == null || !mounted || !_draftReady) return;
    if (_photo == null && _selectedItems.isEmpty) {
      await SellDraftStore.clear(uid);
      _draftPhotoPath = null;
      return;
    }
    if (_photo != null && _photo!.path != _draftPhotoPath) {
      final previous = _draftPhotoPath;
      _draftPhotoPath = await SellDraftStore.keepPhoto(_photo!.path);
      if (previous != null && previous != _draftPhotoPath) {
        try {
          File(previous).deleteSync();
        } catch (_) {}
      }
    }
    await SellDraftStore.save(uid, {
      'photoPath': _photo == null ? null : _draftPhotoPath,
      'items': [
        for (final i in _selectedItems)
          {
            'className': i.className,
            'isCustom': i.isCustom,
            'category': i.category,
            'quantity': i.quantity,
            'weight': i.weightCtrl.text,
            'notes': i.notesCtrl.text,
          },
      ],
      'address': _address,
      'pinLat': _pin?.latitude,
      'pinLon': _pin?.longitude,
      'isAsap': _isAsap,
      'scheduledDate': _scheduledDate?.toIso8601String(),
      'vehicleOverride': _vehicleOverride,
      'bookingNotes': _bookingNotesCtrl.text,
      'spatialAreaRatio': _spatialAreaRatio,
    });
  }

  Future<void> _restoreDraft() async {
    final uid = AuthState.instance.uid;
    final draft = (uid == null || kIsWeb) ? null : SellDraftStore.load(uid);
    if (draft != null && mounted) {
      final photoPath = draft['photoPath'] as String?;
      final items = (draft['items'] as List? ?? const []).whereType<Map>();
      super.setState(() {
        if (photoPath != null && File(photoPath).existsSync()) {
          _photo = XFile(photoPath);
          _draftPhotoPath = photoPath;
        }
        for (final m in items) {
          _selectedItems.add(_newItem(m['className'] as String,
              isCustom: m['isCustom'] == true,
              quantity: (m['quantity'] as num?)?.toInt() ?? 1,
              category: m['category'] as String?,
              weight: m['weight'] as String? ?? '',
              notes: m['notes'] as String? ?? ''));
        }
        final address = draft['address'] as String?;
        if (address != null && address.isNotEmpty) _address = address;
        final lat = draft['pinLat'], lon = draft['pinLon'];
        if (lat is num && lon is num) {
          _pin = LatLng(lat.toDouble(), lon.toDouble());
        }
        final scheduled = DateTime.tryParse(draft['scheduledDate'] ?? '');
        _isAsap = draft['isAsap'] != false;
        _scheduledDate = scheduled;
        // A schedule that has already passed falls back to ASAP.
        if (scheduled != null && scheduled.isBefore(DateTime.now())) {
          _isAsap = true;
          _scheduledDate = null;
        }
        _vehicleOverride = draft['vehicleOverride'] as String?;
        _spatialAreaRatio =
            (draft['spatialAreaRatio'] as num?)?.toDouble() ?? 0;
      });
      _bookingNotesCtrl.text = draft['bookingNotes'] as String? ?? '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Restored your unfinished pickup request.'),
        action: SnackBarAction(label: 'Discard', onPressed: _discardDraft),
      ));
    }
    _draftReady = true;
  }

  Future<void> _discardDraft() async {
    _draftTimer?.cancel();
    final uid = AuthState.instance.uid;
    if (uid != null) await SellDraftStore.clear(uid);
    if (!mounted) return;
    for (final i in _selectedItems) {
      i.weightCtrl.dispose();
      i.notesCtrl.dispose();
    }
    super.setState(() {
      _selectedItems.clear();
      _photo = null;
      _draftPhotoPath = null;
      _detectionError = null;
      _spatialAreaRatio = 0;
      _isAsap = true;
      _scheduledDate = null;
      _vehicleOverride = null;
      _address = AuthState.instance.address;
      _pin = _savedPin();
    });
    _bookingNotesCtrl.clear();
  }

  // Called once the request is sent or queued: the draft is no longer needed.
  Future<void> _clearDraftAfterSend() async {
    _draftReady = false;
    _draftTimer?.cancel();
    final uid = AuthState.instance.uid;
    if (uid != null) {
      await SellDraftStore.clear(uid,
          deletePhoto: _photo == null || _photo!.path != _draftPhotoPath);
    }
  }

  double get _totalWeight {
    double total = 0;
    for (final item in _selectedItems) {
      total += double.tryParse(item.weightCtrl.text) ?? 0;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  List<String> get _sizeClasses => _selectedItems
      .map((item) => ScrapWeightService.instance.getSizeClass(item.className))
      .toList();

  String get _recommendedVehicle =>
      CapacityMatcher.match(totalKg: _totalWeight, sizeClasses: _sizeClasses)
          .label;

  String get _selectedVehicle => _vehicleOverride ?? _recommendedVehicle;

  // Orders the item suggestions (class keys) by collector-preference
  // category, with a header row per category, so the list is easy to scan.
  // While the household is typing something that isn't an exact item name,
  // an "add as a new item" row stays at the bottom so they can still choose
  // their own wording over a suggestion.
  List<_PickerRow> _groupedOptions(Iterable<String> options, String typed) {
    final byCategory = <String, List<String>>{};
    for (final key in options) {
      final category = MaterialPreferences.categoryOf(key) ?? 'Other';
      byCategory.putIfAbsent(category, () => []).add(key);
    }
    final order = [...MaterialPreferences.categories, 'Other'];
    final rows = <_PickerRow>[];
    for (final category in order) {
      final items = byCategory[category];
      if (items == null || items.isEmpty) continue;
      rows.add(_PickerRow(category, isHeader: true));
      items.sort((a, b) => ScrapWeightService.labelFor(a)
          .compareTo(ScrapWeightService.labelFor(b)));
      rows.addAll(items.map((i) => _PickerRow(i)));
    }
    if (typed.isNotEmpty && ScrapWeightService.resolveTyped(typed) == null) {
      rows.add(_PickerRow(typed, isNewItem: true));
    }
    return rows;
  }

  String _titleCase(String s) {
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _displayName(_SellItem item) => item.isCustom
      ? item.className
      : ScrapWeightService.labelFor(item.className);

  /// Adds typed text: an exact item name or alias becomes that known item
  /// (so weight, size class and category still work); anything else becomes
  /// a custom item, unless [asNewItem] forces it to stay custom.
  void _addItem(String rawInput, {bool asNewItem = false}) {
    final text = rawInput.trim();
    if (text.isEmpty) return;
    final match = asNewItem ? null : ScrapWeightService.resolveTyped(text);
    if (match != null) {
      _addEntry(match, isCustom: false);
    } else {
      _addEntry(_titleCase(text), isCustom: true);
    }
  }

  // Adding an item that is already in the list raises its quantity instead
  // of creating a second row, and says so.
  void _addEntry(String key, {required bool isCustom}) {
    final existing = _selectedItems
        .where((e) =>
            e.isCustom == isCustom &&
            e.className.toLowerCase() == key.toLowerCase())
        .toList();
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _selectedItems.add(_newItem(key, isCustom: isCustom));
      }
      _itemInputCtrl.clear();
    });
    if (existing.isNotEmpty) {
      final item = existing.first;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_displayName(item)} is already in your list '
              '- quantity is now ${item.quantity}.')));
    }
  }

  Future<void> _pickPhoto() async {
    final result = await Navigator.push<XFile?>(context,
        MaterialPageRoute(builder: (_) => const CameraPrototypeScreen()));
    if (result == null) return;
    setState(() {
      _photo = result;
      _detectionError = null;
      _spatialAreaRatio = 0.0;
    });
    if (!kIsWeb) await _runDetection(result);
  }

  Future<void> _runDetection(XFile photo) async {
    setState(() => _detecting = true);
    try {
      final result = await _pipeline.run(File(photo.path));
      final counts = <String, int>{};
      for (final d in result.detections) {
        final key = ScrapWeightService.pickerClassFor(d.className);
        counts[key] = (counts[key] ?? 0) + 1;
      }
      final areaRatio = result.detections
          .fold<double>(0.0, (total, d) => total + (d.w * d.h))
          .clamp(0.0, 1.0);

      if (!mounted) return;
      setState(() {
        _spatialAreaRatio = areaRatio;
        for (final entry in counts.entries) {
          final existing =
              _selectedItems.where((e) => e.className == entry.key);
          if (existing.isNotEmpty) {
            existing.first.quantity += entry.value;
          } else {
            _selectedItems.add(_newItem(entry.key,
                isCustom: false, quantity: entry.value));
          }
        }
        if (counts.isEmpty) {
          _detectionError =
              'No known items detected — add items manually below.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detectionError = 'Detection failed: $e — add items manually below.';
      });
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  // The saved pin only counts while it belongs to the current address —
  // AuthService clears it when the barangay or city changes.
  LatLng? _savedPin() {
    final auth = AuthState.instance;
    return auth.hasAddressPin
        ? LatLng(auth.addressLat!, auth.addressLon!)
        : null;
  }

  Future<String?> _editAddress() async {
    final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (_) => AddressEntryPage(initialAddress: _address)));
    if (result == null || !mounted) return null;
    setState(() {
      _address = result;
      _pin = _savedPin();
    });
    return result;
  }

  Future<void> _openPinPage() async {
    final picked = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
            builder: (_) => PinLocationPage(
                initialPin: _pin,
                address: _address,
                onEditAddress: _editAddress)));
    if (picked == null || !mounted) return;
    setState(() => _pin = picked);
    try {
      await AuthService.instance
          .updateSellerPin(picked.latitude, picked.longitude);
    } catch (_) {
      // Non-fatal — the pin still applies to this booking, it just won't be
      // remembered for next time.
    }
  }

  bool get _canSubmit =>
      _selectedItems.isNotEmpty &&
      _photo != null &&
      _address.trim().isNotEmpty &&
      _pin != null &&
      !_submitting;

  // First thing still blocking Submit, in the order the form is filled in.
  String? get _missingStep {
    if (_photo == null) return 'Take a photo of your scrap to continue.';
    if (_selectedItems.isEmpty) return 'Add at least one item to continue.';
    if (_address.trim().isEmpty) return 'Add your pickup address to continue.';
    if (_pin == null) return 'Set your pickup pin on the map to continue.';
    return null;
  }

  // Red-outlines the empty pin card once everything else is ready.
  bool get _showPinError =>
      _pin == null && _photo != null && _selectedItems.isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (_selectedItems
        .any((item) => (double.tryParse(item.weightCtrl.text) ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a valid weight (kg) for every item.')));
      return;
    }
    if (_selectedItems.any((item) => item.isCustom && item.category == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Choose a material type for every custom item (or "Other / Not sure").')));
      return;
    }
    setState(() => _submitting = true);

    try {
      final pin = _pin!;
      final firestoreService = FirestoreService();
      final auth = AuthState.instance;

      final bookingId = firestoreService.newBookingId();
      final booking = <String, dynamic>{
        'Seller_ID': auth.uid,
        'Collector_ID': '',
        'Status': 'Pending',
        'VehicleRequirement': _selectedVehicle,
        'SpatialAreaRatio': double.parse(_spatialAreaRatio.toStringAsFixed(4)),
        'PickupGPS': GeoPoint(pin.latitude, pin.longitude),
        'PickupAddress': _address,
        'Notes': _bookingNotesCtrl.text.trim(),
        'PhotoURL': '',
        'PickupType': _isAsap ? 'ASAP' : 'Scheduled',
        'ScheduledDate': !_isAsap && _scheduledDate != null
            ? Timestamp.fromDate(_scheduledDate!)
            : null,
      };
      final items = <Map<String, dynamic>>[
        for (final item in _selectedItems)
          {
            'ItemName': _displayName(item),
            'Quantity': item.quantity,
            'SizeClass':
                ScrapWeightService.instance.getSizeClass(item.className),
            'EstimatedWeightKg': double.parse(
                (double.tryParse(item.weightCtrl.text) ?? 0)
                    .toStringAsFixed(2)),
            'ScrapClass': item.isCustom ? item.category! : item.className,
            'Notes': item.notesCtrl.text.trim(),
          },
      ];

      // The photo upload is the step that needs a connection. Without one,
      // the request goes to the offline outbox and is sent automatically
      // later (paper 2.3.3.4).
      try {
        if (!kIsWeb && _photo != null) {
          booking['PhotoURL'] = await firestoreService
              .uploadBookingPhoto(File(_photo!.path))
              .timeout(const Duration(seconds: 30));
        }
      } catch (e) {
        if (!BookingOutbox.isNetworkError(e)) rethrow;
        await BookingOutbox.instance.enqueue(
          sellerId: auth.uid ?? '',
          bookingId: bookingId,
          booking: booking,
          items: items,
          photoPath: _photo?.path,
        );
        await _clearDraftAfterSend();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No connection. Your request is saved on this phone '
              'and will be sent automatically when you are back online.'),
          duration: Duration(seconds: 6),
        ));
        Navigator.pushReplacementNamed(context, '/pickups');
        return;
      }

      await firestoreService.createBookingWithItems(booking, items,
          bookingId: bookingId);
      await _clearDraftAfterSend();

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
  void dispose() {
    _draftTimer?.cancel();
    for (final item in _selectedItems) {
      item.weightCtrl.dispose();
      item.notesCtrl.dispose();
    }
    _bookingNotesCtrl.dispose();
    _itemInputCtrl.dispose();
    _itemInputFocus.dispose();
    super.dispose();
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
                                    const Text(
                                        'Point camera at your scrap items',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                  ])
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  kIsWeb
                                      ? Image.network(_photo!.path,
                                          fit: BoxFit.cover)
                                      : Image.file(File(_photo!.path),
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
                                                  fontWeight: FontWeight.w600)),
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
                  if (_detecting)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0))),
                      child: const Row(
                        children: [
                          SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.sellerGreen)),
                          SizedBox(width: 10),
                          Text('Scanning photo for items...',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF166534))),
                        ],
                      ),
                    )
                  else if (_detectionError != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A))),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: Color(0xFFB45309)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(_detectionError!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB45309)))),
                        ],
                      ),
                    ),
                  if (_detecting || _detectionError != null)
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
                                color: AppColors.sellerGreen
                                    .withValues(alpha: 0.1),
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
                          child: Autocomplete<String>(
                            textEditingController: _itemInputCtrl,
                            focusNode: _itemInputFocus,
                            // Options are class keys; matching covers the
                            // display name, hint and aliases ("lata", "phone").
                            optionsBuilder: (TextEditingValue value) {
                              return ScrapWeightService.searchPicker(
                                  value.text);
                            },
                            displayStringForOption:
                                ScrapWeightService.labelFor,
                            onSelected: (key) =>
                                _addEntry(key, isCustom: false),
                            fieldViewBuilder:
                                (context, controller, focusNode, onSubmit) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB))),
                                child: TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF111827)),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: 'Type an item name...',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF)),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onSubmitted: _addItem,
                                ),
                              );
                            },
                            optionsViewBuilder:
                                (context, onSelected, options) {
                              final typed = _itemInputCtrl.text.trim();
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(10),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 260, maxHeight: 220),
                                    child: options.isEmpty
                                        ? (typed.isEmpty
                                            ? const Padding(
                                                padding: EdgeInsets.all(14),
                                                child: Text(
                                                    'Start typing an item name.',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                            0xFF6B7280))),
                                              )
                                            : ListTile(
                                                dense: true,
                                                leading: const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 18,
                                                    color:
                                                        AppColors.sellerGreen),
                                                title: Text(
                                                    'Add "$typed" as a new item',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .sellerGreen)),
                                                onTap: () => _addItem(typed,
                                                    asNewItem: true),
                                              ))
                                        : Builder(builder: (context) {
                                            final rows = _groupedOptions(
                                                options, typed);
                                            return ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: rows.length,
                                              itemBuilder: (context, i) {
                                                final row = rows[i];
                                                if (row.isHeader) {
                                                  return Container(
                                                    width: double.infinity,
                                                    color:
                                                        const Color(0xFFF3F4F6),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14,
                                                        vertical: 6),
                                                    child: Text(
                                                        row.text.toUpperCase(),
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Color(
                                                                0xFF6B7280))),
                                                  );
                                                }
                                                if (row.isNewItem) {
                                                  return ListTile(
                                                    dense: true,
                                                    leading: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size: 18,
                                                        color: AppColors
                                                            .sellerGreen),
                                                    title: Text(
                                                        'Add "${row.text}" as a new item',
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .sellerGreen)),
                                                    onTap: () => _addItem(
                                                        row.text,
                                                        asNewItem: true),
                                                  );
                                                }
                                                final hint = ScrapWeightService
                                                    .pickerHints[row.text];
                                                return ListTile(
                                                  dense: true,
                                                  title: Text(
                                                      ScrapWeightService
                                                          .labelFor(row.text),
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                  subtitle: hint == null
                                                      ? null
                                                      : Text(hint,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Color(
                                                                      0xFF6B7280))),
                                                  onTap: () =>
                                                      onSelected(row.text),
                                                );
                                              },
                                            );
                                          }),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _itemInputCtrl,
                          builder: (context, value, _) {
                            final enabled = value.text.trim().isNotEmpty;
                            return ElevatedButton(
                              onPressed:
                                  enabled ? () => _addItem(_itemInputCtrl.text) : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sellerGreen,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors
                                      .sellerGreen
                                      .withValues(alpha: 0.3),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10))),
                              child: const Icon(Icons.add, size: 20),
                            );
                          },
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
                          final day = await showDatePicker(
                            context: context,
                            initialDate: now.add(const Duration(days: 1)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 30)),
                          );
                          if (day == null || !context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                            helpText: 'Preferred pickup time',
                          );
                          if (time == null) return;
                          final picked = DateTime(day.year, day.month,
                              day.day, time.hour, time.minute);
                          if (picked.isBefore(now)) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Pick a time later than now.')));
                            return;
                          }
                          setState(() {
                            _isAsap = false;
                            _scheduledDate = picked;
                          });
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
                                      ? '${_scheduledDate!.month}/${_scheduledDate!.day} ${formatTime(_scheduledDate!)}'
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
                      onPressed: () => setState(() => _vehicleOverride = null),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _editAddress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB))),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 20, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Pickup Address',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                    _address.isEmpty
                                        ? 'Tap to set address'
                                        : _address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827))),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF9CA3AF), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PickupMapPreview(
                    pin: _pin,
                    showError: _showPinError,
                    onTap: _openPinPage,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _bookingNotesCtrl,
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
                          onPressed: _canSubmit ? _submit : null,
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
                  if (_missingStep != null) ...[
                    const SizedBox(height: 8),
                    Text(_missingStep!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
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
    for (final item in _selectedItems) {
      final sizeClass =
          ScrapWeightService.instance.getSizeClass(item.className);

      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(_displayName(item),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(sizeClass,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280))),
                    ])),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 20, color: Color(0xFF9CA3AF)),
                  onPressed: () => setState(() {
                    if (item.quantity > 1) {
                      item.quantity--;
                    } else {
                      item.weightCtrl.dispose();
                      item.notesCtrl.dispose();
                      _selectedItems.remove(item);
                    }
                  }),
                ),
                Text('${item.quantity}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      size: 20, color: AppColors.sellerGreen),
                  onPressed: () => setState(() => item.quantity++),
                ),
              ],
            ),
            if (item.isCustom) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ObjectKey(item),
                initialValue: item.category,
                isDense: true,
                hint: const Text('Material type (required)',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: item.category == null
                              ? AppColors.error
                              : const Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.sellerGreen, width: 1.5)),
                ),
                items: MaterialPreferences.customItemCategories
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c == MaterialPreferences.other
                            ? 'Other / Not sure'
                            : c)))
                    .toList(),
                onChanged: (v) => setState(() => item.category = v),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: item.weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: 'kg',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.sellerGreen, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: item.notesCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Notes (optional)',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF9CA3AF)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.sellerGreen, width: 1.5)),
                    ),
                  ),
                ),
              ],
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
