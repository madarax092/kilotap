import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;

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
      final route = role == 'Collector'
          ? '/collector'
          : role == 'Admin'
              ? '/admin'
              : '/household';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      _showError('Invalid email or password. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 28, right: 28, bottom: 40),
            child: Column(children: [
              Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/kilotap_logo.png'),
            ),
            const SizedBox(height: 16),
            const Text('KiloTap',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
            const Text('Tap the app, trade the scrap.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 50),
            TextField(
              controller: _emailCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Phone or Email',
                labelStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppColors.inputGrey,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.sellerGreen, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: _obscureText,
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppColors.inputGrey,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.sellerGreen, width: 1.5)),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sellerGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('LOG IN',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.divider)),
                onPressed: _loading ? null : _login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/google.png',
                        height: 20, width: 20),
                    const SizedBox(width: 12),
                    const Text('Continue with Google',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                      text: 'NEW TO KILOTAP? ',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'REGISTER HERE',
                          style: TextStyle(
                              color: AppColors.sellerGreen,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                )),
          ]),
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
