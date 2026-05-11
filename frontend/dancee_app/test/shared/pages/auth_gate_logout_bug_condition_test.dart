// Task 3: Bug condition exploration test for Logout Confirmation
//
// EXPECTED OUTCOME ON UNFIXED CODE: FAILS
// The test confirms the bug: AuthGatePage currently shows the generic
// "Sign in required" UI regardless of whether the user just signed out or
// was never authenticated. No showLogoutSuccess parameter exists and no
// didJustLogOut flag is read from AuthCubit.
//
// Counterexample documented here:
//   AuthGatePage renders identical UI whether the user just signed out
//   (authenticated → unauthenticated via signOut()) or arrived at a protected
//   route without ever logging in. No checkmark icon, no "Signed out
//   successfully" message — only the generic lock icon and t.authGate.title
//   ("Sign in required") are shown.
//
// Requirements: 1.2, 2.2

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/i18n/strings.g.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/states/auth_state.dart';
import 'package:dancee_app/services/destination_service.dart';
import 'package:dancee_app/shared/pages/auth_gate_page.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUserMetadata extends Fake implements UserMetadata {
  @override
  DateTime? get creationTime =>
      DateTime.now().subtract(const Duration(hours: 1));
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
  @override
  bool get emailVerified => true;
  @override
  UserMetadata get metadata => _FakeUserMetadata();
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  bool get isEmailProvider => false;

  void emitUser(User? user) => _controller.add(user);

  Future<void> dispose() => _controller.close();

  @override
  Future<void> ensureDirectusLinked() async {}

  @override
  Future<void> signOut() async {
    // Emit null to simulate Firebase auth state change after sign-out.
    _controller.add(null);
  }
}

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a GoRouter that simulates the ProfileRoute behavior:
/// authenticated → ProfileScreen stub, orElse → AuthGatePage.
GoRouter _buildRouter(AuthCubit authCubit) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) => authState.maybeMap(
              authenticated: (_) => const Scaffold(
                body: Center(child: Text('ProfileScreen')),
              ),
              orElse: () => const AuthGatePage(intendedRoute: '/profile'),
            ),
          ),
        ),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
    if (!sl.isRegistered<DestinationService>()) {
      sl.registerLazySingleton<DestinationService>(() => DestinationService());
    }
  });

  tearDownAll(() async {
    if (sl.isRegistered<DestinationService>()) {
      sl.unregister<DestinationService>();
    }
  });

  group(
    'Task 3 — Bug Condition: AuthGatePage shows no logout confirmation after sign-out',
    () {
      late _FakeAuthRepository fakeAuthRepo;
      late AuthCubit authCubit;

      setUp(() {
        fakeAuthRepo = _FakeAuthRepository();
        authCubit = AuthCubit(
          authRepository: fakeAuthRepo,
          favoritesRepository: _FakeFavoritesRepository(),
        );
      });

      tearDown(() async {
        await authCubit.close();
        await fakeAuthRepo.dispose();
      });

      // -----------------------------------------------------------------------
      // Property 1: Bug Condition
      // isBugCondition2(input) where:
      //   input.previousState = authenticated
      //   input.currentState = unauthenticated
      //   input.trigger = 'signOut'
      //   input.currentRoute IN ['/saved', '/profile']
      //
      // EXPECTED OUTCOME ON UNFIXED CODE: FAILS
      // Reason: AuthGatePage renders with lock icon and t.authGate.title
      // ("Sign in required"), not a checkmark and logout success message.
      // -----------------------------------------------------------------------
      testWidgets(
        'FAILS_ON_UNFIXED: shows logout success icon after authenticated→unauthenticated transition via signOut',
        (tester) async {
          // Start as authenticated.
          fakeAuthRepo.emitUser(_FakeUser());
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouter(authCubit)),
          );
          await tester.pump();
          await tester.pump();

          // Verify we're on the authenticated screen.
          expect(find.text('ProfileScreen'), findsOneWidget);

          // Simulate sign-out: AuthCubit.signOut() emits loading then unauthenticated.
          await authCubit.signOut();
          await tester.pump();
          await tester.pump();

          // Expected behavior (post-fix): AuthGatePage shows a logout success
          // indicator (checkmark icon) distinct from the generic lock icon.
          //
          // Bug (pre-fix): only the lock icon is shown regardless of auth
          // transition type — no showLogoutSuccess parameter exists on AuthGatePage.
          expect(
            find.byIcon(Icons.check_circle_outline_rounded),
            findsOneWidget,
            reason:
                'Expected a checkmark icon to indicate successful logout, '
                'but only the generic lock icon (Icons.lock_outline_rounded) '
                'was found. Bug: AuthGatePage has no showLogoutSuccess parameter '
                'and cannot distinguish post-logout from an unauthenticated visit.',
          );
        },
      );

      testWidgets(
        'FAILS_ON_UNFIXED: shows logout success message text after sign-out (not generic "Sign in required")',
        (tester) async {
          // Start as authenticated.
          fakeAuthRepo.emitUser(_FakeUser());
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouter(authCubit)),
          );
          await tester.pump();
          await tester.pump();

          expect(find.text('ProfileScreen'), findsOneWidget);

          // Simulate sign-out.
          await authCubit.signOut();
          await tester.pump();
          await tester.pump();

          // Expected behavior (post-fix): a logout-specific success message
          // (t.authGate.logoutTitle = "Signed out successfully") is displayed.
          //
          // Bug (pre-fix): only t.authGate.title ("Sign in required") is shown.
          expect(
            find.text('Signed out successfully'),
            findsOneWidget,
            reason:
                'Expected "Signed out successfully" to be displayed after '
                'sign-out, but the generic "Sign in required" title was shown '
                'instead. Bug: AuthGatePage has no mechanism to communicate '
                'that the user just completed a sign-out action.',
          );
        },
      );

      testWidgets(
        'FAILS_ON_UNFIXED: does not show generic "Sign in required" title after sign-out',
        (tester) async {
          // Start as authenticated.
          fakeAuthRepo.emitUser(_FakeUser());
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouter(authCubit)),
          );
          await tester.pump();
          await tester.pump();

          // Simulate sign-out.
          await authCubit.signOut();
          await tester.pump();
          await tester.pump();

          // Expected behavior (post-fix): the generic lock + "Sign in required"
          // title is replaced by the logout success UI.
          //
          // Bug (pre-fix): "Sign in required" IS shown, making this assertion fail.
          expect(
            find.text('Sign in required'),
            findsNothing,
            reason:
                'After sign-out, the page should show a logout confirmation '
                'instead of the generic "Sign in required" title. '
                'Bug: AuthGatePage shows "Sign in required" for all unauthenticated '
                'states, including post-logout, with no distinction.',
          );
        },
      );
    },
  );
}
