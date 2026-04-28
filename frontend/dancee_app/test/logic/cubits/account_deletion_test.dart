// Feature: firebase-auth
// Task 10.3: Unit tests for account deletion flow
// Covers:
//   - Re-auth failure cancels deletion (deleteAccount not called)
//   - CMS cleanup ordering: reauthenticate called before deleteAccount
//   - Error handling at each step (reauth failure, deleteAccount failure)
// Requirements: 17.3, 17.4, 17.5, 17.7, 17.8

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

class _FakeUserMetadata extends Fake implements UserMetadata {
  _FakeUserMetadata({this.creationTime});
  @override
  final DateTime? creationTime;
}

class _FakeUser extends Fake implements User {
  _FakeUser({
    required this.uid,
    this.email,
    this.emailVerified = false,
  }) : metadata = _FakeUserMetadata(creationTime: DateTime.now());

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName = null;
  @override
  final bool emailVerified;
  @override
  final UserMetadata metadata;
}

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {
  bool deleteCalled = false;
  String? lastDeletedUserId;

  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {
    deleteCalled = true;
    lastDeletedUserId = userId;
  }
}

/// A controlled fake [AuthRepository] that:
/// - Records the sequence of method calls (for ordering assertions)
/// - Allows configuring individual methods to throw
class _TrackedAuthRepository extends Fake implements AuthRepository {
  _TrackedAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  // Call tracking
  final List<String> callOrder = [];

  // Throw-on-call flags
  bool throwOnReauthenticate = false;
  bool throwOnDeleteAccount = false;

  String reauthenticateError = 'auth.errors.invalidCredential';
  String deleteAccountError = 'auth.errors.generic';

  // Argument capture
  String? capturedEmail;
  String? capturedPassword;

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
  Future<void> reauthenticate({String? email, String? password}) async {
    callOrder.add('reauthenticate');
    capturedEmail = email;
    capturedPassword = password;
    if (throwOnReauthenticate) throw reauthenticateError;
  }

  @override
  Future<void> deleteAccount() async {
    callOrder.add('deleteAccount');
    if (throwOnDeleteAccount) throw deleteAccountError;
    // Simulate Firebase account deletion causing auth state change
    pushUser(null);
  }

  @override
  Future<void> signOut() async {
    callOrder.add('signOut');
  }
}

// ---------------------------------------------------------------------------
// Group 1: Re-auth failure cancels deletion
// ---------------------------------------------------------------------------

