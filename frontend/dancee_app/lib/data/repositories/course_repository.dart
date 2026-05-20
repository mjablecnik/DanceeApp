import '../../core/clients.dart';
import '../../core/config.dart';
import '../entities/course.dart';
import '../entities/translation_utils.dart';

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

  /// Fetches all courses (published and unpublished) for editor use.
  Future<List<Course>> getCoursesForEditor(String languageCode) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final data = await _client.get(
      '/items/courses',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'sort': 'start_date',
        'limit': '-1',
        'filter[start_date][_gte]': today,
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

  /// Updates the published status of course [id].
  Future<void> updatePublishedStatus(int id, bool published) async {
    await _client.patch('/items/courses/$id', data: {'published': published});
  }

  /// Updates the reviewed status of course [id].
  Future<void> updateReviewedStatus(int id, bool reviewed) async {
    await _client.patch('/items/courses/$id', data: {'reviewed': reviewed});
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

  /// Fetches a single course by [id] and returns it together with the
  /// translation record ID for [languageCode].
  ///
  /// The translation ID is required when constructing PATCH payloads for edits
  /// so Directus updates the existing translation record rather than creating a
  /// new one.
  Future<(Course, int?)> getCourseByIdWithTranslationId(
    int id,
    String languageCode,
  ) async {
    final data = await _client.get(
      '/items/courses/$id',
      queryParameters: {
        'fields': '*,venue.*,translations.*',
        'deep[translations][_filter][languages_code][_eq]': languageCode,
      },
    );
    final json = data as Map<String, dynamic>;
    final translations = (json['translations'] as List<dynamic>?) ?? [];
    final translation = extractTranslation(translations, languageCode);
    final translationId = translation?['id'] as int?;
    final course = Course.fromDirectus(
      json,
      languageCode: languageCode,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
    return (course, translationId);
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
