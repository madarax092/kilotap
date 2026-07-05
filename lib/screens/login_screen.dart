import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _loading = true);

    final role = await AuthService.instance.signIn(email, pass);

    if (!mounted) return;
    setState(() => _loading = false);

    if (role != null) {
      final route = role == 'Collector' ? '/collector' : role == 'Admin' ? '/admin' : '/household';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      _showError('Invalid email or password. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 60),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/kilotap_logo.png'),
              ),
              const SizedBox(height: 16),
              const Text('KiloTap', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const Text('Your Scrap , Their Livelihood, One Tap Away.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 50),
              TextField(
                controller: _emailCtrl,
                enabled: !_loading,
                decoration: InputDecoration(
                  labelText: 'Phone or Email', labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1),
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sellerGreen)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                enabled: !_loading,
                decoration: InputDecoration(
                  labelText: 'Password', labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1),
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sellerGreen)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _loading ? null : _login,
                  child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('LOG IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.divider)),
                  onPressed: _loading ? null : _login,
                  child: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loading ? null : () => Navigator.pushNamed(context, '/register'),
                child: const Text('New to KiloTap? Register here', style: TextStyle(color: AppColors.sellerGreen, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}
