import 'package:flutter/material.dart';
import '../core/address_format.dart';
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
  late final ParsedAddress _initial = parseAddress(widget.initialAddress);
  late final _streetCtrl = TextEditingController(text: _initial.street);
  late String? _barangay = _initial.barangay;
  late final String _city = _initial.city ?? supportedCities.first;
  bool _saving = false;
  // Errors appear under the fields after the first Save attempt.
  bool _showErrors = false;

  String? get _streetError {
    final s = _streetCtrl.text.trim();
    if (s.isEmpty) return 'Enter your street, block or lot';
    if (s.length < 3) return 'Street is too short';
    return null;
  }

  String? get _barangayError =>
      _barangay == null ? 'Select your barangay' : null;

  bool get _canSave => _streetError == null && _barangayError == null;

  String get _preview {
    if (_barangay == null && _streetCtrl.text.trim().isEmpty) return '';
    if (_barangay == null) return _streetCtrl.text.trim();
    return composeAddress(
        street: _streetCtrl.text, barangay: _barangay!, city: _city);
  }

  Future<void> _pickBarangay() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BarangaySheet(selected: _barangay),
    );
    if (picked != null) setState(() => _barangay = picked);
  }

  Future<void> _save() async {
    if (!_canSave) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _saving = true);
    final fullAddress = composeAddress(
        street: _streetCtrl.text, barangay: _barangay!, city: _city);
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
    final preview = _preview;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sellerGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.sellerGreen.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined,
                    color: AppColors.sellerGreen, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your address',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                          preview.isEmpty
                              ? 'Your address will appear here'
                              : preview,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: preview.isEmpty
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Street and block',
            error: _showErrors ? _streetError : null,
            child: TextField(
              controller: _streetCtrl,
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'e.g. Blk 4 Lot 12, Greenwood Subdivision',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Barangay',
            error: _showErrors ? _barangayError : null,
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: _pickBarangay,
                title: Text(
                    _barangay == null
                        ? 'Select barangay'
                        : formatBarangay(_barangay!),
                    style: TextStyle(
                        fontSize: 15,
                        color: _barangay == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary)),
                trailing: const Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'City',
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_city,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                subtitle: const Text('KiloTap currently serves Davao City only',
                    style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.lock_outline,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.sellerGreen.withValues(alpha: 0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('SAVE ADDRESS',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? error;
  const _SectionCard({required this.title, required this.child, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: error != null ? AppColors.error : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(error!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ),
        ],
      ),
    );
  }
}

// Search-as-you-type picker for the 182 barangays — easier than scrolling a
// dropdown. The list is already sorted (numbered ones numerically).
class _BarangaySheet extends StatefulWidget {
  final String? selected;
  const _BarangaySheet({required this.selected});

  @override
  State<_BarangaySheet> createState() => _BarangaySheetState();
}

class _BarangaySheetState extends State<_BarangaySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matches = davaoCityBarangays
        .where((b) => q.isEmpty || b.toLowerCase().contains(q))
        .toList();
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Select barangay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search barangay',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: matches.isEmpty
                    ? const Center(
                        child: Text('No barangay found',
                            style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final b = matches[i];
                          return ListTile(
                            title: Text(formatBarangay(b)),
                            trailing: b == widget.selected
                                ? const Icon(Icons.check,
                                    color: AppColors.sellerGreen)
                                : null,
                            onTap: () => Navigator.pop(context, b),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
