import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Demo user database — email → role
  static const _users = {
    'household@test.com': {'role': 'Household', 'pass': '123'},
    'collector@test.com': {'role': 'Collector', 'pass': '123'},
    'admin@test.com': {'role': 'Admin', 'pass': '123'},
  };

  void _login() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    // Look up user
    final user = _users[email];
    if (user != null && user['pass'] == pass) {
      final role = user['role']!;
      final route = role == 'Collector' ? '/collector' : role == 'Admin' ? '/admin' : '/household';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials. Try household@test.com / collector@test.com / admin@test.com (password: 123)')),
      );
    }
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
              // Logo
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/kilotap_logo.png'),
              ),
              const SizedBox(height: 16),
              const Text('KiloTap', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const Text('Tap the App. Trade the Scrap.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 50),
              // Email
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Phone or Email', labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1),
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sellerGreen)),
                ),
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password', labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1),
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.sellerGreen)),
                ),
              ),
              const SizedBox(height: 28),
              // Log In
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.sellerGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _login,
                  child: const Text('LOG IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Demo: household@test.com / collector@test.com / admin@test.com\nPassword: 123', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              const Divider(),
              // Google
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.divider)),
                  onPressed: _login,
                  child: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              // Register link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
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
