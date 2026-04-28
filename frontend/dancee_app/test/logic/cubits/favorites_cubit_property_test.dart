// Feature: cms-flutter-integration
// Task 5.9: Property tests for favorites logic
// Properties covered:
//   Property 10: Favorite resolution against loaded data
//   Property 11: Favorites sorted by creation date
//   Property 12: Favorites unaffected by filters
//   Property 13: Favorite toggle round-trip
//   Property 14: Optimistic favorite update
//   Property 15: Revert on failure

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/data/entities/course.dart';
import 'package:dancee_app2/data/entities/event.dart';
import 'package:dancee_app2/data/entities/favorite.dart';
import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/data/repositories/favorites_repository.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/cubits/favorites_cubit.dart';
import 'package:dancee_app2/logic/states/favorites_state.dart';

/// Minimal fake [AuthRepository] that returns an empty auth stream.
/// Allows constructing [AuthCubit] without a real Firebase instance.
class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;
}

/// [AuthCubit] subclass that always reports a fixed authenticated UID.
/// Bypasses Firebase stream mechanics so tests can rely on a stable currentUid.
class _FakeAuthCubit extends AuthCubit {
  _FakeAuthCubit()
      : super(
          authRepository: _FakeAuthRepository(),
          favoritesRepository: _FakeFavoritesRepositoryForAuth(),
        );

  @override
  String? get currentUid => 'test-uid';
}

class _FakeFavoritesRepositoryForAuth extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

AuthCubit _makeAuthCubit() => _FakeAuthCubit();

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(42);

/// Fake [FavoritesRepository] backed by in-memory data.
class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository({
    List<Favorite> initialFavorites = const [],
    bool shouldThrowOnAdd = false,
    bool shouldThrowOnRemove = false,
    int addDelayMs = 0,
  })  : _favorites = List<Favorite>.from(initialFavorites),
        _shouldThrowOnAdd = shouldThrowOnAdd,
        _shouldThrowOnRemove = shouldThrowOnRemove,
        _addDelayMs = addDelayMs,
        super(
          client: DirectusClient(
            baseUrl: 'http://test.local',
            accessToken: 'test-token',
            dio: Dio(),
          ),
        );

  final List<Favorite> _favorites;
  final bool _shouldThrowOnAdd;
  final bool _shouldThrowOnRemove;
  final int _addDelayMs;
  int _nextId = 100;

  @override
  Future<List<Favorite>> getFavorites(String userId) async => _favorites;

  @override
  Future<Favorite> addFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {
    if (_addDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: _addDelayMs));
    }
    if (_shouldThrowOnAdd) throw Exception('Add failed');

    final newFav = Favorite(
      id: _nextId++,
      userId: userId,
      itemType: itemType,
      itemId: itemId,
      createdAt: DateTime.now().toIso8601String(),
    );
    _favorites.add(newFav);
    return newFav;
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {
    if (_shouldThrowOnRemove) throw Exception('Remove failed');
    _favorites.removeWhere(
      (f) => f.itemType == itemType && f.itemId == itemId,
    );
  }
}

Event _makeEvent({required int id}) {
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    startTime: DateTime(2025, 1, id),
    organizer: 'Organizer',
    dances: const [],
    eventType: 'party',
    info: const [],
    parts: const [],
    isFavorited: false,
  );
}

Course _makeCourse({required int id}) {
  return Course(
    id: id,
    title: 'Course $id',
    description: '',
    dances: const [],
    learningItems: const [],
    isFavorited: false,
  );
}

Favorite _makeFavorite({
  required int id,
  required String itemType,
  required int itemId,
  String? createdAt,
}) {
  return Favorite(
    id: id,
    userId: 'user1',
    itemType: itemType,
    itemId: itemId,
    createdAt: createdAt,
  );
}

// ---------------------------------------------------------------------------
// Property 10: Favorite resolution against loaded data
// ---------------------------------------------------------------------------

