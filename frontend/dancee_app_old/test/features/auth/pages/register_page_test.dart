import 'package:dancee_app/features/auth/pages/register/register_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  GoRouter _makeRouter() => GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('Login')),
          ),
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

  // =========================================================================
  // TC-L03: RegisterPage smoke test — page mounts and renders form fields
  // =========================================================================

  testWidgets(
    'TC-L03: RegisterPage mounts without error and renders registration form',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);

      // RegisterFormSection has three TextFields: name, email, password
      expect(
        find.byType(TextField),
        findsNWidgets(3),
        reason: 'Name, email, and password TextFields should all be present',
      );
    },
  );

  // =========================================================================
  // TC-M10: RegisterPage login link navigates to /login
  // =========================================================================

  testWidgets(
    'TC-M10: Tapping the Sign In link navigates to /login',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and scroll to the "Sign In" text link before tapping
      final loginLink = find.text('Sign In');
      expect(loginLink, findsOneWidget);
      await tester.ensureVisible(loginLink);
      await tester.tap(loginLink);
      await tester.pumpAndSettle();

      // After navigation, the login destination is shown
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    },
  );
}
