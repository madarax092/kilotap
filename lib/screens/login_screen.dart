import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'Household';

  void _login() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      _role == 'Collector' ? '/collector' : _role == 'Admin' ? '/admin' : '/household',
      (route) => false,
    );
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
              // Phone
              TextField(
                controller: _phoneCtrl,
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
              const SizedBox(height: 16),
              // Role selector — subtle chips
              Row(children: ['Household', 'Collector', 'Admin'].map((r) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _role == r ? _roleColor(r).withOpacity(0.08) : AppColors.inputGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _role == r ? _roleColor(r) : AppColors.divider),
                    ),
                    child: Text(r, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _role == r ? _roleColor(r) : AppColors.textSecondary)),
                  ),
                ),
              )).toList()),
              const SizedBox(height: 28),
              // Log In
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _roleColor(_role), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _login,
                  child: const Text('LOG IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 24),
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

  Color _roleColor(String r) {
    switch (r) { case 'Collector': return AppColors.buyerBlue; case 'Admin': return AppColors.adminRed; default: return AppColors.sellerGreen; }
  }

  @override void dispose() { _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}
