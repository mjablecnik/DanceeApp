import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/course.dart';
import '../../data/entities/dance_style.dart';
import '../../data/repositories/course_repository.dart';
import '../states/course_state.dart';
import '../states/filter_state.dart';
import 'editor_mode_cubit.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit({
    required CourseRepository courseRepository,
    EditorModeCubit? editorModeCubit,
  })  : _courseRepository = courseRepository,
        _editorModeCubit = editorModeCubit,
        super(const CourseState.initial());

  final CourseRepository _courseRepository;
  final EditorModeCubit? _editorModeCubit;
  List<Course> _allCourses = [];
  FilterState _currentFilters = const FilterState();
  List<DanceStyle> _currentDanceStyles = [];

  bool get _isEditorMode => _editorModeCubit?.isEditorMode ?? false;

  /// Fetches courses from CMS for [languageCode], applies current filters, emits loaded state.
  /// In editor mode, fetches all courses (including past ones and unpublished).
  Future<void> loadCourses(String languageCode) async {
    emit(const CourseState.loading());
    try {
      if (_isEditorMode) {
        _allCourses = await _courseRepository.getCoursesForEditor(languageCode);
      } else {
        _allCourses = await _courseRepository.getCourses(languageCode);
      }
      _recompute();
    } catch (e) {
      emit(CourseState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Returns the number of courses whose dances match [styleCode] or any of
  /// its child styles resolved via [allDanceStyles].
  /// Counts are computed against courses filtered by the current region selection.
  int countCoursesForDanceStyle(String styleCode, List<DanceStyle> allDanceStyles) {
    final expandedCodes = <String>{styleCode};
    final expandedNames = <String>{};
    final parent = allDanceStyles.where((s) => s.code == styleCode).firstOrNull;
    if (parent != null) expandedNames.add(parent.name.toLowerCase());
    for (final child in allDanceStyles.where((s) => s.parentCode == styleCode)) {
      expandedCodes.add(child.code);
      expandedNames.add(child.name.toLowerCase());
    }
    final courses = _regionFilteredCourses;
    return courses
        .where((c) => c.dances.any((d) =>
            expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase())))
        .length;
  }

  /// Returns courses filtered only by the current region selection (ignoring
  /// dance style and course type filters). Used for dance style counts.
  List<Course> get _regionFilteredCourses {
    if (_currentFilters.selectedRegions.isEmpty) return _allCourses;
    return _allCourses.where((course) {
      if (course.venue == null) return false;
      return _currentFilters.selectedRegions.contains(course.venue!.region);
    }).toList();
  }

  /// Returns the number of courses whose venue region matches [region].
  int countCoursesForRegion(String region) {
    return _allCourses.where((c) {
      final venue = c.venue;
      if (venue == null) return false;
      return venue.region == region;
    }).length;
  }

  /// Applies [filters] client-side with parent/child dance style expansion.
  void applyFilters(FilterState filters, List<DanceStyle> allDanceStyles) {
    _currentFilters = filters;
    _currentDanceStyles = allDanceStyles;
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  /// Updates the [isFavorited] flag on the course matching [courseId].
  void updateFavoriteStatus(int courseId, bool isFavorited) {
    _allCourses = _allCourses
        .map((c) => c.id == courseId ? c.copyWith(isFavorited: isFavorited) : c)
        .toList();
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  /// Replaces the course matching [courseId] with [updatedCourse] in the cache.
  void replaceCourse(int courseId, Course updatedCourse) {
    _allCourses = _allCourses
        .map((c) => c.id == courseId ? updatedCourse : c)
        .toList();
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  void _recompute() {
    final filtered = _filterCourses(
      _allCourses,
      _currentFilters,
      _currentDanceStyles,
      isEditorMode: _isEditorMode,
    );
    emit(CourseState.loaded(
      allCourses: _allCourses,
      filteredCourses: filtered,
    ));
  }
}

List<Course> _filterCourses(
  List<Course> courses,
  FilterState filters,
  List<DanceStyle> allStyles, {
  bool isEditorMode = false,
}) {
  final today = DateTime.now();
  final todayStr =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  return courses.where((course) {
    // User mode: hide courses whose start date has already passed.
    if (!isEditorMode) {
      final startDate = course.startDate;
      if (startDate != null && startDate.compareTo(todayStr) < 0) return false;
    }
    if (filters.selectedCourseTypes.isNotEmpty) {
      if (!filters.selectedCourseTypes.contains(course.courseType.name)) {
        return false;
      }
    }
    if (filters.selectedDanceStyles.isNotEmpty) {
      final expandedCodes = <String>{};
      final expandedNames = <String>{};
      for (final code in filters.selectedDanceStyles) {
        expandedCodes.add(code);
        final parent = allStyles.where((s) => s.code == code).firstOrNull;
        if (parent != null) expandedNames.add(parent.name.toLowerCase());
        for (final child in allStyles.where((s) => s.parentCode == code)) {
          expandedCodes.add(child.code);
          expandedNames.add(child.name.toLowerCase());
        }
      }
      if (!course.dances.any((d) =>
          expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase()))) {
        return false;
      }
    }
    if (filters.selectedRegions.isNotEmpty) {
      if (course.venue == null ||
          !filters.selectedRegions.contains(course.venue!.region)) {
        return false;
      }
    }
    if (filters.publishedFilter != null) {
      final wantPublished = filters.publishedFilter == 'published';
      if (course.published != wantPublished) return false;
    }
    if (filters.reviewedFilter != null) {
      final wantReviewed = filters.reviewedFilter == 'reviewed';
      if (course.reviewed != wantReviewed) return false;
    }
    return true;
  }).toList();
}
