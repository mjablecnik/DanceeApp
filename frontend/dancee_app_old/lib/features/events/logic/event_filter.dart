import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/entities.dart';
import '../data/filter_persistence_service.dart';
import 'event_list.dart';

part 'event_filter.freezed.dart';
part 'event_filter.g.dart';

// ============================================================================
// FilterState
// ============================================================================

/// Immutable data class holding all filter criteria.
@freezed
class FilterState with _$FilterState {
  const factory FilterState({
    @Default('') String searchQuery,
    @Default(<String>{}) Set<String> selectedDanceTypes,
    @Default(<String>{}) Set<String> selectedRegions,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) = _FilterState;

  factory FilterState.fromJson(Map<String, dynamic> json) =>
      _$FilterStateFromJson(json);
}

// ============================================================================
// EventFilterState
// ============================================================================

/// State emitted by [EventFilterCubit].
@freezed
class EventFilterState with _$EventFilterState {
  const factory EventFilterState({
    required FilterState filters,
    required List<Event> filteredEvents,
    required List<Event> todayEvents,
    required List<Event> tomorrowEvents,
    required List<Event> upcomingEvents,
  }) = _EventFilterState;
}

// ============================================================================
// Pure filter function
// ============================================================================

/// Applies [filters] to [events] using AND logic.
///
/// Empty/unset filter criteria impose no restriction.
List<Event> filterEvents(List<Event> events, FilterState filters) {
  return events.where((event) {
    // Text search — case-insensitive title match
    final query = filters.searchQuery.trim();
    if (query.isNotEmpty) {
      if (!event.title.toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
    }
    // Dance type — event must contain at least one selected dance type
    if (filters.selectedDanceTypes.isNotEmpty) {
      if (!event.dances.any((d) => filters.selectedDanceTypes.contains(d))) {
        return false;
      }
    }
    // Region — event venue region must match one of selected regions
    if (filters.selectedRegions.isNotEmpty) {
      if (!filters.selectedRegions.contains(event.venue.region)) {
        return false;
      }
    }
    // Date range — event startTime must fall within range (inclusive)
    if (filters.dateFrom != null) {
      final fromStart = DateTime(
        filters.dateFrom!.year,
        filters.dateFrom!.month,
        filters.dateFrom!.day,
      );
      if (event.startTime.isBefore(fromStart)) return false;
    }
    if (filters.dateTo != null) {
      final toEnd = DateTime(
        filters.dateTo!.year,
        filters.dateTo!.month,
        filters.dateTo!.day,
        23,
        59,
        59,
      );
      if (event.startTime.isAfter(toEnd)) return false;
    }
    return true;
  }).toList();
}

/// Returns unique dance types from all events, sorted by event count descending.
List<String> extractDanceTypes(List<Event> events) {
  final counts = <String, int>{};
  for (final event in events) {
    for (final dance in event.dances) {
      counts[dance] = (counts[dance] ?? 0) + 1;
    }
  }
  final sorted = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return sorted;
}

/// Returns unique non-empty regions from all events, sorted by event count descending.
List<String> extractRegions(List<Event> events) {
  final counts = <String, int>{};
  for (final event in events) {
    if (event.venue.region.isNotEmpty) {
      counts[event.venue.region] = (counts[event.venue.region] ?? 0) + 1;
    }
  }
  final sorted = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return sorted;
}

/// Returns the count of events matching all active filters except dance type
/// selection, then intersected with [danceType].
int countEventsForDanceType(
  List<Event> events,
  String danceType,
  FilterState filters,
) {
  final filtersWithoutDanceType = filters.copyWith(selectedDanceTypes: {danceType});
  return filterEvents(events, filtersWithoutDanceType).length;
}

/// Returns the count of events matching all active filters except region
/// selection, then intersected with [region].
int countEventsForRegion(
  List<Event> events,
  String region,
  FilterState filters,
) {
  final filtersWithoutRegion = filters.copyWith(selectedRegions: {region});
  return filterEvents(events, filtersWithoutRegion).length;
}

/// Returns the number of active filter categories.
int getActiveFilterCount(FilterState filters) {
  var count = 0;
  if (filters.searchQuery.trim().isNotEmpty) count++;
  if (filters.selectedDanceTypes.isNotEmpty) count++;
  if (filters.selectedRegions.isNotEmpty) count++;
  if (filters.dateFrom != null || filters.dateTo != null) count++;
  return count;
}

// ============================================================================
// Date grouping helpers (shared with EventListCubit)
// ============================================================================

/// Groups [events] that fall on today's date and are not past.
List<Event> groupToday(List<Event> events, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return events.where((e) {
    final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
    return d.isAtSameMomentAs(today) && !e.isPast;
  }).toList();
}

/// Groups [events] that fall on tomorrow's date and are not past.
List<Event> groupTomorrow(List<Event> events, DateTime now) {
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return events.where((e) {
    final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
    return d.isAtSameMomentAs(tomorrow) && !e.isPast;
  }).toList();
}

/// Groups [events] that fall after tomorrow and are not past.
List<Event> groupUpcoming(List<Event> events, DateTime now) {
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return events.where((e) {
    final d = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
    return d.isAfter(tomorrow) && !e.isPast;
  }).toList();
}

// ============================================================================
// Quick date preset helpers
// ============================================================================

/// Computes dateFrom/dateTo for the "Today" preset.
(DateTime, DateTime) todayPreset(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return (start, end);
}

/// Computes dateFrom/dateTo for the "Tomorrow" preset.
(DateTime, DateTime) tomorrowPreset(DateTime now) {
  final tomorrow = now.add(const Duration(days: 1));
  final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  final end = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
  return (start, end);
}

/// Computes dateFrom/dateTo for the "This Week" preset (today through Sunday).
(DateTime, DateTime) thisWeekPreset(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  // weekday: 1=Monday ... 7=Sunday
  final daysUntilSunday = 7 - now.weekday;
  final sunday = now.add(Duration(days: daysUntilSunday));
  final end = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  return (start, end);
}

/// Computes dateFrom/dateTo for the "Weekend" preset (Saturday through Sunday).
(DateTime, DateTime) weekendPreset(DateTime now) {
  // If today is Saturday (6), use today as start through tomorrow (Sunday).
  // If today is Sunday (7), show the current weekend: yesterday (Saturday) to today.
  // Otherwise look forward to the next Saturday.
  if (now.weekday == 7) {
    // Sunday — show the whole current weekend: yesterday (Saturday) to today (Sunday)
    final saturday = now.subtract(const Duration(days: 1));
    final start = DateTime(saturday.year, saturday.month, saturday.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return (start, end);
  }
  final daysUntilSaturday = now.weekday == 6 ? 0 : 6 - now.weekday;
  final saturday = now.add(Duration(days: daysUntilSaturday));
  final sunday = saturday.add(const Duration(days: 1));
  final start = DateTime(saturday.year, saturday.month, saturday.day);
  final end = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  return (start, end);
}

// ============================================================================
// EventFilterCubit
// ============================================================================

/// Cubit that applies filter logic to the event list from [EventListCubit].
class EventFilterCubit extends Cubit<EventFilterState> {
  final EventListCubit _eventListCubit;
  final FilterPersistenceService _persistenceService;
  StreamSubscription<EventListState>? _eventListSubscription;
  Timer? _debounceTimer;

  EventFilterCubit(this._eventListCubit, this._persistenceService)
      : super(
          const EventFilterState(
            filters: FilterState(),
            filteredEvents: [],
            todayEvents: [],
            tomorrowEvents: [],
            upcomingEvents: [],
          ),
        ) {
    _eventListSubscription = _eventListCubit.stream.listen(_onEventListState);
    // Apply to current state if already loaded
    _onEventListState(_eventListCubit.state);
  }

  void _onEventListState(EventListState eventListState) {
    if (eventListState is EventListLoaded) {
      _recompute(eventListState.allEvents, state.filters);
    }
  }

  List<Event> _allEvents() {
    final s = _eventListCubit.state;
    if (s is EventListLoaded) return s.allEvents;
    return const [];
  }

  void _recompute(List<Event> allEvents, FilterState filters) {
    final filtered = filterEvents(allEvents, filters);
    final now = DateTime.now();
    emit(EventFilterState(
      filters: filters,
      filteredEvents: filtered,
      todayEvents: groupToday(filtered, now),
      tomorrowEvents: groupTomorrow(filtered, now),
      upcomingEvents: groupUpcoming(filtered, now),
    ));
  }

  /// Sets new filters and recomputes the filtered event list.
  void applyFilters(FilterState filters) {
    _recompute(_allEvents(), filters);
  }

  /// Resets all filters to default empty state and clears saved filters.
  Future<void> resetFilters() async {
    await _persistenceService.clearFilters();
    _recompute(_allEvents(), const FilterState());
  }

  /// Persists the current [FilterState] via [FilterPersistenceService].
  Future<void> saveFilters() async {
    await _persistenceService.saveFilters(state.filters);
  }

  /// Persists an arbitrary [FilterState] without applying it to the cubit state.
  ///
  /// Use this to save a draft filter for next app launch without changing the
  /// currently applied filters.
  Future<void> persistFilters(FilterState filters) async {
    await _persistenceService.saveFilters(filters);
  }

  /// Loads and restores a previously saved [FilterState] from persistence.
  ///
  /// Falls back to the default empty state if no filters are saved or if
  /// loading fails.
  Future<void> restoreFilters() async {
    final saved = await _persistenceService.loadFilters();
    if (saved != null) {
      _recompute(_allEvents(), saved);
    }
  }

  /// Updates the search query with a 300ms debounce.
  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final newFilters = state.filters.copyWith(searchQuery: query);
      _recompute(_allEvents(), newFilters);
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _eventListSubscription?.cancel();
    return super.close();
  }
}
