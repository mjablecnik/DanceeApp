import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/design/widgets.dart';
import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/features/events/pages/event_list/components.dart';
import 'package:dancee_app/features/events/pages/favorites_page.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockEventListCubit extends Mock implements EventListCubit {}

/// Seedable FavoritesCubit: overrides loadFavorites() so initState() doesn't
/// change state during widget tests. Exposes seed() to force any state.
class _SeedableFavoritesCubit extends FavoritesCubit {
  _SeedableFavoritesCubit(super.repo, super.eventListCubit);

  void seed(FavoritesState state) => emit(state);

  @override
  Future<void> loadFavorites() async {}

  @override
  Future<void> toggleFavorite(String eventId) async {}

  @override
  Future<void> removePastEvent(String eventId) async {}
}

Widget _wrap(Widget child) {
  return TranslationProvider(
    child: MaterialApp(
      home: child,
    ),
  );
}

Event _makeEvent({
  required String id,
  required String title,
  bool isPast = false,
  bool isFavorite = true,
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
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      ),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    ),
    startTime: isPast
        ? now.subtract(const Duration(days: 2))
        : now.add(const Duration(days: 5)),
    endTime: isPast
        ? now.subtract(const Duration(days: 1))
        : now.add(const Duration(days: 5, hours: 4)),
    dances: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}

void main() {
  late MockEventRepository mockRepo;
  late _SeedableFavoritesCubit favoritesCubit;
  late MockEventListCubit mockListCubit;

  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() {
    mockRepo = MockEventRepository();
    mockListCubit = MockEventListCubit();
    favoritesCubit = _SeedableFavoritesCubit(mockRepo, mockListCubit);

    when(() => mockListCubit.state)
        .thenReturn(const EventListState.initial());
    when(() => mockListCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockListCubit.isClosed).thenReturn(false);

    getIt.allowReassignment = true;
    getIt.registerSingleton<FavoritesCubit>(favoritesCubit);
    getIt.registerSingleton<EventListCubit>(mockListCubit);
  });

  tearDown(() async {
    await favoritesCubit.close();
    if (getIt.isRegistered<FavoritesCubit>()) {
      getIt.unregister<FavoritesCubit>();
    }
    if (getIt.isRegistered<EventListCubit>()) {
      getIt.unregister<EventListCubit>();
    }
  });

  // =========================================================================
  // TC-156: FavoritesPage renders FavoritesEmptySection when both lists are empty
  // =========================================================================

  testWidgets(
    'TC-156: renders FavoritesEmptySection when both upcoming and past lists are empty',
    (tester) async {
      favoritesCubit.seed(const FavoritesState.loaded(
        upcomingEvents: [],
        pastEvents: [],
      ));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      expect(find.byType(FavoritesEmptySection), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-157: FavoritesPage renders error message and retry button in error state
  // =========================================================================

  testWidgets(
    'TC-157: renders error message and retry button in FavoritesError state',
    (tester) async {
      favoritesCubit.seed(const FavoritesState.error('Network error'));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byType(AppErrorMessage), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-079: Renders loading state correctly
  // =========================================================================

  testWidgets('TC-079: renders AppLoadingIndicator in loading state',
      (tester) async {
    favoritesCubit.seed(const FavoritesState.loading());

    await tester.pumpWidget(_wrap(const FavoritesPage()));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });

  // =========================================================================
  // TC-080: Renders both upcoming and past favorites sections
  // =========================================================================

  testWidgets(
    'TC-080: renders both upcoming and past event sections with event titles',
    (tester) async {
      // Use 1 upcoming + 1 past so both are visible without scrolling
      final upcomingEvent =
          _makeEvent(id: '1', title: 'Salsa Night', isPast: false);
      final pastEvent =
          _makeEvent(id: '2', title: 'Old Tango Night', isPast: true);

      favoritesCubit.seed(FavoritesState.loaded(
        upcomingEvents: [upcomingEvent],
        pastEvents: [pastEvent],
      ));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      // Scroll to the bottom to ensure all cards are rendered
      await tester.dragUntilVisible(
        find.text('Old Tango Night'),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      expect(find.text('Salsa Night'), findsOneWidget);
      expect(find.text('Old Tango Night'), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-M14: FavoritesPage header renders the total saved-event count
  // =========================================================================

  testWidgets(
    'TC-M14: header renders total saved-event count (2 upcoming + 1 past = 3)',
    (tester) async {
      favoritesCubit.seed(FavoritesState.loaded(
        upcomingEvents: [
          _makeEvent(id: '1', title: 'Event A', isPast: false),
          _makeEvent(id: '2', title: 'Event B', isPast: false),
        ],
        pastEvents: [
          _makeEvent(id: '3', title: 'Event C', isPast: true),
        ],
      ));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      expect(find.text('3 saved events'), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-M15: FavoritesPage filter section renders at least the "All" filter chip
  // =========================================================================

  testWidgets(
    'TC-M15: filter section renders the "All" filter chip',
    (tester) async {
      favoritesCubit.seed(FavoritesState.loaded(
        upcomingEvents: [_makeEvent(id: '1', title: 'Event A')],
        pastEvents: const [],
      ));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-L07: FavoritesPage empty state renders a BrowseEventsButton
  // =========================================================================

  testWidgets(
    'TC-L07: empty state renders BrowseEventsButton',
    (tester) async {
      favoritesCubit.seed(const FavoritesState.loaded(
        upcomingEvents: [],
        pastEvents: [],
      ));

      await tester.pumpWidget(_wrap(const FavoritesPage()));
      await tester.pump();

      expect(find.byType(BrowseEventsButton), findsOneWidget);
    },
  );

  // =========================================================================
  // TC-L08: FavoritesFilterChip — selected shows check icon; unselected does not
  // =========================================================================

  testWidgets(
    'TC-L08: selected FavoritesFilterChip shows check icon; unselected does not',
    (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: const [
                  FavoritesFilterChip(label: 'All', isSelected: true),
                  FavoritesFilterChip(label: 'Today', isSelected: false),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget,
          reason: 'Only the selected chip should show a check icon');
    },
  );
}
