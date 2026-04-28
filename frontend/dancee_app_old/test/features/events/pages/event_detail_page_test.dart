import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/pages/event_detail/event_detail_page.dart';
import 'package:dancee_app/features/events/pages/event_detail/sections.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

/// Extends EventListCubit to suppress auto-loadEvents() in constructor.
class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  @override
  Future<void> loadEvents() async {}
}

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: child),
  );
}

Event _makeEvent({
  required String id,
  String title = 'Test Event',
  String organizer = 'Test Organizer',
  List<String> dances = const [],
}) {
  return Event(
    id: id,
    title: title,
    description: 'Test description',
    organizer: organizer,
    venue: const Venue(
      name: 'Test Venue',
      address: Address(
        street: 'Street 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    ),
    startTime: DateTime.now().add(const Duration(hours: 2)),
    dances: dances,
    isFavorite: false,
  );
}

void main() {
  late MockEventRepository mockRepo;
  late _SeedableEventListCubit listCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    listCubit = _SeedableEventListCubit(mockRepo);

    getIt.allowReassignment = true;
    getIt.registerFactoryParam<EventDetailCubit, String, void>(
      (eventId, _) => EventDetailCubit(
        eventListCubit: listCubit,
        eventId: eventId,
      ),
    );
  });

  tearDown(() async {
    await listCubit.close();
    if (getIt.isRegistered<EventDetailCubit>()) {
      getIt.unregister<EventDetailCubit>();
    }
  });

  // =========================================================================
  // TC-162: EventDetailPage renders event title when cubit emits a non-null Event
  // =========================================================================

  testWidgets(
    'TC-162: renders event title when cubit emits a non-null Event',
    (tester) async {
      const eventId = 'evt-1';
      final event = _makeEvent(id: eventId, title: 'Tango Night');

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      await tester.pumpWidget(_wrap(const EventDetailPage(eventId: eventId)));
      await tester.pump();

      expect(find.text('Tango Night'), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-163: EventDetailPage renders EventNotFoundSection when cubit emits null
  // =========================================================================

  testWidgets(
    'TC-163: renders EventNotFoundSection when cubit emits null (event not found)',
    (tester) async {
      // listCubit is in initial state — no events match → cubit emits null
      await tester.pumpWidget(
          _wrap(const EventDetailPage(eventId: 'nonexistent-id')));
      await tester.pump();

      expect(find.byType(EventNotFoundSection), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-191: EventDetailPage shows map icon when venue has non-null coordinates
  // =========================================================================

  testWidgets(
    'TC-191: renders map icon button when event venue has non-null coordinates',
    (tester) async {
      const eventId = 'evt-map';
      final event = _makeEvent(id: eventId, title: 'Map Test Event');
      // _makeEvent already sets latitude: 50.08 and longitude: 14.43

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      await tester.pumpWidget(_wrap(const EventDetailPage(eventId: eventId)));
      await tester.pump();

      expect(find.byIcon(Icons.map), findsAtLeastNWidgets(1),
          reason: 'Map icon should be visible when venue has coordinates');
    },
  );

  // =========================================================================
  // TC-M12: EventDetailPage — tapping the favorite button triggers toggleFavorite
  // =========================================================================

  testWidgets(
    'TC-M12: tapping the favorite button calls EventListCubit.toggleFavorite',
    (tester) async {
      const eventId = 'evt-fav';
      final event = _makeEvent(id: eventId, title: 'Fav Test Event');

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      when(() => mockRepo.toggleFavorite(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(const EventDetailPage(eventId: eventId)));
      await tester.pump();

      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);
      await tester.tap(favoriteButton);
      await tester.pump();

      verify(() => mockRepo.toggleFavorite(eventId, false)).called(1);
    },
  );

  // =========================================================================
  // TC-M13: EventDetailPage — renders dance-style chips for each dance
  // =========================================================================

  testWidgets(
    'TC-M13: renders dance-style chips for each dance in the event',
    (tester) async {
      const eventId = 'evt-dance';
      final event = _makeEvent(
        id: eventId,
        title: 'Dance Event',
        dances: ['Salsa', 'Bachata'],
      );

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      await tester.pumpWidget(_wrap(const EventDetailPage(eventId: eventId)));
      await tester.pump();

      expect(find.text('Salsa'), findsOneWidget);
      expect(find.text('Bachata'), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-L06: EventDetailPage — renders the organizer name from the event
  // =========================================================================

  testWidgets(
    'TC-L06: renders the organizer name from the event',
    (tester) async {
      const eventId = 'evt-org';
      final event = _makeEvent(
        id: eventId,
        title: 'Organizer Test',
        organizer: 'Dance Academy',
      );

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      await tester.pumpWidget(_wrap(const EventDetailPage(eventId: eventId)));
      await tester.pump();

      expect(find.text('Dance Academy'), findsOneWidget);
    },
  );
}
