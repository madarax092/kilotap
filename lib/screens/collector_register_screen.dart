import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/davao_data.dart';
import '../services/auth_service.dart';

class CollectorRegisterScreen extends StatefulWidget {
  const CollectorRegisterScreen({super.key});
  @override State<CollectorRegisterScreen> createState() => _CollectorRegisterScreenState();
}

class _CollectorRegisterScreenState extends State<CollectorRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _vehicleType = '';
  String _years = '';
  String _area = '';
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

    final role = await AuthService.instance.register(
      email: email, password: pass, fullName: name, phone: phone, role: 'Collector', address: 'Davao City',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (role != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/collector', (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Try a different email.')));
    }
  }

  @override void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Register as Collector', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.buyerBlue.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.buyerBlue.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.delivery_dining, color: AppColors.buyerBlue, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Collector — Sign up now. Verify later to start accepting pickups.', style: TextStyle(color: AppColors.buyerBlue, fontWeight: FontWeight.w600, fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 24),
          _Field('Full Name', 'Juan Dela Cruz', controller: _nameCtrl),
          _Field('Phone Number', '+63 9XX XXX XXXX', controller: _phoneCtrl),
          _Field('Email', 'collector@email.com', controller: _emailCtrl),
          _Field('Password', 'Create password', controller: _passCtrl, obscure: true),
          const SizedBox(height: 20),
          _Dropdown('Vehicle Type', DavaoData.vehicleTypes, (v) => _vehicleType = v ?? ''),
          _Dropdown('Years Collecting', ['1 year', '2 years', '3 years', '4 years', '5+ years'], (v) => _years = v ?? ''),
          _Dropdown('Usual Route Areas', DavaoData.barangays, (v) => _area = v ?? ''),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buyerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _loading ? null : _register,
              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('Documents can be submitted later\nin your Profile to unlock full access.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController? controller;
  final bool obscure;
  const _Field(this.label, this.hint, {this.controller, this.obscure = false});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)), child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration.collapsed(hintText: hint, hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted)), style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
      ]),
    );
  }
}

// Dropdown with search — for barangay list (18+ items)
class _Dropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown(this.label, this.items, this.onChanged);
  @override State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  String? _value;

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.inputGrey, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _value,
              hint: const Text('Select...', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              isExpanded: true,
              dropdownColor: AppColors.pureWhite,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              items: widget.items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) { setState(() => _value = v); widget.onChanged(v); },
            ),
          ),
        ),
      ]),
    );
  }
}
