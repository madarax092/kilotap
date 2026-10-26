import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/input_validators.dart';
import '../core/password_policy.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

/// The account form shared by the Household and Collector register screens.
/// Every field shows its own error under it. A Google sign-up fills in the
/// name and email and still asks for a password, which is attached to the
/// same account so the user can sign in either way later.
class RegisterForm extends StatefulWidget {
  final String role;
  final Color accent;
  final String emailHint;
  final String addressHint;
  final bool addressRequired;
  final String fallbackAddress;
  final String homeRoute;
  final Widget? footer;
  final String? googleUid;
  final String? googleEmail;
  final String? googleDisplayName;

  const RegisterForm({
    super.key,
    required this.role,
    required this.accent,
    required this.emailHint,
    required this.addressHint,
    required this.addressRequired,
    required this.fallbackAddress,
    required this.homeRoute,
    this.footer,
    this.googleUid,
    this.googleEmail,
    this.googleDisplayName,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: widget.googleDisplayName ?? '');
  final _phoneCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController(text: widget.googleEmail ?? '');
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  bool _loading = false;
  String? _submitError;

  bool get _isGoogleFlow => widget.googleUid != null;

  @override
  void initState() {
    super.initState();
    // The checklist under the password follows what is typed.
    for (final c in [_passCtrl, _nameCtrl, _emailCtrl, _phoneCtrl]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmPassCtrl,
      _addrCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _submitError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final addr = _addrCtrl.text.trim();
    final address = addr.isNotEmpty ? addr : widget.fallbackAddress;

    setState(() => _loading = true);
    final auth = AuthService.instance;
    final role = _isGoogleFlow
        ? await auth.completeGoogleRegistration(
            uid: widget.googleUid!,
            email: email,
            password: pass,
            fullName: name,
            phone: phone,
            role: widget.role,
            address: address)
        : await auth.register(
            email: email,
            password: pass,
            fullName: name,
            phone: phone,
            role: widget.role,
            address: address);
    if (!mounted) return;
    setState(() => _loading = false);
    if (role != null) {
      Navigator.pushNamedAndRemoveUntil(context, widget.homeRoute, (r) => false);
    } else {
      setState(() => _submitError =
          auth.takeAuthError() ?? 'Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passCtrl.text;
    final personalOk = pass.isNotEmpty &&
        !passwordHasPersonalDetails(pass,
            name: _nameCtrl.text, email: _emailCtrl.text, phone: _phoneCtrl.text);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 20),
          Text('ACCOUNT DETAILS',
              style: TextStyle(
                  fontSize: 11,
                  color: widget.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          _Field(
            label: 'Full Name',
            hint: 'Juan Dela Cruz',
            controller: _nameCtrl,
            accent: widget.accent,
            textCapitalization: TextCapitalization.words,
            validator: validateFullName,
          ),
          _Field(
            label: 'Mobile Number',
            hint: '09XXXXXXXXX',
            controller: _phoneCtrl,
            accent: widget.accent,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: validatePhMobile,
          ),
          _Field(
            label: 'Email Address',
            hint: widget.emailHint,
            controller: _emailCtrl,
            accent: widget.accent,
            keyboardType: TextInputType.emailAddress,
            readOnly: _isGoogleFlow,
            validator: validateEmail,
          ),
          if (_isGoogleFlow)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                  'Create a password too, so you can also sign in with '
                  'this email and password, not only with Google.',
                  style: TextStyle(
                      fontSize: 12, color: widget.accent, height: 1.4)),
            ),
          _Field(
            label: 'Password',
            hint: 'Create password',
            controller: _passCtrl,
            accent: widget.accent,
            obscure: true,
            bottomGap: 8,
            validator: (v) => passwordError(v ?? '',
                name: _nameCtrl.text,
                email: _emailCtrl.text,
                phone: _phoneCtrl.text),
          ),
          _PasswordChecklist(
            checks: [
              for (final r in basePasswordRules) (r.label, r.test(pass)),
              (personalDetailsRuleLabel, personalOk),
            ],
            accent: widget.accent,
          ),
          _Field(
            label: 'Confirm Password',
            hint: 'Re-enter password',
            controller: _confirmPassCtrl,
            accent: widget.accent,
            obscure: true,
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Re-enter your password';
              if (v != _passCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          _Field(
            label: widget.addressRequired ? 'Address' : 'Address (optional)',
            hint: widget.addressHint,
            controller: _addrCtrl,
            accent: widget.accent,
            validator: widget.addressRequired
                ? (v) => validateRequired(v, 'address')
                : null,
          ),
          if (widget.footer != null) ...[
            const SizedBox(height: 8),
            widget.footer!,
            const SizedBox(height: 20),
          ],
          if (_submitError != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Text(_submitError!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('CREATE ACCOUNT',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  final List<(String, bool)> checks;
  final Color accent;
  const _PasswordChecklist({required this.checks, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, ok) in checks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: ok ? AppColors.success : AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: ok
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

class _Field extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final Color accent;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final double bottomGap;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.accent,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.bottomGap = 20,
    this.validator,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late bool _obscureText = widget.obscure;

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomGap),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          readOnly: widget.readOnly,
          validator: widget.validator,
          style: TextStyle(
              fontSize: 15,
              color: widget.readOnly
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400),
            errorMaxLines: 2,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _border(const Color(0xFFE5E7EB)),
            enabledBorder: _border(const Color(0xFFE5E7EB)),
            focusedBorder: _border(widget.accent, 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.5),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 22),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ]),
    );
  }
}
