import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 2: Dance type extraction returns all unique dances
//
// For any list of events, extractDanceTypes(events) must return a set equal to
// the union of all event.dances values across every event in the list, with
// no duplicates and no missing entries.
//
// Validates: Requirements 3.1
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

const _kVenue = Venue(
  name: 'Venue',
  address: _kAddress,
  description: '',
  latitude: 0,
  longitude: 0,
  region: '',
);

Event _event({
  required String id,
  List<String> dances = const [],
}) {
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    organizer: '',
    venue: _kVenue,
    startTime: DateTime(2025, 6, 1),
    dances: dances,
  );
}

/// Computes the reference expected dance type set — union of all event.dances.
Set<String> _expectedDanceTypes(List<Event> events) {
  final result = <String>{};
  for (final event in events) {
    result.addAll(event.dances);
  }
  return result;
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 2: Dance type extraction returns all unique dances', () {
    // -------------------------------------------------------------------------
    // Sub-property: empty input
    // -------------------------------------------------------------------------
    test('empty event list returns empty list', () {
      expect(extractDanceTypes([]), isEmpty);
    });

    // -------------------------------------------------------------------------
    // Sub-property: single event
    // -------------------------------------------------------------------------
    test('single event with no dances returns empty list', () {
      final events = [_event(id: '1', dances: [])];
      expect(extractDanceTypes(events), isEmpty);
    });

    test('single event with one dance returns that dance', () {
      final events = [_event(id: '1', dances: ['Salsa'])];
      final result = extractDanceTypes(events);
      expect(result.toSet(), equals({'Salsa'}));
    });

    test('single event with multiple dances returns all dances', () {
      final events = [_event(id: '1', dances: ['Salsa', 'Bachata', 'Tango'])];
      final result = extractDanceTypes(events);
      expect(result.toSet(), equals({'Salsa', 'Bachata', 'Tango'}));
    });

    // -------------------------------------------------------------------------
    // Sub-property: multiple events, union correctness
    // -------------------------------------------------------------------------
    test('multiple events: returns union of all dances', () {
      final events = [
        _event(id: '1', dances: ['Salsa']),
        _event(id: '2', dances: ['Tango']),
        _event(id: '3', dances: ['Bachata']),
      ];
      final result = extractDanceTypes(events);
      expect(result.toSet(), equals(_expectedDanceTypes(events)));
    });

    test('overlapping dances across events: no duplicates', () {
      final events = [
        _event(id: '1', dances: ['Salsa', 'Bachata']),
        _event(id: '2', dances: ['Salsa', 'Kizomba']),
        _event(id: '3', dances: ['Bachata', 'Zouk']),
      ];
      final result = extractDanceTypes(events);
      // Verify set equality (no duplicates, no missing)
      expect(result.toSet(), equals(_expectedDanceTypes(events)));
      // Verify no duplicates in the list itself
      expect(result.length, equals(result.toSet().length),
          reason: 'extractDanceTypes must not return duplicate entries');
    });

    test('all events have same dance type: returns exactly one entry', () {
      final events = [
        _event(id: '1', dances: ['Salsa']),
        _event(id: '2', dances: ['Salsa']),
        _event(id: '3', dances: ['Salsa']),
      ];
      final result = extractDanceTypes(events);
      expect(result, equals(['Salsa']),
          reason: 'identical dance type across all events must appear exactly once');
    });

    // -------------------------------------------------------------------------
    // Sub-property: completeness — no missing entries
    // -------------------------------------------------------------------------
    test('no dance from any event is missing from result', () {
      final events = [
        _event(id: '1', dances: ['Salsa', 'Bachata']),
        _event(id: '2', dances: ['Tango', 'Waltz']),
        _event(id: '3', dances: ['Kizomba']),
        _event(id: '4', dances: []),
      ];
      final result = extractDanceTypes(events);
      final expected = _expectedDanceTypes(events);
      for (final dance in expected) {
        expect(result.contains(dance), isTrue,
            reason: 'dance type "$dance" from events must be present in result');
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: no extra entries — only dances from events
    // -------------------------------------------------------------------------
    test('result contains no dance types not present in events', () {
      final events = [
        _event(id: '1', dances: ['Salsa']),
        _event(id: '2', dances: ['Tango']),
      ];
      final result = extractDanceTypes(events);
      final allEventDances = _expectedDanceTypes(events);
      for (final dance in result) {
        expect(allEventDances.contains(dance), isTrue,
            reason: 'result must not contain "$dance" which is not in any event');
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: events with empty dances list contribute nothing
    // -------------------------------------------------------------------------
    test('events with empty dances list do not add empty strings', () {
      final events = [
        _event(id: '1', dances: []),
        _event(id: '2', dances: []),
        _event(id: '3', dances: ['Salsa']),
      ];
      final result = extractDanceTypes(events);
      expect(result.toSet(), equals({'Salsa'}));
    });

    // -------------------------------------------------------------------------
    // Sub-property: result is sorted
    // -------------------------------------------------------------------------
    test('result is sorted alphabetically', () {
      final events = [
        _event(id: '1', dances: ['Tango', 'Salsa']),
        _event(id: '2', dances: ['Bachata', 'Kizomba']),
      ];
      final result = extractDanceTypes(events);
      final sorted = List<String>.from(result)..sort();
      expect(result, equals(sorted),
          reason: 'extractDanceTypes must return sorted dance types');
    });

    // -------------------------------------------------------------------------
    // Sub-property: parameterized cases covering various combinations
    // -------------------------------------------------------------------------
    for (final testCase in [
      (
        'two events, disjoint dances',
        [
          _event(id: '1', dances: ['Salsa', 'Bachata']),
          _event(id: '2', dances: ['Tango', 'Waltz']),
        ],
        {'Salsa', 'Bachata', 'Tango', 'Waltz'},
      ),
      (
        'three events, partial overlap',
        [
          _event(id: '1', dances: ['Salsa']),
          _event(id: '2', dances: ['Salsa', 'Tango']),
          _event(id: '3', dances: ['Tango', 'Kizomba']),
        ],
        {'Salsa', 'Tango', 'Kizomba'},
      ),
      (
        'one event with many dances',
        [
          _event(id: '1', dances: ['Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Tango']),
        ],
        {'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Tango'},
      ),
      (
        'mix of events with and without dances',
        [
          _event(id: '1', dances: ['Salsa']),
          _event(id: '2', dances: []),
          _event(id: '3', dances: ['Bachata']),
          _event(id: '4', dances: []),
        ],
        {'Salsa', 'Bachata'},
      ),
    ]) {
      final label = testCase.$1;
      final events = testCase.$2;
      final expected = testCase.$3;

      test('$label: result equals union of all event dances', () {
        final result = extractDanceTypes(events);
        expect(result.toSet(), equals(expected),
            reason: 'extractDanceTypes must return union of all event.dances');
        expect(result.length, equals(result.toSet().length),
            reason: 'no duplicates allowed');
      });
    }
  });
}
