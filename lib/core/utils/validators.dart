class Validators {
  static String? requiredField(String? value, String name) {
    if (value == null || value.trim().isEmpty) {
      return '$name is required';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  static String? phone10(String? value) {
    final text = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (text.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{10}$').hasMatch(text)) return 'Phone must be 10 digits';
    return null;
  }

  static String? emailOrPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email or mobile is required';

    if (text.contains('@')) {
      return email(text);
    }

    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid email or mobile number';
    }
    return null;
  }
}
