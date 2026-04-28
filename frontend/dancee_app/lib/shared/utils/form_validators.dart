/// Form validation utilities.
///
/// All validator methods return a dot-separated translation key string on
/// failure (e.g. `'validation.emailRequired'`) or [null] on success.
/// The UI layer resolves these keys to translated strings via
/// [resolveValidationKey] from `shared/utils/auth_translations.dart`,
/// decoupling form validation logic from the current locale (design
/// Properties 5–7 — Req 4.6, 5.7–5.9, 9.4, 16.1–16.8).
class FormValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.emailRequired';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'validation.invalidEmail';
    }
    return null;
  }

  static String? notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.fieldRequired';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return 'validation.passwordTooShort';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'validation.passwordsDoNotMatch';
    }
    return null;
  }

  static int passwordStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }
}
