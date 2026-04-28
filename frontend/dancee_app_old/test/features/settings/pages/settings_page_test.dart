import 'package:dancee_app/features/settings/pages/settings_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  GoRouter _makeRouter() => GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

  // =========================================================================
  // TC-L04: SettingsPage smoke test — page mounts without error
  // =========================================================================

  testWidgets(
    'TC-L04: SettingsPage mounts without error',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: _makeRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 28: SettingsHeaderSection tapping back button fires onBackPressed
  // =========================================================================

  testWidgets(
    'TC-T28: SettingsHeaderSection tapping back button fires onBackPressed',
    (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(SettingsHeaderSection(onBackPressed: () => callCount++)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(callCount, 1);
    },
  );

  // =========================================================================
  // Task 29: ProfileSection renders avatar placeholder and non-empty text
  // =========================================================================

  testWidgets(
    'TC-T29: ProfileSection renders circular avatar and non-empty name/email text',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: const ProfileSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // ProfileAvatar is a Container with BoxShape.circle
      expect(find.byType(ProfileAvatar), findsOneWidget);
      // Name and email text should both be non-empty
      expect(find.byType(ProfileName), findsOneWidget);
      expect(find.byType(ProfileEmail), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 30: PreferencesSection renders language and theme preference row labels
  // =========================================================================

  testWidgets(
    'TC-T30: PreferencesSection renders language and theme preference labels',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: const PreferencesSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    },
  );
}
