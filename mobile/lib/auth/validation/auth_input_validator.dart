class AuthInputValidator {
  const AuthInputValidator._();

  static final RegExp _namePattern = RegExp(
    r"^[A-Za-z\u0621-\u063A\u0641-\u064A\u066E-\u06D3\u064B-\u065F\u0670]+(?:[ '\-’][A-Za-z\u0621-\u063A\u0641-\u064A\u066E-\u06D3\u064B-\u065F\u0670]+)*$",
    unicode: true,
  );
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String normalizeName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String? name(String value) {
    final normalized = normalizeName(value);
    if (normalized.isEmpty) return 'الاسم مطلوب.';
    if (normalized.length < 2) return 'يجب ألا يقل الاسم عن حرفين.';
    if (normalized.length > 100) return 'يجب ألا يزيد الاسم عن 100 حرف.';
    if (!_namePattern.hasMatch(normalized)) {
      return 'استخدم حروفًا عربية أو إنجليزية ومسافات أو شرطات أو فواصل عليا فقط.';
    }
    return null;
  }

  static String? email(String value) {
    final normalized = normalizeEmail(value);
    if (normalized.isEmpty) return 'البريد الإلكتروني مطلوب.';
    if (normalized.length > 255 || !_emailPattern.hasMatch(normalized)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'كلمة المرور مطلوبة.';
    if (value.length < 12 || value.length > 128) {
      return 'استخدم كلمة مرور من 12 إلى 128 حرفًا.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value) ||
        !RegExp(r'[A-Z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير ورقم.';
    }
    return null;
  }

  static String? confirmation(String password, String confirmation) {
    if (confirmation.isEmpty) return 'تأكيد كلمة المرور مطلوب.';
    if (password != confirmation) return 'تأكيد كلمة المرور غير مطابق.';
    return null;
  }
}
