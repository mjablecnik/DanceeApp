import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exceptions.dart';
import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import '../data/event_repository.dart';
import 'event_filter.dart';

part 'event_list.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the EventListCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before any events are loaded
/// - [loading]: While events are being fetched
/// - [loaded]: Events successfully loaded and grouped by date
/// - [error]: An error occurred during loading or toggling
@freezed
class EventListState with _$EventListState {
  const factory EventListState.initial() = EventListInitial;

  const factory EventListState.loading() = EventListLoading;

  const factory EventListState.loaded({
    required List<Event> allEvents,
    required List<Event> todayEvents,
    required List<Event> tomorrowEvents,
    required List<Event> upcomingEvents,
  }) = EventListLoaded;

  const factory EventListState.error(String message) = EventListError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing event list screen state.
///
/// Handles loading, searching, and toggling favorites for events.
/// Events are automatically grouped by date (today, tomorrow, upcoming).
class EventListCubit extends Cubit<EventListState> {
  final EventRepository _repository;
  final _errorController = StreamController<String>.broadcast();

  /// Stream of non-fatal error messages (e.g. from [toggleFavorite] failures).
  ///
  /// The UI layer should listen to this stream and show appropriate feedback
  /// (e.g. a snackbar) without destroying the loaded event list.
  Stream<String> get errorStream => _errorController.stream;

  EventListCubit(this._repository) : super(const EventListState.initial()) {
    loadEvents();
  }

  /// Loads all events from the repository and groups them by date.
  ///
  /// Events are grouped into:
  /// - Today: Events starting today that are not past
  /// - Tomorrow: Events starting tomorrow that are not past
  /// - Upcoming: Events starting after tomorrow that are not past
  Future<void> loadEvents() async {
    developer.log('loadEvents() called', name: 'EventListCubit');
    emit(const EventListState.loading());
    try {
      final events = await _repository.getAllEvents();
      developer.log('Received ${events.length} events from repository', name: 'EventListCubit');
      _emitGrouped(events);
    } on ApiException catch (e) {
      developer.log('ApiException in loadEvents: ${e.message} (status: ${e.statusCode}, original: ${e.originalError})', name: 'EventListCubit', level: 900);
      emit(EventListState.error(t.errors.loadEventsError));
    } catch (e, stackTrace) {
      developer.log('Unexpected error in loadEvents: $e', name: 'EventListCubit', level: 1000);
      developer.log('Stack trace: $stackTrace', name: 'EventListCubit', level: 1000);
      emit(EventListState.error(t.errors.genericError));
    }
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the repository first, then updates the local state without
  /// reloading from the API. This prevents UI flickering.
  /// Only works when the current state is [EventListLoaded].
  Future<void> toggleFavorite(String eventId) async {
    final currentState = state;
    if (currentState is! EventListLoaded) return;

    try {
      final event = currentState.allEvents.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw ApiException(message: 'Event not found'),
      );

      await _repository.toggleFavorite(eventId, event.isFavorite);

      // Update favorite status locally in all grouped lists
      List<Event> updateList(List<Event> list) {
        return list.map((e) {
          if (e.id == eventId) {
            return e.copyWith(isFavorite: !e.isFavorite);
          }
          return e;
        }).toList();
      }

      emit(EventListState.loaded(
        allEvents: updateList(currentState.allEvents),
        todayEvents: updateList(currentState.todayEvents),
        tomorrowEvents: updateList(currentState.tomorrowEvents),
        upcomingEvents: updateList(currentState.upcomingEvents),
      ));
    } on ApiException {
      // Keep the current loaded state — a failed favorite toggle is non-fatal.
      // Communicate the error via errorStream so the UI can show a snackbar.
      _errorController.add(t.errors.toggleFavoriteError);
    } catch (_) {
      _errorController.add(t.errors.genericError);
    }
  }

  @override
  Future<void> close() {
    _errorController.close();
    return super.close();
  }

  /// Groups events by date and emits a [EventListLoaded] state.
  void _emitGrouped(List<Event> events) {
    final now = DateTime.now();
    emit(EventListState.loaded(
      allEvents: events,
      todayEvents: groupToday(events, now),
      tomorrowEvents: groupTomorrow(events, now),
      upcomingEvents: groupUpcoming(events, now),
    ));
  }
}
