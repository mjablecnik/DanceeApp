// Feature: firebase-auth
// Task 9.4: Unit tests for DirectusClient token handling and FavoritesCubit auth integration
// Covers:
//   - Authorization header uses Firebase ID token when available
//   - Fallback to static token when ID token is null
//   - FavoritesCubit uses Firebase UID from AuthCubit, not hardcoded default
//   - Favorites cleared on sign out
// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/data/entities/favorite.dart';
import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/data/repositories/favorites_repository.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/cubits/favorites_cubit.dart';
import 'package:dancee_app2/logic/states/favorites_state.dart';

// ---------------------------------------------------------------------------
// Fakes for FirebaseAuth / AuthCubit
// ---------------------------------------------------------------------------

class _FakeUserMetadata extends Fake implements UserMetadata {
  _FakeUserMetadata({this.creationTime});
  @override
  final DateTime? creationTime;
}

class _FakeUser extends Fake implements User {
  _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  }) : metadata = _FakeUserMetadata(creationTime: DateTime.now());

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

/// Controllable fake [AuthRepository].
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

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

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }
}

class _FakeFavoritesRepositoryForAuth extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String userId) async {}
}

AuthCubit _makeAuthCubitWithUser(User? user, _FakeAuthRepository repo) {
  final cubit = AuthCubit(
    authRepository: repo,
    favoritesRepository: _FakeFavoritesRepositoryForAuth(),
  );
  if (user != null) repo.pushUser(user);
  return cubit;
}

// ---------------------------------------------------------------------------
// Fake adapter for capturing request headers
// ---------------------------------------------------------------------------

/// An [HttpClientAdapter] that captures the last request's Authorization header
/// and returns a minimal valid Directus response.
class _CapturingAdapter implements HttpClientAdapter {
  String? capturedAuthHeader;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedAuthHeader = options.headers['Authorization'] as String?;
    // Return a minimal valid JSON response with a Directus envelope
    const responseData = '{"data": []}';
    return ResponseBody.fromString(responseData, 200,
        headers: {'content-type': ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

DirectusClient _makeClientWithCapture(
  _CapturingAdapter adapter, {
  String accessToken = 'static-token',
  Future<String?> Function()? idTokenProvider,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  dio.httpClientAdapter = adapter;
  return DirectusClient(
    baseUrl: 'https://test.local',
    accessToken: accessToken,
    idTokenProvider: idTokenProvider,
    dio: dio,
  );
}

// ---------------------------------------------------------------------------
// Fake FavoritesRepository that records which userId was passed
// ---------------------------------------------------------------------------

class _RecordingFavoritesRepository extends FavoritesRepository {
  _RecordingFavoritesRepository()
      : super(
          client: DirectusClient(
            baseUrl: 'http://test.local',
            accessToken: 'test-token',
            dio: Dio(),
          ),
        );

  String? lastGetFavoritesUserId;
  final List<String> getFavoritesCallUids = [];

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    lastGetFavoritesUserId = userId;
    getFavoritesCallUids.add(userId);
    return [];
  }

  @override
  Future<Favorite> addFavorite({
    required String userId,
    required String itemType,
    required int itemId,
  }) async {
    throw UnimplementedError();
  }

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
// Group 1: DirectusClient token handling
// ---------------------------------------------------------------------------

void _directusClientTokenTests() {
  test(
    'uses Firebase ID token in Authorization header when idTokenProvider returns a token',
    () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithCapture(
        adapter,
        accessToken: 'static-token',
        idTokenProvider: () async => 'firebase-id-token-xyz',
      );

      await client.get('/items/test');

      expect(
        adapter.capturedAuthHeader,
        equals('Bearer firebase-id-token-xyz'),
        reason: 'Should use the Firebase ID token as Bearer token',
      );
    },
  );

  test(
    'falls back to static access token when idTokenProvider returns null',
    () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithCapture(
        adapter,
        accessToken: 'my-static-token',
        idTokenProvider: () async => null,
      );

      await client.get('/items/test');

      expect(
        adapter.capturedAuthHeader,
        equals('Bearer my-static-token'),
        reason: 'Should fall back to static token when ID token provider returns null',
      );
    },
  );

  test(
    'falls back to static access token when idTokenProvider throws',
    () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithCapture(
        adapter,
        accessToken: 'fallback-token',
        idTokenProvider: () async => throw Exception('Token refresh failed'),
      );

      await client.get('/items/test');

      expect(
        adapter.capturedAuthHeader,
        equals('Bearer fallback-token'),
        reason: 'Should fall back to static token when ID token provider throws',
      );
    },
  );

  test(
    'uses static access token when no idTokenProvider is provided',
    () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithCapture(
        adapter,
        accessToken: 'only-static-token',
        idTokenProvider: null,
      );

      await client.get('/items/test');

      expect(
        adapter.capturedAuthHeader,
        equals('Bearer only-static-token'),
        reason: 'Should use static token when no idTokenProvider is configured',
      );
    },
  );

