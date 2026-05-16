import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/entities/dance_style.dart';
import '../../data/repositories/dance_style_repository.dart';
import '../states/filter_state.dart';

// FilterCubit mixes in ChangeNotifier so that widgets can subscribe via
// ListenableBuilder and receive synchronous rebuilds when filter state changes.
// This is necessary because BlocBuilder's stream-based delivery is asynchronous
// and requires two pump() calls in tests, whereas ChangeNotifier.notifyListeners()
// fires synchronously, scheduling a frame before the next pump().
class FilterCubit extends Cubit<FilterState> with ChangeNotifier {
  FilterCubit({required DanceStyleRepository danceStyleRepository})
      : _danceStyleRepository = danceStyleRepository,
        super(const FilterState());

  final DanceStyleRepository _danceStyleRepository;

  /// All loaded dance styles — available for UI and filter expansion logic.
  List<DanceStyle> get allDanceStyles => state.danceStyles;

  /// Only parent dance styles (those with no parentCode) — for filter display.
  List<DanceStyle> get parentDanceStyles => state.parentDanceStyles;

  /// Fetches dance styles from CMS with [languageCode] translations and stores
  /// them in state so BlocBuilder widgets react when styles become available.
  Future<void> loadDanceStyles(String languageCode) async {
    try {
      final styles = await _danceStyleRepository.getDanceStyles(languageCode);
      emit(state.copyWith(danceStyles: styles));
      notifyListeners();
    } catch (_) {
      // Non-fatal — filter UI degrades gracefully without dance styles
    }
  }

  void setDanceStyles(Set<String> codes) {
    emit(state.copyWith(selectedDanceStyles: codes));
    notifyListeners();
  }

  void toggleDanceType(String code) {
    final current = Set<String>.from(state.selectedDanceStyles);
    if (current.contains(code)) {
      current.remove(code);
    } else {
      current.add(code);
    }
    emit(state.copyWith(selectedDanceStyles: current));
    notifyListeners();
  }

  void setLocations(Set<String> regions) {
    emit(state.copyWith(selectedRegions: regions));
    notifyListeners();
  }

  void toggleEventDurationType(String type) {
    final current = state.selectedEventDurationTypes;
    if (current.contains(type)) {
      emit(state.copyWith(selectedEventDurationTypes: {}));
    } else {
      emit(state.copyWith(selectedEventDurationTypes: {type}));
    }
    notifyListeners();
  }

  void toggleCourseType(String type) {
    final current = state.selectedCourseTypes;
    if (current.contains(type)) {
      emit(state.copyWith(selectedCourseTypes: {}));
    } else {
      emit(state.copyWith(selectedCourseTypes: {type}));
    }
    notifyListeners();
  }

  void clearEventDurationTypes() {
    emit(state.copyWith(selectedEventDurationTypes: {}));
    notifyListeners();
  }

  void clearCourseTypes() {
    emit(state.copyWith(selectedCourseTypes: {}));
    notifyListeners();
  }

  void clearAll() {
    emit(state.copyWith(
      selectedDanceStyles: {},
      selectedRegions: {},
      selectedEventDurationTypes: {},
      selectedCourseTypes: {},
    ));
    notifyListeners();
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}
