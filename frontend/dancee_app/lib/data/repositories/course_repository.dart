import '../../core/clients.dart';
import '../../core/config.dart';
import '../entities/course.dart';

class CourseRepository {
  CourseRepository({required DirectusClient client}) : _client = client;

  final DirectusClient _client;

  /// Fetches all published courses with venue and translations for [languageCode].
  Future<List<Course>> getCourses(String languageCode) async {
    final data = await _client.get(
      '/items/courses',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'filter[status][_eq]': 'published',
        'sort': 'start_date',
        'limit': '-1',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map((json) => Course.fromDirectus(
              json,
              languageCode: languageCode,
              directusBaseUrl: AppConfig.directusBaseUrl,
            ))
        .toList();
  }
}
