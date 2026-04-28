import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/entities/course.dart';

part 'course_state.freezed.dart';

@freezed
class CourseState with _$CourseState {
  const factory CourseState.initial() = _Initial;
  const factory CourseState.loading() = _Loading;
  const factory CourseState.loaded({
    required List<Course> allCourses,
    required List<Course> filteredCourses,
  }) = _Loaded;
  const factory CourseState.error({required String message}) = _Error;
}
