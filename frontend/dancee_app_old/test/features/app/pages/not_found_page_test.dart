import 'package:dancee_app/features/app/pages/not_found_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // Minimal GoRouter: NotFoundPage at /404, stub /events destination.
  GoRouter _makeRouter() => GoRouter(
        initialLocation: '/404',
        routes: [
          GoRoute(
            path: '/404',
            builder: (context, state) => const NotFoundPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) =>
                const Scaffold(body: Text('Events Home')),
          ),
        ],
      );

  // =========================================================================
  // TC-156: NotFoundPage displays "not found" message
  // =========================================================================

  testWidgets('TC-156: NotFoundPage displays page-not-found message',
      (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(routerConfig: _makeRouter()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Page not found" text is present
    expect(find.text('Page not found'), findsOneWidget);
  });

  // =========================================================================
  // TC-157: NotFoundPage has a "Go Home" button that navigates away
  // =========================================================================

  testWidgets(
      'TC-157: NotFoundPage "Go Home" button navigates away from 404 page',
      (tester) async {
    final router = _makeRouter();

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Verify NotFoundPage is shown
    expect(find.byType(NotFoundPage), findsOneWidget);

    // Tap "Go to Home" button (translation for goHome in EN)
    expect(find.byType(ElevatedButton), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Should have navigated away from NotFoundPage
    expect(find.byType(NotFoundPage), findsNothing);
    expect(find.text('Events Home'), findsOneWidget);
  });
}
