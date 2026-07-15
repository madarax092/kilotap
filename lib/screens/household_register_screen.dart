import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
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
  final _addrCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }
    setState(() => _loading = true);
    final role = await AuthService.instance.register(email: email, password: pass, fullName: name, phone: phone, role: 'Household', address: addr.isNotEmpty ? addr : 'Maa, Davao City');
    if (!mounted) return;
    setState(() => _loading = false);
    if (role != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/household', (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Try a different email.')));
    }
  }

  @override void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _addrCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Register as Household', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 20),
          const Text('ACCOUNT DETAILS', style: TextStyle(fontSize: 11, color: AppColors.sellerGreen, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 14),
          _Field(label: 'Full Name', hint: 'Juan Dela Cruz', controller: _nameCtrl),
          _Field(label: 'Phone Number', hint: '+63 9XX XXX XXXX', controller: _phoneCtrl),
          _Field(label: 'Email Address', hint: 'household@email.com', controller: _emailCtrl),
          _Field(label: 'Password', hint: 'Create password', controller: _passCtrl, obscure: true),
          _Field(label: 'Address', hint: 'Block/Lot/Street, Barangay, City', controller: _addrCtrl),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _loading ? null : _register,
              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
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
  const _Field({required this.label, required this.hint, this.controller, this.obscure = false});

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration.collapsed(hintText: hint, hintStyle: const TextStyle(fontSize: 15, color: Color(0xFFBBBBBB))),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ),
      ]),
    );
  }
}