void _propertyFavoriteResolution() {
  // Feature: cms-flutter-integration, Property 10: Favorite resolution against loaded data
  test(
    'P10: getResolvedFavorites returns only favorites whose items exist in loaded data (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final eventCount = 3 + _rng.nextInt(8);
        final courseCount = 3 + _rng.nextInt(8);

        final events =
            List.generate(eventCount, (idx) => _makeEvent(id: idx + 1));
        final courses =
            List.generate(courseCount, (idx) => _makeCourse(id: idx + 1));

        // Mix of favorited event/course IDs — some exist, some don't
        final favorites = <Favorite>[];
        var favId = 1;
        // Some matching event favorites
        final matchingEventIds =
            events.take(2).map((e) => e.id).toList();
        for (final id in matchingEventIds) {
          favorites.add(_makeFavorite(
            id: favId++,
            itemType: 'event',
            itemId: id,
            createdAt: '2025-01-0${favId}T00:00:00Z',
          ));
        }
        // A non-existing event favorite
        favorites.add(_makeFavorite(
          id: favId++,
          itemType: 'event',
          itemId: eventCount + 999,
        ));
        // Some matching course favorites
        final matchingCourseIds =
            courses.take(2).map((c) => c.id).toList();
        for (final id in matchingCourseIds) {
          favorites.add(_makeFavorite(
            id: favId++,
            itemType: 'course',
            itemId: id,
            createdAt: '2025-01-0${favId}T00:00:00Z',
          ));
        }
        // A non-existing course favorite
        favorites.add(_makeFavorite(
          id: favId++,
          itemType: 'course',
          itemId: courseCount + 999,
        ));

        final repo = _FakeFavoritesRepository(initialFavorites: favorites);
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        final resolved = cubit.getResolvedFavorites(events, courses);

        // All resolved items must come from the provided events/courses lists
        for (final item in resolved) {
          if (item.itemType == 'event') {
            expect(
              events.any((e) => e.id == (item.item as Event).id),
              isTrue,
              reason: 'Iteration $i: resolved event must exist in events list',
            );
          } else if (item.itemType == 'course') {
            expect(
              courses.any((c) => c.id == (item.item as Course).id),
              isTrue,
              reason:
                  'Iteration $i: resolved course must exist in courses list',
            );
          }
        }

        // Count should equal matching favorites (those with existing items)
        final expectedCount = matchingEventIds.length + matchingCourseIds.length;
        expect(
          resolved.length,
          equals(expectedCount),
          reason:
              'Iteration $i: resolved count should equal number of matching favorites',
        );

        await cubit.close();
      }
    },
  );

  test(
    'P10b: getResolvedFavorites returns empty list when no favorites exist',
    () async {
      final repo = _FakeFavoritesRepository();
      final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
      await cubit.loadFavorites();

      final resolved = cubit.getResolvedFavorites(
        [_makeEvent(id: 1)],
        [_makeCourse(id: 1)],
      );

      expect(resolved, isEmpty, reason: 'No favorites means empty resolved list');

      await cubit.close();
    },
  );

  test(
    'P10c: getResolvedFavorites returns empty list when events/courses lists are empty',
    () async {
      final favorites = [
        _makeFavorite(id: 1, itemType: 'event', itemId: 1),
        _makeFavorite(id: 2, itemType: 'course', itemId: 1),
      ];
      final repo = _FakeFavoritesRepository(initialFavorites: favorites);
      final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
      await cubit.loadFavorites();

      final resolved = cubit.getResolvedFavorites([], []);

      expect(
        resolved,
        isEmpty,
        reason: 'Empty loaded data means nothing can be resolved',
      );

      await cubit.close();
    },
  );
}

// ---------------------------------------------------------------------------
// Property 11: Favorites sorted by creation date
// ---------------------------------------------------------------------------

