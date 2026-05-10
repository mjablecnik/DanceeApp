// Feature: anonymous-browsing
// Property 1: Router guard redirect correctness for anonymous users
// Property 2: Router guard redirect correctness for authenticated users
// Validates: Requirements 1.1, 1.2, 2.8, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app/core/router_guard.dart';
import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/states/auth_state.dart';
import 'package:dancee_app/services/destination_service.dart';

// ---------------------------------------------------------------------------
// Fakes / Helpers
// ---------------------------------------------------------------------------

/// Fake [BuildContext] — not actually used by [routerGuard] but required by
/// the function signature.
class _FakeContext extends Fake implements BuildContext {}

/// Fake [GoRouterState] that exposes only [uri], which is all [routerGuard]
/// reads from the state.
class _FakeRouterState extends Fake implements GoRouterState {
  _FakeRouterState(String path) : uri = Uri(path: path);

  @override
  final Uri uri;
}

/// Minimal [AuthRepository] fake: the stream never emits so that the cubit's
/// internal subscription does not interfere with the state we set manually.
class _NoOpAuthRepository extends Fake implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;
}

class _NoOpFavoritesRepository extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

/// [AuthCubit] subclass that starts with a predetermined [AuthState].
class _FixedStateAuthCubit extends AuthCubit {
  _FixedStateAuthCubit(AuthState fixedState)
      : super(
          authRepository: _NoOpAuthRepository(),
          favoritesRepository: _NoOpFavoritesRepository(),
        ) {
    // ignore: invalid_use_of_protected_member
    emit(fixedState);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Call [routerGuard] with the given path and return the redirect, if any.
String? _guard(String path) =>
    routerGuard(_FakeContext(), _FakeRouterState(path));

/// Register [state] as the active [AuthCubit] in the service locator and
/// return the cubit so it can be closed in tearDown.
AuthCubit _registerState(AuthState state) {
  if (sl.isRegistered<AuthCubit>()) sl.unregister<AuthCubit>();
  final cubit = _FixedStateAuthCubit(state);
  sl.registerSingleton<AuthCubit>(cubit);
  return cubit;
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

/// Public routes — anonymous users can browse these freely.
const _publicRoutes = ['/events', '/events/123', '/courses', '/courses/42'];

/// Protected routes — anonymous users see AuthGatePage in-place (no redirect
/// from the router guard; the page builder handles this).
const _protectedRoutes = ['/profile', '/saved'];

const _authOnlyRoutes = ['/login', '/register', '/forgot-password'];

const _generalRoutes = ['/', '/about'];

const _authenticatedState = AuthState.authenticated(
  uid: 'uid-1',
  email: 'user@example.com',
  displayName: 'Test User',
  emailVerified: true,
  isNewUser: false,
);

const _unverifiedState = AuthState.authenticated(
  uid: 'uid-2',
  email: 'unverified@example.com',
  displayName: null,
  emailVerified: false,
  isNewUser: false,
);

// ---------------------------------------------------------------------------
// Property 1 & 2: Router guard redirect correctness
// ---------------------------------------------------------------------------

void _propertyRouterGuardCorrectness() {
  late AuthCubit cubit;

  setUp(() {
    if (!sl.isRegistered<DestinationService>()) {
      sl.registerLazySingleton<DestinationService>(() => DestinationService());
    }
  });

  tearDown(() async {
    await cubit.close();
    if (sl.isRegistered<AuthCubit>()) sl.unregister<AuthCubit>();
    if (sl.isRegistered<DestinationService>()) {
      sl.unregister<DestinationService>();
    }
  });

  // ── Unauthenticated ──────────────────────────────────────────────────────

  group('Unauthenticated state', () {
    setUp(() {
      cubit = _registerState(const AuthState.unauthenticated());
    });

    test(
      'P1a: unauthenticated + public routes → no redirect (anonymous browsing)',
      () {
        for (final route in _publicRoutes) {
          expect(
            _guard(route),
            isNull,
            reason: 'Expected no redirect for public route "$route"',
          );
        }
      },
    );

    test(
      'P1b: unauthenticated + protected routes → no redirect (AuthGatePage shown in-page)',
      () {
        for (final route in _protectedRoutes) {
          expect(
            _guard(route),
            isNull,
            reason:
                'Expected no redirect for protected route "$route" — AuthGatePage handles this in-page',
          );
        }
      },
    );

    test(
      'P1c: unauthenticated + /onboarding → redirect to /events',
      () => expect(_guard('/onboarding'), equals('/events')),
    );

    test(
      'P1d: unauthenticated + /verify-email → redirect to /events',
      () => expect(_guard('/verify-email'), equals('/events')),
    );

    test(
      'P1e: unauthenticated + auth-only screens → no redirect (null)',
      () {
        for (final route in _authOnlyRoutes) {
          expect(
            _guard(route),
            isNull,
            reason:
                'Expected no redirect for auth screen "$route" when unauthenticated',
          );
        }
      },
    );

    test(
      'P1f: unauthenticated + general routes → no redirect (null)',
      () {
        for (final route in _generalRoutes) {
          expect(
            _guard(route),
            isNull,
            reason: 'Expected no redirect for route "$route"',
          );
        }
      },
    );
  });

  // ── Loading ───────────────────────────────────────────────────────────────

  group('Loading state', () {
    setUp(() {
      cubit = _registerState(const AuthState.loading());
    });

    test(
      'P8f: loading + any route → no redirect (null)',
      () {
        final allRoutes = [
          ..._publicRoutes,
          ..._protectedRoutes,
          ..._authOnlyRoutes,
          ..._generalRoutes,
          '/onboarding',
          '/verify-email',
        ];
        for (final route in allRoutes) {
          expect(
            _guard(route),
            isNull,
            reason: 'Loading state must not redirect "$route"',
          );
        }
      },
    );
  });

  // ── Authenticated + verified ──────────────────────────────────────────────

  group('Authenticated + verified state', () {
    setUp(() {
      cubit = _registerState(_authenticatedState);
    });

    test(
      'P2a: authenticated+verified + auth-only screens → redirect to /events',
      () {
        for (final route in _authOnlyRoutes) {
          expect(
            _guard(route),
            equals('/events'),
            reason:
                'Expected /events redirect for auth-only route "$route" when verified',
          );
        }
      },
    );

    test(
      'P2b: authenticated+verified + /verify-email → redirect to /events',
      () => expect(_guard('/verify-email'), equals('/events')),
    );

    test(
      'P2c: authenticated+verified + public routes → no redirect (null)',
      () {
        for (final route in _publicRoutes) {
          expect(
            _guard(route),
            isNull,
            reason:
                'Expected no redirect for public route "$route" when verified',
          );
        }
      },
    );

    test(
      'P2d: authenticated+verified + protected routes → no redirect (null)',
      () {
        for (final route in _protectedRoutes) {
          expect(
            _guard(route),
            isNull,
            reason:
                'Expected no redirect for protected route "$route" when verified',
          );
        }
      },
    );

    test(
      'P2e: authenticated+verified + /onboarding → no redirect (null)',
      () => expect(_guard('/onboarding'), isNull),
    );
  });

  // ── Authenticated + unverified ────────────────────────────────────────────

  group('Authenticated + unverified state', () {
    setUp(() {
      cubit = _registerState(_unverifiedState);
    });

    test(
      'P8k: authenticated+unverified + /verify-email → no redirect (null)',
      () => expect(_guard('/verify-email'), isNull),
    );

    test(
      'P8l: authenticated+unverified + public routes → redirect to /verify-email',
      () {
        for (final route in _publicRoutes) {
          expect(
            _guard(route),
            equals('/verify-email'),
            reason:
                'Expected /verify-email redirect for "$route" when unverified',
          );
        }
      },
    );

    test(
      'P8l2: authenticated+unverified + protected routes → redirect to /verify-email',
      () {
        for (final route in _protectedRoutes) {
          expect(
            _guard(route),
            equals('/verify-email'),
            reason:
                'Expected /verify-email redirect for "$route" when unverified',
          );
        }
      },
    );

    test(
      'P8m: authenticated+unverified + auth-only screens → redirect to /verify-email',
      () {
        for (final route in _authOnlyRoutes) {
          expect(
            _guard(route),
            equals('/verify-email'),
            reason:
                'Expected /verify-email redirect for "$route" when unverified',
          );
        }
      },
    );

    test(
      'P8n: authenticated+unverified + /onboarding → allowed (no redirect)',
      () => expect(_guard('/onboarding'), isNull),
    );
  });

  // ── Error state ───────────────────────────────────────────────────────────

  group('Error state', () {
    setUp(() {
      cubit = _registerState(const AuthState.error(message: 'some error'));
    });

    test(
      'P8o: error + any route → no redirect (null)',
      () {
        final allRoutes = [
          ..._publicRoutes,
          ..._protectedRoutes,
          ..._authOnlyRoutes,
          ..._generalRoutes,
          '/onboarding',
          '/verify-email',
        ];
        for (final route in allRoutes) {
          expect(
            _guard(route),
            isNull,
            reason: 'Error state must not redirect "$route"',
          );
        }
      },
    );
  });

  // ── Cross-cutting: redirect target invariants ─────────────────────────────

  group('Cross-cutting invariants', () {
    test(
      'P8p: redirect target is always one of the known destinations or null',
      () {
        // After the anonymous-browsing rewrite, /login is no longer a redirect
        // target. Valid targets are /events, /verify-email, or null.
        const validTargets = {'/verify-email', '/events', null};
        final cases = <(AuthState, String)>[
          (const AuthState.unauthenticated(), '/events'),
          (const AuthState.unauthenticated(), '/login'),
          (const AuthState.unauthenticated(), '/onboarding'),
          (const AuthState.unauthenticated(), '/verify-email'),
          (const AuthState.loading(), '/events'),
          (_authenticatedState, '/login'),
          (_authenticatedState, '/events'),
          (_authenticatedState, '/verify-email'),
          (_unverifiedState, '/events'),
          (_unverifiedState, '/verify-email'),
          (const AuthState.error(message: 'e'), '/events'),
        ];

        for (final (state, path) in cases) {
          if (sl.isRegistered<AuthCubit>()) sl.unregister<AuthCubit>();
          final c = _FixedStateAuthCubit(state);
          sl.registerSingleton<AuthCubit>(c);

          final result = _guard(path);

          expect(
            validTargets.contains(result),
            isTrue,
            reason:
                'Unexpected redirect "$result" for state $state on path "$path"',
          );

          c.close();
          sl.unregister<AuthCubit>();
        }

        // Re-register a dummy for tearDown to close/unregister cleanly.
        cubit = _FixedStateAuthCubit(const AuthState.unauthenticated());
        sl.registerSingleton<AuthCubit>(cubit);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('RouterGuard — property tests', () {
    group(
      'Property 1 & 2: Router guard redirect correctness',
      _propertyRouterGuardCorrectness,
    );
  });
}
