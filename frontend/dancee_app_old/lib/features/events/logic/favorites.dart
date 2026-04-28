import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exceptions.dart';
import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import '../data/event_repository.dart';
import 'event_list.dart';

part 'favorites.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the FavoritesCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before any favorites are loaded
/// - [loading]: While favorites are being fetched
/// - [loaded]: Favorites successfully loaded and separated by upcoming/past
/// - [error]: An error occurred during loading or toggling
@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = FavoritesInitial;

  const factory FavoritesState.loading() = FavoritesLoading;

  const factory FavoritesState.loaded({
    required List<Event> upcomingEvents,
    required List<Event> pastEvents,
  }) = FavoritesLoaded;

  const factory FavoritesState.error(String message) = FavoritesError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing favorites screen state.
///
/// Handles loading favorite events and toggling favorite status.
/// Events are automatically separated into upcoming and past for UI convenience.
class FavoritesCubit extends Cubit<FavoritesState> {
  final EventRepository _repository;
  final EventListCubit _eventListCubit;

  FavoritesCubit(this._repository, this._eventListCubit)
      : super(const FavoritesState.initial());

  /// Loads favorite events and separates them into upcoming and past.
  ///
  /// Events are separated based on the isPast flag:
  /// - Upcoming: Events where isPast is false
  /// - Past: Events where isPast is true
  ///
  /// Emits [FavoritesLoading] while loading, then either:
  /// - [FavoritesLoaded] with separated events on success
  /// - [FavoritesError] on failure
  Future<void> loadFavorites() async {
    emit(const FavoritesState.loading());
    try {
      final favorites = await _repository.getFavoriteEvents();

      final upcoming = favorites.where((e) => !e.isPast).toList();
      final past = favorites.where((e) => e.isPast).toList();

      emit(FavoritesState.loaded(
        upcomingEvents: upcoming,
        pastEvents: past,
      ));
    } on ApiException {
      emit(FavoritesState.error(t.errors.loadFavoritesError));
    } catch (_) {
      emit(FavoritesState.error(t.errors.genericError));
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the event's isFavorite status locally without removing it from view.
  /// The event stays visible with toggled heart until user navigates away.
  /// Calls repository to update backend and notifies EventListCubit.
  ///
  /// On error, emits [FavoritesError] with translated error message.
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    try {
      // Find the event in upcoming or past lists
      final event = currentState.upcomingEvents
              .cast<Event?>()
              .firstWhere((e) => e?.id == eventId, orElse: () => null) ??
          currentState.pastEvents
              .cast<Event?>()
              .firstWhere((e) => e?.id == eventId, orElse: () => null);

      if (event == null) {
        emit(FavoritesState.error(t.errors.genericError));
        return;
      }

      // Call repository with current favorite status
      await _repository.toggleFavorite(eventId, event.isFavorite);

      // Update the event locally without removing it from view
      final updatedUpcoming = currentState.upcomingEvents.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isFavorite: !e.isFavorite);
        }
        return e;
      }).toList();

      final updatedPast = currentState.pastEvents.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isFavorite: !e.isFavorite);
        }
        return e;
      }).toList();

      emit(FavoritesState.loaded(
        upcomingEvents: updatedUpcoming,
        pastEvents: updatedPast,
      ));

      // Notify EventListCubit to reload its data
      _eventListCubit.loadEvents();
    } on ApiException {
      emit(FavoritesState.error(t.errors.toggleFavoriteError));
    } catch (_) {
      emit(FavoritesState.error(t.errors.genericError));
    }
  }

  /// Filters out unfavorited events from the current state.
  ///
  /// Removes events where isFavorite is false from the displayed list
  /// without reloading from repository. Used when user navigates away
  /// from the favorites screen to clean up the view.
  void filterUnfavoritedEvents() {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    final filteredUpcoming =
        currentState.upcomingEvents.where((e) => e.isFavorite).toList();
    final filteredPast =
        currentState.pastEvents.where((e) => e.isFavorite).toList();

    emit(FavoritesState.loaded(
      upcomingEvents: filteredUpcoming,
      pastEvents: filteredPast,
    ));
  }

  /// Removes a past event from favorites immediately.
  ///
  /// Used for past events to remove them instantly when user clicks
  /// the delete icon. Updates repository in background and notifies
  /// EventListCubit to reload its data.
  Future<void> removePastEvent(String eventId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    try {
      final event = currentState.pastEvents
          .cast<Event?>()
          .firstWhere((e) => e?.id == eventId, orElse: () => null);

      if (event == null) {
        emit(FavoritesState.error(t.errors.genericError));
        return;
      }

      await _repository.toggleFavorite(eventId, event.isFavorite);

      final updatedUpcoming = currentState.upcomingEvents;
      final updatedPast =
          currentState.pastEvents.where((e) => e.id != eventId).toList();

      emit(FavoritesState.loaded(
        upcomingEvents: updatedUpcoming,
        pastEvents: updatedPast,
      ));

      // Notify EventListCubit to reload its data
      _eventListCubit.loadEvents();
    } on ApiException {
      emit(FavoritesState.error(t.errors.toggleFavoriteError));
    } catch (_) {
      emit(FavoritesState.error(t.errors.genericError));
    }
  }
}
