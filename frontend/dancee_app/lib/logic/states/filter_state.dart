import 'package:equatable/equatable.dart';

import '../../data/entities/dance_style.dart';

class FilterState extends Equatable {
  const FilterState({
    this.selectedDanceStyles = const {},
    this.selectedRegions = const {},
    this.danceStyles = const [],
    this.selectedEventDurationTypes = const {},
    this.selectedCourseTypes = const {},
    this.publishedFilter,
    this.reviewedFilter,
  });

  final Set<String> selectedDanceStyles;
  final Set<String> selectedRegions;
  final Set<String> selectedEventDurationTypes;
  final Set<String> selectedCourseTypes;

  /// Editor filter: 'published', 'unpublished', or null for all.
  final String? publishedFilter;

  /// Editor filter: 'reviewed', 'unreviewed', or null for all.
  final String? reviewedFilter;

  /// All dance styles loaded from the CMS (both parents and children).
  final List<DanceStyle> danceStyles;

  /// Only parent dance styles (those with no parentCode) — for filter display.
  List<DanceStyle> get parentDanceStyles =>
      danceStyles.where((s) => s.parentCode == null).toList();

  bool get hasActiveFilters =>
      selectedDanceStyles.isNotEmpty ||
      selectedRegions.isNotEmpty ||
      selectedEventDurationTypes.isNotEmpty ||
      selectedCourseTypes.isNotEmpty ||
      publishedFilter != null ||
      reviewedFilter != null;

  FilterState copyWith({
    Set<String>? selectedDanceStyles,
    Set<String>? selectedRegions,
    List<DanceStyle>? danceStyles,
    Set<String>? selectedEventDurationTypes,
    Set<String>? selectedCourseTypes,
    Object? publishedFilter = _sentinel,
    Object? reviewedFilter = _sentinel,
  }) {
    return FilterState(
      selectedDanceStyles: selectedDanceStyles ?? this.selectedDanceStyles,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      danceStyles: danceStyles ?? this.danceStyles,
      selectedEventDurationTypes: selectedEventDurationTypes ?? this.selectedEventDurationTypes,
      selectedCourseTypes: selectedCourseTypes ?? this.selectedCourseTypes,
      publishedFilter: publishedFilter == _sentinel ? this.publishedFilter : publishedFilter as String?,
      reviewedFilter: reviewedFilter == _sentinel ? this.reviewedFilter : reviewedFilter as String?,
    );
  }

  @override
  List<Object?> get props => [
        selectedDanceStyles,
        selectedRegions,
        danceStyles,
        selectedEventDurationTypes,
        selectedCourseTypes,
        publishedFilter,
        reviewedFilter,
      ];
}

const Object _sentinel = Object();
