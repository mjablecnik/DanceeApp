import '../../core/clients.dart';
import '../../core/config.dart';
import '../entities/course.dart';

class CourseRepository {
  CourseRepository({
    required DirectusClient client,
    required WorkflowClient workflowClient,
  })  : _client = client,
        _workflowClient = workflowClient;

  final DirectusClient _client;
  final WorkflowClient _workflowClient;

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

  /// Fetches a single course by [id] with venue and translations for [languageCode].
  Future<Course> getCourseById(int id, String languageCode) async {
    final data = await _client.get(
      '/items/courses/$id',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );

    return Course.fromDirectus(
      data as Map<String, dynamic>,
      languageCode: languageCode,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
  }

  /// Sends a PATCH request to update course [id] with [fields].
  ///
  /// [fields] should include both root-level fields and a nested `translations`
  /// array with the appropriate `languages_code` and translation ID.
  Future<void> updateCourse(
    int id,
    Map<String, dynamic> fields,
    String languageCode,
  ) async {
    await _client.patch('/items/courses/$id', data: fields);
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
