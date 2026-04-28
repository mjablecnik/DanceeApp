import 'dart:async';

import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/data/filter_persistence_service.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes / helpers
// ---------------------------------------------------------------------------

class MockEventRepository extends Mock
    implements
        // ignore: avoid_implementing_value_types
        EventRepository {}

/// EventListCubit that does NOT auto-load; allows manual seeding via [seed].
class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState s) => emit(s);

  @override
  Future<void> loadEvents() async {}
}

/// FilterPersistenceService that does nothing (returns null on load).
class _NoOpPersistenceService extends FilterPersistenceService {
  @override
  Future<FilterState?> loadFilters() async => null;

  @override
  Future<void> saveFilters(FilterState filters) async {}

  @override
  Future<void> clearFilters() async {}
}

// ---------------------------------------------------------------------------
// Fixture builders
// ---------------------------------------------------------------------------

const _kDefaultVenue = Venue(
  name: 'Venue',
  address: Address(
    street: 'Street 1',
    city: 'City',
    postalCode: '100 00',
    country: 'CZ',
  ),
  description: '',
  latitude: 0,
  longitude: 0,
);

Event _makeEvent({
  required String id,
  required DateTime startTime,
  DateTime? endTime,
  String title = 'Test Event',
  List<String> dances = const [],
  Venue venue = _kDefaultVenue,
  bool isPast = false,
}) {
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: venue,
    startTime: startTime,
    endTime: endTime,
    dances: dances,
    isPast: isPast,
  );
}

/// Returns a future date (far enough that `isPast` is always false).
DateTime _futureDate({int daysFromNow = 30}) =>
    DateTime.now().add(Duration(days: daysFromNow));

