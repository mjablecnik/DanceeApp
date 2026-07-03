// Task 6: Preservation property tests for Filter UI (BEFORE implementing fix)
//
// EXPECTED OUTCOME ON UNFIXED AND FIXED CODE: PASSES
// These tests document behaviors that already work correctly and MUST continue
// to work after the Bug 3 fix (task 9).
//
// Properties verified:
//   Property 6a: Manual Filter Application Unchanged
//     FilterCubit.toggleDanceType() immediately updates the cubit's state, and
//     EventCubit.applyFilters() immediately reflects the new filter in the
//     filtered events list. The filter CHIP UI (DanceStylesFilterSection) is
//     reactive via its own BlocBuilder<FilterCubit> and always reflects the
//     current selection without a fix.
//
//     NOTE on scope: Bug 3 concerns the event-card dance-style tag highlighting
//     (activeFilterCodes on FeaturedEventsSection / UpcomingEventsSection). This
//     tag highlighting is stale on unfixed code because those sections are inside
//     BlocBuilder<EventCubit> and use context.read<FilterCubit>() which is not
//     re-evaluated when FilterCubit alone emits. However, this staleness affects
//     ALL paths that change FilterCubit (manual toggle AND login prefill) — it
//     is NOT unique to the login-prefill path. The correct observation is that
//     manual toggle already updates the FILTER CHIP UI and the EVENTS LIST
//     (EventCubit.state), which these tests verify at the cubit level.
//
//   Property 6b: No Active Filters After Login Without Preferences
//     When a user logs in without saved dance style preferences (FilterCubit
//     stays empty), FeaturedEventsSection and UpcomingEventsSection show no
//     active filter codes. This is correct on both unfixed and fixed code
//     because FilterCubit.selectedDanceStyles = {} at every BlocBuilder<EventCubit>
//     build time — no stale-read issue when the value is always {}.
//
// Requirements: 3.3, 3.4

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app/data/entities/dance_style.dart';
import 'package:dancee_app/data/entities/event.dart';
import 'package:dancee_app/data/entities/course.dart';
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

class _FakeDanceStyleRepository extends Fake implements DanceStyleRepository {
  @override
  Future<List<DanceStyle>> getDanceStyles(String languageCode) async => [];
}

/// EventRepository returning a fixed, pre-set list of events.
class _PresetEventRepository extends Fake implements EventRepository {
  _PresetEventRepository({required this.events});
  final List<Event> events;

  @override
  Future<List<Event>> getEvents(String languageCode) async => events;
}

