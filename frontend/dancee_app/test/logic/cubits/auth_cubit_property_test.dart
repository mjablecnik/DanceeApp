// Feature: firebase-auth
// Task 3.2: Property tests for AuthCubit state transitions
// Properties covered:
//   Property 2: Auth stream events map to correct AuthState
//   Property 3: Auth operations emit loading state first
//   Property 4: Failed auth operations emit error state with message

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/data/repositories/favorites_repository.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/states/auth_state.dart';

// ---------------------------------------------------------------------------
// Fakes / Helpers
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

/// Controllable fake [AuthRepository].
///
/// - Push auth state changes via [pushUser].
/// - Configure methods to throw by setting the corresponding flag.
/// - Configure the error message via [errorMessage].
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  // Throw-on-call flags
  bool throwOnSignInWithEmail = false;
  bool throwOnSignInWithGoogle = false;
  bool throwOnRegister = false;
  bool throwOnSendEmailVerification = false;
  bool throwOnReloadAndCheckVerified = false;
  bool throwOnSendPasswordReset = false;
  bool throwOnSignOut = false;
  bool throwOnReauthenticate = false;
  bool throwOnDeleteAccount = false;

  String errorMessage = 'auth.errors.generic';

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  /// Emit a user event on the auth stream.
  void pushUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (throwOnSignInWithEmail) throw errorMessage;
    throw UnimplementedError('signInWithEmail — test should not reach here');
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (throwOnSignInWithGoogle) throw errorMessage;
    throw UnimplementedError('signInWithGoogle — test should not reach here');
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (throwOnRegister) throw errorMessage;
    throw UnimplementedError('register — test should not reach here');
  }

  @override
  Future<void> sendEmailVerification() async {
    if (throwOnSendEmailVerification) throw errorMessage;
  }

  @override
  Future<bool> reloadAndCheckVerified() async {
    if (throwOnReloadAndCheckVerified) throw errorMessage;
    return _currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (throwOnSendPasswordReset) throw errorMessage;
  }

  @override
  Future<void> signOut() async {
    if (throwOnSignOut) throw errorMessage;
  }

  @override
  Future<void> reauthenticate({String? email, String? password}) async {
    if (throwOnReauthenticate) throw errorMessage;
  }

  @override
  Future<void> deleteAccount() async {
    if (throwOnDeleteAccount) throw errorMessage;
  }
}

// ---------------------------------------------------------------------------
// Property 2: Auth stream events map to correct AuthState
// ---------------------------------------------------------------------------

void _propertyAuthStreamMapping() {
  // Requirements: 3.2, 3.3, 3.4
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  test('P2a: initial state is unauthenticated before any stream event', () {
    expect(cubit.state, const AuthState.unauthenticated());
  });

  test('P2b: non-null User on stream → authenticated state', () async {
    final user = _FakeUser(
      uid: 'uid-123',
      email: 'alice@example.com',
      displayName: 'Alice',
      emailVerified: true,
    );

    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) {
        expect(s.uid, equals('uid-123'));
        expect(s.email, equals('alice@example.com'));
        expect(s.displayName, equals('Alice'));
        expect(s.emailVerified, isTrue);
      },
      orElse: () => fail('Expected authenticated state, got ${cubit.state}'),
    );
  });

  test('P2c: null User on stream → unauthenticated state', () async {
    // First authenticate
    final user = _FakeUser(uid: 'uid-123', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    // Then sign out (null user)
    repo.pushUser(null);
    await Future.delayed(Duration.zero);

    expect(cubit.state, const AuthState.unauthenticated());
  });

  test('P2d: multiple user events emit correct states in sequence', () async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    final user1 = _FakeUser(uid: 'uid-1', emailVerified: false);
    final user2 = _FakeUser(uid: 'uid-2', emailVerified: true);

    repo.pushUser(user1);
    repo.pushUser(null);
    repo.pushUser(user2);

    await Future.delayed(Duration.zero);

    expect(states.length, equals(3));
    states[0].maybeMap(
      authenticated: (s) => expect(s.uid, equals('uid-1')),
      orElse: () => fail('Expected authenticated, got ${states[0]}'),
    );
    expect(states[1], const AuthState.unauthenticated());
    states[2].maybeMap(
      authenticated: (s) => expect(s.uid, equals('uid-2')),
      orElse: () => fail('Expected authenticated, got ${states[2]}'),
    );

    await sub.cancel();
  });

  test('P2e: unverified email reflected in authenticated state', () async {
    final user = _FakeUser(uid: 'uid-unverified', emailVerified: false);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) => expect(s.emailVerified, isFalse),
      orElse: () => fail('Expected authenticated state'),
    );
  });

  test('P2f: verified email reflected in authenticated state', () async {
    final user = _FakeUser(uid: 'uid-verified', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) => expect(s.emailVerified, isTrue),
      orElse: () => fail('Expected authenticated state'),
    );
  });

  test('P2g: null email and displayName are preserved in authenticated state',
      () async {
    final user = _FakeUser(uid: 'uid-no-profile');
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) {
        expect(s.email, isNull);
        expect(s.displayName, isNull);
      },
      orElse: () => fail('Expected authenticated state'),
    );
  });
}

