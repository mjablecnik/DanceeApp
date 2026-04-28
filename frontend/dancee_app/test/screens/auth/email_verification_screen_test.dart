// Feature: firebase-auth
// Task 7.4: Unit tests for EmailVerificationScreen
// Requirements: 8.4, 8.5, 8.6, 8.7

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/data/repositories/favorites_repository.dart';
import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/states/auth_state.dart';
import 'package:dancee_app2/screens/auth/email_verification/email_verification_screen.dart';

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

/// Fake [AuthRepository] for widget tests.
///
/// Push users via [pushUser]. After [reloadAndCheckVerified] is called,
/// [currentUser] returns [reloadedUser] (if set) instead of the original.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;
  User? _reloadedUser;

  // Call counts
  int sendEmailVerificationCount = 0;
  int reloadAndCheckVerifiedCount = 0;
  int signOutCount = 0;

  // Control flags
  bool throwOnSendEmailVerification = false;
  bool throwOnReloadAndCheckVerified = false;
  bool reloadVerifiedResult = false;
  String errorMessage = 'auth.errors.generic';

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _reloadedUser ?? _currentUser;

  void pushUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  /// Sets the user returned by [currentUser] after [reloadAndCheckVerified].
  void setReloadedUser(User? user) {
    _reloadedUser = user;
  }

  void dispose() => _controller.close();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() async {
    sendEmailVerificationCount++;
    if (throwOnSendEmailVerification) throw errorMessage;
  }

  @override
  Future<bool> reloadAndCheckVerified() async {
    reloadAndCheckVerifiedCount++;
    if (throwOnReloadAndCheckVerified) throw errorMessage;
    return reloadVerifiedResult;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
  }

  @override
  Future<void> reauthenticate({String? email, String? password}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount() async {
    throw UnimplementedError();
  }
}

// ---------------------------------------------------------------------------
// Widget builder helper
// ---------------------------------------------------------------------------

