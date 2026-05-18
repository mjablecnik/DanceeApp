import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/entities/event.dart';

part 'event_detail_state.freezed.dart';

@freezed
class EventDetailState with _$EventDetailState {
  const factory EventDetailState.loading() = _Loading;
  const factory EventDetailState.loaded({
    required Event event,
    required int? translationId,
  }) = _Loaded;
  const factory EventDetailState.editing({
    required Event event,
    required int? translationId,
  }) = _Editing;
  const factory EventDetailState.submitting({required Event event}) = _Submitting;
  const factory EventDetailState.success({required Event event}) = _Success;
  const factory EventDetailState.error({
    Event? event,
    required String message,
  }) = _Error;
}
