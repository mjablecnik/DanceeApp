import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/pages/event_list/components.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal test wrapper: provides MaterialApp + i18n scope.
Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

Event _makeEvent({
  String id = '1',
  String title = 'Salsa Fiesta',
  String venueName = 'Club X',
  bool isFavorite = false,
  bool isPast = false,
  String? badge,
  List<String> dances = const ['Salsa', 'Bachata'],
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: Venue(
      name: venueName,
      address: const Address(
        street: 'Main St 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    ),
    startTime: isPast
        ? now.subtract(const Duration(days: 2))
        : now.add(const Duration(hours: 2)),
    endTime: isPast
        ? now.subtract(const Duration(days: 1))
        : now.add(const Duration(hours: 4)),
    dances: dances,
    isFavorite: isFavorite,
    isPast: isPast,
    badge: badge,
  );
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  // =========================================================================
  // TC-070: EventCard renders event title and venue name
  // =========================================================================

  testWidgets('TC-070: EventCard renders event title and venue name',
      (tester) async {
    final event = _makeEvent(title: 'Salsa Fiesta', venueName: 'Club X');

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () {},
      ),
    ));

    expect(find.text('Salsa Fiesta'), findsOneWidget);
    expect(find.text('Club X'), findsOneWidget);
  });

  // =========================================================================
  // TC-071: Tapping favorite icon fires onFavoriteToggle callback
  // =========================================================================

  testWidgets('TC-071: tapping favorite icon fires onFavoriteToggle callback',
      (tester) async {
    int callCount = 0;
    final event = _makeEvent(isFavorite: false);

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () => callCount++,
      ),
    ));

    // The favorite icon is inside an InkWell. Find it by the icon itself.
    final favoriteIcon = find.byIcon(Icons.favorite_border);
    expect(favoriteIcon, findsOneWidget);
    await tester.tap(favoriteIcon);
    await tester.pump();

    expect(callCount, equals(1));
  });

  // =========================================================================
  // TC-072: EventCard displays badge text when event has a badge
  // =========================================================================

  testWidgets('TC-072: EventCard displays badge text when event has badge',
      (tester) async {
    final event = _makeEvent(badge: 'TODAY');

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () {},
      ),
    ));

    expect(find.text('TODAY'), findsOneWidget);
  });

  // =========================================================================
  // TC-147: EventCard swipe-to-dismiss triggers onDismissed for past events
  // =========================================================================

  testWidgets(
    'TC-147: swiping a past EventCard with enableDismiss invokes onDismissed callback',
    (tester) async {
      int dismissedCount = 0;
      final pastEvent = _makeEvent(isPast: true);

      await tester.pumpWidget(_wrap(
        EventCard(
          event: pastEvent,
          onTap: () {},
          onFavoriteToggle: () {},
          enableDismiss: true,
          onDismissed: () => dismissedCount++,
        ),
      ));

      expect(find.byType(Dismissible), findsOneWidget);

      // Swipe the card from right to left (endToStart direction)
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(dismissedCount, equals(1));
    },
  );

  // =========================================================================
  // TC-074: EventCard dance style chips are rendered for each dance
  // =========================================================================

  testWidgets('TC-074: EventCard renders dance style chips', (tester) async {
    final event = _makeEvent(dances: ['Salsa', 'Bachata']);

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () {},
      ),
    ));

    expect(find.text('Salsa'), findsOneWidget);
    expect(find.text('Bachata'), findsOneWidget);
  });

  // =========================================================================
  // TC-L03b: EventCard with empty dances list renders no dance chips
  // =========================================================================

  testWidgets('TC-L03b: EventCard with empty dances list renders no dance chips',
      (tester) async {
    final event = _makeEvent(dances: []);

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () {},
      ),
    ));

    expect(find.text('Salsa'), findsNothing);
    expect(find.text('Bachata'), findsNothing);
  });

  // =========================================================================
  // TC-L04: EventCard with enableDismiss=false does not wrap card in Dismissible
  // =========================================================================

  testWidgets(
      'TC-L04: EventCard with enableDismiss=false does not wrap card in Dismissible',
      (tester) async {
    final event = _makeEvent();

    await tester.pumpWidget(_wrap(
      EventCard(
        event: event,
        onTap: () {},
        onFavoriteToggle: () {},
        // enableDismiss defaults to false
      ),
    ));

    expect(find.byType(Dismissible), findsNothing);
  });

  // =========================================================================
  // Task 27: EventCard tapping card body fires onTap (which navigates in router)
  // =========================================================================

  testWidgets(
    'TC-T27: tapping EventCard body fires onTap callback',
    (tester) async {
      var callCount = 0;
      final event = _makeEvent(id: 'abc123');

      await tester.pumpWidget(_wrap(
        EventCard(
          event: event,
          onTap: () => callCount++,
          onFavoriteToggle: () {},
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(callCount, 1);
    },
  );
}
