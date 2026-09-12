import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';

class HouseholdPersonalInfoPage extends StatefulWidget {
  const HouseholdPersonalInfoPage({super.key});

  @override
  State<HouseholdPersonalInfoPage> createState() =>
      _HouseholdPersonalInfoPageState();
}

class _HouseholdPersonalInfoPageState extends State<HouseholdPersonalInfoPage> {
  late final _nameCtrl =
      TextEditingController(text: AuthState.instance.displayName);
  late final _phoneCtrl = TextEditingController(text: AuthState.instance.phone);
  late final _addrCtrl =
      TextEditingController(text: AuthState.instance.address);
  String _language = 'Bisaya';
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await AuthService.instance.updateUserAccount(
      displayName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    await AuthService.instance.updateSellerProfile(
      address: _addrCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Personal Info',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 12),
          const Text('Update your personal information',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _Field(label: 'Full Name', controller: _nameCtrl),
          _Field(label: 'Phone Number', controller: _phoneCtrl),
          _Field(
              label: 'Email', value: AuthState.instance.email, readOnly: true),
          _Field(label: 'Address', controller: _addrCtrl),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.language,
                  color: AppColors.textSecondary, size: 22),
              title: const Text('Language',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              trailing: SizedBox(
                width: 130,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isDense: true,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    items: ['Bisaya', 'Tagalog', 'English']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerGreen,
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
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? value;
  final bool readOnly;
  const _Field(
      {required this.label,
      this.controller,
      this.value,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: readOnly
          ? ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              subtitle: Text(value ?? '',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
    );
  }
}
