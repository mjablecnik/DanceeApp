// Task 5: Bug condition exploration test for Filter Visibility
//
// EXPECTED OUTCOME ON UNFIXED CODE: FAILS
// The test confirms the bug: EventsListScreen passes activeFilterCodes to
// FeaturedEventsSection and UpcomingEventsSection via
// context.read<FilterCubit>().state.selectedDanceStyles inside a
// BlocBuilder<EventCubit>. When FilterCubit emits a new state (e.g. after
// prefillFiltersFromProfile) but EventCubit does NOT re-emit, the
// BlocBuilder<EventCubit> doesn't rebuild — so the stale (empty) filter codes
// are passed to the child sections. The sections never see the updated state.
//
// Counterexample documented here:
//   FilterCubit.setDanceStyles({'salsa'}) is called (simulating login profile
//   prefill). EventCubit does not re-emit. BlocBuilder<EventCubit> does not
//   rebuild. FeaturedEventsSection.activeFilterCodes and
//   UpcomingEventsSection.activeFilterCodes remain {} instead of {'salsa'}.
//
// Requirements: 1.3, 2.3

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app/data/entities/course.dart';
import 'package:dancee_app/data/entities/dance_style.dart';
import 'package:dancee_app/data/entities/event.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/course_repository.dart';
import 'package:dancee_app/data/repositories/dance_style_repository.dart';
import 'package:dancee_app/data/repositories/event_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/i18n/strings.g.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/cubits/course_cubit.dart';
import 'package:dancee_app/logic/cubits/editor_mode_cubit.dart';
import 'package:dancee_app/logic/cubits/event_cubit.dart';
import 'package:dancee_app/logic/cubits/favorites_cubit.dart';
import 'package:dancee_app/logic/cubits/filter_cubit.dart';
import 'package:dancee_app/logic/cubits/settings_cubit.dart';
import 'package:dancee_app/logic/states/event_state.dart';
import 'package:dancee_app/logic/states/filter_state.dart';
import 'package:dancee_app/screens/events/events_list/events_list_screen.dart';
import 'package:dancee_app/screens/events/events_list/sections/featured_events_section.dart';
import 'package:dancee_app/screens/events/events_list/sections/upcoming_events_section.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  bool get isEmailProvider => false;

  @override
  Future<void> ensureDirectusLinked() async {}

  void emitUser(User? user) => _controller.add(user);

  Future<void> dispose() => _controller.close();
}

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

class _FakeEventRepository extends Fake implements EventRepository {
  @override
  Future<List<Event>> getEvents(String languageCode) async => [];
}

class _FakeDanceStyleRepository extends Fake implements DanceStyleRepository {
  @override
  Future<List<DanceStyle>> getDanceStyles(String languageCode) async => [];
}

class _FakeCourseRepository extends Fake implements CourseRepository {
  @override
  Future<List<Course>> getCourses(String languageCode) async => [];
}

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

/// EventCubit that starts with a fixed loaded state and ignores applyFilters.
/// This simulates the scenario where EventCubit does not re-emit when
/// FilterCubit changes (e.g. no BlocListener<FilterCubit> wired up in test,
/// or applyFilters produces no state change). This ensures BlocBuilder<EventCubit>
/// does NOT rebuild when FilterCubit changes — which is the bug condition.
class _StubEventCubit extends EventCubit {
  _StubEventCubit({required List<Event> events})
      : super(eventRepository: _FakeEventRepository()) {
    emit(EventState.loaded(
      allEvents: events,
      filteredEvents: events,
      featuredEvents:
          events.where((e) => e.eventType == 'festival').toList(),
    ));
  }

