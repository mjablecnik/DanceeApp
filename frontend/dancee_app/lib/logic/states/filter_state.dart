import 'package:equatable/equatable.dart';

import '../../data/entities/dance_style.dart';

class FilterState extends Equatable {
  const FilterState({
    this.selectedDanceStyles = const {},
    this.selectedRegions = const {},
    this.danceStyles = const [],
    this.selectedEventDurationTypes = const {},
    this.selectedCourseTypes = const {},
  });

  final Set<String> selectedDanceStyles;
  final Set<String> selectedRegions;
  final Set<String> selectedEventDurationTypes;
  final Set<String> selectedCourseTypes;

  /// All dance styles loaded from the CMS (both parents and children).
  final List<DanceStyle> danceStyles;

  /// Only parent dance styles (those with no parentCode) — for filter display.
  List<DanceStyle> get parentDanceStyles =>
      danceStyles.where((s) => s.parentCode == null).toList();

  bool get hasActiveFilters =>
      selectedDanceStyles.isNotEmpty ||
      selectedRegions.isNotEmpty ||
      selectedEventDurationTypes.isNotEmpty ||
      selectedCourseTypes.isNotEmpty;

  FilterState copyWith({
    Set<String>? selectedDanceStyles,
    Set<String>? selectedRegions,
    List<DanceStyle>? danceStyles,
    Set<String>? selectedEventDurationTypes,
    Set<String>? selectedCourseTypes,
  }) {
    return FilterState(
      selectedDanceStyles: selectedDanceStyles ?? this.selectedDanceStyles,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      danceStyles: danceStyles ?? this.danceStyles,
      selectedEventDurationTypes: selectedEventDurationTypes ?? this.selectedEventDurationTypes,
      selectedCourseTypes: selectedCourseTypes ?? this.selectedCourseTypes,
    );
  }

  @override
  List<Object?> get props => [
        selectedDanceStyles,
        selectedRegions,
        danceStyles,
        selectedEventDurationTypes,
        selectedCourseTypes,
      ];
}
