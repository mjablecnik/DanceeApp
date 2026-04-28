import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 3: Region extraction returns all unique regions
//
// For any list of events, extractRegions(events) must return a set equal to
// the set of all unique non-empty event.venue.region values across every event
// in the list, with no duplicates and no missing entries.
//
// Validates: Requirements 4.1
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
  String region = '',
}) {
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    organizer: '',
    venue: _venue(region: region),
    startTime: DateTime(2025, 6, 1),
    dances: const [],
  );
}

/// Reference implementation — unique non-empty regions from all events.
Set<String> _expectedRegions(List<Event> events) {
  return events
      .map((e) => e.venue.region)
      .where((r) => r.isNotEmpty)
      .toSet();
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 3: Region extraction returns all unique regions', () {
    // -------------------------------------------------------------------------
    // Sub-property: empty input
    // -------------------------------------------------------------------------
    test('empty event list returns empty list', () {
      expect(extractRegions([]), isEmpty);
    });

    // -------------------------------------------------------------------------
    // Sub-property: single event
    // -------------------------------------------------------------------------
    test('single event with empty region returns empty list', () {
      final events = [_event(id: '1', region: '')];
      expect(extractRegions(events), isEmpty);
    });

    test('single event with one region returns that region', () {
      final events = [_event(id: '1', region: 'Praha')];
      final result = extractRegions(events);
      expect(result.toSet(), equals({'Praha'}));
    });

    // -------------------------------------------------------------------------
    // Sub-property: multiple events, union correctness
    // -------------------------------------------------------------------------
    test('multiple events: returns union of all non-empty regions', () {
      final events = [
        _event(id: '1', region: 'Praha'),
        _event(id: '2', region: 'Brno'),
        _event(id: '3', region: 'Ostrava'),
      ];
      final result = extractRegions(events);
      expect(result.toSet(), equals(_expectedRegions(events)));
    });

    test('overlapping regions across events: no duplicates', () {
      final events = [
        _event(id: '1', region: 'Praha'),
        _event(id: '2', region: 'Praha'),
        _event(id: '3', region: 'Brno'),
      ];
      final result = extractRegions(events);
      // Verify set equality (no duplicates, no missing)
      expect(result.toSet(), equals(_expectedRegions(events)));
      // Verify no duplicates in the list itself
      expect(result.length, equals(result.toSet().length),
          reason: 'extractRegions must not return duplicate entries');
    });

    test('all events have same region: returns exactly one entry', () {
      final events = [
        _event(id: '1', region: 'Praha'),
        _event(id: '2', region: 'Praha'),
        _event(id: '3', region: 'Praha'),
      ];
      final result = extractRegions(events);
      expect(result, equals(['Praha']),
          reason: 'identical region across all events must appear exactly once');
    });

    // -------------------------------------------------------------------------
    // Sub-property: empty regions are excluded
    // -------------------------------------------------------------------------
    test('events with empty region do not contribute to result', () {
      final events = [
        _event(id: '1', region: ''),
        _event(id: '2', region: ''),
        _event(id: '3', region: 'Praha'),
      ];
      final result = extractRegions(events);
      expect(result.toSet(), equals({'Praha'}));
    });

    test('all events with empty region returns empty list', () {
      final events = [
        _event(id: '1', region: ''),
        _event(id: '2', region: ''),
      ];
      expect(extractRegions(events), isEmpty);
    });

    // -------------------------------------------------------------------------
    // Sub-property: completeness — no missing entries
    // -------------------------------------------------------------------------
    test('no non-empty region from any event is missing from result', () {
      final events = [
        _event(id: '1', region: 'Praha'),
        _event(id: '2', region: 'Brno'),
        _event(id: '3', region: 'Ostrava'),
        _event(id: '4', region: ''),
      ];
      final result = extractRegions(events);
      final expected = _expectedRegions(events);
      for (final region in expected) {
        expect(result.contains(region), isTrue,
            reason: 'region "$region" from events must be present in result');
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: no extra entries — only regions from events
    // -------------------------------------------------------------------------
    test('result contains no regions not present in events', () {
      final events = [
        _event(id: '1', region: 'Praha'),
        _event(id: '2', region: 'Brno'),
      ];
      final result = extractRegions(events);
      final allEventRegions = _expectedRegions(events);
      for (final region in result) {
        expect(allEventRegions.contains(region), isTrue,
            reason: 'result must not contain "$region" which is not in any event');
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: result is sorted
    // -------------------------------------------------------------------------
    test('result is sorted alphabetically', () {
      final events = [
        _event(id: '1', region: 'Ostrava'),
        _event(id: '2', region: 'Praha'),
        _event(id: '3', region: 'Brno'),
      ];
      final result = extractRegions(events);
      final sorted = List<String>.from(result)..sort();
      expect(result, equals(sorted),
          reason: 'extractRegions must return sorted regions');
    });

    // -------------------------------------------------------------------------
    // Sub-property: parameterized cases covering various combinations
    // -------------------------------------------------------------------------
    for (final testCase in [
      (
        'two events, disjoint regions',
        [
          _event(id: '1', region: 'Praha'),
          _event(id: '2', region: 'Brno'),
        ],
        {'Praha', 'Brno'},
      ),
      (
        'three events, partial overlap',
        [
          _event(id: '1', region: 'Praha'),
          _event(id: '2', region: 'Praha'),
          _event(id: '3', region: 'Brno'),
        ],
        {'Praha', 'Brno'},
      ),
      (
        'mix of events with and without regions',
        [
          _event(id: '1', region: 'Praha'),
          _event(id: '2', region: ''),
          _event(id: '3', region: 'Brno'),
          _event(id: '4', region: ''),
        ],
        {'Praha', 'Brno'},
      ),
      (
        'real Czech regions',
        [
          _event(id: '1', region: 'Hlavní město Praha'),
          _event(id: '2', region: 'Jihomoravský kraj'),
          _event(id: '3', region: 'Moravskoslezský kraj'),
          _event(id: '4', region: 'Hlavní město Praha'),
        ],
        {'Hlavní město Praha', 'Jihomoravský kraj', 'Moravskoslezský kraj'},
      ),
    ]) {
      final label = testCase.$1;
      final events = testCase.$2;
      final expected = testCase.$3;

      test('$label: result equals set of unique non-empty regions', () {
        final result = extractRegions(events);
        expect(result.toSet(), equals(expected),
            reason: 'extractRegions must return unique non-empty regions');
        expect(result.length, equals(result.toSet().length),
            reason: 'no duplicates allowed');
      });
    }
  });
}
