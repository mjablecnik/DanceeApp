import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/dance_style.dart';
import '../../data/entities/event.dart';
import '../../data/repositories/event_repository.dart';
import '../states/event_state.dart';
import '../states/filter_state.dart';
import 'editor_mode_cubit.dart';

/// Sentinel key used to represent the "Abroad" filter option in region filters.
/// Events whose venue country is not in [kCzCountryValues] are grouped under
/// this key.
const kAbroadRegionKey = '__abroad__';

/// Known country values used in Directus data for Czech Republic venues.
const kCzCountryValues = {'CZ', 'Česká republika', 'Česko', 'Czech Republic', 'Czechia'};

class EventCubit extends Cubit<EventState> {
  EventCubit({
    required EventRepository eventRepository,
    EditorModeCubit? editorModeCubit,
  })  : _eventRepository = eventRepository,
        _editorModeCubit = editorModeCubit,
        super(const EventState.initial());

  final EventRepository _eventRepository;
  final EditorModeCubit? _editorModeCubit;
  List<Event> _allEvents = [];
  FilterState _currentFilters = const FilterState();
  List<DanceStyle> _currentDanceStyles = [];

  bool get _isEditorMode => _editorModeCubit?.isEditorMode ?? false;

  /// Fetches events from CMS for [languageCode], applies current filters, emits loaded state.
  /// In editor mode, fetches all events (published and unpublished).
  Future<void> loadEvents(String languageCode) async {
    emit(const EventState.loading());
    try {
      if (_isEditorMode) {
        _allEvents = await _eventRepository.getEventsForEditor(languageCode);
      } else {
        _allEvents = await _eventRepository.getEvents(languageCode);
      }
      _recompute();
    } catch (e) {
      emit(EventState.error(
        message: e is ApiException ? e.message : 'api.errors.generic',
      ));
    }
  }

  /// Applies [filters] client-side with parent/child dance style expansion.
  void applyFilters(FilterState filters, List<DanceStyle> allDanceStyles) {
    _currentFilters = filters;
    _currentDanceStyles = allDanceStyles;
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  /// Returns the number of events that match [styleCode] or any of its child styles.
  ///
  /// Uses [allDanceStyles] to resolve parent-child relationships, so a parent
  /// code like "salsa" also counts events tagged "salsa-on1", "salsa-on2", etc.
  /// Counts are computed against events filtered by the current region selection.
  int countEventsForDanceStyle(String styleCode, List<DanceStyle> allDanceStyles) {
    final expandedCodes = <String>{styleCode};
    final expandedNames = <String>{};
    final parent = allDanceStyles.where((s) => s.code == styleCode).firstOrNull;
    if (parent != null) expandedNames.add(parent.name.toLowerCase());
    for (final child in allDanceStyles.where((s) => s.parentCode == styleCode)) {
      expandedCodes.add(child.code);
      expandedNames.add(child.name.toLowerCase());
    }
    final events = _regionFilteredEvents;
    return events
        .where((e) => e.dances.any((d) =>
            expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase())))
        .length;
  }

  /// Returns events filtered only by the current region selection (ignoring
  /// dance style and duration type filters). Used for dance style counts.
  List<Event> get _regionFilteredEvents {
    if (_currentFilters.selectedRegions.isEmpty) return _allEvents;
    return _allEvents.where((event) {
      final venue = event.venue;
      if (venue == null) return false;
      final isCz = kCzCountryValues.contains(venue.country);
      final abroadSelected = _currentFilters.selectedRegions.contains(kAbroadRegionKey);
      final czRegions = _currentFilters.selectedRegions.where((r) => r != kAbroadRegionKey).toSet();
      if (!isCz) {
        return abroadSelected;
      } else {
        if (czRegions.isEmpty) return false;
        return czRegions.contains(venue.region);
      }
    }).toList();
  }

