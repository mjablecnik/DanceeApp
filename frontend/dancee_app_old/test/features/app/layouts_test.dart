import 'package:dancee_app/features/app/layouts.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a minimal GoRouter with /events and /favorites routes to satisfy
/// GoRouter context requirements (AppBottomNavItem taps navigate there).
GoRouter _makeRouter() {
  return GoRouter(
    initialLocation: '/events',
    routes: [
      GoRoute(
        path: '/events',
        builder: (context, state) => Scaffold(
          // Use distinct content so it doesn't conflict with nav bar labels.
          body: const Text('Event list page'),
          bottomNavigationBar:
              const AppBottomNavigationBar(currentPath: '/events'),
        ),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) =>
            const Scaffold(body: Text('Favorites page')),
      ),
    ],
  );
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // =========================================================================
  // TC-158: AppBottomNavigationBar renders two items with correct labels
  // =========================================================================

  testWidgets(
      'TC-158: AppBottomNavigationBar renders Events and Favorites nav items',
      (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(routerConfig: _makeRouter()),
      ),
    );
    await tester.pumpAndSettle();

    // Both labels should be visible
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Both icons should be present
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  // =========================================================================
  // TC-159: AppBottomNavItem fires onTap callback when tapped
  // =========================================================================

  testWidgets('TC-159: AppBottomNavItem fires onTap callback when tapped',
      (tester) async {
    var called = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppBottomNavItem(
            icon: Icons.favorite,
            label: 'Favorites',
            isActive: false,
            onTap: () => called = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    expect(called, isTrue);
  });

  // =========================================================================
  // TC-L05: AppBottomNavItem renders correctly for both active and inactive states
  // =========================================================================

  testWidgets(
    'TC-L05: active AppBottomNavItem renders icon and label; '
    'inactive AppBottomNavItem also renders icon and label',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  AppBottomNavItem(
                    icon: Icons.favorite,
                    label: 'Favorites',
                    isActive: true,
                    onTap: () {},
                  ),
                  AppBottomNavItem(
                    icon: Icons.calendar_today,
                    label: 'Events',
                    isActive: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Both items should render their icons and labels
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);

      // Two AppBottomNavItem widgets are present
      expect(find.byType(AppBottomNavItem), findsNWidgets(2));
    },
  );
}
