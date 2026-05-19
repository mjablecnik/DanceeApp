import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../states/editor_mode_state.dart';

class EditorModeCubit extends Cubit<EditorModeState> {
  EditorModeCubit() : super(const EditorModeState());

  static const _modeKey = 'editor_mode_enabled';

  /// Reads persisted mode from SharedPreferences and sets isEditor from user role.
  Future<void> init({required bool isEditor}) async {
    final prefs = await SharedPreferences.getInstance();
    final persisted = prefs.getBool(_modeKey) ?? false;
    emit(EditorModeState(isEditorMode: persisted, isEditor: isEditor));
  }

  /// Flips isEditorMode and persists the new value to SharedPreferences.
  Future<void> toggleMode() async {
    final newMode = !state.isEditorMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modeKey, newMode);
    emit(state.copyWith(isEditorMode: newMode));
  }

  /// True only when the user has editor permissions AND has enabled editor mode.
  bool get isEditorMode => state.isEditorMode && state.isEditor;

  bool get isEditor => state.isEditor;
}
