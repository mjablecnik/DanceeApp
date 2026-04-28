// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $loginRoute,
      $registerRoute,
      $forgotPasswordRoute,
      $onboardingRoute,
      $verifyEmailRoute,
      $mainShellRouteData,
      $eventDetailRoute,
      $filterDanceRoute,
      $filterLocationRoute,
      $courseDetailRoute,
      $profileEditRoute,
      $changePasswordRoute,
      $premiumRoute,
      $authorContactRoute,
    ];

RouteBase get $loginRoute => GoRouteData.$route(
      path: '/login',
      factory: $LoginRouteExtension._fromState,
    );

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location(
        '/login',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $registerRoute => GoRouteData.$route(
      path: '/register',
      factory: $RegisterRouteExtension._fromState,
    );

extension $RegisterRouteExtension on RegisterRoute {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  String get location => GoRouteData.$location(
        '/register',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $forgotPasswordRoute => GoRouteData.$route(
      path: '/forgot-password',
      factory: $ForgotPasswordRouteExtension._fromState,
    );

extension $ForgotPasswordRouteExtension on ForgotPasswordRoute {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  String get location => GoRouteData.$location(
        '/forgot-password',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      factory: $OnboardingRouteExtension._fromState,
    );

extension $OnboardingRouteExtension on OnboardingRoute {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  String get location => GoRouteData.$location(
        '/onboarding',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyEmailRoute => GoRouteData.$route(
      path: '/verify-email',
      factory: $VerifyEmailRouteExtension._fromState,
    );

extension $VerifyEmailRouteExtension on VerifyEmailRoute {
  static VerifyEmailRoute _fromState(GoRouterState state) =>
      const VerifyEmailRoute();

  String get location => GoRouteData.$location(
        '/verify-email',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mainShellRouteData => ShellRouteData.$route(
      factory: $MainShellRouteDataExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/events',
          factory: $EventsRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/courses',
          factory: $CoursesRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/profile',
          factory: $ProfileRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/saved',
          factory: $SavedRouteExtension._fromState,
        ),
      ],
    );

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

extension $EventsRouteExtension on EventsRoute {
  static EventsRoute _fromState(GoRouterState state) => const EventsRoute();

  String get location => GoRouteData.$location(
        '/events',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CoursesRouteExtension on CoursesRoute {
  static CoursesRoute _fromState(GoRouterState state) => const CoursesRoute();

  String get location => GoRouteData.$location(
        '/courses',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ProfileRouteExtension on ProfileRoute {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  String get location => GoRouteData.$location(
        '/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SavedRouteExtension on SavedRoute {
  static SavedRoute _fromState(GoRouterState state) => const SavedRoute();

  String get location => GoRouteData.$location(
        '/saved',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $eventDetailRoute => GoRouteData.$route(
      path: '/events/detail',
      factory: $EventDetailRouteExtension._fromState,
    );

extension $EventDetailRouteExtension on EventDetailRoute {
  static EventDetailRoute _fromState(GoRouterState state) => EventDetailRoute(
        id: int.parse(state.uri.queryParameters['id']!)!,
      );

  String get location => GoRouteData.$location(
        '/events/detail',
        queryParams: {
          'id': id.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $filterDanceRoute => GoRouteData.$route(
      path: '/events/filter-dance',
      factory: $FilterDanceRouteExtension._fromState,
    );

extension $FilterDanceRouteExtension on FilterDanceRoute {
  static FilterDanceRoute _fromState(GoRouterState state) => FilterDanceRoute(
        source: state.uri.queryParameters['source'] ?? 'events',
      );

  String get location => GoRouteData.$location(
        '/events/filter-dance',
        queryParams: {
          if (source != 'events') 'source': source,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $filterLocationRoute => GoRouteData.$route(
      path: '/events/filter-location',
      factory: $FilterLocationRouteExtension._fromState,
    );

extension $FilterLocationRouteExtension on FilterLocationRoute {
  static FilterLocationRoute _fromState(GoRouterState state) =>
      FilterLocationRoute(
        source: state.uri.queryParameters['source'] ?? 'events',
      );

  String get location => GoRouteData.$location(
        '/events/filter-location',
        queryParams: {
          if (source != 'events') 'source': source,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $courseDetailRoute => GoRouteData.$route(
      path: '/courses/detail',
      factory: $CourseDetailRouteExtension._fromState,
    );

extension $CourseDetailRouteExtension on CourseDetailRoute {
  static CourseDetailRoute _fromState(GoRouterState state) => CourseDetailRoute(
        id: int.parse(state.uri.queryParameters['id']!)!,
      );

  String get location => GoRouteData.$location(
        '/courses/detail',
        queryParams: {
          'id': id.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileEditRoute => GoRouteData.$route(
      path: '/profile/edit',
      factory: $ProfileEditRouteExtension._fromState,
    );

extension $ProfileEditRouteExtension on ProfileEditRoute {
  static ProfileEditRoute _fromState(GoRouterState state) =>
      const ProfileEditRoute();

  String get location => GoRouteData.$location(
        '/profile/edit',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $changePasswordRoute => GoRouteData.$route(
      path: '/profile/change-password',
      factory: $ChangePasswordRouteExtension._fromState,
    );

extension $ChangePasswordRouteExtension on ChangePasswordRoute {
  static ChangePasswordRoute _fromState(GoRouterState state) =>
      const ChangePasswordRoute();

  String get location => GoRouteData.$location(
        '/profile/change-password',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $premiumRoute => GoRouteData.$route(
      path: '/profile/premium',
      factory: $PremiumRouteExtension._fromState,
    );

extension $PremiumRouteExtension on PremiumRoute {
  static PremiumRoute _fromState(GoRouterState state) => const PremiumRoute();

  String get location => GoRouteData.$location(
        '/profile/premium',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authorContactRoute => GoRouteData.$route(
      path: '/profile/author-contact',
      factory: $AuthorContactRouteExtension._fromState,
    );

extension $AuthorContactRouteExtension on AuthorContactRoute {
  static AuthorContactRoute _fromState(GoRouterState state) =>
      const AuthorContactRoute();

  String get location => GoRouteData.$location(
        '/profile/author-contact',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
