import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 5: Active filter category count
//
// getActiveFilterCount(filters) must return a non-negative integer that equals
// the number of active (non-empty) filter categories:
//
// - searchQuery counts as 1 if non-empty
// - selectedDanceTypes counts as 1 if non-empty
// - selectedRegions counts as 1 if non-empty
// - date range (dateFrom OR dateTo set) counts as 1
//
// Maximum possible value is 4. Empty FilterState returns 0.
//
// Validates: Requirements 6.3, 8.1
// ---------------------------------------------------------------------------

void main() {
  group('Property 5: Active filter category count', () {
    // -------------------------------------------------------------------------
    // Sub-property: empty FilterState returns 0
    // -------------------------------------------------------------------------
    test('empty FilterState returns 0', () {
      expect(getActiveFilterCount(const FilterState()), equals(0));
    });

    // -------------------------------------------------------------------------
    // Sub-property: each category individually contributes 1
    // -------------------------------------------------------------------------
    group('individual filter categories each contribute 1', () {
      test('non-empty searchQuery contributes 1', () {
        expect(
          getActiveFilterCount(const FilterState(searchQuery: 'salsa')),
          equals(1),
        );
      });

      test('empty searchQuery contributes 0', () {
        expect(
          getActiveFilterCount(const FilterState(searchQuery: '')),
          equals(0),
        );
      });

      test('non-empty selectedDanceTypes contributes 1', () {
        expect(
          getActiveFilterCount(const FilterState(selectedDanceTypes: {'Salsa'})),
          equals(1),
        );
      });

      test('empty selectedDanceTypes contributes 0', () {
        expect(
          getActiveFilterCount(const FilterState(selectedDanceTypes: {})),
          equals(0),
        );
      });

      test('non-empty selectedRegions contributes 1', () {
        expect(
          getActiveFilterCount(const FilterState(selectedRegions: {'Praha'})),
          equals(1),
        );
      });

      test('empty selectedRegions contributes 0', () {
        expect(
          getActiveFilterCount(const FilterState(selectedRegions: {})),
          equals(0),
        );
      });

      test('dateFrom set alone contributes 1', () {
        expect(
          getActiveFilterCount(FilterState(dateFrom: DateTime(2025, 6, 1))),
          equals(1),
        );
      });

      test('dateTo set alone contributes 1', () {
        expect(
          getActiveFilterCount(FilterState(dateTo: DateTime(2025, 6, 30))),
          equals(1),
        );
      });

      test('both dateFrom and dateTo set together still contribute only 1', () {
        expect(
          getActiveFilterCount(FilterState(
            dateFrom: DateTime(2025, 6, 1),
            dateTo: DateTime(2025, 6, 30),
          )),
          equals(1),
          reason: 'date range is a single filter category regardless of how many date fields are set',
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: multiple categories sum correctly
    // -------------------------------------------------------------------------
    group('multiple active categories sum correctly', () {
      test('two categories returns 2', () {
        expect(
          getActiveFilterCount(const FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: {'Salsa'},
          )),
          equals(2),
        );
      });

      test('three categories returns 3', () {
        expect(
          getActiveFilterCount(const FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: {'Salsa'},
            selectedRegions: {'Praha'},
          )),
          equals(3),
        );
      });

      test('all four categories returns 4', () {
        expect(
          getActiveFilterCount(FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: const {'Salsa'},
            selectedRegions: const {'Praha'},
            dateFrom: DateTime(2025, 6, 1),
          )),
          equals(4),
        );
      });

      test('all four categories with both date fields returns 4', () {
        expect(
          getActiveFilterCount(FilterState(
            searchQuery: 'salsa',
            selectedDanceTypes: const {'Salsa'},
            selectedRegions: const {'Praha'},
            dateFrom: DateTime(2025, 6, 1),
            dateTo: DateTime(2025, 6, 30),
          )),
          equals(4),
        );
      });
    });

    // -------------------------------------------------------------------------
    // Sub-property: result is always in [0, 4]
    // -------------------------------------------------------------------------
    group('result is always in range [0, 4]', () {
      for (final testCase in [
        (const FilterState(), 0),
        (const FilterState(searchQuery: 'x'), 1),
        (const FilterState(selectedDanceTypes: {'Tango'}), 1),
        (const FilterState(selectedRegions: {'Brno'}), 1),
        (FilterState(dateFrom: DateTime(2025, 1, 1)), 1),
        (FilterState(dateTo: DateTime(2025, 12, 31)), 1),
        (
          FilterState(
            dateFrom: DateTime(2025, 1, 1),
            dateTo: DateTime(2025, 12, 31),
          ),
          1,
        ),
        (const FilterState(searchQuery: 'x', selectedDanceTypes: {'Tango'}), 2),
        (
          const FilterState(
            searchQuery: 'x',
            selectedDanceTypes: {'Tango'},
            selectedRegions: {'Brno'},
          ),
          3,
        ),
      ]) {
        final filters = testCase.$1;
        final expectedCount = testCase.$2;

        test('filters with expected count $expectedCount returns $expectedCount', () {
          final actual = getActiveFilterCount(filters);
          expect(actual, equals(expectedCount));
          expect(actual, greaterThanOrEqualTo(0));
          expect(actual, lessThanOrEqualTo(4));
        });
      }
    });

    // -------------------------------------------------------------------------
    // Sub-property: multiple values in a set still count as one category
    // -------------------------------------------------------------------------
    group('multiple values in a set still count as one category', () {
      test('selectedDanceTypes with multiple values counts as 1', () {
        expect(
          getActiveFilterCount(const FilterState(
            selectedDanceTypes: {'Salsa', 'Tango', 'Bachata'},
          )),
          equals(1),
          reason: 'selectedDanceTypes is one category regardless of how many types are selected',
        );
      });

      test('selectedRegions with multiple values counts as 1', () {
        expect(
          getActiveFilterCount(const FilterState(
            selectedRegions: {'Praha', 'Brno', 'Ostrava'},
          )),
          equals(1),
          reason: 'selectedRegions is one category regardless of how many regions are selected',
        );
      });
    });
  });
}