  /// Returns the number of events that match [region].
  ///
  /// If [region] is [kAbroadRegionKey], counts events whose venue country is
  /// not in [kCzCountryValues]. Otherwise counts events whose venue region
  /// matches [region] and whose country is in [kCzCountryValues].
  int countEventsForRegion(String region) {
    if (region == kAbroadRegionKey) {
      return _allEvents.where((e) {
        final venue = e.venue;
        if (venue == null) return true;
        return !kCzCountryValues.contains(venue.country);
      }).length;
    }
    return _allEvents.where((e) {
      final venue = e.venue;
      if (venue == null) return false;
      return kCzCountryValues.contains(venue.country) && venue.region == region;
    }).length;
  }

  /// Updates the [isFavorited] flag on the event matching [eventId].
  void updateFavoriteStatus(int eventId, bool isFavorited) {
    _allEvents = _allEvents
        .map((e) => e.id == eventId ? e.copyWith(isFavorited: isFavorited) : e)
        .toList();
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  /// Replaces the event matching [eventId] with [updatedEvent] in the cache.
  void replaceEvent(int eventId, Event updatedEvent) {
    _allEvents = _allEvents
        .map((e) => e.id == eventId ? updatedEvent : e)
        .toList();
    state.maybeMap(
      loaded: (_) => _recompute(),
      orElse: () {},
    );
  }

  void _recompute() {
    final filtered = _filterEvents(_allEvents, _currentFilters, _currentDanceStyles);
    final deduped = _deduplicateEvents(filtered);
    final featured = deduped.where((e) => e.eventType == 'festival' || e.eventType == 'holiday').toList();
    emit(EventState.loaded(
      allEvents: _allEvents,
      filteredEvents: deduped,
      featuredEvents: featured,
    ));
  }
}

/// Removes duplicate events that share the same title and start date.
/// Keeps the first occurrence.
List<Event> _deduplicateEvents(List<Event> events) {
  final seen = <String>{};
  return events.where((e) {
    final key = '${e.title}|${e.startTime.toIso8601String().substring(0, 10)}';
    return seen.add(key);
  }).toList();
}

List<Event> _filterEvents(
  List<Event> events,
  FilterState filters,
  List<DanceStyle> allStyles,
) {
  return events.where((event) {
    if (filters.selectedEventDurationTypes.isNotEmpty) {
      if (!filters.selectedEventDurationTypes.contains(event.durationType.name)) {
        return false;
      }
    }
    if (filters.selectedDanceStyles.isNotEmpty) {
      final expandedCodes = <String>{};
      final expandedNames = <String>{};
      for (final code in filters.selectedDanceStyles) {
        expandedCodes.add(code);
        final parent = allStyles.where((s) => s.code == code).firstOrNull;
        if (parent != null) expandedNames.add(parent.name.toLowerCase());
        for (final child in allStyles.where((s) => s.parentCode == code)) {
          expandedCodes.add(child.code);
          expandedNames.add(child.name.toLowerCase());
        }
      }
      if (!event.dances.any((d) =>
          expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase()))) {
        return false;
      }
    }
    if (filters.selectedRegions.isNotEmpty) {
      final venue = event.venue;
      if (venue == null) return false;
      final isCz = kCzCountryValues.contains(venue.country);
      final abroadSelected = filters.selectedRegions.contains(kAbroadRegionKey);
      final czRegions = filters.selectedRegions.where((r) => r != kAbroadRegionKey).toSet();

      if (!isCz) {
        // Foreign event: only include if "Abroad" is selected.
        if (!abroadSelected) return false;
      } else {
        // CZ event: include if any CZ region matches, or if no CZ regions are
        // selected at all (only "Abroad" is selected — exclude CZ events).
        if (czRegions.isEmpty) return false;
        if (!czRegions.contains(venue.region)) return false;
      }
    }
    if (filters.publishedFilter != null) {
      final wantPublished = filters.publishedFilter == 'published';
      if (event.published != wantPublished) return false;
    }
    if (filters.reviewedFilter != null) {
      final wantReviewed = filters.reviewedFilter == 'reviewed';
      if (event.reviewed != wantReviewed) return false;
    }
    return true;
  }).toList();
}
