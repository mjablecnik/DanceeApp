import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/course.dart';
import '../../data/entities/event.dart';
import '../../data/entities/favorite.dart';
import '../../data/repositories/favorites_repository.dart';
import '../states/auth_state.dart';
import '../states/favorites_state.dart';
import 'auth_cubit.dart';

/// A resolved favorite item — either an [Event] or [Course] with its creation timestamp.
typedef FavoriteItem = ({String itemType, Object item, String? createdAt});

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required FavoritesRepository favoritesRepository,
    required AuthCubit authCubit,
  })  : _favoritesRepository = favoritesRepository,
        _authCubit = authCubit,
        super(const FavoritesState.initial()) {
    _authSubscription = authCubit.stream.listen(_onAuthStateChanged);
  }

  final FavoritesRepository _favoritesRepository;
  final AuthCubit _authCubit;
  List<Favorite> _allFavorites = [];
  late final StreamSubscription<AuthState> _authSubscription;

  final _toggleErrorController = StreamController<String>.broadcast();

  /// Stream of error messages emitted when a favorite toggle fails.
  /// Listen to this stream to show snackbars or other error feedback.
  Stream<String> get toggleErrors => _toggleErrorController.stream;

  void _onAuthStateChanged(AuthState authState) {
    authState.maybeMap(
      authenticated: (_) => loadFavorites(),
      unauthenticated: (_) {
        _allFavorites = [];
        emit(const FavoritesState.initial());
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _toggleErrorController.close();
    return super.close();
  }

  String get _currentUserId => _authCubit.currentUid ?? '';

  /// Fetches all favorites for the current user, emits loaded state.
  /// Does nothing if the user is not authenticated (empty user ID).
  Future<void> loadFavorites() async {
    if (_currentUserId.isEmpty) return;
    emit(const FavoritesState.loading());
    try {
      _allFavorites = await _favoritesRepository.getFavorites(_currentUserId);
      _emitLoaded();
    } catch (e) {
      emit(FavoritesState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Toggles favorite status with optimistic update; reverts state on CMS failure.
  Future<void> toggleFavorite({
    required String itemType,
    required int itemId,
  }) async {
    final wasAlreadyFavorited = isFavorited(itemType, itemId);

    // Optimistic update
    if (wasAlreadyFavorited) {
      _allFavorites = _allFavorites
          .where((f) => !(f.itemType == itemType && f.itemId == itemId))
          .toList();
    } else {
      _allFavorites = [
        Favorite(
          id: -1,
          userId: _currentUserId,
          itemType: itemType,
          itemId: itemId,
        ),
        ..._allFavorites,
      ];
    }
    _emitLoaded();

    try {
      if (wasAlreadyFavorited) {
        await _favoritesRepository.removeFavorite(
          userId: _currentUserId,
          itemType: itemType,
          itemId: itemId,
        );
      } else {
        final created = await _favoritesRepository.addFavorite(
          userId: _currentUserId,
          itemType: itemType,
          itemId: itemId,
        );
        // Replace the temporary entry with the real persisted record
        _allFavorites = _allFavorites.map((f) {
          if (f.id == -1 && f.itemType == itemType && f.itemId == itemId) {
            return created;
          }
          return f;
        }).toList();
        _emitLoaded();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[FavoritesCubit] toggleFavorite FAILED: $e');
      // Revert optimistic update on failure
      if (wasAlreadyFavorited) {
        // Re-fetch from server to restore accurate state
        await loadFavorites();
      } else {
        _allFavorites = _allFavorites
            .where((f) => !(f.itemType == itemType && f.itemId == itemId))
            .toList();
        _emitLoaded();
      }
      _toggleErrorController.add(
        e is ApiException ? e.message : 'api.errors.generic',
      );
    }
  }

  /// Returns true if the item is currently favorited.
  bool isFavorited(String itemType, int itemId) {
    return _allFavorites
        .any((f) => f.itemType == itemType && f.itemId == itemId);
  }

  /// Resolves favorite IDs against [events] and [courses], sorted newest first.
  List<FavoriteItem> getResolvedFavorites(
    List<Event> events,
    List<Course> courses,
  ) {
    final result = <FavoriteItem>[];

    for (final fav in _allFavorites) {
      if (fav.itemType == 'event') {
        final event = events.where((e) => e.id == fav.itemId).firstOrNull;
        if (event != null) {
          result.add((
            itemType: 'event',
            item: event,
            createdAt: fav.createdAt,
          ));
        }
      } else if (fav.itemType == 'course') {
        final course = courses.where((c) => c.id == fav.itemId).firstOrNull;
        if (course != null) {
          result.add((
            itemType: 'course',
            item: course,
            createdAt: fav.createdAt,
          ));
        }
      }
    }

    // Sort by createdAt descending (newest first)
    result.sort((a, b) {
      final aDate = a.createdAt ?? '';
      final bDate = b.createdAt ?? '';
      return bDate.compareTo(aDate);
    });

    return result;
  }

  void _emitLoaded() {
    final eventIds = _allFavorites
        .where((f) => f.itemType == 'event')
        .map((f) => f.itemId)
        .toSet();
    final courseIds = _allFavorites
        .where((f) => f.itemType == 'course')
        .map((f) => f.itemId)
        .toSet();
    emit(FavoritesState.loaded(eventIds: eventIds, courseIds: courseIds));
  }
}
