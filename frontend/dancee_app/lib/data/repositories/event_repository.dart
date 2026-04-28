import '../../core/clients.dart';
import '../../core/config.dart';
import '../entities/event.dart';

class EventRepository {
  EventRepository({required DirectusClient client}) : _client = client;

  final DirectusClient _client;

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
}
