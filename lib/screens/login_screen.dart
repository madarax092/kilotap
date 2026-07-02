import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'Household';

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.sellerGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('K', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('KiloTap', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const Text('Tap the App. Trade the Scrap.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              // Phone
              TextField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                ),
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: _passCtrl, obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true, fillColor: AppColors.inputGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                ),
              ),
              const SizedBox(height: 12),
              // Role selector
              Row(children: ['Household', 'Collector', 'Admin'].map((r) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _role == r ? _roleColor(r).withOpacity(0.1) : AppColors.inputGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _role == r ? _roleColor(r) : AppColors.divider),
                    ),
                    child: Text(r, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _role == r ? _roleColor(r) : AppColors.textSecondary)),
                  ),
                ),
              )).toList()),
              const SizedBox(height: 24),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _roleColor(_role), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/${_role.toLowerCase()}'),
                  child: const Text('LOG IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('New to KiloTap? Register here', style: TextStyle(color: AppColors.sellerGreen, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Collector': return AppColors.buyerBlue;
      case 'Admin': return AppColors.adminRed;
      default: return AppColors.sellerGreen;
    }
  }

  @override void dispose() { _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}
