import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/data/filter_persistence_service.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/pages/event_filters/event_filters_page.dart';
import 'package:dancee_app/features/events/pages/event_filters/components.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

class _NoOpFilterPersistenceService extends FilterPersistenceService {
  @override
  Future<FilterState?> loadFilters() async => null;

  @override
  Future<void> saveFilters(FilterState filters) async {}

  @override
  Future<void> clearFilters() async {}
}

class _SeedableEventListCubit extends EventListCubit {
  _SeedableEventListCubit(super.repo);

  void seed(EventListState state) => emit(state);

  @override
  Future<void> loadEvents() async {}
}

Event _makeEvent({required String id, required List<String> dances}) {
  return Event(
    id: id,
    title: 'Test Event $id',
    description: '',
    organizer: '',
    venue: const Venue(
      name: 'Test Club',
      address: Address(
        street: 'Test St 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 50.0,
      longitude: 14.0,
    ),
    startTime: DateTime(2027, 6, 1, 20, 0),
    dances: dances,
  );
}

void main() {
  late _SeedableEventListCubit eventListCubit;
  late EventFilterCubit filterCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    final mockRepo = MockEventRepository();
    eventListCubit = _SeedableEventListCubit(mockRepo);
    filterCubit = EventFilterCubit(eventListCubit, _NoOpFilterPersistenceService());
    getIt.allowReassignment = true;
    getIt.registerSingleton<EventListCubit>(eventListCubit);
    getIt.registerSingleton<EventFilterCubit>(filterCubit);
  });

  tearDown(() async {
    await filterCubit.close();
    await eventListCubit.close();
    if (getIt.isRegistered<EventFilterCubit>()) {
      getIt.unregister<EventFilterCubit>();
    }
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  // =========================================================================
  // TC-160: EventFiltersPage mounts without error (smoke test)
  // =========================================================================

  testWidgets('TC-160: EventFiltersPage mounts without error', (tester) async {
    // EventFiltersPage uses context.pop() in its back button, so it needs
    // a GoRouter context.
    final router = GoRouter(
      initialLocation: '/events/filters',
      routes: [
        GoRoute(
          path: '/events',
          builder: (_, __) => const Scaffold(body: Text('Events')),
          routes: [
            GoRoute(
              path: 'filters',
              builder: (_, __) => const EventFiltersPage(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EventFiltersPage), findsOneWidget);
  });

  // =========================================================================
  // Task 69: EventFiltersPage renders at least one dance-type option chip/tile
  // =========================================================================

  testWidgets(
    'TC-T69: EventFiltersPage renders at least one DanceTypeOption below the dance section header',
    (tester) async {
      // Seed events with dance types so that DanceTypeOption widgets are rendered.
      final event = _makeEvent(id: '1', dances: ['Salsa', 'Bachata']);
      eventListCubit.seed(EventListState.loaded(
        allEvents: [event],
        todayEvents: const [],
        tomorrowEvents: const [],
        upcomingEvents: [event],
      ));

      final router = GoRouter(
        initialLocation: '/events/filters',
        routes: [
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (_, __) => const EventFiltersPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DanceTypeOption), findsWidgets);
    },
  );

  // =========================================================================
  // TC-M11: EventFiltersPage back button navigates away from the filters page
  // =========================================================================

  testWidgets(
    'TC-M11: Tapping the back button pops the filters page and shows Events',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/events/filters',
        routes: [
          GoRoute(
            path: '/events',
            builder: (_, __) => const Scaffold(body: Text('Events')),
            routes: [
              GoRoute(
                path: 'filters',
                builder: (_, __) => const EventFiltersPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EventFiltersPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(EventFiltersPage), findsNothing);
      expect(find.text('Events'), findsOneWidget);
    },
  );
}