void _propertyFavoritesSortedByDate() {
  // Feature: cms-flutter-integration, Property 11: Favorites sorted by creation date
  test(
    'P11: getResolvedFavorites returns items sorted by createdAt descending (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final count = 2 + _rng.nextInt(8);
        final events = List.generate(count, (idx) => _makeEvent(id: idx + 1));

        // Build favorites with explicit timestamps in ascending order
        final favorites = List.generate(count, (idx) {
          final month = (idx + 1).toString().padLeft(2, '0');
          return _makeFavorite(
            id: idx + 1,
            itemType: 'event',
            itemId: idx + 1,
            createdAt: '2025-$month-01T00:00:00Z',
          );
        });

        // Shuffle favorites to ensure sort is not order-dependent
        favorites.shuffle(_rng);

        final repo = _FakeFavoritesRepository(initialFavorites: favorites);
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        final resolved = cubit.getResolvedFavorites(events, []);

        // Verify descending order
        for (var j = 0; j < resolved.length - 1; j++) {
          final dateA = resolved[j].createdAt ?? '';
          final dateB = resolved[j + 1].createdAt ?? '';
          expect(
            dateA.compareTo(dateB),
            greaterThanOrEqualTo(0),
            reason:
                'Iteration $i, position $j: items should be in descending date order',
          );
        }

        await cubit.close();
      }
    },
  );

  test(
    'P11b: most recently created favorite appears first',
    () async {
      final events = [
        _makeEvent(id: 1),
        _makeEvent(id: 2),
        _makeEvent(id: 3),
      ];

      final favorites = [
        _makeFavorite(
            id: 1,
            itemType: 'event',
            itemId: 1,
            createdAt: '2025-01-01T00:00:00Z'),
        _makeFavorite(
            id: 2,
            itemType: 'event',
            itemId: 2,
            createdAt: '2025-03-01T00:00:00Z'),
        _makeFavorite(
            id: 3,
            itemType: 'event',
            itemId: 3,
            createdAt: '2025-02-01T00:00:00Z'),
      ];

      final repo = _FakeFavoritesRepository(initialFavorites: favorites);
      final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
      await cubit.loadFavorites();

      final resolved = cubit.getResolvedFavorites(events, []);

      expect(resolved.length, equals(3));
      // Most recent (March) should be first
      expect((resolved[0].item as Event).id, equals(2));
      // February second
      expect((resolved[1].item as Event).id, equals(3));
      // January last
      expect((resolved[2].item as Event).id, equals(1));

      await cubit.close();
    },
  );
}

// ---------------------------------------------------------------------------
// Property 12: Favorites unaffected by filters
// ---------------------------------------------------------------------------

