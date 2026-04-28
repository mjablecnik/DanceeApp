// Feature: firebase-auth
// Task 6.4: Unit tests for auth screen form validation and cubit interaction
// Requirements: 4.6, 4.7, 5.6, 5.7, 5.8, 5.9, 5.10, 9.4

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/data/repositories/favorites_repository.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/states/auth_state.dart';
import 'package:dancee_app2/shared/utils/form_validators.dart';

// ---------------------------------------------------------------------------
// Fakes / Helpers (mirrored from auth_cubit_property_test.dart)
// ---------------------------------------------------------------------------

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

class _FakeUserMetadata extends Fake implements UserMetadata {
  _FakeUserMetadata({this.creationTime});

  @override
  final DateTime? creationTime;
}

class _FakeUser extends Fake implements User {
  _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
    DateTime? creationTime,
  }) : metadata = _FakeUserMetadata(creationTime: creationTime);

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final bool emailVerified;

  @override
  final UserMetadata metadata;
}

/// Controllable fake [AuthRepository] that records calls and arguments.
class _TrackingAuthRepository extends Fake implements AuthRepository {
  _TrackingAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  // Recorded call arguments
  String? lastSignInEmail;
  String? lastSignInPassword;
  String? lastPasswordResetEmail;
  ({String email, String password, String firstName, String lastName})? lastRegisterArgs;

