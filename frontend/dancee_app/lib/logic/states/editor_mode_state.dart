import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_mode_state.freezed.dart';

@freezed
class EditorModeState with _$EditorModeState {
  const factory EditorModeState({
    @Default(false) bool isEditorMode,
    @Default(false) bool isEditor,
  }) = _EditorModeState;
}