/// Builds a testable widget tree with [EmailVerificationScreen] at
/// `/verify-email`, plus stub routes for `/onboarding`, `/events`, `/login`.
///
/// Returns the [GoRouter] so tests can inspect `router.routeInformationProvider`.
Widget _buildTestApp({
  required AuthCubit cubit,
  required GoRouter router,
}) {
  return TranslationProvider(
    child: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

GoRouter _makeRouter() => GoRouter(
      initialLocation: '/verify-email',
      routes: [
        GoRoute(
          path: '/verify-email',
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) =>
              const Scaffold(body: Text('onboarding_screen')),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) =>
              const Scaffold(body: Text('events_screen')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('login_screen')),
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Tests: Requirement 8.4 — Resend button calls sendEmailVerification
// ---------------------------------------------------------------------------

void _resendButtonTests() {
  // Requirement 8.4: "Resend verification email" button sends email

  late _FakeAuthRepository repo;
  late AuthCubit cubit;
  late GoRouter router;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
    router = _makeRouter();
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
    router.dispose();
  });

  testWidgets('resend button calls sendEmailVerification on cubit', (tester) async {
    // Set up: authenticated, unverified user
    final user = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump(); // process state change
    await tester.pump(const Duration(milliseconds: 100)); // settle animation

    // Find and tap the resend button
    final resendFinder = find.text('Resend verification email');
    expect(resendFinder, findsOneWidget);

    await tester.tap(resendFinder);
    await tester.pump();

    expect(
      repo.sendEmailVerificationCount,
      equals(1),
      reason: 'Tapping resend should call sendEmailVerification once',
    );
  });

  testWidgets('resend button is disabled while loading', (tester) async {
    // Set up: loading state
    final user = _FakeUser(uid: 'uid-unverified', email: 'test@example.com');
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Simulate an operation in progress via operationInProgress (task 11:
    // non-auth-changing operations no longer emit AuthState.loading()).
    cubit.operationInProgress.value = true;
    await tester.pump();

    // OutlinedButton with null onPressed is disabled
    final resendButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Resend verification email'),
    );
    expect(resendButton.onPressed, isNull,
        reason: 'Resend button must be disabled when loading');

    cubit.operationInProgress.value = false;
  });

  testWidgets('resend can be tapped multiple times', (tester) async {
    final user = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final resendFinder = find.text('Resend verification email');

    await tester.tap(resendFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(resendFinder);
    await tester.pump();

    expect(repo.sendEmailVerificationCount, equals(2),
        reason: 'Each tap should call sendEmailVerification');
  });
}

// ---------------------------------------------------------------------------
// Tests: Requirement 8.5 — Check button calls reloadUser
// ---------------------------------------------------------------------------

void _checkButtonTests() {
  // Requirement 8.5: "I've verified my email" button reloads user state

  late _FakeAuthRepository repo;
  late AuthCubit cubit;
  late GoRouter router;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
    router = _makeRouter();
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
    router.dispose();
  });

  testWidgets('check button calls reloadAndCheckVerified on repo', (tester) async {
    final user = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(user);
    // After reload, still not verified
    repo.reloadVerifiedResult = false;
    repo.setReloadedUser(
      _FakeUser(uid: 'uid-unverified', email: 'test@example.com', emailVerified: false),
    );

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final checkFinder = find.text("I've verified my email");
    expect(checkFinder, findsOneWidget);

    await tester.tap(checkFinder);
    await tester.pump();

    expect(
      repo.reloadAndCheckVerifiedCount,
      equals(1),
      reason: 'Tapping check button should call reloadAndCheckVerified once',
    );
  });

  testWidgets('check button is disabled while loading', (tester) async {
    final user = _FakeUser(uid: 'uid-unverified', email: 'test@example.com');
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Simulate an operation in progress via operationInProgress (task 11:
    // non-auth-changing operations no longer emit AuthState.loading()).
    cubit.operationInProgress.value = true;
    await tester.pump();

    // When isLoading=true, GradientButton shows CircularProgressIndicator
    // instead of the label text, and onTap is null (InkWell disabled).
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // The label text is hidden while loading
    expect(find.text("I've verified my email"), findsNothing);

    // Verify operationInProgress is true
    expect(cubit.operationInProgress.value, isTrue);

    cubit.operationInProgress.value = false;
  });
}

// ---------------------------------------------------------------------------
// Tests: Requirement 8.6 — Verified → navigate to correct route
// ---------------------------------------------------------------------------

void _verifiedNavigationTests() {
  // Requirement 8.6: After verification confirmed, navigate to onboarding (new)
  //                  or events (returning).

  late _FakeAuthRepository repo;
  late AuthCubit cubit;
  late GoRouter router;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
    router = _makeRouter();
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
    router.dispose();
  });

  testWidgets('verified new user navigates to /onboarding', (tester) async {
    // Start: unverified user on screen
    final unverifiedUser = _FakeUser(
      uid: 'uid-new',
      email: 'new@example.com',
      emailVerified: false,
    );
    repo.pushUser(unverifiedUser);

    // After reload: verified new user (creationTime = now → isNewUser = true)
    final verifiedNewUser = _FakeUser(
      uid: 'uid-new',
      email: 'new@example.com',
      emailVerified: true,
      creationTime: DateTime.now(),
    );
    repo.reloadVerifiedResult = true;
    repo.setReloadedUser(verifiedNewUser);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap check button
    await tester.tap(find.text("I've verified my email"));
    await tester.pump(); // loading state
    await tester.pump(); // auth state change
    await tester.pump(const Duration(milliseconds: 100)); // navigation

    // Should navigate to /onboarding
    expect(find.text('onboarding_screen'), findsOneWidget,
        reason: 'Verified new user should be redirected to /onboarding');
  });

  testWidgets('verified returning user navigates to /events', (tester) async {
    // Start: unverified user on screen
    final unverifiedUser = _FakeUser(
      uid: 'uid-returning',
      email: 'returning@example.com',
      emailVerified: false,
    );
    repo.pushUser(unverifiedUser);

    // After reload: verified returning user (creationTime 5 min ago → isNewUser = false)
    final verifiedReturningUser = _FakeUser(
      uid: 'uid-returning',
      email: 'returning@example.com',
      emailVerified: true,
      creationTime: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    repo.reloadVerifiedResult = true;
    repo.setReloadedUser(verifiedReturningUser);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text("I've verified my email"));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('events_screen'), findsOneWidget,
        reason: 'Verified returning user should be redirected to /events');
  });
}

