import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/kilotap_logo.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class BuyerAuthScreen extends ConsumerStatefulWidget {
  const BuyerAuthScreen({super.key});

  @override
  ConsumerState<BuyerAuthScreen> createState() => _BuyerAuthScreenState();
}

class _BuyerAuthScreenState extends ConsumerState<BuyerAuthScreen> {
  bool _isSignUp = true;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);

    if (_isSignUp) {
      await notifier.signUpBuyer(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        areaOfOperation: _areaCtrl.text.trim(),
      );
    } else {
      await notifier.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    }

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      authState.whenOrNull(
        data: (_) => context.go('/buyer-home'),
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.appCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.appCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo + Title
                const Center(child: KiloTapLogo(size: 60)),
                const SizedBox(height: 16),
                Text(
                  _isSignUp ? 'Buyer Registration' : 'Welcome Back, Buyer',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Collect and buy recyclable scrap',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Tab switcher (Buyer Blue)
                AuthTabSwitcher(
                  isSignUp: _isSignUp,
                  activeColor: AppColors.buyerBlue,
                  onSignUpTap: () => setState(() => _isSignUp = true),
                  onLogInTap: () => setState(() => _isSignUp = false),
                ),
                const SizedBox(height: 24),

                // Sign Up fields
                if (_isSignUp) ...[
                  KiloTextField(
                    label: 'Full Name',
                    hint: 'Juan Dela Cruz',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textHint, size: 20),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  KiloTextField(
                    label: 'Phone Number',
                    hint: '+63 917 xxx xxxx',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textHint, size: 20),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 16),
                  KiloTextField(
                    label: 'Area of Operation',
                    hint: 'Quezon City, Metro Manila',
                    controller: _areaCtrl,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textHint, size: 20),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Area is required' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Shared fields
                KiloTextField(
                  label: 'Email or Phone Number',
                  hint: 'you@email.com or +63 917...',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textHint, size: 20),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                KiloTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20),
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),

                // Submit button (Buyer Blue)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buyerBlue,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.pureWhite,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Create Account' : 'Log In',
                            style: AppTextStyles.buttonText,
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Social login
                const LabeledDivider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SocialLoginButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: Colors.red,
                      onPressed: () => ref
                          .read(authNotifierProvider.notifier)
                          .signInWithGoogle(role: UserRole.buyer),
                    ),
                    const SizedBox(width: 12),
                    SocialLoginButton(
                      label: 'Facebook',
                      icon: Icons.facebook,
                      iconColor: Colors.blue,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
