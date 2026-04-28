import 'package:go_router/go_router.dart';

// Route definitions — importing these files gives access to the generated
// route variables ($initialRoute, $appLayoutRoute, etc.) from their .g.dart parts.
import '../features/app/layouts.dart';
import '../features/app/pages/initial_page.dart';
import '../features/app/pages/not_found_page.dart';
import '../features/events/pages/event_detail/event_detail_page.dart';
import '../features/events/pages/event_filters/event_filters_page.dart';

import '../features/auth/pages/login/login_page.dart';
import '../features/auth/pages/register/register_page.dart';
import '../features/settings/pages/settings_page.dart';

/// Central GoRouter configuration for the Dancee App.
///
/// Composes all generated route definitions into a single router with:
/// - Initial location at `/` (redirects to /events via InitialRoute)
/// - Authentication guards on protected routes
/// - NotFoundPage for undefined routes via [errorBuilder]
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    $initialRoute,
    $appLayoutRoute,
    $eventFiltersRoute,
    $eventDetailRoute,
    $loginRoute,
    $registerRoute,
    $settingsRoute,
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
  redirect: (context, state) {
    // Authentication guard logic
    final isAuthenticated = false; // TODO: Get from auth state
    return authRedirect(
      matchedLocation: state.matchedLocation,
      isAuthenticated: isAuthenticated,
    );
  },
);

/// Protected routes that require authentication.
const protectedRoutes = ['/settings'];

/// Pure redirect logic extracted for testability.
///
/// Returns `'/login'` when [matchedLocation] starts with any protected route
/// and [isAuthenticated] is `false`. Returns `null` otherwise (no redirect).
String? authRedirect({
  required String matchedLocation,
  required bool isAuthenticated,
}) {
  final isProtectedRoute = protectedRoutes.any(
        (route) => matchedLocation.startsWith(route),
  );

  if (!isAuthenticated && isProtectedRoute) {
    return '/login';
  }

  return null;
}