void _propertyFavoritesUnaffectedByFilters() {
  // Feature: cms-flutter-integration, Property 12: Favorites unaffected by filters
  // The FavoritesCubit does not apply dance style or region filters.
  // getResolvedFavorites always returns all matched favorites regardless of
  // what FilterState is active elsewhere in the app.
  test(
    'P12: getResolvedFavorites returns all matched favorites regardless of item content (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final count = 1 + _rng.nextInt(10);
        final events = List.generate(count, (idx) => _makeEvent(id: idx + 1));
        final favorites = List.generate(
          count,
          (idx) => _makeFavorite(
            id: idx + 1,
            itemType: 'event',
            itemId: idx + 1,
          ),
        );

        final repo = _FakeFavoritesRepository(initialFavorites: favorites);
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        // Regardless of any external filter, all $count favorites should be resolved
        final resolved = cubit.getResolvedFavorites(events, []);

        expect(
          resolved.length,
          equals(count),
          reason:
              'Iteration $i: all $count favorites should appear in resolved list regardless of item properties',
        );

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Property 13: Favorite toggle round-trip
// ---------------------------------------------------------------------------

void _propertyFavoriteToggleRoundTrip() {
  // Feature: cms-flutter-integration, Property 13: Favorite toggle round-trip
  test(
    'P13: toggling a favorite twice restores original state (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final itemId = 1 + _rng.nextInt(100);
        const itemType = 'event';

        final repo = _FakeFavoritesRepository();
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        // Initially not favorited
        expect(
          cubit.isFavorited(itemType, itemId),
          isFalse,
          reason: 'Iteration $i: item should not be favorited initially',
        );

        // First toggle — add
        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);
        expect(
          cubit.isFavorited(itemType, itemId),
          isTrue,
          reason:
              'Iteration $i: item should be favorited after first toggle',
        );

        // Second toggle — remove
        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);
        expect(
          cubit.isFavorited(itemType, itemId),
          isFalse,
          reason:
              'Iteration $i: item should not be favorited after second toggle',
        );

        await cubit.close();
      }
    },
  );

  test(
    'P13b: toggle round-trip works for both events and courses',
    () async {
      const types = ['event', 'course'];
      for (final itemType in types) {
        const itemId = 42;

        final repo = _FakeFavoritesRepository();
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);
        expect(cubit.isFavorited(itemType, itemId), isTrue);

        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);
        expect(cubit.isFavorited(itemType, itemId), isFalse);

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Property 14: Optimistic favorite update
// ---------------------------------------------------------------------------

void _propertyOptimisticUpdate() {
  // Feature: cms-flutter-integration, Property 14: Optimistic favorite update
  test(
    'P14: state reflects favorite immediately before API responds (optimistic update)',
    () async {
      const itemType = 'event';
      const itemId = 1;

      // Repository with a delay to simulate slow network
      final repo = _FakeFavoritesRepository(addDelayMs: 50);
      final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
      await cubit.loadFavorites();

      // Start toggle but don't await — check state before API resolves
      final toggleFuture =
          cubit.toggleFavorite(itemType: itemType, itemId: itemId);

      // Immediately after calling toggle, state should already reflect the change
      // because of optimistic update (isFavorited is updated synchronously)
      expect(
        cubit.isFavorited(itemType, itemId),
        isTrue,
        reason: 'Optimistic update: item should appear favorited before API responds',
      );

      // Wait for API to complete
      await toggleFuture;

      // State should still be favorited after API succeeds
      expect(
        cubit.isFavorited(itemType, itemId),
        isTrue,
        reason: 'Item should remain favorited after API succeeds',
      );

      await cubit.close();
    },
  );

  test(
    'P14b: emitted FavoritesState.loaded reflects optimistic add immediately',
    () async {
      const itemType = 'event';
      const itemId = 7;

      final repo = _FakeFavoritesRepository(addDelayMs: 50);
      final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
      await cubit.loadFavorites();

      final states = <FavoritesState>[];
      final sub = cubit.stream.listen(states.add);

      final toggleFuture =
          cubit.toggleFavorite(itemType: itemType, itemId: itemId);

      // Give async code time to emit but not finish the delayed API call
      await Future.delayed(const Duration(milliseconds: 10));

      // At least one state should have been emitted with the new eventId
      // We use maybeMap here via pattern matching on the list
      final anyLoaded = states.any((s) => s.maybeMap(
            loaded: (l) => l.eventIds.contains(itemId),
            orElse: () => false,
          ));
      expect(
        anyLoaded,
        isTrue,
        reason: 'Optimistic state emission should include new eventId before API resolves',
      );

      await toggleFuture;
      await sub.cancel();
      await cubit.close();
    },
  );
}

// ---------------------------------------------------------------------------
// Property 15: Revert on failure
// ---------------------------------------------------------------------------

void _propertyRevertOnFailure() {
  // Feature: cms-flutter-integration, Property 15: Revert on failure
  test(
    'P15: state reverts to unfavorited when add API call fails (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final itemId = 1 + _rng.nextInt(50);
        const itemType = 'event';

        final repo = _FakeFavoritesRepository(shouldThrowOnAdd: true);
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        // Initially not favorited
        expect(cubit.isFavorited(itemType, itemId), isFalse);

        // Toggle — will succeed optimistically then revert when API throws
        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);

        // After failure, item should no longer appear favorited
        expect(
          cubit.isFavorited(itemType, itemId),
          isFalse,
          reason:
              'Iteration $i: item should revert to unfavorited when add API fails',
        );

        await cubit.close();
      }
    },
  );

  test(
    'P15b: state reverts to favorited when remove API call fails (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        final itemId = 1 + _rng.nextInt(50);
        const itemType = 'event';

        // Pre-load a favorite that exists
        final existingFav = _makeFavorite(
          id: 1,
          itemType: itemType,
          itemId: itemId,
        );
        final repo = _FakeFavoritesRepository(
          initialFavorites: [existingFav],
          shouldThrowOnRemove: true,
        );
        final cubit = FavoritesCubit(favoritesRepository: repo, authCubit: _makeAuthCubit());
        await cubit.loadFavorites();

        // Initially favorited
        expect(cubit.isFavorited(itemType, itemId), isTrue);

        // Toggle — will optimistically remove then revert when API throws
        await cubit.toggleFavorite(itemType: itemType, itemId: itemId);

        // After failure, item should be favorited again (reverted via re-fetch)
        expect(
          cubit.isFavorited(itemType, itemId),
          isTrue,
          reason:
              'Iteration $i: item should revert to favorited when remove API fails',
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
  group('FavoritesCubit — property tests', () {
    group(
      'Property 10: Favorite resolution against loaded data',
      _propertyFavoriteResolution,
    );
    group(
      'Property 11: Favorites sorted by creation date',
      _propertyFavoritesSortedByDate,
    );
    group(
      'Property 12: Favorites unaffected by filters',
      _propertyFavoritesUnaffectedByFilters,
    );
    group(
      'Property 13: Favorite toggle round-trip',
      _propertyFavoriteToggleRoundTrip,
    );
    group(
      'Property 14: Optimistic favorite update',
      _propertyOptimisticUpdate,
    );
    group(
      'Property 15: Revert on failure',
      _propertyRevertOnFailure,
    );
  });
}
