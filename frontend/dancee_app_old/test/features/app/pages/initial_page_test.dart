import 'package:dancee_app/features/app/pages/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  // =========================================================================
  // TC-L05: InitialPage redirects to /events on the first frame
  // =========================================================================

  testWidgets(
    'TC-L05: InitialPage triggers navigation to /events on first frame',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const InitialPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // pumpAndSettle lets the post-frame callback execute and navigation complete
      await tester.pumpAndSettle();

      // InitialPage should have navigated away to /events
      expect(find.byType(InitialPage), findsNothing);
      expect(find.text('Events'), findsOneWidget);
    },
  );

  // =========================================================================
  // Task 65: InitialPage shows CircularProgressIndicator before redirect fires
  // =========================================================================

  testWidgets(
    'TC-T65: InitialPage shows CircularProgressIndicator before redirect fires',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const InitialPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Check synchronously before post-frame callbacks run
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
