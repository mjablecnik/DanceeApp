// Feature: firebase-auth
// Task 2.3: Property tests for FormValidators
// Properties covered:
//   Property 5: Email format validation
//   Property 6: Password minimum length validation
//   Property 7: Confirm password equality validation
//   Property 10: Password strength output range

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/shared/utils/form_validators.dart';

// ---------------------------------------------------------------------------
// Property 5: Email format validation
// ---------------------------------------------------------------------------

void _propertyEmailFormatValidation() {
  // Requirements: 4.6, 5.7, 9.4, 16.1, 16.4, 16.8
  test('P5a: valid emails return null', () {
    const validEmails = [
      'user@example.com',
      'user.name@example.com',
      'user+tag@example.org',
      'user@sub.domain.com',
      'a@b.co',
      '123@numbers.io',
    ];

    for (final email in validEmails) {
      expect(
        FormValidators.email(email),
        isNull,
        reason: '"$email" should be valid',
      );
    }
  });

  test('P5b: invalid emails return a non-null translation key', () {
    const invalidEmails = [
      'notanemail',
      'missing@tld',
      '@nodomain.com',
      'spaces in@email.com',
      '',
      '   ',
      'double@@domain.com',
    ];

    for (final email in invalidEmails) {
      expect(
        FormValidators.email(email),
        isNotNull,
        reason: '"$email" should be invalid',
      );
    }
  });

  test('P5c: null input returns a non-null translation key', () {
    expect(FormValidators.email(null), isNotNull);
  });

  test('P5d: empty / whitespace-only returns emailRequired translation key', () {
    expect(FormValidators.email(''), equals('validation.emailRequired'));
    expect(FormValidators.email('   '), equals('validation.emailRequired'));
    expect(FormValidators.email(null), equals('validation.emailRequired'));
  });

  test('P5e: email without @ returns invalidEmail translation key', () {
    expect(FormValidators.email('nodomain.com'), equals('validation.invalidEmail'));
  });
}

// ---------------------------------------------------------------------------
// Property 6: Password minimum length validation
// ---------------------------------------------------------------------------

void _propertyPasswordMinLength() {
  // Requirements: 5.8, 16.5
  test('P6a: passwords with length >= 8 return null', () {
    final validPasswords = [
      'password',        // exactly 8
      'longerpassword',  // > 8
      '12345678',        // exactly 8 digits
      'a' * 100,         // very long
    ];

    for (final pw in validPasswords) {
      expect(
        FormValidators.password(pw),
        isNull,
        reason: '"$pw" (length ${pw.length}) should be valid',
      );
    }
  });

  test('P6b: passwords with length < 8 return a non-null translation key', () {
    final shortPasswords = [
      '',
      'a',
      'abc',
      '1234567',  // exactly 7
    ];

    for (final pw in shortPasswords) {
      expect(
        FormValidators.password(pw),
        isNotNull,
        reason: '"$pw" (length ${pw.length}) should be invalid',
      );
    }
  });

  test('P6c: null input returns passwordTooShort translation key', () {
    expect(FormValidators.password(null), equals('validation.passwordTooShort'));
  });

  test('P6d: 7-char password returns passwordTooShort key, 8-char returns null', () {
    expect(FormValidators.password('1234567'), equals('validation.passwordTooShort'));
    expect(FormValidators.password('12345678'), isNull);
  });
}

// ---------------------------------------------------------------------------
// Property 7: Confirm password equality validation
// ---------------------------------------------------------------------------

void _propertyConfirmPasswordEquality() {
  // Requirements: 5.9, 16.6
  test('P7a: matching passwords return null', () {
    const pairs = [
      ('password123', 'password123'),
      ('', ''),
      ('!@#\$%^&*()', '!@#\$%^&*()'),
      ('abc', 'abc'),
    ];

    for (final (value, password) in pairs) {
      expect(
        FormValidators.confirmPassword(value, password),
        isNull,
        reason: 'Matching pair "$value" == "$password" should return null',
      );
    }
  });

  test('P7b: non-matching passwords return a non-null translation key', () {
    const pairs = [
      ('password123', 'password456'),
      ('abc', 'ABC'),
      ('', 'notempty'),
      ('notempty', ''),
    ];

    for (final (value, password) in pairs) {
      expect(
        FormValidators.confirmPassword(value, password),
        isNotNull,
        reason: 'Non-matching pair "$value" != "$password" should return error key',
      );
    }
  });

  test('P7c: non-matching pair returns passwordsDoNotMatch translation key', () {
    expect(
      FormValidators.confirmPassword('abc', 'xyz'),
      equals('validation.passwordsDoNotMatch'),
    );
  });
}

// ---------------------------------------------------------------------------
// Property 10: Password strength output range
// ---------------------------------------------------------------------------

void _propertyPasswordStrengthRange() {
  // Requirements: 16.7
  test('P10a: passwordStrength always returns a value in [0, 4]', () {
    const testPasswords = [
      '',
      'a',
      'password',
      'Password1',
      'Password1!',
      'Password1!@#\$%',
      'ALL_UPPERCASE_WITH_NUMBERS123!',
      'alllowercase',
      '12345678',
      '!@#\$%^&*()',
      'Aa1!Bb2@Cc3#',
    ];

    for (final pw in testPasswords) {
      final strength = FormValidators.passwordStrength(pw);
      expect(
        strength,
        inInclusiveRange(0, 4),
        reason: '"$pw" should yield strength in [0, 4], got $strength',
      );
    }
  });

  test('P10b: empty string yields 0', () {
    expect(FormValidators.passwordStrength(''), equals(0));
  });

  test('P10c: strong password "Password1!" yields 4', () {
    expect(FormValidators.passwordStrength('Password1!'), equals(4));
  });

  test('P10d: short simple password yields 0', () {
    // "abc" — length < 8, no uppercase/digit/special
    expect(FormValidators.passwordStrength('abc'), equals(0));
  });

  test('P10e: password with only length >=8 and lowercase yields 1', () {
    expect(FormValidators.passwordStrength('alllower'), equals(1));
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('FormValidators — property tests', () {
    group('Property 5: Email format validation', _propertyEmailFormatValidation);
    group('Property 6: Password minimum length validation', _propertyPasswordMinLength);
    group('Property 7: Confirm password equality validation', _propertyConfirmPasswordEquality);
    group('Property 10: Password strength output range', _propertyPasswordStrengthRange);
  });
}
