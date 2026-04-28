import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 4: Per-option cross-filter event count accuracy
//
// For any list of events, any FilterState, and any dance type or region option:
//
// countEventsForDanceType(events, danceType, filters) must equal
//   filterEvents(events, filters.copyWith(selectedDanceTypes: {danceType})).length
//
// countEventsForRegion(events, region, filters) must equal
//   filterEvents(events, filters.copyWith(selectedRegions: {region})).length
//
// In both cases the count ignores the current dance type / region selection
// and replaces it with only the given option, while all other active filter
// criteria (search query, date range, the opposing dimension) are preserved.
//
// Validates: Requirements 3.5, 4.5
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

/// Reference implementation: count for a given dance type using filterEvents directly.
int _referenceCountForDanceType(
  List<Event> events,
  String danceType,
  FilterState filters,
) {
  return filterEvents(
    events,
    filters.copyWith(selectedDanceTypes: {danceType}),
  ).length;
}

/// Reference implementation: count for a given region using filterEvents directly.
int _referenceCountForRegion(
  List<Event> events,
  String region,
  FilterState filters,
) {
  return filterEvents(
    events,
    filters.copyWith(selectedRegions: {region}),
  ).length;
}

void _assertDanceTypeCountProperty(
  List<Event> events,
  String danceType,
  FilterState filters, {
  String reason = '',
}) {
  final actual = countEventsForDanceType(events, danceType, filters);
  final expected = _referenceCountForDanceType(events, danceType, filters);
  expect(
    actual,
    equals(expected),
    reason: reason.isEmpty
        ? 'countEventsForDanceType("$danceType") must equal filterEvents with that dance type'
        : reason,
  );
}

void _assertRegionCountProperty(
  List<Event> events,
  String region,
  FilterState filters, {
  String reason = '',
}) {
  final actual = countEventsForRegion(events, region, filters);
  final expected = _referenceCountForRegion(events, region, filters);
  expect(
    actual,
    equals(expected),
    reason: reason.isEmpty
        ? 'countEventsForRegion("$region") must equal filterEvents with that region'
        : reason,
  );
}

// ============================================================================
// Fixed dates
// ============================================================================