/// Creates a loaded EventListState with the given events.
EventListLoaded _loaded(List<Event> events) => EventListState.loaded(
      allEvents: events,
      todayEvents: const [],
      tomorrowEvents: const [],
      upcomingEvents: events,
    ) as EventListLoaded;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockEventRepository mockRepo;
  late Completer<List<Event>> autoLoadBlocker;

  setUp(() {
    mockRepo = MockEventRepository();
    autoLoadBlocker = Completer<List<Event>>();
    when(() => mockRepo.getAllEvents())
        .thenAnswer((_) => autoLoadBlocker.future);
  });

  tearDown(() {
    if (!autoLoadBlocker.isCompleted) autoLoadBlocker.complete([]);
  });

  // =========================================================================
  // Helper to build a cubit pair
  // =========================================================================

  (
    _SeedableEventListCubit listCubit,
    EventFilterCubit filterCubit,
  ) _buildPair() {
    final listCubit = _SeedableEventListCubit(mockRepo);
    final filterCubit =
        EventFilterCubit(listCubit, _NoOpPersistenceService());
    return (listCubit, filterCubit);
  }

  group('EventFilterCubit', () {
    // -----------------------------------------------------------------------
    // TC-EFC-01: Empty event list returns empty filtered results
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-01: empty event list produces empty filtered and grouped lists',
        () {
      final (listCubit, filterCubit) = _buildPair();

      listCubit.seed(_loaded([]));

      expect(filterCubit.state.filteredEvents, isEmpty);
      expect(filterCubit.state.todayEvents, isEmpty);
      expect(filterCubit.state.tomorrowEvents, isEmpty);
      expect(filterCubit.state.upcomingEvents, isEmpty);

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-02: Whitespace-only search query matches everything
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-02: whitespace-only search query does not filter out any events',
        () async {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(id: '1', startTime: _futureDate(), title: 'Alpha'),
        _makeEvent(id: '2', startTime: _futureDate(), title: 'Beta'),
      ];
      listCubit.seed(_loaded(events));

      filterCubit.applyFilters(
        const FilterState(searchQuery: '   '),
      );

      // filterEvents() trims the searchQuery before comparison: "   ".trim() → "".
      // An empty query imposes no restriction, so all events are returned.
      // Both applyFilters and updateSearchQuery now share the same behavior:
      // trimming happens only inside filterEvents(), not in updateSearchQuery.
      expect(filterCubit.state.filteredEvents, hasLength(2));

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-03: Dance type filter with no matching types returns empty list
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-03: filtering by a dance type absent from all events returns empty',
        () {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(
            id: '1',
            startTime: _futureDate(),
            dances: ['Salsa', 'Bachata']),
        _makeEvent(
            id: '2', startTime: _futureDate(), dances: ['Tango']),
      ];
      listCubit.seed(_loaded(events));

      filterCubit.applyFilters(
        const FilterState(selectedDanceTypes: {'Waltz'}),
      );

      expect(filterCubit.state.filteredEvents, isEmpty);

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-04: Date range from > to returns empty list
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-04: date range where dateFrom is after dateTo returns empty list',
        () {
      final (listCubit, filterCubit) = _buildPair();
      final eventDate = _futureDate(daysFromNow: 10);
      final events = [
        _makeEvent(id: '1', startTime: eventDate),
      ];
      listCubit.seed(_loaded(events));

      // dateFrom is one day AFTER dateTo — an impossible range
      filterCubit.applyFilters(
        FilterState(
          dateFrom: _futureDate(daysFromNow: 20),
          dateTo: _futureDate(daysFromNow: 15),
        ),
      );

      expect(filterCubit.state.filteredEvents, isEmpty);

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-05: Re-apply filters when EventListCubit emits new loaded state
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-05: filters are re-applied when EventListCubit emits new events',
        () {
      final (listCubit, filterCubit) = _buildPair();

      // Seed with one salsa event and apply salsa filter
      final salsaEvent = _makeEvent(
          id: '1', startTime: _futureDate(), dances: ['Salsa']);
      listCubit.seed(_loaded([salsaEvent]));
      filterCubit.applyFilters(
        const FilterState(selectedDanceTypes: {'Salsa'}),
      );
      expect(filterCubit.state.filteredEvents.length, equals(1));

      // Now EventListCubit emits a new list that also has a Tango event
      final tangoEvent = _makeEvent(
          id: '2', startTime: _futureDate(), dances: ['Tango']);
      listCubit.seed(_loaded([salsaEvent, tangoEvent]));

      // Tango event should NOT appear — salsa filter is still active
      expect(filterCubit.state.filteredEvents.length, equals(1));
      expect(
          filterCubit.state.filteredEvents.first.id, equals('1'));

      // Removing filter should now show both events
      filterCubit.applyFilters(const FilterState());
      expect(filterCubit.state.filteredEvents.length, equals(2));

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-06: thisWeekPreset on Sunday covers only today (Sunday)
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-06: thisWeekPreset on Sunday returns dateFrom = dateTo = that Sunday',
        () {
      // Find the next Sunday or use a fixed Sunday
      // weekday: Monday=1 … Sunday=7
      // We'll construct a Sunday manually: 2024-01-07 was a Sunday
      final sunday = DateTime(2024, 1, 7); // Sunday
      expect(sunday.weekday, equals(7)); // sanity check

      final (start, end) = thisWeekPreset(sunday);

      // Start is sunday midnight
      expect(start, equals(DateTime(2024, 1, 7)));
      // End is sunday 23:59:59
      expect(end, equals(DateTime(2024, 1, 7, 23, 59, 59)));
    });

    // -----------------------------------------------------------------------
    // TC-EFC-07: weekendPreset on Saturday starts on that Saturday
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-07: weekendPreset on Saturday starts on the current Saturday',
        () {
      // 2024-01-06 is a Saturday
      final saturday = DateTime(2024, 1, 6);
      expect(saturday.weekday, equals(6)); // sanity check

      final (start, end) = weekendPreset(saturday);

      expect(start, equals(DateTime(2024, 1, 6)));
      expect(end, equals(DateTime(2024, 1, 7, 23, 59, 59)));
    });

    // -----------------------------------------------------------------------
    // TC-EFC-08: weekendPreset on Sunday returns current weekend (Sat–Sun)
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-08: weekendPreset on Sunday returns current weekend (Sat–Sun)',
        () {
      // 2024-01-07 is a Sunday
      final sunday = DateTime(2024, 1, 7);
      expect(sunday.weekday, equals(7)); // sanity check

      final (start, end) = weekendPreset(sunday);

      // Current weekend: Saturday 2024-01-06 through Sunday 2024-01-07
      expect(start, equals(DateTime(2024, 1, 6)));
      expect(end, equals(DateTime(2024, 1, 7, 23, 59, 59)));
    });

    // -----------------------------------------------------------------------
    // TC-EFC-09: resetFilters clears all filters
    // -----------------------------------------------------------------------
    test('TC-EFC-09: resetFilters clears active filters', () async {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(
            id: '1',
            startTime: _futureDate(),
            dances: ['Salsa']),
        _makeEvent(
            id: '2', startTime: _futureDate(), dances: ['Tango']),
      ];
      listCubit.seed(_loaded(events));
      filterCubit.applyFilters(
        const FilterState(selectedDanceTypes: {'Salsa'}),
      );
      expect(filterCubit.state.filteredEvents.length, equals(1));

      await filterCubit.resetFilters();

      expect(filterCubit.state.filters, equals(const FilterState()));
      expect(filterCubit.state.filteredEvents.length, equals(2));

      filterCubit.close();
      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-11: close() cancels the EventListCubit stream subscription
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-11: close() cancels EventListCubit subscription — no error after close',
        () async {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(id: '1', startTime: _futureDate(), title: 'Alpha'),
      ];
      listCubit.seed(_loaded(events));
      await Future<void>.delayed(Duration.zero);

      // Close the filter cubit
      await filterCubit.close();

      // Seeding the list cubit after the filter cubit is closed should not
      // cause an "emit after close" exception or any other error.
      expect(
        () {
          listCubit.seed(_loaded([
            ...events,
            _makeEvent(id: '2', startTime: _futureDate(), title: 'Beta'),
          ]));
        },
        returnsNormally,
        reason: 'No error should occur when listCubit emits after filterCubit is closed',
      );

      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-12: close() cancels the debounce timer — no emission after close
    // -----------------------------------------------------------------------
    test(
        'TC-EFC-12: close() cancels pending debounce timer — no state emitted after debounce period',
        () async {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(id: '1', startTime: _futureDate(), title: 'Salsa Night'),
        _makeEvent(id: '2', startTime: _futureDate(), title: 'Tango Evening'),
      ];
      listCubit.seed(_loaded(events));
      await Future<void>.delayed(Duration.zero);

      final emittedStates = <EventFilterState>[];
      final sub = filterCubit.stream.listen(emittedStates.add);

      // Start a debounced search that would filter to Salsa events only
      filterCubit.updateSearchQuery('Salsa');

      // Close immediately before the debounce (300 ms) fires
      await filterCubit.close();
      await sub.cancel();

      // Wait past the debounce period — timer must have been cancelled
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(
        emittedStates,
        isEmpty,
        reason: 'No state should be emitted after close() cancels the debounce timer',
      );

      listCubit.close();
    });

    // -----------------------------------------------------------------------
    // TC-EFC-10: updateSearchQuery debounces and updates state
    // -----------------------------------------------------------------------
    test('TC-EFC-10: updateSearchQuery applies filter after debounce',
        () async {
      final (listCubit, filterCubit) = _buildPair();
      final events = [
        _makeEvent(
            id: '1', startTime: _futureDate(), title: 'Salsa Night'),
        _makeEvent(
            id: '2', startTime: _futureDate(), title: 'Tango Evening'),
      ];
      listCubit.seed(_loaded(events));
      // Allow stream notification to propagate to EventFilterCubit
      await Future<void>.delayed(Duration.zero);

      // Verify initial state has all events before query
      final initialCount = filterCubit.state.filteredEvents.length;
      expect(initialCount, equals(2));

      filterCubit.updateSearchQuery('Salsa');
      // Before debounce fires, state should not yet be updated
      expect(filterCubit.state.filteredEvents.length, equals(2));

      // Wait for debounce (300ms)
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(filterCubit.state.filteredEvents.length, equals(1));
      expect(filterCubit.state.filteredEvents.first.title,
          equals('Salsa Night'));

      filterCubit.close();
      listCubit.close();
    });
  });
}
