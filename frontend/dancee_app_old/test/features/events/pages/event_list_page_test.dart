import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/design/widgets.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/data/filter_persistence_service.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/pages/event_list/components.dart';
import 'package:dancee_app/features/events/pages/event_list/event_list_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

/// A no-op [FilterPersistenceService] that always returns null on load.
class _NoOpFilterPersistenceService extends FilterPersistenceService {
  @override
  Future<FilterState?> loadFilters() async => null;

  @override
  Future<void> saveFilters(FilterState filters) async {}

  @override
  Future<void> clearFilters() async {}
}

/// Extends EventListCubit to expose emit() for seeding state in tests.
/// Overrides loadEvents() as a no-op so the constructor doesn't kick off
/// a real load (leaving the cubit in initial state so we can seed freely).
class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  @override
  Future<void> loadEvents() async {}
}

/// A cubit that supports seeding state and re-emits all stored events when
/// loadEvents() is called — used to test the "clear search → restore list"
/// flow where clearing the search field calls loadEvents().
class _RestoringEventListCubit extends EventListCubit {
  List<Event> _storedAllEvents = const [];

  _RestoringEventListCubit(super.repo);

  void seed(EventListState state) {
    if (state is EventListLoaded) {
      _storedAllEvents = state.allEvents;
    }
    emit(state);
  }

  @override
  Future<void> loadEvents() async {
    // Skip during construction (before seed() has been called).
    if (_storedAllEvents.isEmpty) return;
    // Re-emit stored events so that clearing the search restores the full list.
    emit(EventListState.loaded(
      allEvents: _storedAllEvents,
      todayEvents: const [],
      tomorrowEvents: const [],
      upcomingEvents: _storedAllEvents,
    ));
  }
}

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(
      home: child,
    ),
  );
}

Event _makeUpcomingEvent({
  required String id,
  required String title,
  String venueName = 'Club X',
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
    startTime: now.add(const Duration(days: 5, hours: 20)),
    endTime: now.add(const Duration(days: 5, hours: 24)),
    dances: const ['Salsa'],
    isFavorite: false,
  );
}

void main() {
  late MockEventRepository mockRepo;
  late _SeedableEventListCubit cubit;
  late EventFilterCubit filterCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    cubit = _SeedableEventListCubit(mockRepo);
    filterCubit = EventFilterCubit(cubit, _NoOpFilterPersistenceService());

    getIt.allowReassignment = true;
    getIt.registerSingleton<EventListCubit>(cubit);
    getIt.registerSingleton<EventFilterCubit>(filterCubit);
  });

  tearDown(() async {
    await filterCubit.close();
    await cubit.close();
    if (getIt.isRegistered<EventFilterCubit>()) {
      getIt.unregister<EventFilterCubit>();
    }
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  // =========================================================================
  // TC-075: Renders AppLoadingIndicator in loading state
  // =========================================================================

  testWidgets('TC-075: renders AppLoadingIndicator when cubit is loading',
      (tester) async {
    cubit.seed(const EventListState.loading());

    await tester.pumpWidget(_wrap(const EventListPage()));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  // =========================================================================
  // TC-076: Renders event cards in loaded state
  // =========================================================================

  testWidgets('TC-076: renders EventCard widgets when cubit is loaded',
      (tester) async {
    final event1 =
        _makeUpcomingEvent(id: '1', title: 'Salsa Night');
    final event2 =
        _makeUpcomingEvent(id: '2', title: 'Tango Evening');

    cubit.seed(EventListState.loaded(
      allEvents: [event1, event2],
      todayEvents: const [],
      tomorrowEvents: const [],
      upcomingEvents: [event1, event2],
    ));

    await tester.pumpWidget(_wrap(const EventListPage()));
    await tester.pump();

    expect(find.byType(EventCard), findsNWidgets(2));
  });

  // =========================================================================
  // TC-077: Renders AppErrorMessage in error state
  // =========================================================================

  testWidgets('TC-077: renders AppErrorMessage with message when cubit errors',
      (tester) async {
    cubit.seed(const EventListState.error('Oops'));

    await tester.pumpWidget(_wrap(const EventListPage()));
    await tester.pump();

    expect(find.byType(AppErrorMessage), findsOneWidget);
    expect(find.text('Oops'), findsOneWidget);
  });

  // =========================================================================
  // TC-153: EventListPage renders empty state when all event groups are empty
  // =========================================================================

  testWidgets(
    'TC-153: renders no EventCard widgets when all event groups are empty',
    (tester) async {
      cubit.seed(EventListState.loaded(
        allEvents: const [],
        todayEvents: const [],
        tomorrowEvents: const [],
        upcomingEvents: const [],
      ));

      await tester.pumpWidget(_wrap(const EventListPage()));
      await tester.pump();

      expect(find.byType(EventCard), findsNothing,
          reason: 'No event cards should be shown when all groups are empty');
    },
  );

  // =========================================================================
  // TC-090 (Integration): Typing in search bar filters displayed EventCards
  // =========================================================================

  testWidgets(
    'TC-090: typing in search bar filters displayed event cards',
    (tester) async {
      final salsaEvent =
          _makeUpcomingEvent(id: '1', title: 'Salsa Night');
      final tangoEvent =
          _makeUpcomingEvent(id: '2', title: 'Tango Evening');

      cubit.seed(EventListState.loaded(
        allEvents: [salsaEvent, tangoEvent],
        todayEvents: const [],
        tomorrowEvents: const [],
        upcomingEvents: [salsaEvent, tangoEvent],
      ));

      await tester.pumpWidget(_wrap(const EventListPage()));
      await tester.pump();

      // Both cards are visible before search
      expect(find.byType(EventCard), findsNWidgets(2));

      // Type "Salsa" into the search bar
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Salsa');
      // Advance past the 300ms debounce in EventFilterCubit.updateSearchQuery
      await tester.pump(const Duration(milliseconds: 350));

      // Only the Salsa event card should be visible
      expect(find.byType(EventCard), findsOneWidget);
      expect(find.text('Salsa Night'), findsOneWidget);
      expect(find.text('Tango Evening'), findsNothing);
    },
  );

  // =========================================================================
  // TC-M17: Clearing the search field restores the full event list
  // =========================================================================

  testWidgets(
    'TC-M17: clearing the search field after filtering restores all event cards',
    (tester) async {
      final event1 = _makeUpcomingEvent(id: '1', title: 'Salsa Night');
      final event2 = _makeUpcomingEvent(id: '2', title: 'Tango Evening');
      final event3 = _makeUpcomingEvent(id: '3', title: 'Bachata Fest');

      // Seed events via EventListCubit — EventFilterCubit will react via its
      // stream subscription and make all 3 events available for display.
      cubit.seed(EventListState.loaded(
        allEvents: [event1, event2, event3],
        todayEvents: const [],
        tomorrowEvents: const [],
        upcomingEvents: [event1, event2, event3],
      ));

      await tester.pumpWidget(_wrap(const EventListPage()));
      await tester.pump();

      // All 3 events visible initially
      expect(find.byType(EventCard), findsNWidgets(3));

      // Type "Salsa" to filter — advance past 300ms debounce
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Salsa');
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(EventCard), findsOneWidget);

      // Clear the search field — EventFilterCubit removes the query filter
      await tester.enterText(searchField, '');
      await tester.pump(const Duration(milliseconds: 350));

      // All 3 event cards should be visible again
      expect(find.byType(EventCard), findsNWidgets(3));
    },
  );
}