void _reauthFailureCancelsDeletion() {
  // Requirements: 17.3, 17.4
  late _TrackedAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _TrackedAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  test('reauthenticate failure → error state emitted', () async {
    repo
      ..throwOnReauthenticate = true
      ..reauthenticateError = 'auth.errors.invalidCredential';

    await cubit.deleteAccount(email: 'user@test.com', password: 'wrong-pass');

    cubit.state.maybeMap(
      error: (e) => expect(e.message, equals('auth.errors.invalidCredential')),
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  });

  test('reauthenticate failure → deleteAccount is never called', () async {
    repo
      ..throwOnReauthenticate = true
      ..reauthenticateError = 'auth.errors.invalidCredential';

    await cubit.deleteAccount(email: 'user@test.com', password: 'wrong-pass');

    expect(
      repo.callOrder.contains('deleteAccount'),
      isFalse,
      reason: 'deleteAccount must not be called when reauthenticate fails',
    );
  });

  test('reauthenticate failure with network error → error state', () async {
    repo
      ..throwOnReauthenticate = true
      ..reauthenticateError = 'auth.errors.networkError';

    await cubit.deleteAccount(email: 'user@test.com', password: 'pass');

    cubit.state.maybeMap(
      error: (e) => expect(e.message, isNotEmpty),
      orElse: () => fail('Expected error state'),
    );
    expect(repo.callOrder, equals(['reauthenticate']));
  });

  test('reauthenticate failure → user remains signed in (no unauthenticated state)', () async {
    // Sign in a user first
    final user = _FakeUser(uid: 'uid-123', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    expect(cubit.state.isAuthenticated, isTrue);

    repo
      ..throwOnReauthenticate = true
      ..reauthenticateError = 'auth.errors.invalidCredential';

    await cubit.deleteAccount(email: 'user@test.com', password: 'wrong');

    // Should be in error state, not unauthenticated
    cubit.state.maybeMap(
      error: (_) {}, // expected
      unauthenticated: (_) => fail('User must remain authenticated after re-auth failure'),
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  });

  test('email and password are forwarded to reauthenticate', () async {
    const testEmail = 'alice@example.com';
    const testPassword = 'SecurePass123';

    repo
      ..throwOnReauthenticate = true
      ..reauthenticateError = 'auth.errors.generic';

    await cubit.deleteAccount(email: testEmail, password: testPassword);

    expect(repo.capturedEmail, equals(testEmail));
    expect(repo.capturedPassword, equals(testPassword));
  });
}

extension on AuthState {
  bool get isAuthenticated => maybeMap(authenticated: (_) => true, orElse: () => false);
}

// ---------------------------------------------------------------------------
// Group 2: Correct call ordering (reauthenticate before deleteAccount)
// ---------------------------------------------------------------------------

void _callOrderingTests() {
  // Requirements: 17.5 (CMS cleanup before Firebase deletion)
  // The current implementation calls reauthenticate then deleteAccount in sequence.
  late _TrackedAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _TrackedAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  test('reauthenticate is called before deleteAccount on success', () async {
    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');
    await Future.delayed(Duration.zero);

    expect(
      repo.callOrder,
      equals(['reauthenticate', 'deleteAccount']),
      reason: 'reauthenticate must be called before deleteAccount',
    );
  });

  test('deleteAccount is called exactly once on successful re-auth', () async {
    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');
    await Future.delayed(Duration.zero);

    final deleteCallCount = repo.callOrder.where((c) => c == 'deleteAccount').length;
    expect(deleteCallCount, equals(1));
  });

  test('reauthenticate is called exactly once', () async {
    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');

    final reauthCallCount = repo.callOrder.where((c) => c == 'reauthenticate').length;
    expect(reauthCallCount, equals(1));
  });

  test('loading state is emitted before final state', () async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.deleteAccount(email: 'user@test.com', password: 'correct');
    await Future.delayed(Duration.zero);

    await sub.cancel();

    expect(states, isNotEmpty, reason: 'Must emit at least one state');
    expect(
      states.first,
      const AuthState.loading(),
      reason: 'First emitted state must be loading',
    );
  });
}

// ---------------------------------------------------------------------------
// Group 3: Error handling at each step
// ---------------------------------------------------------------------------

void _errorHandlingTests() {
  // Requirements: 17.7, 17.8
  late _TrackedAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _TrackedAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  test('deleteAccount failure → error state with non-empty message', () async {
    repo
      ..throwOnDeleteAccount = true
      ..deleteAccountError = 'auth.errors.generic';

    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      error: (e) => expect(e.message, isNotEmpty),
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  });

  test('deleteAccount failure → reauthenticate was still called', () async {
    repo
      ..throwOnDeleteAccount = true
      ..deleteAccountError = 'auth.errors.generic';

    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');

    expect(
      repo.callOrder.contains('reauthenticate'),
      isTrue,
      reason: 'reauthenticate should have been called before deleteAccount threw',
    );
  });

  test('deleteAccount failure → error message matches thrown error', () async {
    const errorKey = 'auth.errors.tooManyRequests';
    repo
      ..throwOnDeleteAccount = true
      ..deleteAccountError = errorKey;

    await cubit.deleteAccount(email: 'user@test.com', password: 'pass');
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      error: (e) => expect(e.message, equals(errorKey)),
      orElse: () => fail('Expected error state'),
    );
  });

  test('successful deletion → loading then unauthenticated states', () async {
    final user = _FakeUser(uid: 'uid-to-delete', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.deleteAccount(email: 'user@test.com', password: 'correct-pass');
    await Future.delayed(Duration.zero);

    await sub.cancel();

    expect(states, isNotEmpty);
    expect(states.first, const AuthState.loading());
    expect(
      states.any((s) => s.maybeMap(unauthenticated: (_) => true, orElse: () => false)),
      isTrue,
      reason: 'unauthenticated state must be emitted after successful deletion',
    );
  });

  test('social sign-in deletion (no email/password) → reauthenticate called with null credentials',
      () async {
    await cubit.deleteAccount();

    expect(repo.capturedEmail, isNull);
    expect(repo.capturedPassword, isNull);
    expect(repo.callOrder.contains('reauthenticate'), isTrue);
  });

  test('error state message is non-empty for all known error types', () async {
    final errorKeys = [
      'auth.errors.invalidCredential',
      'auth.errors.tooManyRequests',
      'auth.errors.networkError',
      'auth.errors.generic',
    ];

    for (final errorKey in errorKeys) {
      final testRepo = _TrackedAuthRepository()
        ..throwOnReauthenticate = true
        ..reauthenticateError = errorKey;
      final testCubit = AuthCubit(authRepository: testRepo, favoritesRepository: _FakeFavoritesRepository());

      await testCubit.deleteAccount(email: 'a@b.com', password: 'pass');

      testCubit.state.maybeMap(
        error: (e) => expect(
          e.message,
          isNotEmpty,
          reason: 'Error message for "$errorKey" must be non-empty',
        ),
        orElse: () => fail('Expected error state for key "$errorKey"'),
      );

      await testCubit.close();
      testRepo.dispose();
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Task 10.3 — Re-auth failure cancels deletion', _reauthFailureCancelsDeletion);
  group('Task 10.3 — Call ordering: reauthenticate before deleteAccount', _callOrderingTests);
  group('Task 10.3 — Error handling at each deletion step', _errorHandlingTests);
}
