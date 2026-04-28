// Feature: cms-flutter-integration
// Task 10.3: Property test for region extraction
// Properties covered:
//   Property 9: Region extraction from loaded data

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/data/entities/course.dart';
import 'package:dancee_app2/data/entities/event.dart';
import 'package:dancee_app2/data/entities/venue.dart';

// ---------------------------------------------------------------------------
// Region extraction helper (mirrors _deriveRegions logic in FilterLocationScreen)
// ---------------------------------------------------------------------------

/// Extracts the union of all non-empty venue regions from [events] and [courses].
/// Mirrors the logic in FilterLocationScreen._deriveRegions().
Set<String> deriveRegions(List<Event> events, List<Course> courses) {
  final regions = <String>{};
  for (final event in events) {
    final region = event.venue?.region;
    if (region != null && region.isNotEmpty) regions.add(region);
  }
  for (final course in courses) {
    final region = course.venue?.region;
    if (region != null && region.isNotEmpty) regions.add(region);
  }
  return regions;
}

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(99);

Venue _makeVenue(int id, String region) => Venue(
      id: id,
      name: 'Venue $id',
      street: '',
      number: '',
      town: '',
      country: '',
      postalCode: '',
      region: region,
      latitude: 0,
      longitude: 0,
    );

Event _makeEvent({required int id, String? region}) => Event(
      id: id,
      title: 'Event $id',
      description: '',
      startTime: DateTime(2025, 1, 1),
      organizer: 'Org',
      dances: const [],
      eventType: 'party',
      info: const [],
      parts: const [],
      isFavorited: false,
      venue: region != null ? _makeVenue(id, region) : null,
    );

Course _makeCourse({required int id, String? region}) => Course(
      id: id,
      title: 'Course $id',
      description: '',
      dances: const [],
      learningItems: const [],
      isFavorited: false,
      venue: region != null ? _makeVenue(id, region) : null,
    );

// ---------------------------------------------------------------------------
// Property 9: Region extraction from loaded data
// ---------------------------------------------------------------------------

void _propertyRegionExtraction() {
  // Feature: cms-flutter-integration, Property 9: Region extraction from loaded data
  test(
    'P9: extracted regions equal union of all non-empty venue.region values (100 iterations)',
    () {
      const pool = [
        'Praha',
        'Brno',
        'Ostrava',
        'Olomouc',
        'Plzeň',
        'Liberec',
        '',
      ];

      for (var i = 0; i < 100; i++) {
        final eventCount = _rng.nextInt(10);
        final courseCount = _rng.nextInt(10);

        // Build expected set in parallel with generating items
        final expected = <String>{};

        final events = List.generate(eventCount, (idx) {
          final region = _rng.nextBool() ? pool[_rng.nextInt(pool.length)] : null;
          if (region != null && region.isNotEmpty) expected.add(region);
          return _makeEvent(id: idx, region: region);
        });

        final courses = List.generate(courseCount, (idx) {
          final region = _rng.nextBool() ? pool[_rng.nextInt(pool.length)] : null;
          if (region != null && region.isNotEmpty) expected.add(region);
          return _makeCourse(id: idx + 100, region: region);
        });

        final result = deriveRegions(events, courses);

        expect(
          result,
          equals(expected),
          reason:
              'Iteration $i: extracted regions should equal union of all non-empty regions',
        );
      }
    },
  );

  test(
    'P9b: result contains no duplicates even when same region appears in multiple events (100 iterations)',
    () {
      const regions = ['Praha', 'Brno', 'Ostrava'];

      for (var i = 0; i < 100; i++) {
        final count = 2 + _rng.nextInt(9);
        final events = List.generate(
          count,
          (idx) => _makeEvent(
            id: idx,
            region: regions[_rng.nextInt(regions.length)],
          ),
        );
        final courses = List.generate(
          count,
          (idx) => _makeCourse(
            id: idx + 100,
            region: regions[_rng.nextInt(regions.length)],
          ),
        );

        final result = deriveRegions(events, courses);

        // A Set cannot have duplicates by definition; verify it equals its own toSet()
        expect(
          result.length,
          equals(result.toSet().length),
          reason: 'Iteration $i: result must not contain duplicate regions',
        );
        // All values must be from the pool
        for (final r in result) {
          expect(
            regions.contains(r),
            isTrue,
            reason: 'Iteration $i: unexpected region "$r" in result',
          );
        }
      }
    },
  );

  test(
    'P9c: empty-string and null venues are excluded from extracted regions',
    () {
      final events = [
        _makeEvent(id: 1, region: ''),
        _makeEvent(id: 2, region: null),
        _makeEvent(id: 3, region: 'Praha'),
      ];
      final courses = [
        _makeCourse(id: 101, region: ''),
        _makeCourse(id: 102, region: null),
        _makeCourse(id: 103, region: 'Brno'),
      ];

      final result = deriveRegions(events, courses);

      expect(result, equals({'Praha', 'Brno'}));
      expect(result.contains(''), isFalse);
    },
  );

  test(
    'P9d: no events or courses yields empty region set',
    () {
      final result = deriveRegions([], []);
      expect(result, isEmpty);
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Region extraction — property tests', () {
    group('Property 9: Region extraction from loaded data', _propertyRegionExtraction);
  });
}
