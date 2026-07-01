import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/kilotap_logo.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class SellerAuthScreen extends ConsumerStatefulWidget {
  const SellerAuthScreen({super.key});

  @override
  ConsumerState<SellerAuthScreen> createState() => _SellerAuthScreenState();
}

class _SellerAuthScreenState extends ConsumerState<SellerAuthScreen> {
  bool _isSignUp = true;
  SellerAccountType? _selectedAccountType;
  bool _showForm = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);

    if (_isSignUp) {
      await notifier.signUpSeller(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        accountType: _selectedAccountType ?? SellerAccountType.individual,
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
        data: (_) => context.go('/seller-home'),
        error: (e, _) => _showError(e.toString()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

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
                  _isSignUp ? 'Seller Registration' : 'Welcome Back, Seller',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sell your recyclable scrap easily',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Tab switcher
                AuthTabSwitcher(
                  isSignUp: _isSignUp,
                  activeColor: AppColors.sellerGreen,
                  onSignUpTap: () => setState(() {
                    _isSignUp = true;
                    _showForm = false;
                    _selectedAccountType = null;
                  }),
                  onLogInTap: () => setState(() {
                    _isSignUp = false;
                    _showForm = false;
                  }),
                ),
                const SizedBox(height: 24),

                if (_isSignUp && !_showForm) ...[
                  _buildAccountTypeSelector(),
                ] else ...[
                  _buildLoginForm(isLoading),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose your account type',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _AccountTypeCard(
          icon: Icons.person_outline_rounded,
          title: 'Individual / Household',
          subtitle: 'Sell scrap from your home',
          isSelected: _selectedAccountType == SellerAccountType.individual,
          onTap: () => setState(() => _selectedAccountType = SellerAccountType.individual),
        ),
        const SizedBox(height: 12),
        _AccountTypeCard(
          icon: Icons.business_outlined,
          title: 'Business / Organization',
          subtitle: 'Sell scrap from your business',
          isSelected: _selectedAccountType == SellerAccountType.business,
          onTap: () => setState(() => _selectedAccountType = SellerAccountType.business),
        ),
        const SizedBox(height: 24),
        KiloTapButton(
          label: 'Continue',
          backgroundColor: AppColors.sellerGreen,
          onPressed: _selectedAccountType == null
              ? null
              : () => setState(() => _showForm = true),
        ),
        const SizedBox(height: 20),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isSignUp && _showForm) ...[
          // Show selected account type chip
          if (_selectedAccountType != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Chip(
                avatar: const Icon(Icons.person_outline, size: 16),
                label: Text(
                  _selectedAccountType == SellerAccountType.individual
                      ? 'Individual / Household'
                      : 'Business / Organization',
                ),
                backgroundColor: AppColors.sellerGreenSurface,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.sellerGreen,
                ),
              ),
            ),
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
            label: 'Address',
            hint: '123 Rizal Ave, Quezon City',
            controller: _addressCtrl,
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textHint, size: 20),
            validator: (v) => (v?.isEmpty ?? true) ? 'Address is required' : null,
          ),
          const SizedBox(height: 16),
        ],
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
          validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
        ),
        if (_isSignUp && _showForm) ...[
          const SizedBox(height: 16),
          KiloTextField(
            label: 'Confirm Password',
            hint: '••••••••',
            controller: _confirmPasswordCtrl,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20),
            textInputAction: TextInputAction.done,
            validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
          ),
        ],
        const SizedBox(height: 24),
        KiloTapButton(
          label: _isSignUp ? 'Create Account' : 'Log In',
          backgroundColor: AppColors.sellerGreen,
          isLoading: isLoading,
          onPressed: _handleSubmit,
        ),
        const SizedBox(height: 20),
        _buildSocialButtons(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        const LabeledDivider(),
        const SizedBox(height: 16),
        Row(
          children: [
            SocialLoginButton(
              label: 'Google',
              icon: Icons.g_mobiledata_rounded,
              iconColor: Colors.red,
              onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(
                    role: UserRole.seller,
                  ),
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
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.sellerGreen : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.sellerGreen, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.sellerGreen,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.sellerGreen,
            ),
          ],
        ),
      ),
    );
  }
}
