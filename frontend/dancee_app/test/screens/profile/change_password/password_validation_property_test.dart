// Feature: profile-page-features
// Task 9.4: Property test for password validation correctness
// Properties covered:
//   Property 2: Password validation correctness

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// The validation predicate under test
//
// Mirrors `_isPasswordValid` from
// `lib/screens/profile/change_password/sections/password_form_section.dart`:
//
//   bool _isPasswordValid(String password) {
//     return password.length >= 8 &&
//         password.contains(RegExp(r'[A-Z]')) &&
//         password.contains(RegExp(r'[a-z]')) &&
//         password.contains(RegExp(r'\d'));
//   }
//
// Requirements 3.4: password must be ≥ 8 chars, have uppercase, lowercase,
// and a digit; special characters are NOT required.
// ---------------------------------------------------------------------------

bool _isPasswordValid(String password) {
  return password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'\d'));
}

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(7);

const _lower = 'abcdefghijklmnopqrstuvwxyz';
const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _digits = '0123456789';
const _special = '!@#\$%^&*()-_=+[]{}|;:,.<>?/`~';
const _allChars = _lower + _upper + _digits + _special;

String _pick(String chars) => chars[_rng.nextInt(chars.length)];

/// Build a string from [pool] with [length] random characters.
String _randomFrom(String pool, int length) =>
    List.generate(length, (_) => _pick(pool)).join();

/// Produce a random string that is guaranteed to satisfy all four criteria.
String _validPassword() {
  // Always include at least one character from each mandatory class.
  final parts = [
    _pick(_upper),
    _pick(_lower),
    _pick(_digits),
    // Fill the rest (up to length 12) from the full alphabet.
    _randomFrom(_allChars, 5 + _rng.nextInt(8)),
  ];
  return (parts..shuffle(_rng)).join();
}

/// Produce a random string that violates exactly one criterion (chosen at random).
String _invalidPassword() {
  switch (_rng.nextInt(4)) {
    case 0: // too short (< 8 chars) but otherwise might have all char classes
      final len = _rng.nextInt(7); // 0–6
      return _randomFrom(_allChars, len);
    case 1: // no uppercase
      return _randomFrom(_lower + _digits + _special, 8 + _rng.nextInt(8));
    case 2: // no lowercase
      return _randomFrom(_upper + _digits + _special, 8 + _rng.nextInt(8));
    case 3: // no digit
      return _randomFrom(_lower + _upper + _special, 8 + _rng.nextInt(8));
    default:
      return _randomFrom(_lower, 7);
  }
}

// ---------------------------------------------------------------------------
// Property 2: Password validation correctness
// ---------------------------------------------------------------------------

