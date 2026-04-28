// Feature: cms-flutter-integration
// Task 5.6: Property tests for filtering logic
// Properties covered:
//   Property 6: Featured events are filtered festivals
//   Property 7: Combined AND filtering
//   Property 8: Parent/child dance style expansion

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/data/entities/dance_style.dart';
import 'package:dancee_app2/data/entities/event.dart';
import 'package:dancee_app2/data/entities/venue.dart';
import 'package:dancee_app2/data/repositories/event_repository.dart';
import 'package:dancee_app2/logic/cubits/event_cubit.dart';
import 'package:dancee_app2/logic/states/filter_state.dart';

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(42);

/// A fake [EventRepository] returning pre-set events without HTTP calls.
class _FakeEventRepository extends EventRepository {
  _FakeEventRepository(this._events)
      : super(
          client: DirectusClient(
            baseUrl: 'http://test.local',
            accessToken: 'test-token',
            dio: Dio(),
          ),
        );

  final List<Event> _events;

  @override
  Future<List<Event>> getEvents(String languageCode) async => _events;
}

Event _makeEvent({
  required int id,
  List<String> dances = const [],
  String eventType = 'party',
  String? region,
  String country = 'CZ',
}) {
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    startTime: DateTime(2025, 1, 1),
    organizer: 'Organizer',
    dances: List<String>.from(dances),
    eventType: eventType,
    info: const [],
    parts: const [],
    isFavorited: false,
    venue: region != null
        ? Venue(
            id: id,
            name: 'Venue $id',
            street: '',
            number: '',
            town: '',
            country: country,
            postalCode: '',
            region: region,
            latitude: 0,
            longitude: 0,
          )
        : null,
  );
}

DanceStyle _makeStyle(String code, {String? parentCode}) {
  return DanceStyle(
    code: code,
    name: code,
    parentCode: parentCode,
    sortOrder: 0,
  );
}

// ---------------------------------------------------------------------------
// Property 6: Featured events are filtered festivals
// ---------------------------------------------------------------------------