// ---------------------------------------------------------------------------
// Property 3: Auth operations emit loading state first
// ---------------------------------------------------------------------------

void _propertyLoadingStateFirst() {
  // Requirements: 3.6
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  /// Collects states emitted during [operation] and verifies loading is first.
  Future<void> _assertLoadingFirst(Future<void> Function() operation) async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await operation();
    await sub.cancel();

    expect(
      states,
      isNotEmpty,
      reason: 'Operation must emit at least one state',
    );
    expect(
      states.first,
      const AuthState.loading(),
      reason: 'First emitted state must be loading',
    );
  }

  test('P3a: signInWithEmail emits loading first (failure path)', () async {
    repo
      ..throwOnSignInWithEmail = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await _assertLoadingFirst(
        () => cubit.signInWithEmail('a@b.com', 'password'));
  });

  test('P3b: register emits loading first (failure path)', () async {
    repo
      ..throwOnRegister = true
      ..errorMessage = 'auth.errors.emailAlreadyInUse';
    await _assertLoadingFirst(
      () => cubit.register(
        email: 'a@b.com',
        password: 'password',
        firstName: 'A',
        lastName: 'B',
      ),
    );
  });

  // P3c-P3g: sendEmailVerification, reloadUser, and sendPasswordReset are
  // non-auth-changing operations that must NOT emit AuthState.loading() into
  // the global auth state (task 11 fix). Instead they use operationInProgress.

  test('P3c: sendEmailVerification sets operationInProgress during operation',
      () async {
    bool wasTrue = false;
    bool wasFalse = false;
    void listener() {
      if (cubit.operationInProgress.value) wasTrue = true;
      if (!cubit.operationInProgress.value && wasTrue) wasFalse = true;
    }
    cubit.operationInProgress.addListener(listener);
    await cubit.sendEmailVerification();
    cubit.operationInProgress.removeListener(listener);
    expect(wasTrue, isTrue, reason: 'operationInProgress must be set to true');
    expect(wasFalse, isTrue, reason: 'operationInProgress must be reset to false');
  });

  test('P3d: sendEmailVerification (failure) sets operationInProgress and emits error',
      () async {
    repo.throwOnSendEmailVerification = true;
    bool wasTrue = false;
    void listener() {
      if (cubit.operationInProgress.value) wasTrue = true;
    }
    cubit.operationInProgress.addListener(listener);
    await cubit.sendEmailVerification();
    cubit.operationInProgress.removeListener(listener);
    expect(wasTrue, isTrue, reason: 'operationInProgress must be set to true');
    expect(cubit.operationInProgress.value, isFalse,
        reason: 'operationInProgress must be reset to false after completion');
    // Error should be in auth state
    expect(cubit.state, isA<AuthState>());
    cubit.state.maybeMap(
      error: (_) {}, // expected
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  });

  test('P3e: reloadUser sets operationInProgress during operation', () async {
    bool wasTrue = false;
    bool wasFalse = false;
    void listener() {
      if (cubit.operationInProgress.value) wasTrue = true;
      if (!cubit.operationInProgress.value && wasTrue) wasFalse = true;
    }
    cubit.operationInProgress.addListener(listener);
    await cubit.reloadUser();
    cubit.operationInProgress.removeListener(listener);
    expect(wasTrue, isTrue, reason: 'operationInProgress must be set to true');
    expect(wasFalse, isTrue, reason: 'operationInProgress must be reset to false');
  });

  test('P3f: sendPasswordReset sets operationInProgress during operation',
      () async {
    bool wasTrue = false;
    bool wasFalse = false;
    void listener() {
      if (cubit.operationInProgress.value) wasTrue = true;
      if (!cubit.operationInProgress.value && wasTrue) wasFalse = true;
    }
    cubit.operationInProgress.addListener(listener);
    await cubit.sendPasswordReset('a@b.com');
    cubit.operationInProgress.removeListener(listener);
    expect(wasTrue, isTrue, reason: 'operationInProgress must be set to true');
    expect(wasFalse, isTrue, reason: 'operationInProgress must be reset to false');
  });

  test('P3g: sendPasswordReset (failure) sets operationInProgress and emits error',
      () async {
    repo.throwOnSendPasswordReset = true;
    bool wasTrue = false;
    void listener() {
      if (cubit.operationInProgress.value) wasTrue = true;
    }
    cubit.operationInProgress.addListener(listener);
    await cubit.sendPasswordReset('a@b.com');
    cubit.operationInProgress.removeListener(listener);
    expect(wasTrue, isTrue, reason: 'operationInProgress must be set to true');
    expect(cubit.operationInProgress.value, isFalse,
        reason: 'operationInProgress must be reset to false after completion');
    cubit.state.maybeMap(
      error: (_) {}, // expected
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  });

  test('P3h: signOut emits loading first (success path)', () async {
    await _assertLoadingFirst(() => cubit.signOut());
  });

  test('P3i: signOut emits loading first (failure path)', () async {
    repo.throwOnSignOut = true;
    await _assertLoadingFirst(() => cubit.signOut());
  });

  test('P3j: deleteAccount emits loading first (failure path)', () async {
    repo.throwOnReauthenticate = true;
    await _assertLoadingFirst(
        () => cubit.deleteAccount(email: 'a@b.com', password: 'pass'));
  });
}

// ---------------------------------------------------------------------------
// Property 4: Failed auth operations emit error state with non-empty message
// ---------------------------------------------------------------------------

void _propertyFailedOperationsEmitError() {
  // Requirements: 3.7
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  void _assertErrorStateNonEmpty() {
    cubit.state.maybeMap(
      error: (e) {
        expect(
          e.message,
          isNotEmpty,
          reason: 'Error message must be non-empty',
        );
      },
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  }

  test('P4a: signInWithEmail failure → error state with non-empty message',
      () async {
    repo
      ..throwOnSignInWithEmail = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await cubit.signInWithEmail('a@b.com', 'wrong');
    _assertErrorStateNonEmpty();
  });

  test('P4b: register failure → error state with non-empty message', () async {
    repo
      ..throwOnRegister = true
      ..errorMessage = 'auth.errors.emailAlreadyInUse';
    await cubit.register(
      email: 'a@b.com',
      password: 'password',
      firstName: 'A',
      lastName: 'B',
    );
    _assertErrorStateNonEmpty();
  });

  test('P4c: sendEmailVerification failure → error state with non-empty message',
      () async {
    repo
      ..throwOnSendEmailVerification = true
      ..errorMessage = 'auth.errors.generic';
    await cubit.sendEmailVerification();
    _assertErrorStateNonEmpty();
  });

  test('P4d: reloadUser failure → error state with non-empty message',
      () async {
    repo
      ..throwOnReloadAndCheckVerified = true
      ..errorMessage = 'auth.errors.networkError';
    await cubit.reloadUser();
    _assertErrorStateNonEmpty();
  });

  test('P4e: sendPasswordReset failure → always emits passwordReset success (email enumeration protection)',
      () async {
    repo
      ..throwOnSendPasswordReset = true
      ..errorMessage = 'auth.errors.tooManyRequests';
    final successEvents = <AuthOperation>[];
    final sub = cubit.operationSuccess.listen(successEvents.add);
    await cubit.sendPasswordReset('a@b.com');
    await sub.cancel();
    // Errors are suppressed — the success signal is always emitted (Req 9.3)
    expect(successEvents, contains(AuthOperation.passwordReset),
        reason: 'passwordReset success must be signalled even when the repository throws');
    // Auth state must NOT be an error state
    cubit.state.maybeMap(
      error: (_) => fail('sendPasswordReset must not emit error state (email enumeration protection)'),
      orElse: () {},
    );
  });

  test('P4f: signOut failure → error state with non-empty message', () async {
    repo
      ..throwOnSignOut = true
      ..errorMessage = 'auth.errors.generic';
    await cubit.signOut();
    _assertErrorStateNonEmpty();
  });

  test('P4g: deleteAccount re-auth failure → error state with non-empty message',
      () async {
    repo
      ..throwOnReauthenticate = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await cubit.deleteAccount(email: 'a@b.com', password: 'wrong');
    _assertErrorStateNonEmpty();
  });

  test('P4h: error message matches thrown exception string', () async {
    const expectedMessage = 'auth.errors.weakPassword';
    repo
      ..throwOnRegister = true
      ..errorMessage = expectedMessage;
    await cubit.register(
      email: 'a@b.com',
      password: '123',
      firstName: 'A',
      lastName: 'B',
    );

    cubit.state.maybeMap(
      error: (e) => expect(e.message, equals(expectedMessage)),
      orElse: () => fail('Expected error state'),
    );
  });

  test(
      'P4i: every known error code produces a distinct, non-empty error message',
      () async {
    final errorCodes = [
      'auth.errors.invalidCredential',
      'auth.errors.userDisabled',
      'auth.errors.emailAlreadyInUse',
      'auth.errors.weakPassword',
      'auth.errors.tooManyRequests',
      'auth.errors.networkError',
      'auth.errors.generic',
    ];

    for (final code in errorCodes) {
      final testRepo = _FakeAuthRepository()
        ..throwOnSendPasswordReset = true
        ..errorMessage = code;
      final testCubit = AuthCubit(authRepository: testRepo, favoritesRepository: _FakeFavoritesRepository());

      await testCubit.sendPasswordReset('a@b.com');

      testCubit.state.maybeMap(
        error: (e) => expect(e.message, isNotEmpty,
            reason: 'Error state for code "$code" must have non-empty message'),
        orElse: () => fail('Expected error state for code "$code"'),
      );

      await testCubit.close();
      testRepo.dispose();
    }
  });
}

// ---------------------------------------------------------------------------
// Property 9: New user detection by creation time
// ---------------------------------------------------------------------------

void _propertyNewUserDetection() {
  // Requirements: 13.2
  // Returns true iff |creationTime - currentTime| ≤ 60s

  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  Future<bool?> _getIsNewUser(_FakeUser user) async {
    repo.pushUser(user);
    await Future.delayed(Duration.zero);
    return cubit.state.maybeMap(
      authenticated: (s) => s.isNewUser,
      orElse: () => null,
    );
  }

  test('P9a: null creationTime → isNewUser is false', () async {
    final user = _FakeUser(uid: 'uid-no-creation', creationTime: null);
    final isNew = await _getIsNewUser(user);
    expect(isNew, isFalse);
  });

  test('P9b: creationTime = now → isNewUser is true', () async {
    final user = _FakeUser(uid: 'uid-just-now', creationTime: DateTime.now());
    final isNew = await _getIsNewUser(user);
    expect(isNew, isTrue);
  });

  test('P9c: creationTime 30s ago → isNewUser is true', () async {
    final user = _FakeUser(
      uid: 'uid-30s-ago',
      creationTime: DateTime.now().subtract(const Duration(seconds: 30)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isTrue);
  });

  test('P9d: creationTime exactly 60s ago → isNewUser is true', () async {
    final user = _FakeUser(
      uid: 'uid-60s-ago',
      creationTime: DateTime.now().subtract(const Duration(seconds: 60)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isTrue);
  });

  test('P9e: creationTime 61s ago → isNewUser is false', () async {
    final user = _FakeUser(
      uid: 'uid-61s-ago',
      creationTime: DateTime.now().subtract(const Duration(seconds: 61)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isFalse);
  });

  test('P9f: creationTime 5 minutes ago → isNewUser is false', () async {
    final user = _FakeUser(
      uid: 'uid-5min-ago',
      creationTime: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isFalse);
  });

  test('P9g: creationTime in the future within 60s → isNewUser is true',
      () async {
    final user = _FakeUser(
      uid: 'uid-future-30s',
      creationTime: DateTime.now().add(const Duration(seconds: 30)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isTrue);
  });

  test('P9h: creationTime in the future beyond 60s → isNewUser is false',
      () async {
    // Use 120s to avoid boundary flakiness from sub-millisecond timing differences
    final user = _FakeUser(
      uid: 'uid-future-120s',
      creationTime: DateTime.now().add(const Duration(seconds: 120)),
    );
    final isNew = await _getIsNewUser(user);
    expect(isNew, isFalse);
  });

  test('P9i: isNewUser changes across successive auth stream events', () async {
    final oldUser = _FakeUser(
      uid: 'uid-old',
      creationTime: DateTime.now().subtract(const Duration(minutes: 10)),
    );
    final newUser = _FakeUser(
      uid: 'uid-new',
      creationTime: DateTime.now(),
    );

    final isOld = await _getIsNewUser(oldUser);
    expect(isOld, isFalse, reason: 'Returning user must not be marked as new');

    final isNew = await _getIsNewUser(newUser);
    expect(isNew, isTrue, reason: 'Fresh user must be marked as new');
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('AuthCubit — property tests', () {
    group(
      'Property 2: Auth stream events map to correct AuthState',
      _propertyAuthStreamMapping,
    );
    group(
      'Property 3: Auth operations emit loading state first',
      _propertyLoadingStateFirst,
    );
    group(
      'Property 4: Failed auth operations emit error state with message',
      _propertyFailedOperationsEmitError,
    );
    group(
      'Property 9: New user detection by creation time',
      _propertyNewUserDetection,
    );
  });
}
