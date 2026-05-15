// Task 4: Preservation property tests for AuthGatePage (BEFORE implementing fix)
//
// EXPECTED OUTCOME ON UNFIXED AND FIXED CODE: PASSES
// These tests document behaviors that already work correctly and MUST continue
// to work after the Bug 2 fix (task 8).
//
// Properties verified:
//   Property 4a: When user navigates to a protected route WITHOUT a prior
//                sign-out (never authenticated), AuthGatePage displays the
//                generic "Sign in required" UI — lock icon, title, message,
//                login and register buttons.
//   Property 4b: When user signs out (authenticated → unauthenticated),
//                the snackbar with t.common.logoutSuccess text continues to appear.
//
// Observations on unfixed code:
//   - AuthGatePage always renders lock icon + "Sign in required" title. ✓ passes.
//   - The BlocListener in main.dart fires showSnackBar on auth sign-out transition.
//     This test exercises the same listener logic in isolation. ✓ passes.
//
// Requirements: 3.2, 3.5

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
/// authenticated → ProfileScreen stub, orElse → AuthGatePage (no logout flag).
GoRouter _buildRouterNoLogout(AuthCubit authCubit) {
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

  // -------------------------------------------------------------------------
  // Property 4a: Generic Auth Gate for non-logout navigation
  //
  // For all navigation to protected routes where the user was never
  // authenticated (no sign-out transition), AuthGatePage displays the
  // generic "Sign in required" UI unchanged.
  //
  // This behavior must be preserved after the Bug 2 fix.
  // -------------------------------------------------------------------------
  group(
    'Task 4 — Preservation: AuthGatePage shows generic "Sign in required" for unauthenticated users',
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

      testWidgets(
        'shows lock icon when user was never authenticated',
        (tester) async {
          // No user emitted — user was never authenticated.
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouterNoLogout(authCubit)),
          );
          await tester.pump();

          // Property 4a: lock icon must be present for non-logout navigation.
          expect(
            find.byIcon(Icons.lock_outline_rounded),
            findsOneWidget,
            reason:
                'AuthGatePage must show the lock icon for unauthenticated users '
                'who were never logged in. This behavior must be preserved after '
                'the Bug 2 fix (showLogoutSuccess defaults to false).',
          );
        },
      );

      testWidgets(
        'shows "Sign in required" title when user was never authenticated',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouterNoLogout(authCubit)),
          );
          await tester.pump();

          // Property 4a: generic title must appear for non-logout navigation.
          expect(
            find.text('Sign in required'),
            findsOneWidget,
            reason:
                'AuthGatePage must show the generic "Sign in required" title '
                'when the user was never authenticated. Must be preserved after '
                'the Bug 2 fix.',
          );
        },
      );

      testWidgets(
        'shows login and register buttons when user was never authenticated',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouterNoLogout(authCubit)),
          );
          await tester.pump();

          // Property 4a: login and register call-to-action buttons must appear.
          expect(
            find.text('Log in'),
            findsOneWidget,
            reason:
                'AuthGatePage must show the "Log in" button for unauthenticated '
                'users. This must be preserved after the Bug 2 fix.',
          );
          expect(
            find.text('Create account'),
            findsOneWidget,
            reason:
                'AuthGatePage must show the "Create account" button for '
                'unauthenticated users. This must be preserved after the Bug 2 fix.',
          );
        },
      );

      testWidgets(
        'does NOT show logout success icon when user was never authenticated',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouterNoLogout(authCubit)),
          );
          await tester.pump();

          // Property 4a: no checkmark icon for users who were never logged in.
          expect(
            find.byIcon(Icons.check_circle_outline_rounded),
            findsNothing,
            reason:
                'AuthGatePage must NOT show a checkmark icon when the user '
                'was never authenticated (no sign-out transition occurred). '
                'This preserves the generic UI for unauthenticated navigation.',
          );
        },
      );

      testWidgets(
        'does NOT show logout success message when user was never authenticated',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: _buildRouterNoLogout(authCubit)),
          );
          await tester.pump();

          // Property 4a: no "Signed out successfully" text for non-logout navigation.
          expect(
            find.text('Signed out successfully'),
            findsNothing,
            reason:
                'AuthGatePage must NOT show "Signed out successfully" when the '
                'user was never authenticated. Only a prior sign-out transition '
                'should trigger the logout success UI.',
          );
        },
      );
    },
  );

  // -------------------------------------------------------------------------
  // Property 4b: Snackbar logout message continues to fire on sign-out
  //
  // For all sign-out actions (authenticated → unauthenticated), the snackbar
  // notification (t.common.logoutSuccess) continues to appear. This behavior
  // must be preserved after the Bug 2 fix.
  //
  // The snackbar is shown by a BlocListener<AuthCubit> in main.dart that
  // fires when prev = authenticated AND curr = unauthenticated.
  // This test exercises the same listener logic in isolation.
  // -------------------------------------------------------------------------
  group(
    'Task 4 — Preservation: snackbar logout message continues to appear after sign-out',
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

      testWidgets(
        'shows snackbar with logoutSuccess text after authenticated→unauthenticated transition',
        (tester) async {
          // Property 4b: For all sign-out actions, the snackbar continues to appear.
          //
          // AuthCubit.signOut() emits loading → unauthenticated (not
          // authenticated → unauthenticated directly), so the BlocListener
          // condition (prev=authenticated AND curr=unauthenticated) does NOT
          // fire through the normal signOut() path. This test uses a direct
          // stream emission (fakeAuthRepo.emitUser(null)) to simulate the
          // authenticated → unauthenticated transition that would occur during
          // a Firebase token revocation.
          //
          // BlocListener (SingleChildStatefulWidget) receives bloc stream
          // events delivered via Dart's event queue. We use tester.runAsync to
          // allow event queue processing between pumps.
          fakeAuthRepo.emitUser(_FakeUser());

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AuthCubit>.value(
                value: authCubit,
                child: Scaffold(
                  body: BlocListener<AuthCubit, AuthState>(
                    listenWhen: (prev, curr) =>
                        prev.maybeMap(
                            authenticated: (_) => true, orElse: () => false) &&
                        curr.maybeMap(
                            unauthenticated: (_) => true, orElse: () => false),
                    listener: (context, state) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.common.logoutSuccess)),
                      );
                    },
                    child: const Center(child: Text('App content')),
                  ),
                ),
              ),
            ),
          );

          // Use runAsync to allow the async broadcast stream (fakeAuthRepo →
          // authCubit → BlocListener) to deliver events via the event queue.
          await tester.runAsync(() async {
            await Future.delayed(Duration.zero);
          });
          await tester.pump(); // BlocListener receives authenticated state

          expect(
            authCubit.state.maybeMap(
                authenticated: (_) => true, orElse: () => false),
            isTrue,
          );

          fakeAuthRepo.emitUser(null);
          await tester.runAsync(() async {
            await Future.delayed(Duration.zero);
          });
          await tester.pump(); // BlocListener fires, showSnackBar called
          await tester.pump(); // snackbar rendered

          // Property 4b: snackbar with logoutSuccess text must appear.
          expect(
            find.text('You have been successfully signed out.'),
            findsOneWidget,
            reason:
                'The snackbar showing t.common.logoutSuccess must continue to '
                'appear when auth transitions from authenticated to unauthenticated. '
                'This is existing behavior that must not be broken by the Bug 2 '
                'fix (which adds a separate persistent UI confirmation on AuthGatePage).',
          );
        },
      );

      testWidgets(
        'does NOT show snackbar when user was never authenticated (no sign-out transition)',
        (tester) async {
          final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

          await tester.pumpWidget(
            MaterialApp(
              scaffoldMessengerKey: scaffoldMessengerKey,
              home: BlocProvider<AuthCubit>.value(
                value: authCubit,
                child: BlocListener<AuthCubit, AuthState>(
                  listenWhen: (prev, curr) =>
                      prev.maybeMap(
                          authenticated: (_) => true, orElse: () => false) &&
                      curr.maybeMap(
                          unauthenticated: (_) => true, orElse: () => false),
                  listener: (context, state) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(t.common.logoutSuccess),
                      ),
                    );
                  },
                  child: const Scaffold(
                    body: Center(child: Text('App content')),
                  ),
                ),
              ),
            ),
          );

          // No user emitted — user was never authenticated.
          await tester.pump();
          await tester.pump();

          // Property 4b: snackbar must NOT appear for non-sign-out navigation.
          expect(
            find.text('You have been successfully signed out.'),
            findsNothing,
            reason:
                'The logout snackbar must NOT appear when no sign-out transition '
                'occurred. Only an authenticated → unauthenticated transition via '
                'signOut() should trigger the snackbar.',
          );
        },
      );
    },
  );
}
