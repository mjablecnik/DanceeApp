import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/event.dart';
import '../../data/repositories/event_repository.dart';
import '../states/event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventDetailState.loading());

  final EventRepository _eventRepository;

  /// Loads event by [eventId].
  ///
  /// If [cachedEvents] is provided and contains the event it is used
  /// immediately (no network call; translationId will be null in that case).
  /// Otherwise the event is fetched from the API together with its translation
  /// record ID.
  Future<void> loadEvent(
    int eventId,
    String languageCode, {
    List<Event>? cachedEvents,
  }) async {
    // Fast path: use the event from the global list cache if available.
    if (cachedEvents != null) {
      final cached = cachedEvents.where((e) => e.id == eventId).firstOrNull;
      if (cached != null) {
        emit(EventDetailState.loaded(event: cached, translationId: null));
        return;
      }
    }

    // Slow path: fetch from Directus (supports deep links / cold start).
    emit(const EventDetailState.loading());
    try {
      final (event, translationId) =
          await _eventRepository.getEventByIdWithTranslationId(
        eventId,
        languageCode,
      );
      emit(EventDetailState.loaded(event: event, translationId: translationId));
    } catch (e) {
      emit(EventDetailState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Transitions from [loaded] to [editing] state, enabling the edit form.
  void startEditing() {
    state.maybeMap(
      loaded: (s) => emit(
        EventDetailState.editing(event: s.event, translationId: s.translationId),
      ),
      orElse: () {},
    );
  }

  /// Submits [modifiedFields] via PATCH and triggers retranslation on success.
  ///
  /// [modifiedTextFields] contains only the translatable text fields that were
  /// changed; it is forwarded to the workflow service for re-translation into
  /// the other supported languages.
  Future<void> submitEdit(
    int eventId,
    Map<String, dynamic> modifiedFields,
    String languageCode, {
    Map<String, String> modifiedTextFields = const {},
  }) async {
    final currentEvent = state.maybeMap(
      editing: (s) => s.event,
      orElse: () => null,
    );
    if (currentEvent == null) return;

    emit(EventDetailState.submitting(event: currentEvent));
    try {
      await _eventRepository.updateEvent(eventId, modifiedFields, languageCode);

      // Fire-and-forget: retranslation must not block the success feedback.
      if (modifiedTextFields.isNotEmpty) {
        _eventRepository.triggerRetranslation(
          eventId,
          'event',
          languageCode,
          modifiedTextFields,
        );
      }

      // Re-fetch the updated event so the success state contains fresh data.
      try {
        final (freshEvent, _) =
            await _eventRepository.getEventByIdWithTranslationId(
          eventId,
          languageCode,
        );
        emit(EventDetailState.success(event: freshEvent));
      } catch (_) {
        // If re-fetch fails, emit success with the stale event — the edit
        // itself succeeded.
        emit(EventDetailState.success(event: currentEvent));
      }
    } catch (e) {
      emit(EventDetailState.error(
        event: currentEvent,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Toggles the published status and re-fetches the event.
  Future<void> togglePublished(int eventId, String languageCode) async {
    final currentEvent = state.maybeMap(
      loaded: (s) => s.event,
      success: (s) => s.event,
      error: (s) => s.event,
      orElse: () => null,
    );
    if (currentEvent == null) return;
    try {
      await _eventRepository.updatePublishedStatus(eventId, !currentEvent.published);
      await refreshEvent(eventId, languageCode);
    } catch (e) {
      emit(EventDetailState.error(
        event: currentEvent,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Toggles the reviewed status and re-fetches the event.
  Future<void> toggleReviewed(int eventId, String languageCode) async {
    final currentEvent = state.maybeMap(
      loaded: (s) => s.event,
      success: (s) => s.event,
      error: (s) => s.event,
      orElse: () => null,
    );
    if (currentEvent == null) return;
    try {
      await _eventRepository.updateReviewedStatus(eventId, !currentEvent.reviewed);
      await refreshEvent(eventId, languageCode);
    } catch (e) {
      emit(EventDetailState.error(
        event: currentEvent,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Re-fetches the event from the API after a successful edit so the detail
  /// page shows the latest saved data.
  Future<void> refreshEvent(int eventId, String languageCode) async {
    final previousEvent = state.maybeMap(
      success: (s) => s.event,
      loaded: (s) => s.event,
      error: (s) => s.event,
      orElse: () => null,
    );
    emit(const EventDetailState.loading());
    try {
      final (event, translationId) =
          await _eventRepository.getEventByIdWithTranslationId(
        eventId,
        languageCode,
      );
      emit(EventDetailState.loaded(event: event, translationId: translationId));
    } catch (e) {
      emit(EventDetailState.error(
        event: previousEvent,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }
}
