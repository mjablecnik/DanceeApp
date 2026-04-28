import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 1: Combined AND filter correctness
//
// For any list of events and any FilterState, filterEvents(events, filters)
// must contain exactly those events where:
// - if searchQuery is non-empty: event.title contains query (case-insensitive)
// - if selectedDanceTypes is non-empty: event.dances has at least one selected
// - if selectedRegions is non-empty: event.venue.region is in selected set
// - if dateFrom is set: event.startTime is on or after dateFrom (start of day)
// - if dateTo is set: event.startTime is on or before dateTo (end of day)
//
// All criteria combine with AND logic. Empty/unset criteria impose no restriction.
//
// Validates: Requirements 1.2, 1.3, 3.3, 3.4, 4.3, 4.4, 5.2, 5.3, 5.4, 5.5,
//            6.1, 9.1, 9.2
// ---------------------------------------------------------------------------

// ============================================================================
// Helpers
// ============================================================================

const _kAddress = Address(
  street: 'Test St',
  city: 'City',
  postalCode: '100 00',
  country: 'CZ',
);

Venue _venue({String region = ''}) => Venue(
      name: 'Venue',
      address: _kAddress,
      description: '',
      latitude: 0,
      longitude: 0,
      region: region,
    );

Event _event({
  required String id,
  String title = 'Event',
  List<String> dances = const [],
  String region = '',
  required DateTime startTime,
}) {
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: _venue(region: region),
    startTime: startTime,
    dances: dances,
  );
}

/// Reference implementation of the filter predicate — mirrors filterEvents
/// but computed per-event so tests can independently verify each event.
bool _passesFilter(Event event, FilterState filters) {
  if (filters.searchQuery.isNotEmpty) {
    if (!event.title.toLowerCase().contains(filters.searchQuery.toLowerCase())) {
      return false;
    }
  }
  if (filters.selectedDanceTypes.isNotEmpty) {
    if (!event.dances.any((d) => filters.selectedDanceTypes.contains(d))) {
      return false;
    }
  }
  if (filters.selectedRegions.isNotEmpty) {
    if (!filters.selectedRegions.contains(event.venue.region)) {
      return false;
    }
  }
  if (filters.dateFrom != null) {
    final fromStart = DateTime(
      filters.dateFrom!.year,
      filters.dateFrom!.month,
      filters.dateFrom!.day,
    );
    if (event.startTime.isBefore(fromStart)) return false;
  }
  if (filters.dateTo != null) {
    final toEnd = DateTime(
      filters.dateTo!.year,
      filters.dateTo!.month,
      filters.dateTo!.day,
      23,
      59,
      59,
    );
    if (event.startTime.isAfter(toEnd)) return false;
  }
  return true;
}

/// Asserts the property: filterEvents(events, filters) == {e | _passesFilter(e)}
void _assertCombinedFilterProperty(
  List<Event> events,
  FilterState filters, {
  String reason = '',
}) {
  final actual = filterEvents(events, filters);
  final expectedIds =
      events.where((e) => _passesFilter(e, filters)).map((e) => e.id).toSet();
  final actualIds = actual.map((e) => e.id).toSet();

  expect(actualIds, equals(expectedIds),
      reason: reason.isEmpty
          ? 'filterEvents must return exactly the events that satisfy all active criteria'
          : reason);
  // Also verify no duplicates
  expect(actual.length, equals(expectedIds.length),
      reason: 'filterEvents must not produce duplicate events');
}

// ============================================================================
// Fixed dates used across tests
// ============================================================================