  @override
  void applyFilters(FilterState filters, List<DanceStyle> allDanceStyles) {
    // Intentionally a no-op: simulates that EventCubit does not re-emit
    // when FilterCubit changes. This ensures BlocBuilder<EventCubit> doesn't
    // rebuild and exposes the stale activeFilterCodes bug.
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Event _makeEvent({
  required int id,
  required String title,
  required String eventType,
  List<String> dances = const [],
}) {
  return Event(
    id: id,
    title: title,
    description: '',
    startTime: DateTime(2026, 6, 15, 20, 0),
    organizer: 'Test Organizer',
    dances: dances,
    eventType: eventType,
    info: const [],
    parts: const [],
    isFavorited: false,
  );
}

GoRouter _buildRouter({
  required FilterCubit filterCubit,
  required EventCubit eventCubit,
  required AuthCubit authCubit,
  required FavoritesCubit favoritesCubit,
  required SettingsCubit settingsCubit,
  required CourseCubit courseCubit,
}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<FilterCubit>.value(value: filterCubit),
            BlocProvider<EventCubit>.value(value: eventCubit),
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<CourseCubit>.value(value: courseCubit),
            BlocProvider<EditorModeCubit>(create: (_) => EditorModeCubit()),
          ],
          child: const Scaffold(body: EventsListScreen()),
        ),
      ),
      GoRoute(
          path: '/events/filter-location',
          builder: (_, __) => const Scaffold()),
      GoRoute(
          path: '/events/filter-dance',
          builder: (_, __) => const Scaffold()),
      GoRoute(
          path: '/events/detail', builder: (_, __) => const Scaffold()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group(
    'Task 5 — Bug Condition: Filter codes not updated in event sections when only FilterCubit changes',
    () {
      late _FakeAuthRepository fakeAuthRepo;
      late AuthCubit authCubit;
      late FavoritesCubit favoritesCubit;
      late FilterCubit filterCubit;
      late _StubEventCubit eventCubit;
      late CourseCubit courseCubit;
      late SettingsCubit settingsCubit;

      final testEvents = [
        _makeEvent(
          id: 1,
          title: 'Salsa Festival',
          eventType: 'festival',
          dances: ['salsa'],
        ),
        _makeEvent(
          id: 2,
          title: 'Salsa Party',
          eventType: 'party',
          dances: ['salsa'],
        ),
      ];

      setUp(() {
        fakeAuthRepo = _FakeAuthRepository();
        authCubit = AuthCubit(
          authRepository: fakeAuthRepo,
          favoritesRepository: _FakeFavoritesRepository(),
        );
        favoritesCubit = FavoritesCubit(
          favoritesRepository: _FakeFavoritesRepository(),
          authCubit: authCubit,
        );
        filterCubit =
            FilterCubit(danceStyleRepository: _FakeDanceStyleRepository());
        eventCubit = _StubEventCubit(events: testEvents);
        courseCubit = CourseCubit(
          courseRepository: _FakeCourseRepository(),
        );
        settingsCubit = SettingsCubit();
      });

      tearDown(() async {
        await eventCubit.close();
        await filterCubit.close();
        await favoritesCubit.close();
        await authCubit.close();
        await courseCubit.close();
        await settingsCubit.close();
        await fakeAuthRepo.dispose();
      });

      // -----------------------------------------------------------------------
      // Property 1: Bug Condition
      // isBugCondition3(input) where:
      //   input.authTransition = (unauthenticated → authenticated)
      //   input.profileHasFilterPreferences = true
      //   input.filterCubit.hasActiveFilters = false (before prefill)
      //
      // In the test: FilterCubit emits selectedDanceStyles = {'salsa'} but
      // EventCubit does NOT re-emit → BlocBuilder<EventCubit> doesn't rebuild.
      //
      // EXPECTED OUTCOME ON UNFIXED CODE: FAILS
      // Reason: FeaturedEventsSection receives activeFilterCodes from
      // context.read<FilterCubit>().state.selectedDanceStyles inside
      // BlocBuilder<EventCubit>. When only FilterCubit changes, EventCubit
      // doesn't re-emit, so BlocBuilder<EventCubit> doesn't rebuild, so the
      // stale empty set is still passed to FeaturedEventsSection.
      // -----------------------------------------------------------------------
      testWidgets(
        'FAILS_ON_UNFIXED: FeaturedEventsSection receives updated activeFilterCodes when FilterCubit emits new state',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: _buildRouter(
                filterCubit: filterCubit,
                eventCubit: eventCubit,
                authCubit: authCubit,
                favoritesCubit: favoritesCubit,
                settingsCubit: settingsCubit,
                courseCubit: courseCubit,
              ),
            ),
          );
          await tester.pump();

          // Verify FeaturedEventsSection is rendered with initial empty filter codes.
          expect(
            find.byType(FeaturedEventsSection),
            findsOneWidget,
            reason: 'FeaturedEventsSection must be visible (festival event present)',
          );
          final initialSection = tester.widget<FeaturedEventsSection>(
            find.byType(FeaturedEventsSection),
          );
          expect(
            initialSection.activeFilterCodes,
            isEmpty,
            reason: 'Initial activeFilterCodes should be empty before prefill',
          );

          // Simulate prefillFiltersFromProfile: update FilterCubit state to
          // {'salsa'} without causing EventCubit to re-emit.
          // (In the real bug, BlocListener<FilterCubit> calls applyFilters, but
          // here we bypass that to isolate the bug: EventCubit.applyFilters is a
          // no-op in the stub, so BlocBuilder<EventCubit> will NOT rebuild.)
          filterCubit.setDanceStyles({'salsa'});
          await tester.pump();

          // Expected behavior (post-fix): FeaturedEventsSection is wrapped in a
          // BlocBuilder<FilterCubit, FilterState> and rebuilds with updated
          // activeFilterCodes = {'salsa'}.
          //
          // Bug (pre-fix): FeaturedEventsSection is inside BlocBuilder<EventCubit>
          // and receives activeFilterCodes from context.read<FilterCubit>(). Since
          // EventCubit didn't re-emit, BlocBuilder<EventCubit> didn't rebuild, so
          // context.read<FilterCubit>().state.selectedDanceStyles was never
          // re-evaluated — stale empty set still passed to the widget.
          final updatedSection = tester.widget<FeaturedEventsSection>(
            find.byType(FeaturedEventsSection),
          );
          expect(
            updatedSection.activeFilterCodes,
            equals({'salsa'}),
            reason:
                'Counterexample: FeaturedEventsSection.activeFilterCodes is still '
                '{} after FilterCubit emitted selectedDanceStyles = {salsa}. '
                'Bug: context.read<FilterCubit>().state.selectedDanceStyles inside '
                'BlocBuilder<EventCubit> is not re-evaluated when only FilterCubit '
                'changes — stale value passed to child section.',
          );
        },
      );

      testWidgets(
        'FAILS_ON_UNFIXED: UpcomingEventsSection receives updated activeFilterCodes when FilterCubit emits new state',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: _buildRouter(
                filterCubit: filterCubit,
                eventCubit: eventCubit,
                authCubit: authCubit,
                favoritesCubit: favoritesCubit,
                settingsCubit: settingsCubit,
                courseCubit: courseCubit,
              ),
            ),
          );
          await tester.pump();

          // Verify UpcomingEventsSection is rendered with initial empty filter codes.
          expect(
            find.byType(UpcomingEventsSection),
            findsOneWidget,
            reason: 'UpcomingEventsSection must be visible',
          );
          final initialSection = tester.widget<UpcomingEventsSection>(
            find.byType(UpcomingEventsSection),
          );
          expect(
            initialSection.activeFilterCodes,
            isEmpty,
            reason: 'Initial activeFilterCodes should be empty before prefill',
          );
          expect(
            initialSection.hasActiveFilters,
            isFalse,
            reason: 'Initial hasActiveFilters should be false before prefill',
          );

          // Simulate prefillFiltersFromProfile.
          filterCubit.setDanceStyles({'salsa'});
          await tester.pump();

          // Expected behavior (post-fix): UpcomingEventsSection rebuilds with
          // activeFilterCodes = {'salsa'} and hasActiveFilters = true.
          //
          // Bug (pre-fix): Stale empty activeFilterCodes and hasActiveFilters = false
          // because BlocBuilder<EventCubit> didn't rebuild when FilterCubit changed.
          final updatedSection = tester.widget<UpcomingEventsSection>(
            find.byType(UpcomingEventsSection),
          );
          expect(
            updatedSection.activeFilterCodes,
            equals({'salsa'}),
            reason:
                'Counterexample: UpcomingEventsSection.activeFilterCodes is still '
                '{} after FilterCubit emitted selectedDanceStyles = {salsa}. '
                'Bug: context.read<FilterCubit>().state.selectedDanceStyles is '
                'captured at BlocBuilder<EventCubit> build time, not subscribed to '
                'FilterCubit — stale value when only FilterCubit emits.',
          );
          expect(
            updatedSection.hasActiveFilters,
            isTrue,
            reason:
                'Counterexample: UpcomingEventsSection.hasActiveFilters is still '
                'false after FilterCubit emitted hasActiveFilters = true. '
                'Bug: context.read<FilterCubit>().state.hasActiveFilters is not '
                're-evaluated when BlocBuilder<EventCubit> does not rebuild.',
          );
        },
      );
    },
  );
}
