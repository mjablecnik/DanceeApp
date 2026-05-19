import '../../core/clients.dart';
import '../../core/config.dart';
import '../entities/event.dart';
import '../entities/translation_utils.dart';

class EventRepository {
  EventRepository({
    required DirectusClient client,
    required WorkflowClient workflowClient,
  })  : _client = client,
        _workflowClient = workflowClient;

  final DirectusClient _client;
  final WorkflowClient _workflowClient;

  /// Fetches all published events with venue and translations for [languageCode].
  Future<List<Event>> getEvents(String languageCode) async {
    final data = await _client.get(
      '/items/events',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'filter[status][_eq]': 'published',
        'filter[start_time][_gte]': '\$NOW',
        'sort': 'start_time',
        'limit': '-1',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map((json) => Event.fromDirectus(
              json,
              languageCode: languageCode,
              directusBaseUrl: AppConfig.directusBaseUrl,
            ))
        .toList();
  }

  /// Fetches all events (published and unpublished) for editor use.
  Future<List<Event>> getEventsForEditor(String languageCode) async {
    final data = await _client.get(
      '/items/events',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'sort': 'start_time',
        'limit': '-1',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map((json) => Event.fromDirectus(
              json,
              languageCode: languageCode,
              directusBaseUrl: AppConfig.directusBaseUrl,
            ))
        .toList();
  }

  /// Updates the published status of event [id].
  Future<void> updatePublishedStatus(int id, bool published) async {
    await _client.patch('/items/events/$id', data: {'published': published});
  }

  /// Updates the reviewed status of event [id].
  Future<void> updateReviewedStatus(int id, bool reviewed) async {
    await _client.patch('/items/events/$id', data: {'reviewed': reviewed});
  }

  /// Fetches a single event by [id] with venue and translations for [languageCode].
  Future<Event> getEventById(int id, String languageCode) async {
    final data = await _client.get(
      '/items/events/$id',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    return Event.fromDirectus(
      data as Map<String, dynamic>,
      languageCode: languageCode,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
  }

  /// Fetches a single event by [id] and returns it together with the
  /// translation record ID for [languageCode].
  ///
  /// The translation ID is required when constructing PATCH payloads for edits
  /// so Directus updates the existing translation record rather than creating a
  /// new one.
  Future<(Event, int?)> getEventByIdWithTranslationId(
    int id,
    String languageCode,
  ) async {
    final data = await _client.get(
      '/items/events/$id',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );
    final json = data as Map<String, dynamic>;
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final translation = extractTranslation(translations, languageCode);
    final translationId = translation?['id'] as int?;
    final event = Event.fromDirectus(
      json,
      languageCode: languageCode,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
    return (event, translationId);
  }

  /// Sends a PATCH request to update event [id] with [fields].
  ///
  /// [fields] should include both root-level fields and a nested `translations`
  /// array with the appropriate `languages_code` and translation ID.
  Future<void> updateEvent(
    int id,
    Map<String, dynamic> fields,
    String languageCode,
  ) async {
    await _client.patch('/items/events/$id', data: fields);
  }

  /// Triggers asynchronous retranslation on the workflow service (fire-and-forget).
  ///
  /// Posts [modifiedTextFields] (translatable text only) to the workflow service
  /// so it can translate them into the other supported languages. Errors are
  /// swallowed — the editor's original save is never affected by this call.
  Future<void> triggerRetranslation(
    int id,
    String itemType,
    String sourceLang,
    Map<String, String> modifiedTextFields,
  ) async {
    try {
      await _workflowClient.post('/api/event/retranslate', data: {
        'itemId': id,
        'itemType': itemType,
        'sourceLang': sourceLang,
        'modifiedTextFields': modifiedTextFields,
      });
    } catch (_) {
      // Fire-and-forget: translation failures must not surface to the editor.
    }
  }
}