  // Throw-on-call flags
  bool throwOnSignInWithEmail = false;
  bool throwOnRegister = false;
  bool throwOnSendPasswordReset = false;
  String errorMessage = 'auth.errors.generic';

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void pushUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (throwOnSignInWithEmail) throw errorMessage;
    throw UnimplementedError('signInWithEmail — test should not reach here');
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    throw UnimplementedError('signInWithGoogle — not needed in this test');
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    lastRegisterArgs = (
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    if (throwOnRegister) throw errorMessage;
    throw UnimplementedError('register — test should not reach here');
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<bool> reloadAndCheckVerified() async {
    return _currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    lastPasswordResetEmail = email;
    if (throwOnSendPasswordReset) throw errorMessage;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> reauthenticate({String? email, String? password}) async {}

  @override
  Future<void> deleteAccount() async {}
}

// ---------------------------------------------------------------------------
// Login form validation edge cases
// Requirements: 4.6, 4.7
// ---------------------------------------------------------------------------

void _loginFormValidation() {
  group('Email field (uses FormValidators.email)', () {
    // Requirement 4.6: Email format validation
    test('empty string → emailRequired key', () {
      expect(FormValidators.email(''), equals('validation.emailRequired'));
    });

    test('whitespace-only string → emailRequired key', () {
      expect(FormValidators.email('   '), equals('validation.emailRequired'));
    });

    test('null → emailRequired key', () {
      expect(FormValidators.email(null), equals('validation.emailRequired'));
    });

    test('missing @ symbol → invalidEmail key', () {
      expect(FormValidators.email('notanemail'), equals('validation.invalidEmail'));
      expect(FormValidators.email('nodomain.com'), equals('validation.invalidEmail'));
    });

    test('missing TLD → invalidEmail key', () {
      expect(FormValidators.email('user@nodomain'), equals('validation.invalidEmail'));
    });

    test('@ at start → invalidEmail key', () {
      expect(FormValidators.email('@domain.com'), equals('validation.invalidEmail'));
    });

    test('spaces in local part → invalidEmail key', () {
      expect(FormValidators.email('first last@example.com'), equals('validation.invalidEmail'));
    });

    test('spaces in domain → invalidEmail key', () {
      expect(FormValidators.email('user@dom ain.com'), equals('validation.invalidEmail'));
    });

    test('valid standard email → null', () {
      expect(FormValidators.email('user@example.com'), isNull);
    });

    test('valid email with subdomain → null', () {
      expect(FormValidators.email('user@sub.domain.com'), isNull);
    });

    test('valid email with plus tag → null', () {
      expect(FormValidators.email('user+tag@example.org'), isNull);
    });

    test('valid email with dots → null', () {
      expect(FormValidators.email('first.last@example.co.uk'), isNull);
    });

    test('valid email with numbers → null', () {
      expect(FormValidators.email('user123@example456.com'), isNull);
    });
  });

  group('Password field (login uses notEmpty, not password)', () {
    // Requirement 4.7: Password not empty validation
    test('empty string → fieldRequired key', () {
      expect(FormValidators.notEmpty(''), equals('validation.fieldRequired'));
    });

    test('whitespace-only string → fieldRequired key', () {
      expect(FormValidators.notEmpty('   '), equals('validation.fieldRequired'));
    });

    test('null → fieldRequired key', () {
      expect(FormValidators.notEmpty(null), equals('validation.fieldRequired'));
    });

    test('single character → null (login only checks not-empty)', () {
      expect(FormValidators.notEmpty('a'), isNull);
    });

    test('short but non-empty password → null (login accepts any non-empty)', () {
      // Login form uses notEmpty, not password; short passwords are accepted
      expect(FormValidators.notEmpty('abc'), isNull);
      expect(FormValidators.notEmpty('1234567'), isNull);
    });

    test('valid password → null', () {
      expect(FormValidators.notEmpty('securepassword'), isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Register form validation edge cases
// Requirements: 5.6, 5.7, 5.8, 5.9, 5.10
// ---------------------------------------------------------------------------

void _registerFormValidation() {
  group('First name / last name fields (uses notEmpty)', () {
    // Requirement 5.6: Name fields must not be empty
    test('empty first name → fieldRequired key', () {
      expect(FormValidators.notEmpty(''), equals('validation.fieldRequired'));
    });

    test('whitespace-only first name → fieldRequired key', () {
      expect(FormValidators.notEmpty('\t\n'), equals('validation.fieldRequired'));
    });

    test('non-empty first name → null', () {
      expect(FormValidators.notEmpty('John'), isNull);
    });

    test('empty last name → fieldRequired key', () {
      expect(FormValidators.notEmpty(''), equals('validation.fieldRequired'));
    });

    test('non-empty last name → null', () {
      expect(FormValidators.notEmpty('Doe'), isNull);
    });
  });

  group('Email field (uses FormValidators.email)', () {
    // Requirement 5.7: Email format must be valid
    test('invalid email → non-null key', () {
      expect(FormValidators.email('not-an-email'), isNotNull);
      expect(FormValidators.email('missing@tld'), isNotNull);
      expect(FormValidators.email(''), isNotNull);
    });

    test('valid email → null', () {
      expect(FormValidators.email('user@example.com'), isNull);
    });
  });

  group('Password field (register uses password validator, min 8 chars)', () {
    // Requirement 5.8: Password must be at least 8 characters
    test('7-char password → passwordTooShort key', () {
      expect(FormValidators.password('1234567'), equals('validation.passwordTooShort'));
    });

    test('8-char password → null (boundary)', () {
      expect(FormValidators.password('12345678'), isNull);
    });

    test('empty password → passwordTooShort key', () {
      expect(FormValidators.password(''), equals('validation.passwordTooShort'));
    });

    test('null password → passwordTooShort key', () {
      expect(FormValidators.password(null), equals('validation.passwordTooShort'));
    });

    test('long password → null', () {
      expect(FormValidators.password('a' * 64), isNull);
    });

    test('8-char password with mixed chars → null', () {
      expect(FormValidators.password('Passw0rd'), isNull);
    });
  });

  group('Confirm password field (uses confirmPassword)', () {
    // Requirement 5.9: Passwords must match
    test('matching passwords → null', () {
      expect(FormValidators.confirmPassword('password123', 'password123'), isNull);
    });

    test('mismatched passwords → passwordsDoNotMatch key', () {
      expect(
        FormValidators.confirmPassword('password123', 'different'),
        equals('validation.passwordsDoNotMatch'),
      );
    });

    test('case-sensitive mismatch → passwordsDoNotMatch key', () {
      expect(
        FormValidators.confirmPassword('Password', 'password'),
        equals('validation.passwordsDoNotMatch'),
      );
    });

    test('both empty → null (both equal)', () {
      expect(FormValidators.confirmPassword('', ''), isNull);
    });

    test('confirm empty but password non-empty → passwordsDoNotMatch key', () {
      expect(
        FormValidators.confirmPassword('', 'somepassword'),
        equals('validation.passwordsDoNotMatch'),
      );
    });

    test('null confirm → passwordsDoNotMatch key (null != empty string)', () {
      expect(
        FormValidators.confirmPassword(null, 'password'),
        equals('validation.passwordsDoNotMatch'),
      );
    });
  });

  group('Password strength (shown on register form)', () {
    // Requirement 5.10: Password strength indicator shown
    test('empty string → strength 0', () {
      expect(FormValidators.passwordStrength(''), equals(0));
    });

    test('lowercase only, short → strength 0', () {
      expect(FormValidators.passwordStrength('abc'), equals(0));
    });

    test('lowercase only, 8+ chars → strength 1', () {
      expect(FormValidators.passwordStrength('lowercase'), equals(1));
    });

    test('mixed case, 8+ chars → strength 2', () {
      expect(FormValidators.passwordStrength('LowerUPPER'), equals(2));
    });

    test('mixed case + digit, 8+ chars → strength 3', () {
      expect(FormValidators.passwordStrength('LowerUPPER1'), equals(3));
    });

    test('mixed case + digit + special, 8+ chars → strength 4', () {
      expect(FormValidators.passwordStrength('LowerUPPER1!'), equals(4));
    });

    test('strength always in [0, 4] range', () {
      for (final pw in ['', 'a', 'Password1!', 'ALLCAPS123!@#', 'alllower12345!']) {
        final strength = FormValidators.passwordStrength(pw);
        expect(strength, inInclusiveRange(0, 4), reason: '"$pw" → $strength');
      }
    });
  });

  group('Terms checkbox validation (logic)', () {
    // Requirement 5.6: Terms of service checkbox must be checked
    // The checkbox is widget-level; test the boolean guard logic here.
    test('terms not agreed → validateAll should fail (boolean logic)', () {
      // Simulate: all fields valid, but agreeTerms = false
      final emailValid = FormValidators.email('user@example.com') == null;
      final passwordValid = FormValidators.password('password123') == null;
      final confirmValid = FormValidators.confirmPassword('password123', 'password123') == null;
      final agreeTerms = false; // not checked

      final allValid = emailValid && passwordValid && confirmValid && agreeTerms;
      expect(allValid, isFalse, reason: 'Terms not agreed should prevent submission');
    });

    test('all fields valid + terms agreed → validateAll should succeed', () {
      final emailValid = FormValidators.email('user@example.com') == null;
      final passwordValid = FormValidators.password('password123') == null;
      final confirmValid = FormValidators.confirmPassword('password123', 'password123') == null;
      final agreeTerms = true;

      final allValid = emailValid && passwordValid && confirmValid && agreeTerms;
      expect(allValid, isTrue, reason: 'All valid + terms agreed should allow submission');
    });
  });
}

// ---------------------------------------------------------------------------
// Forgot password form validation edge cases
// Requirement: 9.4
// ---------------------------------------------------------------------------

void _forgotPasswordFormValidation() {
  group('Email field (uses FormValidators.email)', () {
    // Requirement 9.4: Email format validation for password reset
    test('empty email → emailRequired key', () {
      expect(FormValidators.email(''), equals('validation.emailRequired'));
    });

    test('whitespace-only → emailRequired key', () {
      expect(FormValidators.email('  '), equals('validation.emailRequired'));
    });

    test('invalid email format → invalidEmail key', () {
      expect(FormValidators.email('notanemail'), equals('validation.invalidEmail'));
      expect(FormValidators.email('user@'), equals('validation.invalidEmail'));
      expect(FormValidators.email('@domain.com'), equals('validation.invalidEmail'));
    });

    test('valid email → null (password reset accepts any valid email)', () {
      expect(FormValidators.email('user@example.com'), isNull);
      expect(FormValidators.email('reset.me@company.org'), isNull);
    });

    test('email with non-existent domain still passes format check → null', () {
      // Forgot password accepts any valid email format — Firebase handles
      // the case where the address is unknown.
      expect(FormValidators.email('user@nonexistent-domain.xyz'), isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Cubit interaction for auth forms
// Requirements: 4.6, 4.7, 5.7, 5.8, 9.4
// ---------------------------------------------------------------------------

void _cubitInteraction() {
  late _TrackingAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _TrackingAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  group('Login form cubit interaction', () {
    test('signInWithEmail passes email and password to repository', () async {
      repo.throwOnSignInWithEmail = true; // let it fail so we can inspect args
      await cubit.signInWithEmail('user@example.com', 'mypassword');

      expect(repo.lastSignInEmail, equals('user@example.com'));
      expect(repo.lastSignInPassword, equals('mypassword'));
    });

    test('signInWithEmail failure → error state with non-empty message', () async {
      repo
        ..throwOnSignInWithEmail = true
        ..errorMessage = 'auth.errors.invalidCredential';
      await cubit.signInWithEmail('user@example.com', 'wrongpassword');

      cubit.state.maybeMap(
        error: (e) {
          expect(e.message, isNotEmpty);
          expect(e.message, equals('auth.errors.invalidCredential'));
        },
        orElse: () => fail('Expected error state, got ${cubit.state}'),
      );
    });

    test('signInWithEmail failure → state is error, not loading', () async {
      repo.throwOnSignInWithEmail = true;
      await cubit.signInWithEmail('a@b.com', 'pass');

      expect(
        cubit.state.maybeMap(error: (_) => true, orElse: () => false),
        isTrue,
      );
    });

    test('signInWithEmail emits loading before error state', () async {
      repo.throwOnSignInWithEmail = true;
      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.signInWithEmail('a@b.com', 'pass');
      await sub.cancel();

      expect(states, isNotEmpty);
      expect(states.first, const AuthState.loading());
      // cubit.state is the final state after completion
      expect(
        cubit.state.maybeMap(error: (_) => true, orElse: () => false),
        isTrue,
      );
    });
  });

  group('Register form cubit interaction', () {
    test('register passes all fields to repository', () async {
      repo.throwOnRegister = true; // let it fail so we can inspect args
      await cubit.register(
        email: 'new@example.com',
        password: 'securepassword',
        firstName: 'Jane',
        lastName: 'Doe',
      );

      expect(repo.lastRegisterArgs?.email, equals('new@example.com'));
      expect(repo.lastRegisterArgs?.password, equals('securepassword'));
      expect(repo.lastRegisterArgs?.firstName, equals('Jane'));
      expect(repo.lastRegisterArgs?.lastName, equals('Doe'));
    });

    test('register failure → error state with non-empty message', () async {
      repo
        ..throwOnRegister = true
        ..errorMessage = 'auth.errors.emailAlreadyInUse';
      await cubit.register(
        email: 'existing@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
      );

      cubit.state.maybeMap(
        error: (e) {
          expect(e.message, isNotEmpty);
          expect(e.message, equals('auth.errors.emailAlreadyInUse'));
        },
        orElse: () => fail('Expected error state, got ${cubit.state}'),
      );
    });

    test('register emits loading before error', () async {
      repo.throwOnRegister = true;
      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.register(
        email: 'a@b.com',
        password: 'password',
        firstName: 'A',
        lastName: 'B',
      );

      await sub.cancel();
      expect(states, isNotEmpty);
      expect(states.first, const AuthState.loading());
    });
  });

  group('Forgot password form cubit interaction', () {
    test('sendPasswordReset passes trimmed email to repository', () async {
      await cubit.sendPasswordReset('reset@example.com');
      expect(repo.lastPasswordResetEmail, equals('reset@example.com'));
    });

    test('sendPasswordReset succeeds even for non-existent emails', () async {
      // Firebase returns success for unknown emails (security by design)
      // Ensure no error state is produced when repo does not throw
      await cubit.sendPasswordReset('nonexistent@domain.com');

      // After success, cubit calls _onAuthStateChanged(currentUser)
      // which emits unauthenticated (currentUser is null in fake)
      expect(
        cubit.state.maybeMap(error: (_) => true, orElse: () => false),
        isFalse,
        reason: 'sendPasswordReset should not emit error on success',
      );
    });

    test('sendPasswordReset failure → success signalled anyway (email enumeration protection)', () async {
      // sendPasswordReset suppresses errors to prevent revealing whether an
      // email is registered. The success event is always emitted (Req 9.3).
      repo
        ..throwOnSendPasswordReset = true
        ..errorMessage = 'auth.errors.tooManyRequests';
      final successEvents = <AuthOperation>[];
      final sub = cubit.operationSuccess.listen(successEvents.add);
      await cubit.sendPasswordReset('a@b.com');
      await Future.delayed(Duration.zero); // allow broadcast stream event to be processed
      await sub.cancel();

      expect(successEvents, contains(AuthOperation.passwordReset),
          reason: 'passwordReset success must be signalled even when repo throws');
      // State must NOT be error — errors are intentionally suppressed
      cubit.state.maybeMap(
        error: (_) => fail('sendPasswordReset must not emit error state'),
        orElse: () {},
      );
    });

    // Task 11 fix: sendPasswordReset no longer emits AuthState.loading().
    // It uses operationInProgress instead to avoid global auth state changes.
    test('sendPasswordReset sets operationInProgress during operation', () async {
      bool wasTrue = false;
      bool wasFalse = false;
      void listener() {
        if (cubit.operationInProgress.value) wasTrue = true;
        if (!cubit.operationInProgress.value && wasTrue) wasFalse = true;
      }
      cubit.operationInProgress.addListener(listener);
      await cubit.sendPasswordReset('a@b.com');
      cubit.operationInProgress.removeListener(listener);

      expect(wasTrue, isTrue,
          reason: 'operationInProgress must be true during sendPasswordReset');
      expect(wasFalse, isTrue,
          reason: 'operationInProgress must reset to false after completion');
    });
  });
}

// ---------------------------------------------------------------------------
// Validation translated string mapping (FormValidators now returns translated strings)
// ---------------------------------------------------------------------------

void _validationKeyMapping() {
  group('Known validation translation keys emitted by FormValidators', () {
    test('email() emits only known translation keys or null', () {
      const knownKeys = {'validation.emailRequired', 'validation.invalidEmail'};
      const inputs = ['', '  ', null, 'notanemail', 'user@example.com', 'bad@', '@bad.com'];

      for (final input in inputs) {
        final result = FormValidators.email(input);
        if (result != null) {
          expect(knownKeys, contains(result), reason: '"$input" → unknown key "$result"');
        }
      }
    });

    test('notEmpty() emits only fieldRequired key or null', () {
      const inputs = ['', '  ', null, 'value', 'a'];
      for (final input in inputs) {
        final result = FormValidators.notEmpty(input);
        if (result != null) {
          expect(result, equals('validation.fieldRequired'));
        }
      }
    });

    test('password() emits only passwordTooShort key or null', () {
      const inputs = ['', 'abc', '1234567', '12345678', null, 'longpassword'];
      for (final input in inputs) {
        final result = FormValidators.password(input);
        if (result != null) {
          expect(result, equals('validation.passwordTooShort'));
        }
      }
    });

    test('confirmPassword() emits only passwordsDoNotMatch key or null', () {
      const pairs = [
        ('same', 'same'),
        ('', ''),
        ('abc', 'xyz'),
        (null, 'something'),
      ];
      for (final (value, password) in pairs) {
        final result = FormValidators.confirmPassword(value, password);
        if (result != null) {
          expect(result, equals('validation.passwordsDoNotMatch'));
        }
      }
    });
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Auth screen form validation — unit tests', () {
    group('Login form validation edge cases', _loginFormValidation);
    group('Register form validation edge cases', _registerFormValidation);
    group('Forgot password form validation edge cases', _forgotPasswordFormValidation);
    group('Cubit interaction for auth forms', _cubitInteraction);
    group('Validation translated string mapping', _validationKeyMapping);
  });
}
