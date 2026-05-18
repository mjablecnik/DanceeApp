import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/course.dart';
import '../../data/repositories/course_repository.dart';
import '../states/course_detail_state.dart';

class CourseDetailCubit extends Cubit<CourseDetailState> {
  CourseDetailCubit({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(const CourseDetailState.loading());

  final CourseRepository _courseRepository;

  /// Loads course by [courseId].
  ///
  /// If [cachedCourses] is provided and contains the course it is used
  /// immediately (no network call; translationId will be null in that case).
  /// Otherwise the course is fetched from the API together with its translation
  /// record ID.
  Future<void> loadCourse(
    int courseId,
    String languageCode, {
    List<Course>? cachedCourses,
  }) async {
    // Fast path: use the course from the global list cache if available.
    if (cachedCourses != null) {
      final cached = cachedCourses.where((c) => c.id == courseId).firstOrNull;
      if (cached != null) {
        emit(CourseDetailState.loaded(course: cached, translationId: null));
        return;
      }
    }

    // Slow path: fetch from Directus (supports deep links / cold start).
    emit(const CourseDetailState.loading());
    try {
      final (course, translationId) =
          await _courseRepository.getCourseByIdWithTranslationId(
        courseId,
        languageCode,
      );
      emit(CourseDetailState.loaded(course: course, translationId: translationId));
    } catch (e) {
      emit(CourseDetailState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Transitions from [loaded] to [editing] state, enabling the edit form.
  void startEditing() {
    state.maybeMap(
      loaded: (s) => emit(
        CourseDetailState.editing(course: s.course, translationId: s.translationId),
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
    int courseId,
    Map<String, dynamic> modifiedFields,
    String languageCode, {
    Map<String, String> modifiedTextFields = const {},
  }) async {
    final currentCourse = state.maybeMap(
      editing: (s) => s.course,
      orElse: () => null,
    );
    if (currentCourse == null) return;

    emit(CourseDetailState.submitting(course: currentCourse));
    try {
      await _courseRepository.updateCourse(courseId, modifiedFields, languageCode);

      // Fire-and-forget: retranslation must not block the success feedback.
      if (modifiedTextFields.isNotEmpty) {
        _courseRepository.triggerRetranslation(
          courseId,
          'course',
          languageCode,
          modifiedTextFields,
        );
      }

      emit(CourseDetailState.success(course: currentCourse));
    } catch (e) {
      emit(CourseDetailState.error(
        course: currentCourse,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Re-fetches the course from the API after a successful edit so the detail
  /// page shows the latest saved data.
  Future<void> refreshCourse(int courseId, String languageCode) async {
    final previousCourse = state.maybeMap(
      success: (s) => s.course,
      loaded: (s) => s.course,
      error: (s) => s.course,
      orElse: () => null,
    );
    emit(const CourseDetailState.loading());
    try {
      final (course, translationId) =
          await _courseRepository.getCourseByIdWithTranslationId(
        courseId,
        languageCode,
      );
      emit(CourseDetailState.loaded(course: course, translationId: translationId));
    } catch (e) {
      emit(CourseDetailState.error(
        course: previousCourse,
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }
}
