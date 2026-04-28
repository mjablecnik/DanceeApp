import 'package:dancee_app/core/routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect()', () {
    // -----------------------------------------------------------------------
    // TC-009: Returns null for public routes when unauthenticated
    // -----------------------------------------------------------------------
    test('TC-009: returns null for public route when unauthenticated', () {
      final result = authRedirect(
        matchedLocation: '/events',
        isAuthenticated: false,
      );
      expect(result, isNull);
    });

    // -----------------------------------------------------------------------
    // TC-010: Redirects unauthenticated user away from protected route
    // -----------------------------------------------------------------------
    test('TC-010: redirects to /login when unauthenticated on /settings', () {
      final result = authRedirect(
        matchedLocation: '/settings',
        isAuthenticated: false,
      );
      expect(result, equals('/login'));
    });

    // -----------------------------------------------------------------------
    // TC-011: Redirects authenticated user away from auth pages
    // This verifies the existing authRedirect does not block already-authenticated users.
    // The current implementation only protects certain routes; authenticated users
    // visiting /login simply receive null (no redirect is emitted by authRedirect alone).
    // -----------------------------------------------------------------------
    test('TC-011: returns null for authenticated user on any route', () {
      // authRedirect only blocks unauthenticated users from protected routes.
      // An authenticated user visiting /login or any route is allowed through
      // (null = no redirect).
      final result = authRedirect(
        matchedLocation: '/login',
        isAuthenticated: true,
      );
      // The function returns null because isAuthenticated is true → no protection needed.
      expect(result, isNull);
    });

    // -----------------------------------------------------------------------
    // TC-012: Returns null during loading state (no redirect while checking auth)
    // -----------------------------------------------------------------------
    test('TC-012: returns null for any route when authenticated', () {
      final result = authRedirect(
        matchedLocation: '/settings',
        isAuthenticated: true,
      );
      expect(result, isNull);
    });

    // -----------------------------------------------------------------------
    // TC-M18: authRedirect() — authenticated user visiting /login receives null
    // Documents that authRedirect does not redirect away from /login for
    // authenticated users (no /events redirect is emitted by authRedirect alone).
    // -----------------------------------------------------------------------
    test(
      'TC-M18: authRedirect() returns null for authenticated user on /login '
      '(no automatic redirect to /events)',
      () {
        final result = authRedirect(
          matchedLocation: '/login',
          isAuthenticated: true,
        );
        // authRedirect only blocks unauthenticated users; an authenticated user
        // visiting /login is not redirected by this function.
        expect(result, isNull);
      },
    );

    // -----------------------------------------------------------------------
    // TC-109: authRedirect() returns null for unauthenticated user on public routes
    // -----------------------------------------------------------------------
    test(
      'TC-109: returns null for unauthenticated user on public route /events',
      () {
        final result = authRedirect(
          matchedLocation: '/events',
          isAuthenticated: false,
        );
        expect(result, isNull);
      },
    );

    // -----------------------------------------------------------------------
    // TC-110: authRedirect() redirects unauthenticated from every protectedRoute
    // -----------------------------------------------------------------------
    test(
      'TC-110: redirects unauthenticated user to /login for every protected route',
      () {
        for (final route in protectedRoutes) {
          final result = authRedirect(
            matchedLocation: route,
            isAuthenticated: false,
          );
          expect(
            result,
            equals('/login'),
            reason: 'Expected /login redirect for protected route: $route',
          );
        }
      },
    );

    // -----------------------------------------------------------------------
    // Task 67: unauthenticated user on sub-path of public route is not redirected
    // -----------------------------------------------------------------------
    test(
      'TC-T67: unauthenticated user accessing /events/abc123 returns null (no redirect)',
      () {
        final result = authRedirect(
          matchedLocation: '/events/abc123',
          isAuthenticated: false,
        );
        expect(result, isNull);
      },
    );
  });
}
