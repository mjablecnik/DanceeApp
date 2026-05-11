// Task 1: Bug condition exploration test for Favorites 403
//
// EXPECTED OUTCOME ON UNFIXED CODE: FAILS
// The test confirms the bug: FavoritesCubit._onAuthStateChanged calls
// loadFavorites() immediately when authenticated state is received, before the
// Firebase → Directus token exchange completes (directusLinkedNotifier fires).
//
// Counterexample documented here:
//   FavoritesCubit._onAuthStateChanged receives AuthState.authenticated and
//   immediately calls loadFavorites(), which calls getFavorites() on the
//   repository. In production, DirectusAuthService.hasTokens is still false
//   at this point (exchange in progress), so the request goes out without an
//   Authorization header → Directus treats it as the public role → 403 "Access
//   denied" because the favorites collection is NOT accessible to the public role.
//
// Requirements: 1.1, 2.1

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/data/entities/favorite.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
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

/// Auth repository where [ensureDirectusLinked] never completes.
/// This simulates the window between AuthCubit emitting [authenticated] and
/// the Firebase → Directus token exchange finishing.
class _NeverLinkingAuthRepository extends Fake implements AuthRepository {
  _NeverLinkingAuthRepository()
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
  Future<void> signOut() async {}

  /// Never completes — simulates token exchange still in progress.
  @override
  Future<void> ensureDirectusLinked() async {
    await Completer<void>().future;
  }
}

class _FakeFavoritesRepositoryForAuth extends Fake
    implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

/// Tracks how many times [getFavorites] is called and for which userId.
class _TrackingFavoritesRepository extends FavoritesRepository {
  _TrackingFavoritesRepository()
      : super(
          client: DirectusClient(
            baseUrl: 'http://test.local',
            accessToken: 'test-token',
            dio: Dio(),
          ),
        );

  int getFavoritesCallCount = 0;
  final List<String> getFavoritesUserIds = [];

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    getFavoritesCallCount++;
    getFavoritesUserIds.add(userId);
    // Simulate what a 403 would do in production (AccessDeniedException).
    // We just return empty here; the real bug is that the call is made at all.
    return [];
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group(
    'Task 1 — Bug Condition: Favorites 403 — FavoritesCubit fires before Directus token exchange',
    () {
      late _NeverLinkingAuthRepository authRepo;
      late _TrackingFavoritesRepository trackingRepo;
      late AuthCubit authCubit;
      late FavoritesCubit favoritesCubit;

      setUp(() {
        authRepo = _NeverLinkingAuthRepository();
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

      // -----------------------------------------------------------------------
      // Property 1: Bug Condition
      // isBugCondition1(input) where:
      //   input.authState = authenticated
      //   input.directusLinkedNotifier has NOT fired (token exchange in progress)
      //   input.targetCollection = 'favorites'
      //
      // EXPECTED OUTCOME ON UNFIXED CODE: FAILS
      // Reason: _onAuthStateChanged calls loadFavorites() immediately, so
      // getFavoritesCallCount > 0. The assertion below requires count == 0.
      // -----------------------------------------------------------------------
      test(
        'FAILS_ON_UNFIXED: does not call repository when authenticated but directusLinkedNotifier not yet fired',
        () async {
          // Simulate login: AuthCubit emits authenticated, but ensureDirectusLinked
          // never completes → directusLinkedNotifier never fires.
          authRepo.pushUser(_FakeUser(uid: 'test-uid-abc'));

          // Allow microtasks / stream events to propagate.
          await Future.delayed(Duration.zero);

          // Expected behavior (post-fix): FavoritesCubit waits for
          // directusLinkedNotifier before calling loadFavorites().
          //
          // Bug (pre-fix): loadFavorites() fires immediately on authenticated
          // → getFavorites() is called → in production this returns 403.
          expect(
            trackingRepo.getFavoritesCallCount,
            equals(0),
            reason:
                'FavoritesCubit must NOT call getFavorites before the '
                'Directus token exchange completes (directusLinkedNotifier fires). '
                'Bug: _onAuthStateChanged calls loadFavorites() immediately on '
                'authenticated state, before hasTokens = true.',
          );
        },
      );

      test(
        'FAILS_ON_UNFIXED: emits loading/waiting state (not loaded/error) while token exchange is in progress',
        () async {
          final states = <FavoritesState>[];
          final sub = favoritesCubit.stream.listen(states.add);

          authRepo.pushUser(_FakeUser(uid: 'test-uid-abc'));
          await Future.delayed(Duration.zero);

          // Expected behavior (post-fix): state is loading (waiting for token),
          // NOT loaded (which would mean an API call was made and returned).
          //
          // Bug (pre-fix): state transitions to loaded(empty) because loadFavorites()
          // fires immediately and the tracking repo returns []. In production it
          // would be an error state (403).
          final hasLoadedState = states
              .any((s) => s.maybeMap(loaded: (_) => true, orElse: () => false));
          expect(
            hasLoadedState,
            isFalse,
            reason:
                'FavoritesCubit should not reach loaded state before '
                'directusLinkedNotifier fires. The tracking repo returning [] '
                'instead of throwing just masks the production 403 error.',
          );

          await sub.cancel();
        },
      );
    },
  );
}
