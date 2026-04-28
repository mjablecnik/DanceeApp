import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Property 7: FilterState serialization round trip
//
// For any valid FilterState, serializing it to JSON and then deserializing
// the JSON back must produce a FilterState that is equal to the original.
//
// Validates: Requirements 7.2, 7.3
// ---------------------------------------------------------------------------

void main() {
  group('Property 7: FilterState serialization round trip', () {
    // -----------------------------------------------------------------------
    // Helper to assert round-trip equality
    // -----------------------------------------------------------------------
    void assertRoundTrip(FilterState original) {
      final json = original.toJson();
      final restored = FilterState.fromJson(json);
      expect(restored, equals(original),
          reason: 'fromJson(toJson(x)) must equal x for FilterState');
    }

    // -----------------------------------------------------------------------
    // Property: default/empty FilterState round-trips correctly
    // -----------------------------------------------------------------------
    test('empty FilterState round-trips correctly', () {
      assertRoundTrip(const FilterState());
    });

    // -----------------------------------------------------------------------
    // Property: FilterState with searchQuery round-trips correctly
    // -----------------------------------------------------------------------
    const searchQueries = [
      'salsa',
      'bachata festival',
      'Prague',
      '  spaces  ',
      'a',
      '1234',
      'Special chars: @#\$%',
      '',
    ];

    for (final query in searchQueries) {
      test('searchQuery "$query" round-trips correctly', () {
        assertRoundTrip(FilterState(searchQuery: query));
      });
    }

    // -----------------------------------------------------------------------
    // Property: FilterState with selectedDanceTypes round-trips correctly
    // -----------------------------------------------------------------------
    final danceTypeCases = <Set<String>>[
      {'Salsa'},
      {'Bachata', 'Salsa'},
      {'Tango', 'Waltz', 'Foxtrot'},
      {},
      {'Kizomba', 'Zouk', 'West Coast Swing', 'Lindy Hop'},
    ];

    for (var i = 0; i < danceTypeCases.length; i++) {
      final danceTypes = danceTypeCases[i];
      test('selectedDanceTypes case $i round-trips correctly', () {
        assertRoundTrip(FilterState(selectedDanceTypes: danceTypes));
      });
    }

    // -----------------------------------------------------------------------
    // Property: FilterState with selectedRegions round-trips correctly
    // -----------------------------------------------------------------------
    final regionCases = <Set<String>>[
      {'Prague'},
      {'South Moravia', 'Central Bohemia'},
      {'Ústí nad Labem Region', 'Zlín Region', 'Liberec Region'},
      {},
    ];

    for (var i = 0; i < regionCases.length; i++) {
      final regions = regionCases[i];
      test('selectedRegions case $i round-trips correctly', () {
        assertRoundTrip(FilterState(selectedRegions: regions));
      });
    }

    // -----------------------------------------------------------------------
    // Property: FilterState with dateFrom/dateTo round-trips correctly
    // -----------------------------------------------------------------------
    final dateCases = <(DateTime?, DateTime?)>[
      (DateTime(2025, 6, 15), null),
      (null, DateTime(2025, 12, 31)),
      (DateTime(2025, 1, 1), DateTime(2025, 12, 31)),
      (null, null),
      (DateTime(2025, 6, 15, 10, 30), DateTime(2025, 6, 20, 23, 59, 59)),
    ];

    for (var i = 0; i < dateCases.length; i++) {
      final (dateFrom, dateTo) = dateCases[i];
      test('dateFrom/dateTo case $i round-trips correctly', () {
        assertRoundTrip(FilterState(dateFrom: dateFrom, dateTo: dateTo));
      });
    }

    // -----------------------------------------------------------------------
    // Property: FilterState with all fields populated round-trips correctly
    // -----------------------------------------------------------------------
    test('fully populated FilterState round-trips correctly', () {
      assertRoundTrip(FilterState(
        searchQuery: 'salsa festival',
        selectedDanceTypes: const {'Salsa', 'Bachata'},
        selectedRegions: const {'Prague', 'South Moravia'},
        dateFrom: DateTime(2025, 6, 1),
        dateTo: DateTime(2025, 6, 30),
      ));
    });

    // -----------------------------------------------------------------------
    // Property: toJson produces expected keys
    // -----------------------------------------------------------------------
    test('toJson includes all required keys', () {
      const state = FilterState(
        searchQuery: 'test',
        selectedDanceTypes: {'Salsa'},
        selectedRegions: {'Prague'},
      );
      final json = state.toJson();

      expect(json.containsKey('searchQuery'), isTrue);
      expect(json.containsKey('selectedDanceTypes'), isTrue);
      expect(json.containsKey('selectedRegions'), isTrue);
      expect(json.containsKey('dateFrom'), isTrue);
      expect(json.containsKey('dateTo'), isTrue);
    });

    // -----------------------------------------------------------------------
    // Property: null dates serialize to null and deserialize back to null
    // -----------------------------------------------------------------------
    test('null dates serialize to null JSON values', () {
      const state = FilterState();
      final json = state.toJson();

      expect(json['dateFrom'], isNull);
      expect(json['dateTo'], isNull);

      final restored = FilterState.fromJson(json);
      expect(restored.dateFrom, isNull);
      expect(restored.dateTo, isNull);
    });

    // -----------------------------------------------------------------------
    // Property: sets serialize to lists and deserialize back to sets
    // -----------------------------------------------------------------------
    test('selectedDanceTypes and selectedRegions serialize as lists', () {
      const state = FilterState(
        selectedDanceTypes: {'Salsa', 'Bachata'},
        selectedRegions: {'Prague'},
      );
      final json = state.toJson();

      expect(json['selectedDanceTypes'], isA<List>());
      expect(json['selectedRegions'], isA<List>());

      final restored = FilterState.fromJson(json);
      expect(restored.selectedDanceTypes, isA<Set<String>>());
      expect(restored.selectedRegions, isA<Set<String>>());
      expect(restored.selectedDanceTypes, equals(state.selectedDanceTypes));
      expect(restored.selectedRegions, equals(state.selectedRegions));
    });

    // -----------------------------------------------------------------------
    // Property: multiple round-trips are idempotent
    // -----------------------------------------------------------------------
    test('multiple sequential round-trips produce the same result', () {
      const original = FilterState(
        searchQuery: 'dance',
        selectedDanceTypes: {'Tango', 'Waltz'},
        selectedRegions: {'Prague'},
        dateFrom: null,
        dateTo: null,
      );

      final json1 = original.toJson();
      final restored1 = FilterState.fromJson(json1);
      final json2 = restored1.toJson();
      final restored2 = FilterState.fromJson(json2);

      expect(restored1, equals(original));
      expect(restored2, equals(original));
      expect(restored2, equals(restored1));
    });
  });
}