// ---------------------------------------------------------------------------
// Tests: Requirement 8.7 — Not verified → show "not verified yet" message
// ---------------------------------------------------------------------------

void _notVerifiedMessageTests() {
  // Requirement 8.7: When email is still not verified, show informative message.

  late _FakeAuthRepository repo;
  late AuthCubit cubit;
  late GoRouter router;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
    router = _makeRouter();
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
    router.dispose();
  });

  testWidgets('"not verified yet" message not shown initially', (tester) async {
    final user = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Email not verified yet. Please check your inbox.'),
      findsNothing,
      reason: '"Not verified yet" message should not appear before the user taps check',
    );
  });

  testWidgets('"not verified yet" message shown after check when still unverified',
      (tester) async {
    final user = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(user);

    // After reload, still not verified
    final stillUnverifiedUser = _FakeUser(
      uid: 'uid-unverified',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.reloadVerifiedResult = false;
    repo.setReloadedUser(stillUnverifiedUser);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap check
    await tester.tap(find.text("I've verified my email"));
    await tester.pump(); // loading
    await tester.pump(); // auth state (unverified authenticated)
    await tester.pump(const Duration(milliseconds: 100)); // settle

    expect(
      find.text('Email not verified yet. Please check your inbox.'),
      findsOneWidget,
      reason: '"Not verified yet" message should appear when email is still unverified',
    );

    // Still on verify-email screen
    expect(find.text('onboarding_screen'), findsNothing);
    expect(find.text('events_screen'), findsNothing);
  });

  testWidgets('"not verified yet" message disappears after successful verification',
      (tester) async {
    final unverifiedUser = _FakeUser(
      uid: 'uid-test',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.pushUser(unverifiedUser);

    // First reload: still not verified
    final stillUnverified = _FakeUser(
      uid: 'uid-test',
      email: 'test@example.com',
      emailVerified: false,
    );
    repo.reloadVerifiedResult = false;
    repo.setReloadedUser(stillUnverified);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // First tap: not verified yet
    await tester.tap(find.text("I've verified my email"));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Email not verified yet. Please check your inbox.'),
      findsOneWidget,
    );

    // Second reload: now verified (returning user)
    final nowVerified = _FakeUser(
      uid: 'uid-test',
      email: 'test@example.com',
      emailVerified: true,
      creationTime: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    repo.reloadVerifiedResult = true;
    repo.setReloadedUser(nowVerified);

    // Second tap: now verified → navigate away
    await tester.tap(find.text("I've verified my email"));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should have navigated to /events
    expect(find.text('events_screen'), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------
// Tests: Sign out button
// ---------------------------------------------------------------------------

void _signOutButtonTests() {
  // Requirement 8.8: Sign out option is available on email verification screen

  late _FakeAuthRepository repo;
  late AuthCubit cubit;
  late GoRouter router;

  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo, favoritesRepository: _FakeFavoritesRepository());
    router = _makeRouter();
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
    router.dispose();
  });

  testWidgets('sign out button is present on screen', (tester) async {
    final user = _FakeUser(uid: 'uid-test', email: 'test@example.com');
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('sign out button calls signOut on cubit', (tester) async {
    final user = _FakeUser(uid: 'uid-test', email: 'test@example.com');
    repo.pushUser(user);

    await tester.pumpWidget(_buildTestApp(cubit: cubit, router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(repo.signOutCount, equals(1),
        reason: 'Sign out button should call signOut once');
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('EmailVerificationScreen — unit tests', () {
    group(
      'Requirement 8.4: Resend button calls sendEmailVerification',
      _resendButtonTests,
    );
    group(
      'Requirement 8.5: Check button calls reloadUser',
      _checkButtonTests,
    );
    group(
      'Requirement 8.6: Verified state navigates to correct route',
      _verifiedNavigationTests,
    );
    group(
      'Requirement 8.7: Unverified state shows "not verified yet" message',
      _notVerifiedMessageTests,
    );
    group(
      'Requirement 8.8: Sign out button available',
      _signOutButtonTests,
    );
  });
}
