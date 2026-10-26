// Shared form-field validators. Each returns an error message to show under
// the field, or null when the value is fine.

String? validateRequired(String? value, String fieldName) {
  if ((value ?? '').trim().isEmpty) return 'Enter your $fieldName';
  return null;
}

String? validateFullName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter your full name';
  if (v.length < 2) return 'Name is too short';
  if (!RegExp(r"^[A-Za-zÀ-ÿÑñ.' -]+$").hasMatch(v)) {
    return 'Use letters only (no numbers or symbols)';
  }
  return null;
}

/// Philippine mobile number: 11 digits starting with 09.
String? validatePhMobile(String? value, {bool required = true}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return required ? 'Enter your mobile number' : null;
  if (!RegExp(r'^09\d{9}$').hasMatch(v)) {
    return 'Enter an 11-digit mobile number starting with 09';
  }
  return null;
}

String? validateEmail(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter your email address';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v)) {
    return 'Enter a valid email, like name@email.com';
  }
  return null;
}

/// A positive number, optionally capped (e.g. a weight or a capacity).
String? validatePositiveNumber(String? value, String fieldName,
    {double? max, bool required = true}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return required ? 'Enter the $fieldName' : null;
  final n = double.tryParse(v);
  if (n == null) return 'Enter a number';
  if (n <= 0) return '${_cap(fieldName)} must be more than 0';
  if (max != null && n > max) {
    return '${_cap(fieldName)} must be ${max.toStringAsFixed(0)} or less';
  }
  return null;
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
