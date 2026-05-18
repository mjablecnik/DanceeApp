import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'service_locator.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/profile_cubit.dart';

/// Auth-only screens that authenticated+verified users should be redirected away from.
const _authOnlyScreens = ['/login', '/register', '/forgot-password'];

/// Editor-only route paths.
const _editorOnlyPaths = ['/events/edit', '/courses/edit'];

/// Returns the detail redirect path for an editor-only path, falling back to
/// the collection if [id] is null.
String _editorRedirect(String path, String? id) {
  if (path == '/events/edit') {
    return id != null ? '/events/detail?id=$id' : '/events';
  }
  return id != null ? '/courses/detail?id=$id' : '/courses';
}

/// GoRouter redirect callback. Reads [AuthCubit] state from the service locator
/// and returns the appropriate redirect path, or null for no redirect.
String? routerGuard(BuildContext context, GoRouterState state) {
  final authState = sl<AuthCubit>().state;
  final location = state.uri.path;

  return authState.map(
    unauthenticated: (_) {
      // Anonymous users can access public routes and auth screens freely.
      // Protected routes are handled in-page (AuthGatePage renders inside shell).
      if (location == '/onboarding' || location == '/verify-email') {
        return '/events';
      }
      // Editor-only routes require authentication; redirect to detail page.
      if (_editorOnlyPaths.contains(location)) {
        return _editorRedirect(location, state.uri.queryParameters['id']);
      }
      return null;
    },
    loading: (_) => null,
    authenticated: (s) {
      if (!s.emailVerified) {
        // Allow /verify-email for all unverified users.
        if (location == '/verify-email') return null;
        // Allow /onboarding for all authenticated users regardless of email
        // verification status. Social sign-in users (Google, Apple) skip email
        // verification and go straight to onboarding, so the guard must let
        // them through. Email/password users who just registered also need to
        // reach the onboarding flow before being redirected to /verify-email.
        if (location == '/onboarding') return null;
        // Redirect all other unverified routes to email verification.
        return '/verify-email';
      }
      // Email is verified — redirect away from auth screens
      if (_authOnlyScreens.contains(location) || location == '/verify-email') {
        return '/events';
      }
      // Editor-only routes: redirect non-editors to the detail page.
      if (_editorOnlyPaths.contains(location)) {
        if (!sl<ProfileCubit>().isEditor) {
          return _editorRedirect(location, state.uri.queryParameters['id']);
        }
      }
      return null;
    },
    error: (_) => null,
  );
}
