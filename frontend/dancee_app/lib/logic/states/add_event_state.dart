import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_event_state.freezed.dart';

@freezed
class AddEventState with _$AddEventState {
  const factory AddEventState.idle() = _Idle;
  const factory AddEventState.submitting() = _Submitting;
  const factory AddEventState.success() = _Success;
  const factory AddEventState.error({required String message}) = _Error;
}