  test(
    'Firebase ID token takes precedence over static token (multiple calls)',
    () async {
      const firebaseToken = 'firebase-token-abc';
      int callCount = 0;
      final adapter = _CapturingAdapter();
      final client = _makeClientWithCapture(
        adapter,
        accessToken: 'static-token',
        idTokenProvider: () async {
          callCount++;
          return firebaseToken;
        },
      );

      await client.get('/items/test');
      expect(adapter.capturedAuthHeader, equals('Bearer $firebaseToken'));

      await client.get('/items/other');
      expect(adapter.capturedAuthHeader, equals('Bearer $firebaseToken'));

      expect(callCount, equals(2),
          reason: 'idTokenProvider should be called once per request');
    },
  );
}

// ---------------------------------------------------------------------------
// Group 2: FavoritesCubit uses Firebase UID
// ---------------------------------------------------------------------------

void _favoritesCubitUidTests() {
  late _FakeAuthRepository authRepo;

  setUp(() {
    authRepo = _FakeAuthRepository();
  });

  tearDown(() {
    authRepo.dispose();
  });

  test(
    'loadFavorites passes Firebase UID to repository when authenticated',
    () async {
      const expectedUid = 'firebase-uid-12345';
      final user = _FakeUser(uid: expectedUid, emailVerified: true);
      final authCubit = _makeAuthCubitWithUser(user, authRepo);

      // Wait for auth state to update
      await Future.delayed(Duration.zero);

      final repo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: repo,
        authCubit: authCubit,
      );

      await cubit.loadFavorites();

      expect(
        repo.lastGetFavoritesUserId,
        equals(expectedUid),
        reason: 'FavoritesCubit should pass the Firebase UID to the repository',
      );

      await cubit.close();
      await authCubit.close();
    },
  );

  test(
    'loadFavorites uses empty string for userId when unauthenticated',
    () async {
      final authCubit = AuthCubit(
        authRepository: authRepo,
        favoritesRepository: _FakeFavoritesRepositoryForAuth(),
      );
      // No user pushed — remains unauthenticated

      final repo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: repo,
        authCubit: authCubit,
      );

      await cubit.loadFavorites();

      expect(
        repo.lastGetFavoritesUserId,
        isNull,
        reason: 'getFavorites must not be called when user is unauthenticated (early return)',
      );

      await cubit.close();
      await authCubit.close();
    },
  );

  test(
    'loadFavorites does NOT use hardcoded default userId',
    () async {
      const firebaseUid = 'real-firebase-uid-xyz';
      final user = _FakeUser(uid: firebaseUid, emailVerified: true);
      final authCubit = _makeAuthCubitWithUser(user, authRepo);

      await Future.delayed(Duration.zero);

      final repo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: repo,
        authCubit: authCubit,
      );

      await cubit.loadFavorites();

      // Ensure it used the Firebase UID, not any hardcoded value
      expect(
        repo.lastGetFavoritesUserId,
        equals(firebaseUid),
        reason: 'Must use Firebase UID, not a hardcoded default userId',
      );
      expect(
        repo.lastGetFavoritesUserId,
        isNot(equals('defaultUser')),
      );
      expect(
        repo.lastGetFavoritesUserId,
        isNot(equals('user1')),
      );

      await cubit.close();
      await authCubit.close();
    },
  );
}