void _propertyFeaturedEventsAreFilteredFestivals() {
  // Feature: cms-flutter-integration, Property 6: Featured events are filtered festivals
  test(
    'P6: featuredEvents contains only festivals that match all active filters (100 iterations)',
    () async {
      const eventTypes = ['festival', 'party', 'workshop', 'competition'];
      const danceCodes = ['salsa', 'bachata', 'tango', 'swing', 'waltz'];
      const regions = ['Praha', 'Brno', 'Ostrava', 'Olomouc'];

      for (var i = 0; i < 100; i++) {
        final eventCount = 5 + _rng.nextInt(11);
        final events = List.generate(eventCount, (idx) {
          final eventType = eventTypes[_rng.nextInt(eventTypes.length)];
          final danceCount = 1 + _rng.nextInt(3);
          final dances = List.generate(
            danceCount,
            (_) => danceCodes[_rng.nextInt(danceCodes.length)],
          ).toSet().toList();
          final region = _rng.nextBool()
              ? regions[_rng.nextInt(regions.length)]
              : null;
          return _makeEvent(
            id: idx + 1,
            eventType: eventType,
            dances: dances,
            region: region,
          );
        });

        final filterDances = _rng.nextBool()
            ? {danceCodes[_rng.nextInt(danceCodes.length)]}
            : <String>{};
        final filterRegions = _rng.nextBool()
            ? {regions[_rng.nextInt(regions.length)]}
            : <String>{};
        final filter = FilterState(
          selectedDanceStyles: filterDances,
          selectedRegions: filterRegions,
        );

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, []);

        cubit.state.maybeMap(
          loaded: (loaded) {
            // P6a: All featured events must be festivals
            for (final featured in loaded.featuredEvents) {
              expect(
                featured.eventType,
                equals('festival'),
                reason:
                    'Iteration $i: featured event ${featured.id} must be a festival',
              );
            }

            // P6b: All featured events must be in filteredEvents
            for (final featured in loaded.featuredEvents) {
              expect(
                loaded.filteredEvents.any((e) => e.id == featured.id),
                isTrue,
                reason:
                    'Iteration $i: featured event ${featured.id} must be in filteredEvents',
              );
            }

            // P6c: featuredEvents count equals festivals in filteredEvents
            final filteredFestivalCount =
                loaded.filteredEvents.where((e) => e.eventType == 'festival').length;
            expect(
              loaded.featuredEvents.length,
              equals(filteredFestivalCount),
              reason:
                  'Iteration $i: featuredEvents count should equal filtered festivals count',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Property 7: Combined AND filtering
// ---------------------------------------------------------------------------

void _propertyAndFiltering() {
  // Feature: cms-flutter-integration, Property 7: Combined AND filtering
  test(
    'P7: Dance style AND region filter requires both conditions to match (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final events = [
          _makeEvent(id: 1, dances: ['salsa'], region: 'Praha'),
          _makeEvent(id: 2, dances: ['bachata'], region: 'Praha'),
          _makeEvent(id: 3, dances: ['salsa'], region: 'Brno'),
          _makeEvent(id: 4, dances: ['tango'], region: 'Ostrava'),
          _makeEvent(id: 5, dances: ['salsa', 'bachata'], region: 'Praha'),
          _makeEvent(id: 6, dances: ['salsa'], region: null),
        ];

        const filter = FilterState(
          selectedDanceStyles: {'salsa'},
          selectedRegions: {'Praha'},
        );

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, []);

        cubit.state.maybeMap(
          loaded: (loaded) {
            final filteredIds =
                loaded.filteredEvents.map((e) => e.id).toSet();

            // Events 1 and 5 have salsa AND are in Praha
            expect(
              filteredIds,
              containsAll([1, 5]),
              reason: 'Iteration $i: events 1 and 5 should pass both filters',
            );
            // Events 2, 3, 4, 6 fail at least one condition
            expect(
              filteredIds.intersection({2, 3, 4, 6}),
              isEmpty,
              reason: 'Iteration $i: events failing either filter should be excluded',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );

  test(
    'P7b: Dance-style-only filter accepts events regardless of region (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final events = [
          _makeEvent(id: 1, dances: ['salsa'], region: 'Praha'),
          _makeEvent(id: 2, dances: ['salsa'], region: 'Brno'),
          _makeEvent(id: 3, dances: ['bachata'], region: 'Praha'),
          _makeEvent(id: 4, dances: ['salsa'], region: null),
        ];

        const filter = FilterState(selectedDanceStyles: {'salsa'});

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, []);

        cubit.state.maybeMap(
          loaded: (loaded) {
            final filteredIds =
                loaded.filteredEvents.map((e) => e.id).toSet();

            expect(
              filteredIds,
              containsAll([1, 2, 4]),
              reason: 'Iteration $i: salsa events from any region should pass',
            );
            expect(
              filteredIds.contains(3),
              isFalse,
              reason: 'Iteration $i: bachata-only event should be excluded',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );

  test(
    'P7c: Empty filter passes all events (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final eventCount = 1 + _rng.nextInt(20);
        final events = List.generate(
          eventCount,
          (idx) => _makeEvent(id: idx + 1, dances: ['salsa']),
        );

        const filter = FilterState();

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, []);

        cubit.state.maybeMap(
          loaded: (loaded) {
            expect(
              loaded.filteredEvents.length,
              equals(eventCount),
              reason:
                  'Iteration $i: empty filter should pass all $eventCount events',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Property 8: Parent/child dance style expansion
// ---------------------------------------------------------------------------

void _propertyParentChildExpansion() {
  // Feature: cms-flutter-integration, Property 8: Parent/child dance style expansion
  test(
    'P8: Selecting a parent style also includes events tagged with child styles (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final danceStyles = [
          _makeStyle('salsa'),
          _makeStyle('salsa_cubana', parentCode: 'salsa'),
          _makeStyle('salsa_on2', parentCode: 'salsa'),
          _makeStyle('bachata'),
        ];

        final events = [
          _makeEvent(id: 1, dances: ['salsa']),
          _makeEvent(id: 2, dances: ['salsa_cubana']),
          _makeEvent(id: 3, dances: ['salsa_on2']),
          _makeEvent(id: 4, dances: ['bachata']),
          _makeEvent(id: 5, dances: ['salsa_cubana', 'salsa_on2']),
        ];

        const filter = FilterState(selectedDanceStyles: {'salsa'});

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, danceStyles);

        cubit.state.maybeMap(
          loaded: (loaded) {
            final filteredIds =
                loaded.filteredEvents.map((e) => e.id).toSet();

            expect(
              filteredIds,
              containsAll([1, 2, 3, 5]),
              reason:
                  'Iteration $i: parent filter should match parent and all child events',
            );
            expect(
              filteredIds.contains(4),
              isFalse,
              reason: 'Iteration $i: unrelated dance event should be excluded',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );

  test(
    'P8b: Selecting a child style does NOT match sibling or parent events (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final danceStyles = [
          _makeStyle('salsa'),
          _makeStyle('salsa_cubana', parentCode: 'salsa'),
          _makeStyle('salsa_on2', parentCode: 'salsa'),
        ];

        final events = [
          _makeEvent(id: 1, dances: ['salsa_cubana']),
          _makeEvent(id: 2, dances: ['salsa_on2']),
          _makeEvent(id: 3, dances: ['salsa']),
        ];

        const filter = FilterState(selectedDanceStyles: {'salsa_cubana'});

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, danceStyles);

        cubit.state.maybeMap(
          loaded: (loaded) {
            final filteredIds =
                loaded.filteredEvents.map((e) => e.id).toSet();

            expect(
              filteredIds,
              equals({1}),
              reason:
                  'Iteration $i: child filter should only match the specific child style',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );

  test(
    'P8c: Expansion covers all children for randomly generated style trees (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final parentCode = 'style_parent_$i';
        final childCount = 1 + _rng.nextInt(4);
        final childCodes =
            List.generate(childCount, (j) => 'style_child_${i}_$j');

        final danceStyles = [
          _makeStyle(parentCode),
          ...childCodes.map((c) => _makeStyle(c, parentCode: parentCode)),
          _makeStyle('unrelated_style'),
        ];

        final events = [
          _makeEvent(id: 0, dances: [parentCode]),
          ...childCodes.asMap().entries.map(
                (e) => _makeEvent(id: e.key + 1, dances: [e.value]),
              ),
          _makeEvent(id: childCount + 1, dances: ['unrelated_style']),
        ];

        final filter = FilterState(selectedDanceStyles: {parentCode});

        final cubit = EventCubit(
          eventRepository: _FakeEventRepository(events),
        );
        await cubit.loadEvents('en');
        cubit.applyFilters(filter, danceStyles);

        cubit.state.maybeMap(
          loaded: (loaded) {
            // parent event + all child events should be included
            expect(
              loaded.filteredEvents.length,
              equals(childCount + 1),
              reason:
                  'Iteration $i: should include parent + all $childCount children, got ${loaded.filteredEvents.length}',
            );
            expect(
              loaded.filteredEvents.any((e) => e.id == childCount + 1),
              isFalse,
              reason: 'Iteration $i: unrelated style event should be excluded',
            );
          },
          orElse: () => fail('Iteration $i: expected loaded state'),
        );

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('EventCubit filtering — property tests', () {
    group(
      'Property 6: Featured events are filtered festivals',
      _propertyFeaturedEventsAreFilteredFestivals,
    );
    group('Property 7: Combined AND filtering', _propertyAndFiltering);
    group(
      'Property 8: Parent/child dance style expansion',
      _propertyParentChildExpansion,
    );
  });
}
