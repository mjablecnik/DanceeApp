// Type-safe route definitions using go_router_builder.
// Run `dart run build_runner build` to regenerate app_routes.g.dart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/email_verification/email_verification_screen.dart';
import '../screens/auth/forgot_password/forgot_password_screen.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/auth/onboarding/onboarding_screen.dart';
import '../screens/auth/register/register_screen.dart';
import '../screens/courses/course_detail/course_detail_screen.dart';
import '../screens/courses/courses_list/courses_list_screen.dart';
import '../screens/events/event_detail/event_detail_screen.dart';
import '../screens/events/events_list/events_list_screen.dart';
import '../screens/events/filter_dance/filter_dance_screen.dart';
import '../screens/events/filter_location/filter_location_screen.dart';
import '../screens/profile/author_contact/author_contact_screen.dart';
import '../screens/profile/change_password/change_password_screen.dart';
import '../screens/profile/premium/premium_screen.dart';
import '../screens/profile/profile/profile_screen.dart';
import '../screens/profile/profile_edit/profile_edit_screen.dart';
import '../screens/saved/saved_events_screen.dart';
import '../shared/elements/navigation/app_bottom_nav_bar.dart';
import '../shared/elements/navigation/main_shell.dart';

part 'app_routes.g.dart';

// ---------------------------------------------------------------------------
// Auth routes
// ---------------------------------------------------------------------------

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: LoginScreen());
}

@TypedGoRoute<RegisterRoute>(path: '/register')
@immutable
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: RegisterScreen());
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
@immutable
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: ForgotPasswordScreen());
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
@immutable
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: OnboardingScreen());
}

@TypedGoRoute<VerifyEmailRoute>(path: '/verify-email')
@immutable
class VerifyEmailRoute extends GoRouteData {
  const VerifyEmailRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: EmailVerificationScreen());
}

// ---------------------------------------------------------------------------
// Main shell (bottom nav) with child routes
// ---------------------------------------------------------------------------

@TypedShellRoute<MainShellRouteData>(
  routes: [
    TypedGoRoute<EventsRoute>(path: '/events'),
    TypedGoRoute<CoursesRoute>(path: '/courses'),
    TypedGoRoute<ProfileRoute>(path: '/profile'),
    TypedGoRoute<SavedRoute>(path: '/saved'),
  ],
)
@immutable
class MainShellRouteData extends ShellRouteData {
  const MainShellRouteData();

  @override
  Page<void> pageBuilder(
      BuildContext context, GoRouterState state, Widget navigator) {
    final location = state.uri.path;
    final NavTab currentTab;
    if (location.startsWith('/courses')) {
      currentTab = NavTab.courses;
    } else if (location.startsWith('/profile')) {
      currentTab = NavTab.profile;
    } else if (location.startsWith('/saved')) {
      currentTab = NavTab.saved;
    } else {
      currentTab = NavTab.events;
    }
    return NoTransitionPage(
      child: MainShell(currentTab: currentTab, child: navigator),
    );
  }
}

@immutable
class EventsRoute extends GoRouteData {
  const EventsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: EventsListScreen());
}

@immutable
class CoursesRoute extends GoRouteData {
  const CoursesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: CoursesListScreen());
}

@immutable
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: ProfileScreen());
}

@immutable
class SavedRoute extends GoRouteData {
  const SavedRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: SavedEventsScreen());
}

// ---------------------------------------------------------------------------
// Sub-pages (no bottom nav)
// ---------------------------------------------------------------------------

@TypedGoRoute<EventDetailRoute>(path: '/events/detail')
@immutable
class EventDetailRoute extends GoRouteData {
  const EventDetailRoute({required this.id});

  final int id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(child: EventDetailScreen(eventId: id));
}

@TypedGoRoute<FilterDanceRoute>(path: '/events/filter-dance')
@immutable
class FilterDanceRoute extends GoRouteData {
  const FilterDanceRoute({this.source = 'events'});

  final String source;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(child: FilterDanceScreen(source: source));
}

@TypedGoRoute<FilterLocationRoute>(path: '/events/filter-location')
@immutable
class FilterLocationRoute extends GoRouteData {
  const FilterLocationRoute({this.source = 'events'});

  final String source;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(child: FilterLocationScreen(source: source));
}

@TypedGoRoute<CourseDetailRoute>(path: '/courses/detail')
@immutable
class CourseDetailRoute extends GoRouteData {
  const CourseDetailRoute({required this.id});

  final int id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(child: CourseDetailScreen(courseId: id));
}

@TypedGoRoute<ProfileEditRoute>(path: '/profile/edit')
@immutable
class ProfileEditRoute extends GoRouteData {
  const ProfileEditRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: ProfileEditScreen());
}

@TypedGoRoute<ChangePasswordRoute>(path: '/profile/change-password')
@immutable
class ChangePasswordRoute extends GoRouteData {
  const ChangePasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: ChangePasswordScreen());
}

@TypedGoRoute<PremiumRoute>(path: '/profile/premium')
@immutable
class PremiumRoute extends GoRouteData {
  const PremiumRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: PremiumScreen());
}

@TypedGoRoute<AuthorContactRoute>(path: '/profile/author-contact')
@immutable
class AuthorContactRoute extends GoRouteData {
  const AuthorContactRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: AuthorContactScreen());
}
