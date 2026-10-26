import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/input_validators.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';
import 'address_entry_page.dart';

/// The Personal Info page shared by households and collectors: name and
/// mobile number (each with its own error), read-only email, and the
/// address, edited on its own page.
class PersonalInfoForm extends StatefulWidget {
  final Color accent;
  final String Function() address;
  final Future<void> Function(String address)? onSaveAddress;

  const PersonalInfoForm({
    super.key,
    required this.accent,
    required this.address,
    this.onSaveAddress,
  });

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: AuthState.instance.displayName);
  late final _phoneCtrl = TextEditingController(text: AuthState.instance.phone);
  bool _saving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateUserAccount(
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: AppColors.error));
    }
  }

  Future<void> _editAddress() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddressEntryPage(
                initialAddress: widget.address(),
                onSave: widget.onSaveAddress)));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
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
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 12),
            const Text('Update your personal information',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _InputField(
              label: 'Full Name',
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              validator: validateFullName,
            ),
            _InputField(
              label: 'Mobile Number',
              hint: '09XXXXXXXXX',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: validatePhMobile,
            ),
            _ReadOnlyField(label: 'Email', value: AuthState.instance.email),
            _ReadOnlyField(
                label: 'Address',
                value: widget.address(),
                emptyText: 'Tap to set address',
                onTap: _editAddress),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
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
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?) validator;

  const _InputField({
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorMaxLines: 2,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: border(Colors.transparent),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(AppColors.textSecondary),
          errorBorder: border(AppColors.error),
          focusedErrorBorder: border(AppColors.error),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label, value;
  final String emptyText;
  final VoidCallback? onTap;
  const _ReadOnlyField(
      {required this.label,
      required this.value,
      this.emptyText = '',
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: onTap,
          trailing: onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
              : null,
          title: Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          subtitle: Text(value.isEmpty ? emptyText : value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}
