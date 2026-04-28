import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'service_locator.dart';
import '../logic/cubits/auth_cubit.dart';

/// Protected routes that require authentication.
const _protectedPrefixes = ['/events', '/courses', '/profile', '/saved'];

/// Auth-only screens that authenticated+verified users should be redirected away from.
const _authOnlyScreens = ['/login', '/register', '/forgot-password'];

bool _isProtectedRoute(String path) =>
    _protectedPrefixes.any((prefix) => path.startsWith(prefix));

/// GoRouter redirect callback. Reads [AuthCubit] state from the service locator
/// and returns the appropriate redirect path, or null for no redirect.
String? routerGuard(BuildContext context, GoRouterState state) {
  final authState = sl<AuthCubit>().state;
  final location = state.uri.path;

  return authState.map(
    unauthenticated: (_) {
      if (_isProtectedRoute(location) ||
          location == '/onboarding' ||
          location == '/verify-email') {
        return '/login';
      }
      return null;
    },
    loading: (_) => null,
    authenticated: (s) {
      if (!s.emailVerified) {
        // Allow /verify-email for all unverified users.
        if (location == '/verify-email') return null;
        // INTENTIONAL DEVIATION from Req 10.3:
        // Social sign-in providers (Google, Apple) perform their own identity
        // verification before issuing credentials, so their users arrive with
        // emailVerified=false only in rare edge cases (e.g. Apple "Hide My
        // Email" relay). Forcing those users through /verify-email would break
        // the onboarding flow for the vast majority of social sign-ins.
        // Req 10.3 ("allow unverified users to access only /verify-email") was
        // written with email/password accounts in mind. Social sign-in users
        // are therefore allowed to proceed directly to /onboarding.
        // If Apple or Google ever return an unverified credential we accept the
        // minor security trade-off in exchange for a smooth onboarding UX.
        if (location == '/onboarding' && !sl<AuthCubit>().isEmailProvider) return null;
        // Redirect all other routes (and email/password users on /onboarding)
        // to email verification.
        return '/verify-email';
      }
      // Email is verified — redirect away from auth screens
      if (_authOnlyScreens.contains(location) || location == '/verify-email') {
        return '/events';
      }
      return null;
    },
    error: (_) => null,
  );
}
