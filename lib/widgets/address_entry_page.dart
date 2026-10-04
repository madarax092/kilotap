import 'package:flutter/material.dart';
import '../core/constants/davao_barangays.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class AddressEntryPage extends StatefulWidget {
  final String initialAddress;
  // Defaults to the Household (ScrapSeller) save path — Collector's Personal
  // Info page passes AuthService.instance.updateCollectorAddress instead so
  // this one screen/form serves both roles.
  final Future<void> Function(String address)? onSave;

  const AddressEntryPage({
    super.key,
    required this.initialAddress,
    this.onSave,
  });

  @override
  State<AddressEntryPage> createState() => _AddressEntryPageState();
}

class _AddressEntryPageState extends State<AddressEntryPage> {
  late final _streetCtrl = TextEditingController(text: widget.initialAddress);
  String? _barangay;
  late String _city = supportedCities.first;
  bool _saving = false;

  Future<void> _save() async {
    final street = _streetCtrl.text.trim();
    if (street.isEmpty || _barangay == null) return;
    setState(() => _saving = true);
    final address = 'Barangay $_barangay, $_city';
    final fullAddress = '$street, $address';
    try {
      final save = widget.onSave ??
          (addr) => AuthService.instance.updateSellerProfile(address: addr);
      await save(fullAddress);
      if (!mounted) return;
      Navigator.pop(context, fullAddress);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not save address: $e'),
        backgroundColor: Colors.red,
      ));
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _streetCtrl.text.trim().isNotEmpty && _barangay != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Address',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Subdivision / Block / Lot / Street',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _streetCtrl,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Blk 4 Lot 12, Greenwood Subdivision',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Barangay',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: _barangay,
                isExpanded: true,
                menuMaxHeight: 400,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  hintText: 'Select barangay',
                ),
                items: davaoCityBarangays
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _barangay = v),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('City',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: _city,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                items: supportedCities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _city = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.sellerGreen.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving || !canSave ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('SAVE ADDRESS',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
