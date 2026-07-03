// Task 2: Preservation property tests for Favorites loading (BEFORE implementing fix)
//
// EXPECTED OUTCOME ON UNFIXED AND FIXED CODE: PASSES
// These tests document behaviors that already work correctly and MUST continue
// to work after the Bug 1 fix (task 7).
//
// Properties verified:
//   Property 2a: When directusLinkedNotifier fires (hasTokens = true equivalent),
//                FavoritesCubit.loadFavorites() executes and returns loaded state.
//   Property 2b: When user is unauthenticated, no favorites API call is made.
//   Property 2c: EventCubit loads events independently — no dependency on
//                FavoritesCubit or token exchange timing.
//
// Observations on unfixed code:
//   - When ensureDirectusLinked() completes immediately, _onAuthStateChanged
//     calls loadFavorites() immediately (before notifier on unfixed code), and
//     the repo returns data → loaded state. ✓ passes.
//   - When unauthenticated, _onAuthStateChanged emits initial state and does
//     not call the repository. ✓ passes.
//   - EventCubit has no dependency on AuthCubit or token exchange. ✓ passes.
//
// Requirements: 3.1, 3.6, 3.7

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/data/entities/event.dart';
import 'package:dancee_app/data/entities/favorite.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/event_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/cubits/event_cubit.dart';
import 'package:dancee_app/logic/cubits/favorites_cubit.dart';
import 'package:dancee_app/logic/states/favorites_state.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUserMetadata extends Fake implements UserMetadata {
  _FakeUserMetadata() : creationTime = DateTime.now();
  @override
  final DateTime? creationTime;
}

class _FakeUser extends Fake implements User {
  _FakeUser({required this.uid})
      : emailVerified = true,
        email = '$uid@test.com',
        displayName = null,
        metadata = _FakeUserMetadata();
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final UserMetadata metadata;
}

/// Auth repository where [ensureDirectusLinked] completes immediately,
/// simulating the case where Directus tokens are already available (hasTokens = true).
class _ImmediateLinkAuthRepository extends Fake implements AuthRepository {
  _ImmediateLinkAuthRepository()
      : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void pushUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  /// Completes immediately — simulates tokens already available (hasTokens = true).
  @override
  Future<void> ensureDirectusLinked() async {}
}

class _FakeFavoritesRepositoryForAuth extends Fake
    implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

/// Tracks calls to [getFavorites] and returns a fixed list.
class _TrackingFavoritesRepository extends FavoritesRepository {
  _TrackingFavoritesRepository({List<Favorite> favorites = const []})
      : _favorites = favorites,
        super(
          client: DirectusClient(
            baseUrl: 'http://test.local',
            accessToken: 'test-token',
            dio: Dio(),
          ),
        );

  final List<Favorite> _favorites;
  int getFavoritesCallCount = 0;

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    getFavoritesCallCount++;
    return _favorites;
  }

  @override
  Future<Favorite> addFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> removeFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {}

  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

/// Fake [EventRepository] that returns an empty list without making real HTTP calls.
class _FakeEventRepository extends Fake implements EventRepository {
  int getEventsCallCount = 0;

