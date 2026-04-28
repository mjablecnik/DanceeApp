import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/course.dart';
import '../../data/entities/dance_style.dart';
import '../../data/repositories/course_repository.dart';
import '../states/course_state.dart';
import '../states/filter_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(const CourseState.initial());

  final CourseRepository _courseRepository;
  List<Course> _allCourses = [];
  FilterState _currentFilters = const FilterState();
  List<DanceStyle> _currentDanceStyles = [];

  /// Fetches courses from CMS for [languageCode], applies current filters, emits loaded state.
  Future<void> loadCourses(String languageCode) async {
    emit(const CourseState.loading());
    try {
      _allCourses = await _courseRepository.getCourses(languageCode);
      _recompute();
    } catch (e) {
      emit(CourseState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Returns the number of courses whose dances match [styleCode] or any of
  /// its child styles resolved via [allDanceStyles].
  int countCoursesForDanceStyle(String styleCode, List<DanceStyle> allDanceStyles) {
    final expandedCodes = <String>{styleCode};
    final expandedNames = <String>{};
    final parent = allDanceStyles.where((s) => s.code == styleCode).firstOrNull;
    if (parent != null) expandedNames.add(parent.name.toLowerCase());
    for (final child in allDanceStyles.where((s) => s.parentCode == styleCode)) {
      expandedCodes.add(child.code);
      expandedNames.add(child.name.toLowerCase());
    }
    return _allCourses
        .where((c) => c.dances.any((d) =>
            expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase())))
        .length;
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

  void _recompute() {
    final filtered = _filterCourses(_allCourses, _currentFilters, _currentDanceStyles);
    emit(CourseState.loaded(
      allCourses: _allCourses,
      filteredCourses: filtered,
    ));
  }
}

List<Course> _filterCourses(
  List<Course> courses,
  FilterState filters,
  List<DanceStyle> allStyles,
) {
  return courses.where((course) {
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
    return true;
  }).toList();
}
