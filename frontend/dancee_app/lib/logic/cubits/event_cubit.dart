import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/exceptions.dart';
import '../../data/entities/dance_style.dart';
import '../../data/entities/event.dart';
import '../../data/repositories/event_repository.dart';
import '../states/event_state.dart';
import '../states/filter_state.dart';

/// Sentinel key used to represent the "Abroad" filter option in region filters.
/// Events whose venue country is not in [kCzCountryValues] are grouped under
/// this key.
const kAbroadRegionKey = '__abroad__';

/// Known country values used in Directus data for Czech Republic venues.
const kCzCountryValues = {'CZ', 'Česká republika', 'Česko', 'Czech Republic', 'Czechia'};

class EventCubit extends Cubit<EventState> {
  EventCubit({required EventRepository eventRepository})
      : _eventRepository = eventRepository,
        super(const EventState.initial());

  final EventRepository _eventRepository;
  List<Event> _allEvents = [];
  FilterState _currentFilters = const FilterState();
  List<DanceStyle> _currentDanceStyles = [];

  /// Fetches events from CMS for [languageCode], applies current filters, emits loaded state.
  Future<void> loadEvents(String languageCode) async {
    emit(const EventState.loading());
    try {
      _allEvents = await _eventRepository.getEvents(languageCode);
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
  int countEventsForDanceStyle(String styleCode, List<DanceStyle> allDanceStyles) {
    final expandedCodes = <String>{styleCode};
    final expandedNames = <String>{};
    final parent = allDanceStyles.where((s) => s.code == styleCode).firstOrNull;
    if (parent != null) expandedNames.add(parent.name.toLowerCase());
    for (final child in allDanceStyles.where((s) => s.parentCode == styleCode)) {
      expandedCodes.add(child.code);
      expandedNames.add(child.name.toLowerCase());
    }
    return _allEvents
        .where((e) => e.dances.any((d) =>
            expandedCodes.contains(d) || expandedNames.contains(d.toLowerCase())))
        .length;
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

  void _recompute() {
    final filtered = _filterEvents(_allEvents, _currentFilters, _currentDanceStyles);
    final deduped = _deduplicateEvents(filtered);
    final featured = deduped.where((e) => e.eventType == 'festival').toList();
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
    return true;
  }).toList();
}
