// Feature: firebase-auth
// Task 2.5: Property test for error code mapping
// Properties covered:
//   Property 1: Error code mapping always returns a non-empty string

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {}

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {}

// ---------------------------------------------------------------------------
// Property 1: Error code mapping always returns a non-empty translation key
// ---------------------------------------------------------------------------

void _propertyErrorCodeMapping() {
  // Requirements: 2.10, 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7
  late AuthRepository repository;

  setUp(() {
    repository = AuthRepository(
      firebaseAuth: _FakeFirebaseAuth(),
      googleSignIn: _FakeGoogleSignIn(),
    );
  });

  FirebaseAuthException _makeException(String code) =>
      FirebaseAuthException(code: code);

  test('P1a: known error codes map to their distinct, non-empty translation keys', () {
    final knownMappings = {
      'invalid-credential': 'auth.errors.invalidCredential',
      'user-disabled': 'auth.errors.userDisabled',
      'email-already-in-use': 'auth.errors.emailAlreadyInUse',
      'weak-password': 'auth.errors.weakPassword',
      'too-many-requests': 'auth.errors.tooManyRequests',
      'network-request-failed': 'auth.errors.networkError',
    };

    for (final entry in knownMappings.entries) {
      final result = repository.mapFirebaseError(_makeException(entry.key));
      expect(
        result,
        equals(entry.value),
        reason: 'Code "${entry.key}" should map to key "${entry.value}"',
      );
    }
  });

  test('P1b: known codes produce distinct translation keys', () {
    final knownCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
    ];

    final results = knownCodes.map((code) {
      return repository.mapFirebaseError(_makeException(code));
    }).toList();

    // All results should be unique (distinct keys)
    expect(results.toSet().length, equals(results.length),
        reason: 'Each known error code should map to a distinct translation key');
  });

  test('P1c: unknown error codes fall back to the generic translation key', () {
    const unknownCodes = [
      'some-unknown-code',
      'random-error',
      '',
      'INVALID-CREDENTIAL', // wrong case
      'network_request_failed', // wrong separator
      'user_disabled',
    ];

    const expectedGenericKey = 'auth.errors.generic';
    for (final code in unknownCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(
        result,
        equals(expectedGenericKey),
        reason: 'Unknown code "$code" should fall back to the generic error key',
      );
    }
  });

  test('P1d: every error code (known or unknown) returns a non-null, non-empty key', () {
    final allCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
      'some-unknown-code',
      '',
      'random-error-xyz',
    ];

    for (final code in allCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(result, isNotNull,
          reason: 'mapFirebaseError("$code") must not return null');
      expect(result, isNotEmpty,
          reason: 'mapFirebaseError("$code") must not return an empty string');
    }
  });

  test('P1e: all returned keys are dot-separated auth.errors.* paths', () {
    final allCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
      'unknown-code',
      '',
    ];

    for (final code in allCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(
        result,
        startsWith('auth.errors.'),
        reason: 'Key for "$code" should be a dot-separated auth.errors.* path',
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('AuthRepository — property tests', () {
    group('Property 1: Error code mapping always returns a non-empty string',
        _propertyErrorCodeMapping);
  });
}
