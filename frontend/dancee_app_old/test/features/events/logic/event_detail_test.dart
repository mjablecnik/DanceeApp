import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockEventRepository extends Mock implements EventRepository {}

// Helper to create an event with minimal required fields
Event _makeEvent({
  required String id,
  String title = 'Test Event',
  bool isFavorite = false,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: title,
    description: '',
    organizer: '',
    venue: const Venue(
      name: 'Test Venue',
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
    startTime: now.add(const Duration(hours: 1)),
    dances: const [],
    isFavorite: isFavorite,
  );
}

/// Extends EventListCubit to expose emit() for seeding state in tests.
class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  /// Override to be a no-op so the constructor doesn't trigger a real load.
  @override
  Future<void> loadEvents() async {}

  @override
  Future<void> toggleFavorite(String eventId) async {}
}

void main() {
  late MockEventRepository mockRepo;
  late _SeedableEventListCubit listCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    listCubit = _SeedableEventListCubit(mockRepo);
  });

  tearDown(() async {
    await listCubit.close();
  });

  // =========================================================================
  // TC-H10: EventDetailCubit emits null when EventListCubit is in loading state
  // =========================================================================

  test('TC-H10: EventDetailCubit state is null when EventListCubit is loading', () {
    listCubit.seed(const EventListState.loading());

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '5',
    );

    expect(detailCubit.state, isNull);
    detailCubit.close();
  });

  // =========================================================================
  // TC-046: EventDetailCubit emits correct event from EventListCubit state
  // =========================================================================

  test('TC-046: emits event matching eventId from loaded EventListCubit', () {
    final event5 = _makeEvent(id: '5', title: 'Salsa Night');
    final event6 = _makeEvent(id: '6', title: 'Tango Evening');

    listCubit.seed(EventListState.loaded(
      allEvents: [event5, event6],
      todayEvents: [],
      tomorrowEvents: [event5],
      upcomingEvents: [event6],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '5',
    );

    expect(detailCubit.state, equals(event5));
    detailCubit.close();
  });

  // =========================================================================
  // TC-047: EventDetailCubit emits null when event ID does not exist
  // =========================================================================

  test('TC-047: emits null when eventId not found in loaded EventListCubit', () {
    final event1 = _makeEvent(id: '1');
    final event2 = _makeEvent(id: '2');

    listCubit.seed(EventListState.loaded(
      allEvents: [event1, event2],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event1, event2],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '999',
    );

    expect(detailCubit.state, isNull);
    detailCubit.close();
  });

  // =========================================================================
  // TC-048: EventDetailCubit reacts to EventListCubit stream updates
  // =========================================================================

  test('TC-048: updates state when EventListCubit emits a new loaded state', () async {
    final event5 = _makeEvent(id: '5', isFavorite: false);

    listCubit.seed(EventListState.loaded(
      allEvents: [event5],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event5],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '5',
    );

    expect(detailCubit.state?.isFavorite, isFalse);

    // Simulate EventListCubit toggling the favorite on event "5"
    final updatedEvent5 = event5.copyWith(isFavorite: true);
    listCubit.seed(EventListState.loaded(
      allEvents: [updatedEvent5],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [updatedEvent5],
    ));

    // Allow stream listener to fire
    await Future<void>.delayed(Duration.zero);

    expect(detailCubit.state?.isFavorite, isTrue);
    await detailCubit.close();
  });

  // =========================================================================
  // TC-049: toggleFavorite() delegates to EventListCubit
  // =========================================================================

  test('TC-049: toggleFavorite delegates to EventListCubit.toggleFavorite()', () async {
    // Use a mock cubit so we can verify the delegation
    final mockListCubit = _MockEventListCubit();
    when(() => mockListCubit.state)
        .thenReturn(const EventListState.initial());
    when(() => mockListCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockListCubit.toggleFavorite(any()))
        .thenAnswer((_) async {});
    when(() => mockListCubit.isClosed).thenReturn(false);

    final detailCubit = EventDetailCubit(
      eventListCubit: mockListCubit,
      eventId: '42',
    );

    await detailCubit.toggleFavorite();

    verify(() => mockListCubit.toggleFavorite('42')).called(1);
    await detailCubit.close();
  });

  // =========================================================================
  // TC-050: openMap() launches Google Maps URL with venue coordinates
  // =========================================================================

  test('TC-050: openMap launches Google Maps URL containing venue coordinates',
      () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    const venue = Venue(
      name: 'Test Venue',
      address: Address(street: 'St', city: 'Prague', postalCode: '100', country: 'CZ'),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    );

    await detailCubit.openMap(venue);

    expect(fakePlatform.launchedUrls, isNotEmpty);
    expect(fakePlatform.launchedUrls.first, contains('50.08'));
    expect(fakePlatform.launchedUrls.first, contains('14.43'));

    await detailCubit.close();
  });

  // =========================================================================
  // TC-051: openUrl() calls url_launcher with the given URL
  // =========================================================================

  test('TC-051: openUrl calls url_launcher with the provided URI', () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    await detailCubit.openUrl('https://example.com/event');

    expect(fakePlatform.launchedUrls, contains('https://example.com/event'));

    await detailCubit.close();
  });

  // =========================================================================
  // TC-089 (Integration): EventDetailCubit reflects favorite toggle via
  //         EventListCubit
  // =========================================================================

  test(
    'TC-089: EventDetailCubit isFavorite reflects toggle from EventListCubit',
    () async {
      final event = _makeEvent(id: '7', isFavorite: false);

      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      final detailCubit = EventDetailCubit(
        eventListCubit: listCubit,
        eventId: '7',
      );

      expect(detailCubit.state?.isFavorite, isFalse);

      // Simulate what EventListCubit does when toggling favorite
      final toggled = event.copyWith(isFavorite: true);
      listCubit.seed(EventListState.loaded(
        allEvents: [toggled],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [toggled],
      ));

      await Future<void>.delayed(Duration.zero);

      expect(detailCubit.state?.isFavorite, isTrue,
          reason: 'EventDetailCubit should reflect the toggled favourite');
      await detailCubit.close();
    },
  );
  // =========================================================================
  // TC-130: openMap() constructs correct Google Maps URL with venue coordinates
  // =========================================================================

  test('TC-130: openMap launches exact Google Maps destination URL', () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    const venue = Venue(
      name: 'Studio Tango',
      address: Address(
          street: 'Wenceslas 42', city: 'Prague', postalCode: '11000', country: 'CZ'),
      description: '',
      latitude: 50.0755,
      longitude: 14.4378,
    );

    await detailCubit.openMap(venue);

    expect(fakePlatform.launchedUrls, isNotEmpty);
    expect(
      fakePlatform.launchedUrls.first,
      equals('https://www.google.com/maps/dir/?api=1&destination=50.0755,14.4378'),
    );

    await detailCubit.close();
  });

  // =========================================================================
  // TC-131: openMap() does not throw when venue has zero/missing coordinates
  // =========================================================================

  test('TC-131: openMap does not throw when venue has zero coordinates', () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    // Venue with 0.0 coordinates (fallback for missing lat/lon in JSON)
    const venue = Venue(
      name: 'Unknown Venue',
      address: Address(street: '', city: '', postalCode: '', country: ''),
      description: '',
      latitude: 0.0,
      longitude: 0.0,
    );

    // Should complete without throwing
    await expectLater(detailCubit.openMap(venue), completes);

    await detailCubit.close();
  });

  // =========================================================================
  // TC-L11: openUrl() with an empty string does not throw
  // =========================================================================

  test('TC-L11: openUrl with empty string does not throw', () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    await expectLater(detailCubit.openUrl(''), completes);

    await detailCubit.close();
  });

  // =========================================================================
  // TC-L11b: openUrl() with a malformed URL does not throw
  // =========================================================================

  test('TC-L11b: openUrl with malformed URL does not throw', () async {
    final fakePlatform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakePlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    await expectLater(detailCubit.openUrl('not a url'), completes);

    await detailCubit.close();
  });

  // =========================================================================
  // TC-H11: openUrl() emits to errorStream when URL launch throws
  // =========================================================================

  test('TC-H11: openUrl emits error message to errorStream when launch fails',
      () async {
    final throwingPlatform = _ThrowingUrlLauncherPlatform();
    UrlLauncherPlatform.instance = throwingPlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    final errors = <String>[];
    final sub = detailCubit.errorStream.listen(errors.add);

    await detailCubit.openUrl('https://example.com/event');
    // Yield to the event loop so the broadcast stream delivers the event.
    await Future<void>.delayed(Duration.zero);

    expect(errors, isNotEmpty,
        reason: 'errorStream should emit when URL launch fails');

    await sub.cancel();
    await detailCubit.close();
  });

  // =========================================================================
  // TC-H12: openMap() emits to errorStream when map launch throws
  // =========================================================================

  test('TC-H12: openMap emits error message to errorStream when launch fails',
      () async {
    final throwingPlatform = _ThrowingUrlLauncherPlatform();
    UrlLauncherPlatform.instance = throwingPlatform;

    final event = _makeEvent(id: '1');
    listCubit.seed(EventListState.loaded(
      allEvents: [event],
      todayEvents: [],
      tomorrowEvents: [],
      upcomingEvents: [event],
    ));

    final detailCubit = EventDetailCubit(
      eventListCubit: listCubit,
      eventId: '1',
    );

    const venue = Venue(
      name: 'Test Venue',
      address: Address(street: 'St', city: 'Prague', postalCode: '100', country: 'CZ'),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    );

    final errors = <String>[];
    final sub = detailCubit.errorStream.listen(errors.add);

    await detailCubit.openMap(venue);
    // Yield to the event loop so the broadcast stream delivers the event.
    await Future<void>.delayed(Duration.zero);

    expect(errors, isNotEmpty,
        reason: 'errorStream should emit when map launch fails');

    await sub.cancel();
    await detailCubit.close();
  });

  // =========================================================================
  // TC-129: close() cancels the EventListCubit stream subscription
  // =========================================================================

  test(
    'TC-129: after close(), EventListCubit state changes do not cause errors',
    () async {
      final event = _makeEvent(id: '10');
      listCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: [],
        tomorrowEvents: [],
        upcomingEvents: [event],
      ));

      final detailCubit = EventDetailCubit(
        eventListCubit: listCubit,
        eventId: '10',
      );

      expect(detailCubit.state, equals(event));

      // Close the detail cubit — should cancel the stream subscription
      await detailCubit.close();

      // Emit a new state from listCubit; should not cause any errors
      expect(
        () {
          final updatedEvent = event.copyWith(isFavorite: true);
          listCubit.seed(EventListState.loaded(
            allEvents: [updatedEvent],
            todayEvents: [],
            tomorrowEvents: [],
            upcomingEvents: [updatedEvent],
          ));
        },
        returnsNormally,
        reason: 'No error should occur after detailCubit is closed',
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Mock for EventListCubit (needed for TC-049)
// ---------------------------------------------------------------------------
class _MockEventListCubit extends Mock implements EventListCubit {}

// ---------------------------------------------------------------------------
// Fake UrlLauncherPlatform for TC-050, TC-051
// ---------------------------------------------------------------------------
class _FakeUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => false;
}

// ---------------------------------------------------------------------------
// Throwing UrlLauncherPlatform for TC-H11, TC-H12 (error path tests)
// ---------------------------------------------------------------------------
class _ThrowingUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    throw Exception('URL launch failed in test');
  }

  @override
  Future<bool> canLaunch(String url) async => true;

  /// Return true so url_launcher proceeds to call launchUrl (which throws).
  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => false;
}
