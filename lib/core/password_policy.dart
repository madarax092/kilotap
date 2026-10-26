// Password rules for new passwords (register, Google sign-up): at least 12
// characters, a mix of upper and lower case letters, a number and a symbol,
// and nothing taken from the user's own details.

class PasswordRule {
  final String label;
  final bool Function(String password) test;
  const PasswordRule(this.label, this.test);
}

const int passwordMinLength = 12;

final List<PasswordRule> basePasswordRules = [
  PasswordRule('At least $passwordMinLength characters',
      (p) => p.length >= passwordMinLength),
  PasswordRule('An uppercase letter (A-Z)', (p) => p.contains(RegExp(r'[A-Z]'))),
  PasswordRule('A lowercase letter (a-z)', (p) => p.contains(RegExp(r'[a-z]'))),
  PasswordRule('A number (0-9)', (p) => p.contains(RegExp(r'\d'))),
  PasswordRule('A symbol, like ! @ # \$ %',
      (p) => p.contains(RegExp(r'[^A-Za-z0-9\s]'))),
];

const String personalDetailsRuleLabel =
    'No part of your name, email or phone number';

/// True when the password contains a piece of the user's own details: a
/// word of the name (3+ letters), the part of the email before '@' (3+
/// characters), or the last 7 digits of the phone number.
bool passwordHasPersonalDetails(String password,
    {String name = '', String email = '', String phone = ''}) {
  final p = password.toLowerCase();
  if (p.isEmpty) return false;
  final parts = <String>[
    ...name.toLowerCase().split(RegExp(r'[^a-z]+')),
    email.toLowerCase().split('@').first,
  ].where((s) => s.length >= 3);
  if (parts.any(p.contains)) return true;
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 7 && p.contains(digits.substring(digits.length - 7))) {
    return true;
  }
  return false;
}

/// The first unmet rule as an error message, or null when the password is
/// acceptable.
String? passwordError(String password,
    {String name = '', String email = '', String phone = ''}) {
  if (password.isEmpty) return 'Create a password';
  for (final r in basePasswordRules) {
    if (!r.test(password)) return 'Password needs: ${r.label.toLowerCase()}';
  }
  if (passwordHasPersonalDetails(password,
      name: name, email: email, phone: phone)) {
    return 'Password must not contain your name, email or phone number';
  }
  return null;
}
