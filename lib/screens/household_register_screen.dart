import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/davao_data.dart';
import '../services/auth_service.dart';

class HouseholdRegisterScreen extends StatefulWidget {
  const HouseholdRegisterScreen({super.key});
  @override State<HouseholdRegisterScreen> createState() => _HouseholdRegisterScreenState();
}

class _HouseholdRegisterScreenState extends State<HouseholdRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _barangay = '';
  String _housingType = '';
  bool _loading = false;

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }
    setState(() => _loading = true);
    final role = await AuthService.instance.register(email, pass, name, phone, 'Household', extraFields: {'barangay': _barangay, 'housingType': _housingType});
    if (!mounted) return;
    setState(() => _loading = false);
    if (role != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/household', (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Try a different email.')));
    }
  }

  @override void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(backgroundColor: AppColors.canvas, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)), title: const Text('Register as Household', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 28), children: [
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.sellerGreen.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.sellerGreen.withOpacity(0.2))), child: const Row(children: [Icon(Icons.home, color: AppColors.sellerGreen, size: 20), SizedBox(width: 8), Text('Household — Sell your scrap', style: TextStyle(color: AppColors.sellerGreen, fontWeight: FontWeight.w700, fontSize: 13))])),
        const SizedBox(height: 24),
        _Step('STEP 1 OF 2 — VERIFY PHONE', AppColors.sellerGreen),
        _Field('Phone Number', '+63 9XX XXX XXXX', controller: _phoneCtrl, action: 'SEND OTP'),
        _Field('OTP Code', 'Enter 6-digit code'),
        const SizedBox(height: 20),
        _Step('STEP 2 OF 2 — PROFILE', AppColors.sellerGreen),
        _Field('Full Name', 'Juan Dela Cruz', controller: _nameCtrl),
        _Field('Email', 'household@email.com', controller: _emailCtrl),
        _Field('Password', 'Create password', controller: _passCtrl, obscure: true),
        _Drop('Barangay', DavaoData.barangays, (v) => _barangay = v ?? ''),
        _Field('Address', 'Block/Lot/Street'),
        _Drop('Housing Type', DavaoData.housingTypes, (v) => _housingType = v ?? ''),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _loading ? null : _register, child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _Step extends StatelessWidget { final String label; final Color color; const _Step(this.label, this.color); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700))); }

class _Field extends StatelessWidget {
  final String label, hint; final TextEditingController? controller; final String? action; final bool obscure;
  const _Field(this.label, this.hint, {this.controller, this.action, this.obscure = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    const SizedBox(height: 4),
    action != null ? Row(children: [
      Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: TextField(controller: controller, decoration: InputDecoration.collapsed(hintText: hint, hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted)), style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)))),
      const SizedBox(width: 8),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {}, child: Text(action!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
    ]) : Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration.collapsed(hintText: hint, hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted)), style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
  ]));
}

class _Drop extends StatefulWidget { final String label; final List<String> items; final ValueChanged<String?> onChanged; const _Drop(this.label, this.items, this.onChanged); @override State<_Drop> createState() => _DropState(); }
class _DropState extends State<_Drop> { String? _value; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _value, hint: const Text('Select...', style: TextStyle(fontSize: 14, color: AppColors.textMuted)), isExpanded: true, dropdownColor: AppColors.pureWhite, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary), items: widget.items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(), onChanged: (v) { setState(() => _value = v); widget.onChanged(v); })))])); }
