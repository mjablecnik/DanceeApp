import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/entities/course.dart';

part 'course_detail_state.freezed.dart';

@freezed
class CourseDetailState with _$CourseDetailState {
  const factory CourseDetailState.loading() = _Loading;
  const factory CourseDetailState.loaded({
    required Course course,
    required int? translationId,
  }) = _Loaded;
  const factory CourseDetailState.editing({
    required Course course,
    required int? translationId,
  }) = _Editing;
  const factory CourseDetailState.submitting({required Course course}) = _Submitting;
  const factory CourseDetailState.success({required Course course}) = _Success;
  const factory CourseDetailState.error({
    Course? course,
    required String message,
  }) = _Error;
}