class _FakeCourseRepository extends Fake implements CourseRepository {
  @override
  Future<List<Course>> getCourses(String languageCode) async => [];
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
      GoRoute(path: '/events/detail', builder: (_, __) => const Scaffold()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Test data: events with salsa and bachata styles so that applying the salsa
// filter produces a different EventCubit.state (fewer filteredEvents), and
// applying no filter shows all events.
// ---------------------------------------------------------------------------

final _mixedEvents = [
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
  _makeEvent(
    id: 3,
    title: 'Bachata Festival',
    eventType: 'festival',
    dances: ['bachata'],
  ),
  _makeEvent(
    id: 4,
    title: 'Bachata Party',
    eventType: 'party',
    dances: ['bachata'],
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  // =========================================================================
  // Property 6a: Manual Filter Application Unchanged
  //
  // These tests operate at the CUBIT level, not the widget level, because the
  // widget-level activeFilterCodes behavior on FeaturedEventsSection and
  // UpcomingEventsSection is affected by Bug 3 on ALL filter-change paths
  // (not only the login-prefill path). The cubit behavior — the filter state
  // itself and the filtered event list — is correctly updated on manual toggle
  // and is unaffected by the fix.
  //
  // EXPECTED OUTCOME ON UNFIXED CODE: PASSES
  // EXPECTED OUTCOME ON FIXED CODE: PASSES (no regression)
  // =========================================================================
  group(
    'Task 6 — Preservation 6a: FilterCubit toggleDanceType and EventCubit filtering work correctly',
    () {
      late FilterCubit filterCubit;
      late EventCubit eventCubit;

      setUp(() async {
        filterCubit =
            FilterCubit(danceStyleRepository: _FakeDanceStyleRepository());
        eventCubit = EventCubit(
          eventRepository: _PresetEventRepository(events: _mixedEvents),
        );
        // Pre-populate _allEvents so applyFilters can call _recompute().
        await eventCubit.loadEvents('en');
      });

      tearDown(() async {
        await filterCubit.close();
        await eventCubit.close();
      });

      // -----------------------------------------------------------------------
      // 6a-1: FilterCubit state is immediately updated on toggleDanceType
      //
      // Observation: The filter chip UI (DanceStylesFilterSection) uses a
      // BlocBuilder<FilterCubit> and immediately reflects the new selection.
      // This works on both unfixed and fixed code because the chip UI is already
      // inside a reactive BlocBuilder. These tests verify the underlying cubit
      // state that drives the chip UI.
      // -----------------------------------------------------------------------
      group('FilterCubit.toggleDanceType immediately updates selectedDanceStyles', () {
        test(
          'toggleDanceType adds a code when not previously selected',
          () {
            expect(
              filterCubit.state.selectedDanceStyles,
              isEmpty,
              reason: 'selectedDanceStyles must be empty before any toggle',
            );

            filterCubit.toggleDanceType('salsa');

            expect(
              filterCubit.state.selectedDanceStyles,
              equals({'salsa'}),
              reason:
                  'Preservation 6a: FilterCubit.toggleDanceType must immediately '
                  'add the code to selectedDanceStyles. This is the state that '
                  'drives both the filter chip UI and EventCubit.applyFilters. '
                  'Must continue to work after Bug 3 fix.',
            );
          },
        );

        test(
          'toggleDanceType removes a code when already selected',
          () {
            filterCubit.toggleDanceType('salsa');
            expect(filterCubit.state.selectedDanceStyles, equals({'salsa'}));

            filterCubit.toggleDanceType('salsa');

            expect(
              filterCubit.state.selectedDanceStyles,
              isEmpty,
              reason:
                  'Preservation 6a: FilterCubit.toggleDanceType must immediately '
                  'remove the code when already selected (deselect behavior). '
                  'Must continue to work after Bug 3 fix.',
            );
          },
        );

        test(
          'multiple toggles accumulate and remove codes correctly',
          () {
            filterCubit.toggleDanceType('salsa');
            expect(
              filterCubit.state.selectedDanceStyles,
              equals({'salsa'}),
            );

            filterCubit.toggleDanceType('bachata');
            expect(
              filterCubit.state.selectedDanceStyles,
              equals({'salsa', 'bachata'}),
              reason: 'After salsa+bachata toggle: both codes must be selected',
            );

            filterCubit.toggleDanceType('salsa');
            expect(
              filterCubit.state.selectedDanceStyles,
              equals({'bachata'}),
              reason: 'After deselecting salsa: only bachata must remain selected',
            );

            filterCubit.toggleDanceType('bachata');
            expect(
              filterCubit.state.selectedDanceStyles,
              isEmpty,
              reason: 'After deselecting bachata: no codes must be selected',
            );
          },
        );

        test(
          'hasActiveFilters reflects whether any dance style is selected',
          () {
            expect(
              filterCubit.state.hasActiveFilters,
              isFalse,
              reason: 'hasActiveFilters must be false with no selections',
            );

            filterCubit.toggleDanceType('salsa');
            expect(
              filterCubit.state.hasActiveFilters,
              isTrue,
              reason:
                  'Preservation 6a: hasActiveFilters must be true after selecting '
                  'a dance style. This drives the filter indicator in the UI. '
                  'Must continue to work after Bug 3 fix.',
            );

            filterCubit.toggleDanceType('salsa');
            expect(
              filterCubit.state.hasActiveFilters,
              isFalse,
              reason:
                  'hasActiveFilters must return to false after deselecting all styles',
            );
          },
        );
      });

      // -----------------------------------------------------------------------
      // 6a-2: EventCubit correctly reflects filtered events after applyFilters
      //
      // Observation: When FilterCubit changes via manual toggle and the
      // BlocListener calls EventCubit.applyFilters(), the EventCubit emits a
      // new loaded state with the correct filtered events. This is what updates
      // the events list visible to the user (which events are shown). This
      // behavior is unaffected by Bug 3 (Bug 3 only affects the active-filter
      // code highlighting on event card tags).
      // -----------------------------------------------------------------------
      group('EventCubit.applyFilters produces correct filtered event state', () {
        test(
          'salsa filter leaves only salsa events in filteredEvents',
          () {
            filterCubit.toggleDanceType('salsa');
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.filteredEvents.length,
                  equals(2),
                  reason:
                      'Preservation 6a: With salsa filter active, only 2 salsa '
                      'events must remain in filteredEvents (Salsa Festival and '
                      'Salsa Party). Bachata events must be excluded. '
                      'This is the correct filter behavior that must be preserved.',
                );
                expect(
                  s.filteredEvents.every((e) => e.dances.contains('salsa')),
                  isTrue,
                  reason:
                      'All remaining filteredEvents must have salsa in their dances',
                );
              },
              orElse: () => fail('Expected loaded state but got: ${eventCubit.state}'),
            );
          },
        );

        test(
          'salsa filter correctly separates featured (festival) from non-featured events',
          () {
            filterCubit.toggleDanceType('salsa');
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.featuredEvents.length,
                  equals(1),
                  reason:
                      'With salsa filter: only 1 festival event (Salsa Festival) '
                      'must appear in featuredEvents',
                );
                expect(
                  s.featuredEvents.first.title,
                  equals('Salsa Festival'),
                );
              },
              orElse: () => fail('Expected loaded state'),
            );
          },
        );

        test(
          'clearing filter restores all events in filteredEvents',
          () {
            // Apply filter.
            filterCubit.toggleDanceType('salsa');
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) => expect(s.filteredEvents.length, equals(2)),
              orElse: () => fail('Expected loaded state'),
            );

            // Clear filter.
            filterCubit.toggleDanceType('salsa');
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.filteredEvents.length,
                  equals(4),
                  reason:
                      'Preservation 6a: After clearing the salsa filter, all 4 '
                      'events must be restored in filteredEvents. '
                      'Must continue to work after Bug 3 fix.',
                );
              },
              orElse: () => fail('Expected loaded state'),
            );
          },
        );

        test(
          'combined salsa+bachata filter includes events from both dance styles',
          () {
            // Both salsa and bachata events should pass a salsa+bachata filter.
            filterCubit.toggleDanceType('salsa');
            filterCubit.toggleDanceType('bachata');
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.filteredEvents.length,
                  equals(4),
                  reason:
                      'With both salsa+bachata selected, all 4 events must '
                      'appear (salsa OR bachata match).',
                );
              },
              orElse: () => fail('Expected loaded state'),
            );
          },
        );

        test(
          'no filter (initial state) shows all events',
          () {
            // No toggleDanceType called — FilterCubit in initial empty state.
            eventCubit.applyFilters(filterCubit.state, []);

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.filteredEvents.length,
                  equals(4),
                  reason:
                      'Preservation 6a: With no filters active, all 4 events must '
                      'appear in filteredEvents. This simulates the no-preference '
                      'login case (FilterCubit stays empty).',
                );
              },
              orElse: () => fail('Expected loaded state'),
            );
          },
        );

        test(
          'EventCubit emits a new state after applyFilters with active filter',
          () async {
            final states = <EventState>[];
            final sub = eventCubit.stream.listen(states.add);

            filterCubit.toggleDanceType('salsa');
            eventCubit.applyFilters(filterCubit.state, []);

            await Future.delayed(Duration.zero);

            // EventCubit must have emitted a new state with filtered results.
            expect(
              states.isNotEmpty,
              isTrue,
              reason:
                  'Preservation 6a: EventCubit must emit a new state when '
                  'applyFilters is called with an active filter. This drives '
                  'the BlocBuilder<EventCubit> rebuild that shows filtered events.',
            );
            final lastLoaded = states
                .lastWhere((s) => s.maybeMap(loaded: (_) => true, orElse: () => false))
                .maybeMap(loaded: (s) => s, orElse: () => null);
            expect(
              lastLoaded?.filteredEvents.length,
              equals(2),
              reason: 'The new state must have 2 filteredEvents (salsa only)',
            );

            await sub.cancel();
          },
        );
      });
    },
  );

  // =========================================================================
  // Property 6b: No Active Filters After Login Without Preferences
  //
  // When FilterCubit stays empty (no profile preferences), the widget correctly
  // shows no active filter codes in both FeaturedEventsSection and
  // UpcomingEventsSection. This works on unfixed code because the stale-read
  // bug only manifests when FilterCubit is non-empty: context.read<FilterCubit>()
  // inside BlocBuilder<EventCubit> always returns {} when the cubit has no
  // selected styles, so there is nothing stale to expose.
  //
  // EXPECTED OUTCOME ON UNFIXED CODE: PASSES
  // EXPECTED OUTCOME ON FIXED CODE: PASSES (no regression)
  // =========================================================================
  group(
    'Task 6 — Preservation 6b: No active filter codes when FilterCubit has no selected styles',
    () {
      late _FakeAuthRepository fakeAuthRepo;
      late AuthCubit authCubit;
      late FavoritesCubit favoritesCubit;
      late FilterCubit filterCubit;
      late EventCubit eventCubit;
      late CourseCubit courseCubit;
      late SettingsCubit settingsCubit;

      setUp(() async {
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
        eventCubit = EventCubit(
          eventRepository: _PresetEventRepository(events: _mixedEvents),
        );
        await eventCubit.loadEvents('en');
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

      testWidgets(
        'FeaturedEventsSection has empty activeFilterCodes when FilterCubit starts with no selection',
        (tester) async {
          // FilterCubit is in initial state — no selected dance styles.
          // This represents login with no dance style preferences in profile,
          // or a user who has not manually selected any filters.
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

          expect(
            find.byType(FeaturedEventsSection),
            findsOneWidget,
            reason: 'FeaturedEventsSection must be visible (festival events present)',
          );
          final section = tester.widget<FeaturedEventsSection>(
            find.byType(FeaturedEventsSection),
          );
          expect(
            section.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: FeaturedEventsSection must show no active '
                'filter codes when FilterCubit has no selected dance styles. '
                'This simulates login with no profile filter preferences. '
                'The stale-read bug is not triggered because FilterCubit returns '
                '{} at both initial build time and any subsequent build. '
                'Must continue to work after Bug 3 fix.',
          );
        },
      );

      testWidgets(
        'UpcomingEventsSection has empty activeFilterCodes and hasActiveFilters=false when FilterCubit starts with no selection',
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

          final section = tester.widget<UpcomingEventsSection>(
            find.byType(UpcomingEventsSection),
          );
          expect(
            section.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: UpcomingEventsSection must show no active '
                'filter codes when FilterCubit has no selected dance styles. '
                'Simulates login with no profile filter preferences.',
          );
          expect(
            section.hasActiveFilters,
            isFalse,
            reason:
                'Preservation 6b: UpcomingEventsSection.hasActiveFilters must '
                'be false when no filters are selected. Must continue to work '
                'after Bug 3 fix.',
          );
        },
      );

      testWidgets(
        'filter codes stay empty when setDanceStyles is called with empty set (explicit no-preference login)',
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

          // Explicit no-preference login: prefillFiltersFromProfile is called
          // with an empty set (user has no saved dance style preferences).
          filterCubit.setDanceStyles({});
          await tester.pump();

          final featured = tester.widget<FeaturedEventsSection>(
            find.byType(FeaturedEventsSection),
          );
          expect(
            featured.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: FeaturedEventsSection must show no active '
                'filter codes when setDanceStyles({}) is called (user logged in '
                'with no dance style preferences in profile). '
                'Must continue to work after Bug 3 fix.',
          );
          final upcoming = tester.widget<UpcomingEventsSection>(
            find.byType(UpcomingEventsSection),
          );
          expect(
            upcoming.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: UpcomingEventsSection must show no active '
                'filter codes when setDanceStyles({}) is called.',
          );
          expect(
            upcoming.hasActiveFilters,
            isFalse,
            reason:
                'Preservation 6b: UpcomingEventsSection.hasActiveFilters must '
                'be false when no dance style preferences are set.',
          );
        },
      );

      testWidgets(
        'filter codes remain empty after EventCubit re-emits with empty FilterCubit',
        (tester) async {
          // Simulates post-login: EventCubit re-emits (e.g., events reloaded or
          // preferences processed) while FilterCubit remains empty (no preferences).
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

          // EventCubit re-emits (simulates applyFilters called after login with
          // no dance style preferences). FilterCubit remains empty.
          eventCubit.applyFilters(filterCubit.state, []);
          await tester.pump();

          final featured = tester.widget<FeaturedEventsSection>(
            find.byType(FeaturedEventsSection),
          );
          expect(
            featured.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: FeaturedEventsSection.activeFilterCodes must '
                'remain empty when FilterCubit has no selected dance styles, '
                'even after EventCubit re-emits. This simulates login with no '
                'dance style preferences in the user profile.',
          );
          final upcoming = tester.widget<UpcomingEventsSection>(
            find.byType(UpcomingEventsSection),
          );
          expect(
            upcoming.activeFilterCodes,
            isEmpty,
            reason:
                'Preservation 6b: UpcomingEventsSection.activeFilterCodes must '
                'remain empty after EventCubit re-emits with no filter preferences.',
          );
          expect(
            upcoming.hasActiveFilters,
            isFalse,
            reason:
                'Preservation 6b: UpcomingEventsSection.hasActiveFilters must '
                'remain false after EventCubit re-emits with no filter preferences.',
          );
        },
      );
    },
  );
}
