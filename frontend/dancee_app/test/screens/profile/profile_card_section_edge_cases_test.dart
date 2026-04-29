// Optional unit tests for ProfileCardSection edge cases
// From profile-page-completion design spec (Testing Strategy → Unit Tests):
//   - Test edge case: UserRepository returns user with empty danceTags list
//   - Test edge case: UserRepository returns user with null avatarUrl
//     (avatarUrl is non-nullable in ProfileCardSection; the ProfileScreen passes
//      `_userData!.avatarUrl ?? ''` so the empty-string case is the relevant edge)
//
// These tests exercise the ProfileCardSection widget in isolation, without a
// full ProfileScreen, to verify it renders without error for boundary inputs.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/screens/profile/profile/sections/profile_card_section.dart';
import 'package:dancee_app/screens/profile/profile/components/dance_tag.dart';
import 'package:dancee_app/core/colors.dart';

void main() {
  group('ProfileCardSection — edge cases (optional unit tests)', () {
    // ── Helper ──────────────────────────────────────────────────────────────

    /// Pumps [ProfileCardSection] inside a minimal [MaterialApp] so widget
    /// rendering infrastructure is available without needing BLoC providers.
    Future<void> pumpCard(
      WidgetTester tester, {
      required String name,
      required String email,
      required String avatarUrl,
      required List<({String label, Color color})> danceTags,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileCardSection(
              name: name,
              email: email,
              avatarUrl: avatarUrl,
              danceTags: danceTags,
            ),
          ),
        ),
      );
      // Allow any post-frame callbacks and async microtasks to drain.
      await tester.pumpAndSettle();
    }

    // ── Edge case 1: empty danceTags list ────────────────────────────────────

    testWidgets(
      'renders without error when danceTags list is empty',
      (tester) async {
        await pumpCard(
          tester,
          name: 'Test User',
          email: 'test@example.com',
          avatarUrl: '',
          danceTags: const [],
        );

        // The card must render the name and email labels.
        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);

        // With an empty list, no DanceTag chip should appear.
        expect(
          find.byType(DanceTag),
          findsNothing,
          reason: 'Empty danceTags should render no DanceTag chips',
        );
      },
    );

    // ── Edge case 2: empty avatarUrl (null-fallback value from ProfileScreen) ──

    testWidgets(
      'renders without error when avatarUrl is empty string',
      (tester) async {
        await pumpCard(
          tester,
          name: 'No Avatar User',
          email: 'noavatar@example.com',
          avatarUrl: '',
          danceTags: const [
            (label: 'Salsa', color: appPrimary),
          ],
        );

        // The card must render the name and email labels.
        expect(find.text('No Avatar User'), findsOneWidget);
        expect(find.text('noavatar@example.com'), findsOneWidget);

        // The dance tag should still appear.
        expect(find.byType(DanceTag), findsOneWidget);

        // AppCachedImage handles empty URL by showing a fallback icon instead
        // of a network image — verify the image_not_supported icon is present.
        expect(
          find.byIcon(Icons.image_not_supported),
          findsOneWidget,
          reason:
              'Empty avatarUrl should render the image_not_supported placeholder '
              'icon from AppCachedImage',
        );
      },
    );

    // ── Edge case 3: both empty (combined boundary) ─────────────────────────

    testWidgets(
      'renders without error when both avatarUrl is empty and danceTags is empty',
      (tester) async {
        await pumpCard(
          tester,
          name: 'Minimal User',
          email: 'minimal@example.com',
          avatarUrl: '',
          danceTags: const [],
        );

        expect(find.text('Minimal User'), findsOneWidget);
        expect(find.text('minimal@example.com'), findsOneWidget);
        expect(find.byType(DanceTag), findsNothing);
        expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      },
    );
  });
}
