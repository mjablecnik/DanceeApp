import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

// ---------------------------------------------------------------------------
// Helper factory
// ---------------------------------------------------------------------------

Event _makeEvent({
  required String id,
  required DateTime startTime,
  DateTime? endTime,
  String title = 'Test Event',
  bool isFavorite = false,
  bool isPast = false,
}) {
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: const Venue(
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
    ),
    startTime: startTime,
    endTime: endTime,
    dances: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}

/// The EventListCubit auto-calls loadEvents() in its constructor, which
/// synchronously emits the loading state BEFORE bloc_test's stream
/// subscription is set up — so that first loading emission is always lost.
///
/// To test state sequences starting from a predictable state we:
/// 1. Block the constructor's getAllEvents() call with a Completer (so it
///    never resolves and emits no extra states).
/// 2. Use `seed: () => EventListState.initial()` in each blocTest, which
///    resets the cubit's state to `initial` BEFORE the subscription is
///    established, so that act()'s explicit loadEvents() call can produce a
///    fresh [loading → loaded/error] sequence captured by the subscription.

void main() {
  late MockEventRepository mockRepo;
  late Completer<List<Event>> autoLoadBlocker;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    autoLoadBlocker = Completer<List<Event>>();
    // Block the constructor's auto-load so it never resolves during tests.
    when(() => mockRepo.getAllEvents())
        .thenAnswer((_) => autoLoadBlocker.future);
  });

  tearDown(() {
    // Complete the blocker to avoid dangling futures.
    if (!autoLoadBlocker.isCompleted) autoLoadBlocker.complete([]);
  });

  // =========================================================================
  // TC-037: Initial state type
  // =========================================================================

  test('TC-037: EventListState.initial() is EventListInitial', () {
    // The cubit calls super(EventListState.initial()); verify the state type.
    expect(const EventListState.initial(), isA<EventListInitial>());
  });

  // =========================================================================
  // TC-038: loadEvents() emits loading then loaded
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-038: loadEvents emits loading → loaded',
    build: () => EventListCubit(mockRepo),
    // seed resets state to initial BEFORE subscription; act's loadEvents()
    // then fires a genuine loading → loaded transition.
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      final now = DateTime.now();
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(id: '1', startTime: now.add(const Duration(hours: 3))),
            _makeEvent(id: '2', startTime: now.add(const Duration(hours: 5))),
          ]);
      await cubit.loadEvents();
    },
    expect: () => [
      isA<EventListLoading>(),
      isA<EventListLoaded>(),
    ],
  );

  // =========================================================================
  // TC-039: loadEvents() emits loading then error on ApiException
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-039: loadEvents emits loading → error on ApiException',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      when(() => mockRepo.getAllEvents())
          .thenThrow(ApiException(message: 'Network error', statusCode: 500));
      await cubit.loadEvents();
    },
    expect: () => [
      isA<EventListLoading>(),
      isA<EventListError>(),
    ],
  );

  // =========================================================================
  // TC-040: Events are correctly grouped into today / tomorrow / upcoming
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-040: _emitGrouped assigns events to correct date buckets',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      final now = DateTime.now();
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(
              id: 'today',
              startTime: DateTime(now.year, now.month, now.day, 20),
            ),
            _makeEvent(
              id: 'tomorrow',
              startTime: DateTime(now.year, now.month, now.day + 1, 20),
            ),
            _makeEvent(
              id: 'upcoming',
              startTime: DateTime(now.year, now.month, now.day + 5, 20),
            ),
          ]);
      await cubit.loadEvents();
    },
    expect: () => [isA<EventListLoading>(), isA<EventListLoaded>()],
    verify: (cubit) {
      final s = cubit.state as EventListLoaded;
      expect(s.todayEvents.map((e) => e.id), contains('today'));
      expect(s.tomorrowEvents.map((e) => e.id), contains('tomorrow'));
      expect(s.upcomingEvents.map((e) => e.id), contains('upcoming'));
      expect(s.todayEvents.length, 1);
      expect(s.tomorrowEvents.length, 1);
      expect(s.upcomingEvents.length, 1);
    },
  );

  // =========================================================================
  // TC-043: toggleFavorite() optimistically flips isFavorite in loaded state
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-043: toggleFavorite optimistically sets isFavorite to true',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      final now = DateTime.now();
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(
              id: '1',
              startTime: now.add(const Duration(hours: 1)),
              isFavorite: false,
            ),
          ]);
      when(() => mockRepo.toggleFavorite(any(), any()))
          .thenAnswer((_) async {});
      await cubit.loadEvents();
      await cubit.toggleFavorite('1');
    },
    skip: 2, // skip [loading, loaded] from loadEvents
    expect: () => [
      isA<EventListLoaded>().having(
        (s) => s.allEvents.first.isFavorite,
        'isFavorite',
        isTrue,
      ),
    ],
  );

  // =========================================================================
  // TC-125: toggleFavorite() does nothing when state is not EventListLoaded
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-125: toggleFavorite does nothing when state is not EventListLoaded',
    build: () => EventListCubit(mockRepo),
    // Seed with loading state (not loaded)
    seed: () => const EventListState.loading(),
    act: (cubit) async {
      await cubit.toggleFavorite('evt-1');
    },
    expect: () => <EventListState>[],
    verify: (_) {
      verifyNever(() => mockRepo.toggleFavorite(any(), any()));
    },
  );

  // =========================================================================
  // TC-126: _emitGrouped() excludes isPast=true events from date groups
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-126: _emitGrouped excludes past events from date groups but keeps them in allEvents',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      final now = DateTime.now();
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(
              id: 'past',
              startTime: now.subtract(const Duration(days: 2)),
              isPast: true,
            ),
            _makeEvent(
              id: 'future',
              startTime: now.add(const Duration(hours: 3)),
              isPast: false,
            ),
          ]);
      await cubit.loadEvents();
    },
    expect: () => [isA<EventListLoading>(), isA<EventListLoaded>()],
    verify: (cubit) {
      final s = cubit.state as EventListLoaded;
      expect(s.allEvents.length, equals(2),
          reason: 'allEvents should include past events');
      expect(s.allEvents.map((e) => e.id), containsAll(['past', 'future']));

      final groupedIds = [
        ...s.todayEvents,
        ...s.tomorrowEvents,
        ...s.upcomingEvents,
      ].map((e) => e.id).toList();
      expect(groupedIds, isNot(contains('past')),
          reason: 'Past event should not appear in any date group');
      expect(groupedIds, contains('future'));
    },
  );

  // =========================================================================
  // TC-173: loadEvents() emits EventListError (not crash) for ApiException
  //          with null statusCode
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-173: loadEvents emits EventListError when ApiException has null statusCode',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      when(() => mockRepo.getAllEvents())
          .thenThrow(ApiException(message: 'No internet', statusCode: null));
      await cubit.loadEvents();
    },
    expect: () => [
      isA<EventListLoading>(),
      isA<EventListError>(),
    ],
    verify: (cubit) {
      final errorState = cubit.state as EventListError;
      expect(errorState.message, isNotEmpty);
    },
  );

  // =========================================================================
  // TC-151: toggleFavorite() with non-existent ID preserves loaded state
  // =========================================================================

  test(
    'TC-151: toggleFavorite with non-existent ID preserves loaded state and emits to errorStream',
    () async {
      final cubit = EventListCubit(mockRepo);
      final now = DateTime.now();
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(id: '1', startTime: now.add(const Duration(hours: 1))),
          ]);

      await cubit.loadEvents();
      expect(cubit.state, isA<EventListLoaded>(),
          reason: 'Cubit should be in loaded state after loadEvents');

      final errors = <String>[];
      final sub = cubit.errorStream.listen(errors.add);

      // Toggle a non-existent ID — should NOT replace loaded state with error
      await cubit.toggleFavorite('999');

      expect(cubit.state, isA<EventListLoaded>(),
          reason: 'Loaded state must be preserved on toggleFavorite failure');
      expect(errors, isNotEmpty,
          reason: 'errorStream should receive a message on toggleFavorite failure');

      await sub.cancel();
      // Complete the constructor's blocked autoLoad before closing to avoid
      // "emit after close" errors from the pending future.
      if (!autoLoadBlocker.isCompleted) autoLoadBlocker.complete([]);
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
    },
  );

  // =========================================================================
  // TC-H08: loadEvents() emits EventListError on a non-ApiException (generic catch)
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-H08: loadEvents emits EventListError when repository throws a generic exception',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      when(() => mockRepo.getAllEvents())
          .thenThrow(Exception('unexpected'));
      await cubit.loadEvents();
    },
    expect: () => [
      isA<EventListLoading>(),
      isA<EventListError>(),
    ],
  );

  // =========================================================================
  // TC-MEDIUM-14: Error recovery — loadEvents() succeeds after toggleFavorite failure
  // =========================================================================

  test(
    'TC-MEDIUM-14: loadEvents recovers to EventListLoaded after toggleFavorite failure',
    () async {
      final cubit = EventListCubit(mockRepo);
      final now = DateTime.now();

      // Step 1: Load events successfully
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(id: '1', startTime: now.add(const Duration(hours: 1))),
          ]);
      await cubit.loadEvents();
      expect(cubit.state, isA<EventListLoaded>(),
          reason: 'Cubit should be loaded after initial loadEvents');

      // Step 2: Trigger toggleFavorite failure (non-existent ID)
      final errors = <String>[];
      final sub = cubit.errorStream.listen(errors.add);

      await cubit.toggleFavorite('non-existent-id');

      // Step 3: Verify loaded state is preserved (not replaced by error state)
      expect(cubit.state, isA<EventListLoaded>(),
          reason: 'Loaded state must be preserved after toggleFavorite failure');
      expect(errors, isNotEmpty,
          reason: 'errorStream should emit a message on failure');

      // Step 4: Call loadEvents again — cubit must recover to loaded state
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(id: '1', startTime: now.add(const Duration(hours: 1))),
            _makeEvent(id: '2', startTime: now.add(const Duration(hours: 2))),
          ]);
      await cubit.loadEvents();
      expect(cubit.state, isA<EventListLoaded>(),
          reason: 'Cubit should recover to EventListLoaded after loadEvents');
      final loaded = cubit.state as EventListLoaded;
      expect(loaded.allEvents.length, equals(2),
          reason: 'Recovered state should contain the newly loaded events');

      await sub.cancel();
      if (!autoLoadBlocker.isCompleted) autoLoadBlocker.complete([]);
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
    },
  );

  // =========================================================================
  // TC-094: Midnight boundary — event at 00:00:00 tomorrow goes to tomorrowEvents
  // =========================================================================

  blocTest<EventListCubit, EventListState>(
    'TC-094: event at midnight tomorrow is placed in tomorrowEvents',
    build: () => EventListCubit(mockRepo),
    seed: () => const EventListState.initial(),
    act: (cubit) async {
      final now = DateTime.now();
      // Exactly 00:00:00 on the next day
      final midnightTomorrow =
          DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
      when(() => mockRepo.getAllEvents()).thenAnswer((_) async => [
            _makeEvent(id: 'midnight', startTime: midnightTomorrow),
          ]);
      await cubit.loadEvents();
    },
    expect: () => [isA<EventListLoading>(), isA<EventListLoaded>()],
    verify: (cubit) {
      final s = cubit.state as EventListLoaded;
      expect(s.tomorrowEvents.map((e) => e.id), contains('midnight'),
          reason: 'Event at midnight tomorrow should be in tomorrowEvents');
      expect(s.todayEvents, isEmpty);
      expect(s.upcomingEvents, isEmpty);
    },
  );
}
