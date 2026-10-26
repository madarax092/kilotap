import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/input_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/vehicle_verification.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';
import '../../services/firestore_service.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({super.key});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleEntry {
  String type;
  String photoUrl;
  bool uploading = false;
  final TextEditingController capacityCtrl;
  // Vehicles[].Plate_Number — not in the paper's Table 9. A pushcart has none.
  final TextEditingController plateCtrl;
  _VehicleEntry(
      {required this.type,
      this.photoUrl = '',
      required this.capacityCtrl,
      String plate = ''})
      : plateCtrl = TextEditingController(text: plate);

  void dispose() {
    capacityCtrl.dispose();
    plateCtrl.dispose();
  }
}

// Philippine plates: letters and numbers, 4 to 8 characters, with an
// optional space or dash (e.g. ABC 1234, 123 ABC, AB 12345).
String? _validatePlate(String? value) {
  final v = (value ?? '').trim().toUpperCase();
  if (v.isEmpty) return 'Enter the plate number';
  final compact = v.replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^[A-Z0-9]{4,8}$').hasMatch(compact) ||
      !compact.contains(RegExp(r'[A-Z]')) ||
      !compact.contains(RegExp(r'\d'))) {
    return 'Use letters and numbers, like ABC 1234';
  }
  return null;
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  static const _maxVehicles = 2;
  final _formKey = GlobalKey<FormState>();
  late final List<_VehicleEntry> _entries = _loadEntries();
  bool _saving = false;

  // Per-vehicle approval only applies once the account itself is verified —
  // before that, every vehicle is reviewed as part of the application.
  bool get _isVerified =>
      AuthState.instance.verificationStatus == 'Verified';

  bool _isApproved(_VehicleEntry e) =>
      AuthState.instance.isVehicleApproved(e.type);

  List<_VehicleEntry> _loadEntries() {
    final stored = AuthState.instance.vehicles;
    if (stored.isEmpty) {
      return [
        _VehicleEntry(
            type: 'Pushcart', capacityCtrl: TextEditingController(text: '20')),
      ];
    }
    return stored
        .map((v) => _VehicleEntry(
              type: v['Vehicle_Type'] as String? ?? 'Pushcart',
              photoUrl: v['Photo_URL'] as String? ?? '',
              capacityCtrl: TextEditingController(
                  text: '${(v['Vehicle_Capacity_Kg'] as num?) ?? 20}'),
              plate: v['Plate_Number'] as String? ?? '',
            ))
        .toList();
  }

  void _addVehicle() {
    if (_entries.length >= _maxVehicles) return;
    setState(() => _entries.add(_VehicleEntry(
        type: 'Pushcart', capacityCtrl: TextEditingController(text: '20'))));
  }

  void _removeVehicle(int i) {
    if (_entries.length <= 1) return;
    setState(() {
      _entries[i].dispose();
      _entries.removeAt(i);
    });
  }

  void _changeType(_VehicleEntry e, String type) {
    if (type == e.type) return;
    setState(() {
      e.type = type;
      // The old photo shows a different vehicle — it can't back this one.
      e.photoUrl = '';
    });
  }

  Future<void> _pickPhoto(_VehicleEntry e) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final photo = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (photo == null) return;
    setState(() => e.uploading = true);
    try {
      final url = await FirestoreService().uploadVehiclePhoto(File(photo.path));
      if (mounted) setState(() => e.photoUrl = url);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not upload photo: $err')));
      }
    } finally {
      if (mounted) setState(() => e.uploading = false);
    }
  }

  String? _validate() {
    if (_entries.any((e) => e.uploading)) {
      return 'Wait for the photo upload to finish.';
    }
    if (!_isVerified) return null;
    if (!_entries.any(_isApproved)) {
      return 'Keep at least one approved vehicle — new vehicles can\'t be '
          'used until an admin approves them.';
    }
    if (_entries.any((e) => !_isApproved(e) && e.photoUrl.isEmpty)) {
      return 'Add a photo for each new vehicle so an admin can approve it.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _saving = true);
    final vehicles = _entries
        .map((e) => {
              'Vehicle_Type': e.type,
              'Vehicle_Capacity_Kg': double.tryParse(e.capacityCtrl.text) ?? 0,
              if (e.photoUrl.isNotEmpty) 'Photo_URL': e.photoUrl,
              if (vehicleNeedsPlate(e.type))
                'Plate_Number': e.plateCtrl.text.trim().toUpperCase(),
            })
        .toList();
    try {
      await AuthService.instance.updateCollectorVehicles(vehicles);
    } catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save vehicles: $err')));
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (_isVerified && _entries.any((e) => !_isApproved(e))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Saved. New vehicles are pending admin approval — until then '
              'you can only accept bookings with your approved vehicle.')));
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Vehicle Details',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          Text(
              _isVerified
                  ? 'Register up to 2 vehicles. A vehicle you add now needs '
                      'admin approval before you can go online with it.'
                  : 'Register up to 2 vehicles. You\'ll choose which one is '
                      'active before going online.',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          for (var i = 0; i < _entries.length; i++) ...[
            _VehicleCard(
              entry: _entries[i],
              status: !_isVerified
                  ? null
                  : _isApproved(_entries[i])
                      ? _ApprovalStatus.approved
                      : _ApprovalStatus.pending,
              onTypeChanged: (v) => _changeType(_entries[i], v),
              onPickPhoto: () => _pickPhoto(_entries[i]),
              onRemove: _entries.length > 1 ? () => _removeVehicle(i) : null,
            ),
            const SizedBox(height: 10),
          ],
          if (_entries.length < _maxVehicles)
            OutlinedButton.icon(
              onPressed: _addVehicle,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.buyerBlue,
                side: const BorderSide(color: AppColors.buyerBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Vehicle'),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The system recommends but does not enforce. You decide if your vehicle can handle each booking.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buyerBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }
}

enum _ApprovalStatus { approved, pending }

class _VehicleCard extends StatelessWidget {
  final _VehicleEntry entry;
  // Null before the account is verified (no per-vehicle badge then).
  final _ApprovalStatus? status;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback? onRemove;

  const _VehicleCard({
    required this.entry,
    required this.status,
    required this.onTypeChanged,
    required this.onPickPhoto,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final approved = status == _ApprovalStatus.approved;
    final badgeColor = approved ? AppColors.success : AppColors.warning;
    return Material(
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: [
        if (status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(approved ? 'Approved' : 'Pending approval',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor)),
              ),
            ]),
          ),
        ListTile(
          leading: const Icon(Icons.local_shipping_outlined,
              color: AppColors.textSecondary, size: 22),
          title: const Text('Vehicle Type',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing: SizedBox(
            width: onRemove != null ? 160 : 140,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: entry.type,
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buyerBlue),
                      items: AppConstants.vehicleTypes
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => onTypeChanged(v!),
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        ListTile(
          leading: const Icon(Icons.scale_outlined,
              color: AppColors.textSecondary, size: 22),
          title: const Text('Max Capacity (kg)',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              controller: entry.capacityCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'kg',
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        // The capacity error shows on its own line under the row.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FormField<String>(
            validator: (_) => validatePositiveNumber(
                entry.capacityCtrl.text, 'capacity',
                max: 50000),
            builder: (field) => field.hasError
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(field.errorText!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.error)),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (vehicleNeedsPlate(entry.type))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextFormField(
              controller: entry.plateCtrl,
              textCapitalization: TextCapitalization.characters,
              validator: _validatePlate,
              decoration: InputDecoration(
                labelText: 'Plate Number',
                hintText: 'ABC 1234',
                prefixIcon: const Icon(Icons.pin_outlined,
                    color: AppColors.textSecondary, size: 22),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ListTile(
          onTap: entry.uploading ? null : onPickPhoto,
          leading: const Icon(Icons.photo_camera_outlined,
              color: AppColors.textSecondary, size: 22),
          title: Text(
              status == _ApprovalStatus.pending
                  ? 'Vehicle Photo (required)'
                  : 'Vehicle Photo',
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing: entry.uploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : entry.photoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(entry.photoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textMuted)))
                  : const Text('Add',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.buyerBlue)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ]),
      ),
    );
  }
}