void _propertyPasswordValidationCorrectness() {
  // Requirements: 3.4

  test('P2a: passwords with length >= 8, uppercase, lowercase, digit are valid (100 iterations)',
      () {
    for (var i = 0; i < 100; i++) {
      final pw = _validPassword();
      expect(
        _isPasswordValid(pw),
        isTrue,
        reason: 'Iteration $i: "$pw" meets all criteria and should be valid',
      );
    }
  });

  test('P2b: fixed valid passwords are accepted', () {
    const validPasswords = [
      'Password1',     // exactly 8 chars: upper, lower, digit
      'Abcdef1g',      // 8 chars
      'StrongPass9',   // 11 chars
      'A1bcdefg',      // 8 chars
      'aB3ddddd',      // 8 chars
    ];

    for (final pw in validPasswords) {
      expect(
        _isPasswordValid(pw),
        isTrue,
        reason: '"$pw" should be valid',
      );
    }
  });

  test('P2c: passwords failing length check are invalid', () {
    const shortPasswords = [
      '',
      'A1b',          // 3 chars
      'Ab1defg',      // 7 chars — boundary
    ];

    for (final pw in shortPasswords) {
      expect(
        _isPasswordValid(pw),
        isFalse,
        reason: '"$pw" (length ${pw.length}) is too short and should be invalid',
      );
    }
  });

  test('P2d: passwords missing uppercase are invalid', () {
    const noUpper = [
      'abcdefg1',   // 8 chars, no uppercase
      'password1',  // common pattern without uppercase
      'ab1cdefgh',  // 9 chars, no uppercase
    ];

    for (final pw in noUpper) {
      expect(
        _isPasswordValid(pw),
        isFalse,
        reason: '"$pw" has no uppercase and should be invalid',
      );
    }
  });

  test('P2e: passwords missing lowercase are invalid', () {
    const noLower = [
      'ABCDEFG1',   // 8 chars, no lowercase
      'PASSWORD1',  // no lowercase
      'AB1CDEFGH',  // 9 chars, no lowercase
    ];

    for (final pw in noLower) {
      expect(
        _isPasswordValid(pw),
        isFalse,
        reason: '"$pw" has no lowercase and should be invalid',
      );
    }
  });

  test('P2f: passwords missing digit are invalid', () {
    const noDigit = [
      'Abcdefgh',   // 8 chars, no digit
      'Password',   // no digit
      'StrongPass', // no digit
    ];

    for (final pw in noDigit) {
      expect(
        _isPasswordValid(pw),
        isFalse,
        reason: '"$pw" has no digit and should be invalid',
      );
    }
  });

  test('P2g: special characters do NOT affect validity — valid with special chars', () {
    // A password that meets all four criteria remains valid even with specials.
    const withSpecial = [
      'Password1!',
      'Str0ng!Pass',
      'Ab1#\$%^&*()',
      r'P@ssw0rd!',
    ];

    for (final pw in withSpecial) {
      expect(
        _isPasswordValid(pw),
        isTrue,
        reason: '"$pw" meets all criteria and special chars should not disqualify it',
      );
    }
  });

  test('P2h: special characters do NOT affect validity — invalid without other criteria', () {
    // Adding special chars to a short/incomplete password does not make it valid.
    const withSpecialButInvalid = [
      '!@#\$%^&',    // 7 chars (short), even with specials
      'abcdef!@',    // 8 chars but no uppercase, no digit
      'ABCDEF!@',    // 8 chars but no lowercase, no digit
      '12345!@A',    // 8 chars but no lowercase
    ];

    for (final pw in withSpecialButInvalid) {
      expect(
        _isPasswordValid(pw),
        isFalse,
        reason: '"$pw" is still invalid despite having special characters',
      );
    }
  });

  test('P2i: randomly generated invalid passwords are rejected (200 iterations)', () {
    for (var i = 0; i < 200; i++) {
      final pw = _invalidPassword();
      // An invalid password violates at least one criterion — verify that.
      final meetsLength = pw.length >= 8;
      final hasUpper = pw.contains(RegExp(r'[A-Z]'));
      final hasLower = pw.contains(RegExp(r'[a-z]'));
      final hasDigit = pw.contains(RegExp(r'\d'));

      final criteriaCount = [meetsLength, hasUpper, hasLower, hasDigit]
          .where((c) => c)
          .length;

      if (criteriaCount < 4) {
        // The password violates at least one criterion; must be invalid.
        expect(
          _isPasswordValid(pw),
          isFalse,
          reason: 'Iteration $i: "$pw" violates ≥1 criterion and must be invalid',
        );
      }
      // If by chance all criteria are met (rare with _invalidPassword generator),
      // the predicate should return true — that is also correct.
    }
  });

  test('P2j: validation is deterministic — same input always returns same result', () {
    const passwords = [
      'Password1',
      'short',
      'NoDigitHere',
      '',
      'ALLCAPS1',
      'alllower1',
      'ValidPass2!',
    ];

    for (final pw in passwords) {
      final first = _isPasswordValid(pw);
      for (var i = 0; i < 10; i++) {
        expect(
          _isPasswordValid(pw),
          equals(first),
          reason: '"$pw" must yield the same result on every call',
        );
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Password validation — property tests', () {
    group('Property 2: Password validation correctness', _propertyPasswordValidationCorrectness);
  });
}