final _d0 = DateTime(2025, 6, 1);
final _d1 = DateTime(2025, 6, 5);
final _d2 = DateTime(2025, 6, 10);
final _d3 = DateTime(2025, 6, 15);
final _d4 = DateTime(2025, 6, 20);

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 4: Per-option cross-filter event count accuracy', () {
    // -------------------------------------------------------------------------
    // Sub-property: countEventsForDanceType
    // -------------------------------------------------------------------------
    group('countEventsForDanceType correctness', () {
      final events = [
        _event(id: '1', dances: ['Salsa'],          region: 'Praha',   startTime: _d0),
        _event(id: '2', dances: ['Tango'],          region: 'Praha',   startTime: _d1),
        _event(id: '3', dances: ['Salsa', 'Bachata'], region: 'Brno',  startTime: _d2),
        _event(id: '4', dances: ['Bachata'],        region: 'Ostrava', startTime: _d3),
        _event(id: '5', dances: [],                 region: 'Praha',   startTime: _d4),
      ];

      test('empty filters: count equals number of events with that dance type', () {
        _assertDanceTypeCountProperty(events, 'Salsa', const FilterState());
        _assertDanceTypeCountProperty(events, 'Tango', const FilterState());
        _assertDanceTypeCountProperty(events, 'Bachata', const FilterState());
      });

      test('dance type not present in any event returns 0', () {
        _assertDanceTypeCountProperty(
          events,
          'Waltz',
          const FilterState(),
          reason: 'no event has Waltz, count must be 0',
        );
        expect(countEventsForDanceType(events, 'Waltz', const FilterState()), equals(0));
      });

      test('count ignores currently selected dance types in filters', () {
        // Even though filters has Tango selected, the count for Salsa should
        // be the number of events matching all other criteria plus Salsa (not Tango)
        final filters = const FilterState(selectedDanceTypes: {'Tango'});
        _assertDanceTypeCountProperty(events, 'Salsa', filters,
            reason: 'count for Salsa must ignore the current selectedDanceTypes selection');
      });

      test('count respects active region filter', () {
        final filters = const FilterState(selectedRegions: {'Praha'});
        _assertDanceTypeCountProperty(events, 'Salsa', filters,
            reason: 'count for Salsa must only include Praha events');
        // Verify the actual expected value
        expect(
          countEventsForDanceType(events, 'Salsa', filters),
          equals(1), // only event 1 is Salsa in Praha
        );
      });

      test('count respects active search query', () {
        final eventsWithTitles = [
          _event(id: '1', title: 'Salsa Night', dances: ['Salsa'], startTime: _d0),
          _event(id: '2', title: 'Salsa Party', dances: ['Salsa'], startTime: _d1),
          _event(id: '3', title: 'Tango Night', dances: ['Tango'], startTime: _d2),
        ];
        final filters = const FilterState(searchQuery: 'night');
        _assertDanceTypeCountProperty(eventsWithTitles, 'Salsa', filters,
            reason: 'count for Salsa must respect search query "night"');
        expect(
          countEventsForDanceType(eventsWithTitles, 'Salsa', filters),
          equals(1), // only "Salsa Night" matches both
        );
      });

      test('count respects active date range filter', () {
        _assertDanceTypeCountProperty(
          events,
          'Salsa',
          FilterState(dateFrom: _d1, dateTo: _d3),
          reason: 'count for Salsa must respect date range',
        );
        expect(
          countEventsForDanceType(events, 'Salsa', FilterState(dateFrom: _d1, dateTo: _d3)),
          equals(1), // only event 3 (Salsa+Bachata, Brno, d2) falls in range
        );
      });

      test('count on empty event list is always 0', () {
        expect(countEventsForDanceType([], 'Salsa', const FilterState()), equals(0));
        expect(
          countEventsForDanceType([], 'Salsa', const FilterState(selectedRegions: {'Praha'})),
          equals(0),
        );
      });

      test('count is consistent with reference implementation for all dance types', () {
        for (final dt in extractDanceTypes(events)) {
          _assertDanceTypeCountProperty(events, dt, const FilterState(),
              reason: 'count for dance type "$dt" must match reference');
        }
      });

      test('count with all criteria active returns correct value', () {
        final filters = FilterState(
          searchQuery: 'event',
          selectedRegions: const {'Brno'},
          dateFrom: _d1,
          dateTo: _d3,
        );
        _assertDanceTypeCountProperty(events, 'Salsa', filters);
        _assertDanceTypeCountProperty(events, 'Bachata', filters);
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: countEventsForRegion
    // -------------------------------------------------------------------------
    group('countEventsForRegion correctness', () {
      final events = [
        _event(id: '1', dances: ['Salsa'],    region: 'Praha',   startTime: _d0),
        _event(id: '2', dances: ['Tango'],    region: 'Praha',   startTime: _d1),
        _event(id: '3', dances: ['Bachata'],  region: 'Brno',    startTime: _d2),
        _event(id: '4', dances: ['Salsa'],    region: 'Ostrava', startTime: _d3),
        _event(id: '5', dances: ['Kizomba'],  region: '',        startTime: _d4),
      ];

      test('empty filters: count equals number of events in that region', () {
        _assertRegionCountProperty(events, 'Praha', const FilterState());
        _assertRegionCountProperty(events, 'Brno', const FilterState());
        _assertRegionCountProperty(events, 'Ostrava', const FilterState());
        expect(countEventsForRegion(events, 'Praha', const FilterState()), equals(2));
        expect(countEventsForRegion(events, 'Brno', const FilterState()), equals(1));
      });

      test('region not present in any event returns 0', () {
        _assertRegionCountProperty(
          events,
          'Plzeň',
          const FilterState(),
          reason: 'no event is in Plzeň, count must be 0',
        );
        expect(countEventsForRegion(events, 'Plzeň', const FilterState()), equals(0));
      });

      test('count ignores currently selected regions in filters', () {
        // Even though filters has Brno selected, the count for Praha should
        // be the number of events matching all other criteria plus Praha (not Brno)
        final filters = const FilterState(selectedRegions: {'Brno'});
        _assertRegionCountProperty(events, 'Praha', filters,
            reason: 'count for Praha must ignore the current selectedRegions selection');
      });

      test('count respects active dance type filter', () {
        final filters = const FilterState(selectedDanceTypes: {'Salsa'});
        _assertRegionCountProperty(events, 'Praha', filters,
            reason: 'count for Praha must only include Salsa events');
        expect(
          countEventsForRegion(events, 'Praha', filters),
          equals(1), // only event 1 is Salsa in Praha
        );
      });

      test('count respects active search query', () {
        final eventsWithTitles = [
          _event(id: '1', title: 'Salsa Night', dances: ['Salsa'], region: 'Praha', startTime: _d0),
          _event(id: '2', title: 'Tango Night', dances: ['Tango'], region: 'Praha', startTime: _d1),
          _event(id: '3', title: 'Salsa Party', dances: ['Salsa'], region: 'Brno',  startTime: _d2),
        ];
        final filters = const FilterState(searchQuery: 'night');
        _assertRegionCountProperty(eventsWithTitles, 'Praha', filters,
            reason: 'count for Praha must respect search query "night"');
        expect(
          countEventsForRegion(eventsWithTitles, 'Praha', filters),
          equals(2), // both Praha events have "night" in title
        );
      });

      test('count respects active date range filter', () {
        _assertRegionCountProperty(
          events,
          'Praha',
          FilterState(dateFrom: _d1, dateTo: _d3),
          reason: 'count for Praha must respect date range',
        );
        expect(
          countEventsForRegion(events, 'Praha', FilterState(dateFrom: _d1, dateTo: _d3)),
          equals(1), // only event 2 (Tango, Praha, d1) falls in range
        );
      });

      test('count on empty event list is always 0', () {
        expect(countEventsForRegion([], 'Praha', const FilterState()), equals(0));
        expect(
          countEventsForRegion([], 'Praha', const FilterState(selectedDanceTypes: {'Salsa'})),
          equals(0),
        );
      });

      test('count is consistent with reference implementation for all regions', () {
        for (final region in extractRegions(events)) {
          _assertRegionCountProperty(events, region, const FilterState(),
              reason: 'count for region "$region" must match reference');
        }
      });

      test('event with empty region is not counted for any named region', () {
        // Event 5 has region='', it should not be counted for Praha, Brno, etc.
        expect(
          countEventsForRegion(events, 'Praha', const FilterState()),
          equals(2),
          reason: 'empty-region event must not be counted for Praha',
        );
      });

      test('count with all criteria active returns correct value', () {
        final filters = FilterState(
          searchQuery: 'event',
          selectedDanceTypes: const {'Salsa'},
          dateFrom: _d0,
          dateTo: _d3,
        );
        _assertRegionCountProperty(events, 'Praha', filters);
        _assertRegionCountProperty(events, 'Brno', filters);
        _assertRegionCountProperty(events, 'Ostrava', filters);
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: symmetry between the two count functions
    // -------------------------------------------------------------------------
    group('symmetry: counts sum to total filtered count', () {
      test('sum of per-dance-type counts (no other filters) covers all events with dances', () {
        final events = [
          _event(id: '1', dances: ['Salsa'],           region: 'Praha', startTime: _d0),
          _event(id: '2', dances: ['Tango'],           region: 'Brno',  startTime: _d1),
          _event(id: '3', dances: ['Salsa', 'Bachata'], region: 'Praha', startTime: _d2),
        ];
        final danceTypes = extractDanceTypes(events);
        final filters = const FilterState();

        for (final dt in danceTypes) {
          final count = countEventsForDanceType(events, dt, filters);
          final expected = _referenceCountForDanceType(events, dt, filters);
          expect(count, equals(expected),
              reason: 'count for "$dt" must match reference');
        }
      });

      test('sum of per-region counts (no other filters) covers all events with regions', () {
        final events = [
          _event(id: '1', dances: ['Salsa'], region: 'Praha',   startTime: _d0),
          _event(id: '2', dances: ['Tango'], region: 'Brno',    startTime: _d1),
          _event(id: '3', dances: ['Salsa'], region: 'Praha',   startTime: _d2),
          _event(id: '4', dances: ['Salsa'], region: 'Ostrava', startTime: _d3),
          _event(id: '5', dances: ['Salsa'], region: '',        startTime: _d4),
        ];
        final regions = extractRegions(events); // excludes empty region
        final filters = const FilterState();

        for (final region in regions) {
          final count = countEventsForRegion(events, region, filters);
          final expected = _referenceCountForRegion(events, region, filters);
          expect(count, equals(expected),
              reason: 'count for region "$region" must match reference');
        }

        // The sum of all per-region counts should equal events-with-region count
        final totalWithRegion = events.where((e) => e.venue.region.isNotEmpty).length;
        final sumOfCounts = regions.fold<int>(
          0,
          (sum, region) => sum + countEventsForRegion(events, region, filters),
        );
        expect(sumOfCounts, equals(totalWithRegion),
            reason: 'sum of per-region counts must equal total events with a region');
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: parameterized cases
    // -------------------------------------------------------------------------
    for (final testCase in [
      (
        'Salsa in Praha with no other filters',
        [
          _event(id: '1', dances: ['Salsa'], region: 'Praha', startTime: _d0),
          _event(id: '2', dances: ['Salsa'], region: 'Brno',  startTime: _d1),
          _event(id: '3', dances: ['Tango'], region: 'Praha', startTime: _d2),
        ],
        'Salsa',
        'Praha',
        const FilterState(),
        2, // events 1 and 2 have Salsa
        2, // events 1 and 3 are in Praha
      ),
      (
        'dance count with region filter active',
        [
          _event(id: '1', dances: ['Salsa'], region: 'Praha', startTime: _d0),
          _event(id: '2', dances: ['Salsa'], region: 'Brno',  startTime: _d1),
          _event(id: '3', dances: ['Tango'], region: 'Praha', startTime: _d2),
        ],
        'Salsa',
        'Praha',
        const FilterState(selectedRegions: {'Praha'}),
        1, // only event 1 is Salsa in Praha
        2, // Praha has events 1 and 3 (ignoring selectedRegions)
      ),
    ]) {
      final label = testCase.$1;
      final events = testCase.$2;
      final danceType = testCase.$3;
      final region = testCase.$4;
      final filters = testCase.$5;
      final expectedDanceCount = testCase.$6;
      final expectedRegionCount = testCase.$7;

      test('$label: dance count for "$danceType" = $expectedDanceCount', () {
        expect(
          countEventsForDanceType(events, danceType, filters),
          equals(expectedDanceCount),
        );
        _assertDanceTypeCountProperty(events, danceType, filters);
      });

      test('$label: region count for "$region" = $expectedRegionCount', () {
        expect(
          countEventsForRegion(events, region, filters),
          equals(expectedRegionCount),
        );
        _assertRegionCountProperty(events, region, filters);
      });
    }
  });
}