  @override
  Future<List<Event>> getEvents(String languageCode) async {
    getEventsCallCount++;
    return [];
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group(
    'Task 2 — Preservation: Normal Favorites Loading Unchanged',
    () {
      // -----------------------------------------------------------------------
      // Property 2a: When directus link completes immediately (hasTokens = true),
      // FavoritesCubit reaches loaded state.
      //
      // Observation: On unfixed code, loadFavorites() is called immediately on
      // authenticated. On fixed code, it will be called when directusLinkedNotifier
      // fires (which happens immediately when ensureDirectusLinked() returns).
      // Both paths must result in a loaded state.
      // -----------------------------------------------------------------------
      group('Property 2a: favorites load when directus link completes immediately', () {
        late _ImmediateLinkAuthRepository authRepo;
        late _TrackingFavoritesRepository trackingRepo;
        late AuthCubit authCubit;
        late FavoritesCubit favoritesCubit;

        setUp(() {
          authRepo = _ImmediateLinkAuthRepository();
          trackingRepo = _TrackingFavoritesRepository(
            favorites: [
              const Favorite(
                id: 1,
                userId: 'test-uid',
                itemType: 'event',
                itemId: 42,
              ),
            ],
          );
          authCubit = AuthCubit(
            authRepository: authRepo,
            favoritesRepository: _FakeFavoritesRepositoryForAuth(),
          );
          favoritesCubit = FavoritesCubit(
            favoritesRepository: trackingRepo,
            authCubit: authCubit,
          );
        });

        tearDown(() async {
          await favoritesCubit.close();
          await authCubit.close();
          authRepo.dispose();
        });

        test(
          'calls getFavorites when authenticated and directus link completes immediately',
          () async {
            authRepo.pushUser(_FakeUser(uid: 'test-uid'));

            // Wait for auth state change + ensureDirectusLinked + notifier propagation
            await Future.delayed(const Duration(milliseconds: 50));

            expect(
              trackingRepo.getFavoritesCallCount,
              greaterThan(0),
              reason:
                  'When directus link completes immediately (hasTokens = true equivalent), '
                  'FavoritesCubit must call getFavorites. '
                  'This behavior must be preserved after the Bug 1 fix.',
            );
          },
        );

        test(
          'reaches loaded state when authenticated and directus link completes immediately',
          () async {
            final states = <FavoritesState>[];
            final sub = favoritesCubit.stream.listen(states.add);

            authRepo.pushUser(_FakeUser(uid: 'test-uid'));
            await Future.delayed(const Duration(milliseconds: 50));

            final hasLoadedState = states
                .any((s) => s.maybeMap(loaded: (_) => true, orElse: () => false));
            expect(
              hasLoadedState,
              isTrue,
              reason:
                  'When directus link completes immediately (hasTokens = true equivalent), '
                  'FavoritesCubit must reach loaded state without extra delay. '
                  'This behavior must be preserved after the Bug 1 fix.',
            );

            final hasErrorState = states
                .any((s) => s.maybeMap(error: (_) => true, orElse: () => false));
            expect(
              hasErrorState,
              isFalse,
              reason: 'No error state should be emitted when tokens are available.',
            );

            await sub.cancel();
          },
        );

        test(
          'loaded state contains correct favorite IDs',
          () async {
            authRepo.pushUser(_FakeUser(uid: 'test-uid'));
            await Future.delayed(const Duration(milliseconds: 50));

            final state = favoritesCubit.state;
            state.maybeMap(
              loaded: (s) {
                expect(s.eventIds, contains(42));
              },
              orElse: () => fail(
                'Expected loaded state but got: $state',
              ),
            );
          },
        );
      });

      // -----------------------------------------------------------------------
      // Property 2b: When unauthenticated, no favorites API call is made and
      // cubit remains in initial state.
      //
      // Observation: _onAuthStateChanged on unauthenticated emits initial state
      // and does not call the repository. This is existing behavior that must
      // not be broken by the fix.
      // -----------------------------------------------------------------------
      group('Property 2b: no API call when unauthenticated', () {
        late _ImmediateLinkAuthRepository authRepo;
        late _TrackingFavoritesRepository trackingRepo;
        late AuthCubit authCubit;
        late FavoritesCubit favoritesCubit;

        setUp(() {
          authRepo = _ImmediateLinkAuthRepository();
          trackingRepo = _TrackingFavoritesRepository();
          authCubit = AuthCubit(
            authRepository: authRepo,
            favoritesRepository: _FakeFavoritesRepositoryForAuth(),
          );
          favoritesCubit = FavoritesCubit(
            favoritesRepository: trackingRepo,
            authCubit: authCubit,
          );
        });

        tearDown(() async {
          await favoritesCubit.close();
          await authCubit.close();
          authRepo.dispose();
        });

        test(
          'does not call getFavorites when no user is authenticated',
          () async {
            // No user pushed — auth state remains unauthenticated
            await Future.delayed(const Duration(milliseconds: 50));

            expect(
              trackingRepo.getFavoritesCallCount,
              equals(0),
              reason:
                  'FavoritesCubit must NOT call getFavorites when unauthenticated. '
                  'This behavior must be preserved after the Bug 1 fix.',
            );
          },
        );

        test(
          'remains in initial state when unauthenticated',
          () async {
            await Future.delayed(const Duration(milliseconds: 50));

            final isInitial = favoritesCubit.state.maybeMap(
              initial: (_) => true,
              orElse: () => false,
            );
            expect(
              isInitial,
              isTrue,
              reason:
                  'FavoritesCubit must stay in initial state when no user is authenticated.',
            );
          },
        );

        test(
          'resets to initial state on sign-out after being authenticated',
          () async {
            // First, authenticate and wait for favorites to load
            authRepo.pushUser(_FakeUser(uid: 'test-uid'));
            await Future.delayed(const Duration(milliseconds: 50));

            // Then sign out
            await authRepo.signOut();
            await Future.delayed(const Duration(milliseconds: 10));

            final isInitial = favoritesCubit.state.maybeMap(
              initial: (_) => true,
              orElse: () => false,
            );
            expect(
              isInitial,
              isTrue,
              reason:
                  'FavoritesCubit must reset to initial state on sign-out. '
                  'This behavior must be preserved after the Bug 1 fix.',
            );
          },
        );

        test(
          'does not call getFavorites again after sign-out',
          () async {
            // Authenticate (may call getFavorites once)
            authRepo.pushUser(_FakeUser(uid: 'test-uid'));
            await Future.delayed(const Duration(milliseconds: 50));
            final countAfterLogin = trackingRepo.getFavoritesCallCount;

            // Sign out
            await authRepo.signOut();
            await Future.delayed(const Duration(milliseconds: 10));

            expect(
              trackingRepo.getFavoritesCallCount,
              equals(countAfterLogin),
              reason:
                  'Sign-out must not trigger additional getFavorites calls. '
                  'The count after sign-out must equal the count right after login.',
            );
          },
        );
      });

      // -----------------------------------------------------------------------
      // Property 2c: EventCubit loads events independently of FavoritesCubit
      // and token exchange timing. Events/Courses use public role access.
      //
      // Observation: EventCubit has no dependency on AuthCubit or
      // directusLinkedNotifier — it loads immediately when loadEvents() is called.
      // This behavior must not be affected by the Bug 1 fix (which only changes
      // FavoritesCubit).
      // -----------------------------------------------------------------------
      group('Property 2c: EventCubit loads independently of token exchange', () {
        late _FakeEventRepository fakeEventRepo;
        late EventCubit eventCubit;

        setUp(() {
          fakeEventRepo = _FakeEventRepository();
          eventCubit = EventCubit(eventRepository: fakeEventRepo);
        });

        tearDown(() async {
          await eventCubit.close();
        });

        test(
          'loads events immediately without any AuthCubit or token dependency',
          () async {
            // EventCubit has no AuthCubit dependency — call loadEvents directly
            await eventCubit.loadEvents('en');

            final isLoaded = eventCubit.state.maybeMap(
              loaded: (_) => true,
              orElse: () => false,
            );
            expect(
              isLoaded,
              isTrue,
              reason:
                  'EventCubit must load events immediately without waiting for '
                  'any token exchange. Events use public role access and must '
                  'not be affected by the Bug 1 fix.',
            );

            expect(
              fakeEventRepo.getEventsCallCount,
              equals(1),
              reason: 'getEvents must be called exactly once.',
            );
          },
        );

        test(
          'EventCubit reaches loaded state with correct event count',
          () async {
            await eventCubit.loadEvents('en');

            eventCubit.state.maybeMap(
              loaded: (s) {
                expect(
                  s.allEvents.length,
                  equals(0),
                  reason: 'Loaded state must reflect the empty event list from fake repo.',
                );
              },
              orElse: () => fail('Expected loaded state, got: ${eventCubit.state}'),
            );
          },
        );

        test(
          'EventCubit is not affected by whether FavoritesCubit has tokens or not',
          () async {
            // Simulate that no directus token exchange has happened
            // (no AuthCubit, no directusLinkedNotifier)
            // EventCubit still loads fine
            await eventCubit.loadEvents('cs');

            // Check current state directly — no need for stream listener
            final isLoaded = eventCubit.state.maybeMap(
              loaded: (_) => true,
              orElse: () => false,
            );
            expect(
              isLoaded,
              isTrue,
              reason:
                  'EventCubit must reach loaded state regardless of token exchange state. '
                  'It uses public role access and has no dependency on Directus user tokens.',
            );
          },
        );
      });
    },
  );
}