final _d0 = DateTime(2025, 6, 1); // base date
final _d1 = DateTime(2025, 6, 2);
final _d2 = DateTime(2025, 6, 3);
final _d3 = DateTime(2025, 6, 10);
final _d4 = DateTime(2025, 6, 20);
final _d5 = DateTime(2025, 6, 30);

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 1: Combined AND filter correctness', () {
    // -------------------------------------------------------------------------
    // Sub-property: empty filters impose no restriction
    // -------------------------------------------------------------------------
    group('empty filters pass all events', () {
      test('empty filters on empty list returns empty', () {
        _assertCombinedFilterProperty([], const FilterState());
      });

      test('empty filters on single event returns that event', () {
        final events = [_event(id: '1', startTime: _d0)];
        _assertCombinedFilterProperty(events, const FilterState());
      });

      test('empty filters on multiple events returns all events', () {
        final events = [
          _event(id: '1', title: 'Salsa Night', dances: ['Salsa'], region: 'Praha', startTime: _d0),
          _event(id: '2', title: 'Tango Evening', dances: ['Tango'], region: 'Brno', startTime: _d1),
          _event(id: '3', title: 'Bachata Party', dances: ['Bachata'], startTime: _d2),
        ];
        _assertCombinedFilterProperty(events, const FilterState());
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: searchQuery filter
    // -------------------------------------------------------------------------
    group('searchQuery filter correctness', () {
      final events = [
        _event(id: '1', title: 'Salsa Night', startTime: _d0),
        _event(id: '2', title: 'Tango Evening', startTime: _d1),
        _event(id: '3', title: 'Bachata Party', startTime: _d2),
        _event(id: '4', title: 'SALSA FESTIVAL', startTime: _d3),
        _event(id: '5', title: 'salsa social', startTime: _d4),
      ];

      test('exact case match', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: 'Salsa'),
          reason: 'exact case match',
        );
      });

      test('case-insensitive match returns all matching events', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: 'salsa'),
          reason: 'lowercase query must match case-insensitively',
        );
      });

      test('uppercase query matches lowercase title', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: 'SALSA'),
          reason: 'uppercase query must match case-insensitively',
        );
      });

      test('partial word match', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: 'night'),
        );
      });

      test('no matching query returns empty', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: 'waltz'),
          reason: 'no event title contains "waltz"',
        );
      });

      test('query matching all events', () {
        final allTitleEvents = [
          _event(id: '1', title: 'Dance Night', startTime: _d0),
          _event(id: '2', title: 'Dance Festival', startTime: _d1),
          _event(id: '3', title: 'dance social', startTime: _d2),
        ];
        _assertCombinedFilterProperty(
          allTitleEvents,
          const FilterState(searchQuery: 'dance'),
        );
      });

      test('empty searchQuery imposes no restriction', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(searchQuery: ''),
        );
      });

      for (final cases in [
        ('Salsa', ['1', '4', '5']),
        ('Evening', ['2']),
        ('Party', ['3']),
        ('FESTIVAL', ['4']),
        ('Social', ['5']),
        ('night', ['1']),
      ]) {
        final query = cases.$1 as String;
        test('query "$query" matches expected ids', () {
          _assertCombinedFilterProperty(
            events,
            FilterState(searchQuery: query),
          );
        });
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: selectedDanceTypes filter
    // -------------------------------------------------------------------------
    group('selectedDanceTypes filter correctness', () {
      final events = [
        _event(id: '1', dances: ['Salsa'], startTime: _d0),
        _event(id: '2', dances: ['Tango'], startTime: _d1),
        _event(id: '3', dances: ['Salsa', 'Bachata'], startTime: _d2),
        _event(id: '4', dances: ['Bachata', 'Zouk'], startTime: _d3),
        _event(id: '5', dances: [], startTime: _d4),
      ];

      test('single dance type filter', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {'Salsa'}),
        );
      });

      test('event with multiple dances matches if any dance is selected', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {'Bachata'}),
          reason: 'event with dances=[Salsa, Bachata] must match when Bachata is selected',
        );
      });

      test('multiple selected dance types act as OR within set', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {'Salsa', 'Tango'}),
          reason: 'event matches if it has ANY of the selected dance types',
        );
      });

      test('dance type not in any event returns empty', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {'Waltz'}),
        );
      });

      test('event with no dances excluded when dance filter active', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {'Salsa'}),
          reason: 'event with empty dances list must be excluded',
        );
      });

      test('empty selectedDanceTypes imposes no restriction', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedDanceTypes: {}),
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: selectedRegions filter
    // -------------------------------------------------------------------------
    group('selectedRegions filter correctness', () {
      final events = [
        _event(id: '1', region: 'Praha', startTime: _d0),
        _event(id: '2', region: 'Brno', startTime: _d1),
        _event(id: '3', region: 'Praha', startTime: _d2),
        _event(id: '4', region: 'Ostrava', startTime: _d3),
        _event(id: '5', region: '', startTime: _d4),
      ];

      test('single region filter', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {'Praha'}),
        );
      });

      test('multiple regions act as OR within set', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {'Praha', 'Brno'}),
        );
      });

      test('region not in any event returns empty', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {'Plzeň'}),
        );
      });

      test('event with empty region excluded when region filter active', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {'Praha'}),
          reason: 'event with empty region must not match any region filter',
        );
      });

      test('empty selectedRegions imposes no restriction', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {}),
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: dateFrom filter
    // -------------------------------------------------------------------------
    group('dateFrom filter correctness', () {
      final events = [
        _event(id: '1', startTime: DateTime(2025, 6, 1)),
        _event(id: '2', startTime: DateTime(2025, 6, 5)),
        _event(id: '3', startTime: DateTime(2025, 6, 10)),
        _event(id: '4', startTime: DateTime(2025, 6, 10, 12, 0)),
        _event(id: '5', startTime: DateTime(2025, 6, 20)),
      ];

      test('dateFrom excludes earlier events', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(dateFrom: DateTime(2025, 6, 5)),
        );
      });

      test('event on exactly dateFrom date is included (start of day)', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(dateFrom: DateTime(2025, 6, 10)),
          reason: 'event at 2025-06-10 00:00 should be included when dateFrom is 2025-06-10',
        );
      });

      test('event at time portion on dateFrom date is included', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(dateFrom: DateTime(2025, 6, 10, 18, 0)),
          reason: 'dateFrom truncates to start of day — event at 12:00 on same day is included',
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: dateTo filter
    // -------------------------------------------------------------------------
    group('dateTo filter correctness', () {
      final events = [
        _event(id: '1', startTime: DateTime(2025, 6, 1)),
        _event(id: '2', startTime: DateTime(2025, 6, 5)),
        _event(id: '3', startTime: DateTime(2025, 6, 10)),
        _event(id: '4', startTime: DateTime(2025, 6, 10, 23, 59, 59)),
        _event(id: '5', startTime: DateTime(2025, 6, 20)),
      ];

      test('dateTo excludes later events', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(dateTo: DateTime(2025, 6, 10)),
        );
      });

      test('event on exactly dateTo date is included (end of day)', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(dateTo: DateTime(2025, 6, 10)),
          reason: 'event at 23:59:59 on dateTo day must be included',
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: combined dateFrom + dateTo range
    // -------------------------------------------------------------------------
    group('date range filter correctness', () {
      final events = [
        _event(id: '1', startTime: DateTime(2025, 6, 1)),
        _event(id: '2', startTime: DateTime(2025, 6, 5)),
        _event(id: '3', startTime: DateTime(2025, 6, 10)),
        _event(id: '4', startTime: DateTime(2025, 6, 15)),
        _event(id: '5', startTime: DateTime(2025, 6, 20)),
        _event(id: '6', startTime: DateTime(2025, 6, 30)),
      ];

      test('date range includes events within bounds', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            dateFrom: DateTime(2025, 6, 5),
            dateTo: DateTime(2025, 6, 15),
          ),
        );
      });

      test('date range from > to yields no results', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            dateFrom: DateTime(2025, 6, 20),
            dateTo: DateTime(2025, 6, 10),
          ),
          reason: 'impossible range must return zero events',
        );
      });

      test('single-day range includes only that day', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            dateFrom: DateTime(2025, 6, 10),
            dateTo: DateTime(2025, 6, 10),
          ),
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: AND logic across all filter types
    // -------------------------------------------------------------------------
    group('AND logic across multiple filter criteria', () {
      final events = [
        _event(id: '1', title: 'Salsa Night',  dances: ['Salsa'],          region: 'Praha',   startTime: DateTime(2025, 6, 5)),
        _event(id: '2', title: 'Tango Evening', dances: ['Tango'],          region: 'Praha',   startTime: DateTime(2025, 6, 5)),
        _event(id: '3', title: 'Salsa Party',   dances: ['Salsa', 'Kizomba'], region: 'Brno',   startTime: DateTime(2025, 6, 10)),
        _event(id: '4', title: 'Dance Social',  dances: ['Salsa'],          region: 'Praha',   startTime: DateTime(2025, 6, 20)),
        _event(id: '5', title: 'Salsa Festival', dances: ['Salsa'],         region: 'Ostrava', startTime: DateTime(2025, 6, 5)),
      ];

      test('search + dance type: AND narrows results', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: {'Salsa'},
          ),
        );
      });

      test('dance type + region: AND narrows results', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(
            selectedDanceTypes: {'Salsa'},
            selectedRegions: {'Praha'},
          ),
        );
      });

      test('dance type + region + date range: all three criteria combined', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            selectedDanceTypes: const {'Salsa'},
            selectedRegions: const {'Praha'},
            dateFrom: DateTime(2025, 6, 1),
            dateTo: DateTime(2025, 6, 10),
          ),
        );
      });

      test('all four criteria active: only events satisfying all are returned', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: const {'Salsa'},
            selectedRegions: const {'Praha'},
            dateFrom: DateTime(2025, 6, 1),
            dateTo: DateTime(2025, 6, 10),
          ),
        );
      });

      test('criteria that eliminates all events returns empty', () {
        _assertCombinedFilterProperty(
          events,
          FilterState(
            selectedDanceTypes: const {'Waltz'},
            selectedRegions: const {'Praha'},
          ),
          reason: 'no event in Praha dances Waltz',
        );
      });

      test('region filter alone filters correctly', () {
        _assertCombinedFilterProperty(
          events,
          const FilterState(selectedRegions: {'Brno'}),
        );
      });

      test('each event either satisfies all criteria or is excluded', () {
        // Build a variety of events and verify all pass/fail individually
        final mixedEvents = [
          _event(id: 'a', title: 'Alpha Dance', dances: ['Salsa'], region: 'Praha', startTime: DateTime(2025, 7, 1)),
          _event(id: 'b', title: 'Beta Fiesta',  dances: ['Tango'], region: 'Praha', startTime: DateTime(2025, 7, 5)),
          _event(id: 'c', title: 'Gamma Night',  dances: ['Salsa'], region: 'Brno',  startTime: DateTime(2025, 7, 1)),
          _event(id: 'd', title: 'Delta Alpha',  dances: ['Salsa'], region: 'Praha', startTime: DateTime(2025, 8, 1)),
        ];

        final filters = FilterState(
          searchQuery: 'alpha',
          selectedDanceTypes: const {'Salsa'},
          selectedRegions: const {'Praha'},
          dateFrom: DateTime(2025, 7, 1),
          dateTo: DateTime(2025, 7, 31),
        );

        _assertCombinedFilterProperty(mixedEvents, filters,
            reason: 'only event "a" satisfies all four criteria');
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: filter result is deterministic
    // -------------------------------------------------------------------------
    test('same inputs always produce same result (determinism)', () {
      final events = [
        _event(id: '1', title: 'Salsa Night', dances: ['Salsa'], region: 'Praha', startTime: _d0),
        _event(id: '2', title: 'Tango',       dances: ['Tango'], region: 'Brno',  startTime: _d1),
      ];
      final filters = FilterState(
        selectedDanceTypes: const {'Salsa'},
        dateFrom: DateTime(2025, 6, 1),
      );

      final result1 = filterEvents(events, filters).map((e) => e.id).toSet();
      final result2 = filterEvents(events, filters).map((e) => e.id).toSet();

      expect(result1, equals(result2), reason: 'filterEvents must be deterministic');
    });

    // -------------------------------------------------------------------------
    // Sub-property: filter does not mutate input list
    // -------------------------------------------------------------------------
    test('filterEvents does not mutate the original event list', () {
      final events = [
        _event(id: '1', dances: ['Salsa'], startTime: _d0),
        _event(id: '2', dances: ['Tango'], startTime: _d1),
      ];
      final originalIds = events.map((e) => e.id).toList();

      filterEvents(events, const FilterState(selectedDanceTypes: {'Salsa'}));

      expect(events.map((e) => e.id).toList(), equals(originalIds),
          reason: 'filterEvents must not mutate the input list');
    });
  });
}
