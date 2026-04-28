import '../../core/clients.dart';
import '../entities/dance_style.dart';

class DanceStyleRepository {
  DanceStyleRepository({required DirectusClient client}) : _client = client;

  final DirectusClient _client;

  /// Fetches all dance styles with translations for [languageCode].
  Future<List<DanceStyle>> getDanceStyles(String languageCode) async {
    final data = await _client.get(
      '/items/dance_styles',
      queryParameters: {
        'fields': '*,translations.*',
        'sort': 'sort_order',
        'limit': '-1',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map((json) => DanceStyle.fromDirectus(json, languageCode: languageCode))
        .toList();
  }
}