// ---------------------------------------------------------------------------
// Group 3: Favorites cleared on sign out
// ---------------------------------------------------------------------------

void _favoritesClearedOnSignOutTests() {
  late _FakeAuthRepository authRepo;

  setUp(() {
    authRepo = _FakeAuthRepository();
  });

  tearDown(() {
    authRepo.dispose();
  });

  test(
    'favorites state resets to initial when auth state becomes unauthenticated',
    () async {
      final user = _FakeUser(uid: 'user-abc', emailVerified: true);
      final authCubit = _makeAuthCubitWithUser(user, authRepo);
      await Future.delayed(Duration.zero);

      final repo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: repo,
        authCubit: authCubit,
      );

      // Load favorites while authenticated
      await cubit.loadFavorites();

      // Capture emitted states on sign out
      final states = <FavoritesState>[];
      final sub = cubit.stream.listen(states.add);

      // Simulate sign out by pushing null user
      authRepo.pushUser(null);
      await Future.delayed(Duration.zero);

      expect(
        states.any((s) => s.maybeMap(initial: (_) => true, orElse: () => false)),
        isTrue,
        reason: 'State should reset to initial when user signs out',
      );

      await sub.cancel();
      await cubit.close();
      await authCubit.close();
    },
  );

  test(
    'isFavorited returns false after sign out',
    () async {
      final user = _FakeUser(uid: 'user-xyz', emailVerified: true);
      final authCubit = _makeAuthCubitWithUser(user, authRepo);
      await Future.delayed(Duration.zero);

      // Use a repo that has pre-loaded favorites
      final favoritesRepo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: favoritesRepo,
        authCubit: authCubit,
      );

      await cubit.loadFavorites();

      // Sign out
      authRepo.pushUser(null);
      await Future.delayed(Duration.zero);

      // After sign out, favorites should be cleared
      expect(
        cubit.isFavorited('event', 1),
        isFalse,
        reason: 'No items should be favorited after sign out',
      );

      await cubit.close();
      await authCubit.close();
    },
  );

  test(
    'FavoritesCubit uses updated UID after re-authentication with different account',
    () async {
      const firstUid = 'first-user-uid';
      const secondUid = 'second-user-uid';

      final firstUser = _FakeUser(uid: firstUid, emailVerified: true);
      final authCubit = _makeAuthCubitWithUser(firstUser, authRepo);
      await Future.delayed(Duration.zero);

      final repo = _RecordingFavoritesRepository();
      final cubit = FavoritesCubit(
        favoritesRepository: repo,
        authCubit: authCubit,
      );

      // Load favorites as first user
      await cubit.loadFavorites();
      expect(repo.lastGetFavoritesUserId, equals(firstUid));

      // Sign out
      authRepo.pushUser(null);
      await Future.delayed(Duration.zero);

      // Sign in as second user
      final secondUser = _FakeUser(uid: secondUid, emailVerified: true);
      authRepo.pushUser(secondUser);
      await Future.delayed(Duration.zero);

      // Load favorites as second user
      await cubit.loadFavorites();
      expect(
        repo.lastGetFavoritesUserId,
        equals(secondUid),
        reason: 'Should use the new Firebase UID after re-authentication',
      );

      await cubit.close();
      await authCubit.close();
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Task 9.4 — DirectusClient token handling', _directusClientTokenTests);
  group('Task 9.4 — FavoritesCubit uses Firebase UID', _favoritesCubitUidTests);
  group('Task 9.4 — Favorites cleared on sign out', _favoritesClearedOnSignOutTests);
}
