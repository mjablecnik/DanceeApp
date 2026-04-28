import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_filter.dart';
import '../../logic/event_list.dart';
import 'sections.dart';

part 'event_filters_page.g.dart';

/// Route definition for the event filters page.
///
/// Accepts an optional [scrollTo] query parameter to auto-scroll to a section
/// ('date' or 'location') on open.
@TypedGoRoute<EventFiltersRoute>(path: '/events/filters')
class EventFiltersRoute extends GoRouteData {
  final String? scrollTo;

  const EventFiltersRoute({this.scrollTo});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: EventFiltersPage(scrollTo: scrollTo));
  }
}

/// Page for filtering and sorting dance events.
///
/// Maintains a local draft [FilterState] for live preview. Filters are only
/// pushed to [EventFilterCubit] when the user taps "Apply filters".
class EventFiltersPage extends StatefulWidget {
  final String? scrollTo;

  const EventFiltersPage({super.key, this.scrollTo});

  @override
  State<EventFiltersPage> createState() => _EventFiltersPageState();
}

class _EventFiltersPageState extends State<EventFiltersPage> {
  late FilterState _draft;
  final _scrollController = ScrollController();
  final _locationSectionKey = GlobalKey();
  final _dateSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _draft = getIt<EventFilterCubit>().state.filters;
    if (widget.scrollTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Small delay to ensure ListView has laid out off-screen sections
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _scrollToSection(widget.scrollTo!);
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Event> get _allEvents {
    final s = getIt<EventListCubit>().state;
    if (s is EventListLoaded) return s.allEvents;
    return const [];
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    if (section == 'date') {
      // Date section is below location in the ListView and may not be laid out
      // yet. First scroll to location to force layout, then scroll to date.
      if (_locationSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _locationSectionKey.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _dateSectionKey.currentContext != null) {
              Scrollable.ensureVisible(
                _dateSectionKey.currentContext!,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          });
        });
      }
      return;
    }
    if (section == 'location') key = _locationSectionKey;
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateDraft(FilterState newDraft) {
    // Auto-swap if both dates are set and dateFrom > dateTo to prevent
    // invalid ranges that would silently return zero results.
    FilterState validated = newDraft;
    if (newDraft.dateFrom != null &&
        newDraft.dateTo != null &&
        newDraft.dateFrom!.isAfter(newDraft.dateTo!)) {
      validated = newDraft.copyWith(
        dateFrom: newDraft.dateTo,
        dateTo: newDraft.dateFrom,
      );
    }
    setState(() => _draft = validated);
  }

  Future<void> _pickDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      var newDraft = _draft.copyWith(dateFrom: date);
      // Auto-swap if dateFrom > dateTo
      if (newDraft.dateTo != null && date.isAfter(newDraft.dateTo!)) {
        newDraft = newDraft.copyWith(dateFrom: newDraft.dateTo, dateTo: date);
      }
      _updateDraft(newDraft);
    }
  }

  Future<void> _pickDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      var newDraft = _draft.copyWith(dateTo: date);
      // Auto-swap if dateTo < dateFrom
      if (newDraft.dateFrom != null && date.isBefore(newDraft.dateFrom!)) {
        newDraft = newDraft.copyWith(dateTo: newDraft.dateFrom, dateFrom: date);
      }
      _updateDraft(newDraft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = _allEvents;
    final danceTypes = extractDanceTypes(allEvents);
    final regions = extractRegions(allEvents);
    final matchingCount = filterEvents(allEvents, _draft).length;
    final activeCount = getActiveFilterCount(_draft);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          EventFiltersHeaderSection(
            onBackPressed: () => context.pop(),
            onResetPressed: () {
              _updateDraft(const FilterState());
            },
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                ActiveFiltersSummary(
                  activeCount: activeCount,
                  matchingCount: matchingCount,
                ),
                const SizedBox(height: 24),
                DanceTypeFilterSection(
                  danceTypes: danceTypes,
                  selectedTypes: _draft.selectedDanceTypes,
                  allEvents: allEvents,
                  filters: _draft,
                  onToggle: (type) {
                    final newSet = Set<String>.from(_draft.selectedDanceTypes);
                    if (newSet.contains(type)) {
                      newSet.remove(type);
                    } else {
                      newSet.add(type);
                    }
                    _updateDraft(_draft.copyWith(selectedDanceTypes: newSet));
                  },
                  onClear: () =>
                      _updateDraft(_draft.copyWith(selectedDanceTypes: const {})),
                ),
                const SizedBox(height: 24),
                LocationFilterSection(
                  key: _locationSectionKey,
                  regions: regions,
                  selectedRegions: _draft.selectedRegions,
                  allEvents: allEvents,
                  filters: _draft,
                  onToggle: (region) {
                    final newSet = Set<String>.from(_draft.selectedRegions);
                    if (newSet.contains(region)) {
                      newSet.remove(region);
                    } else {
                      newSet.add(region);
                    }
                    _updateDraft(_draft.copyWith(selectedRegions: newSet));
                  },
                  onClear: () =>
                      _updateDraft(_draft.copyWith(selectedRegions: const {})),
                ),
                const SizedBox(height: 24),
                DateRangeFilterSection(
                  key: _dateSectionKey,
                  dateFrom: _draft.dateFrom,
                  dateTo: _draft.dateTo,
                  onDateFromTap: _pickDateFrom,
                  onDateToTap: _pickDateTo,
                  onTodayPreset: () {
                    final (from, to) = todayPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onTomorrowPreset: () {
                    final (from, to) = tomorrowPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onThisWeekPreset: () {
                    final (from, to) = thisWeekPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onWeekendPreset: () {
                    final (from, to) = weekendPreset(DateTime.now());
                    _updateDraft(_draft.copyWith(dateFrom: from, dateTo: to));
                  },
                  onClear: () => _updateDraft(
                      _draft.copyWith(dateFrom: null, dateTo: null)),
                ),
                const SizedBox(height: 24),
                SaveFilterSection(
                  onSave: () async {
                    try {
                      await getIt<EventFilterCubit>().persistFilters(_draft);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.eventFilters.filtersSaved),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e, st) {
                      developer.log(
                        'Failed to save filters',
                        error: e,
                        stackTrace: st,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.eventFilters.filtersSaveError),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          FilterFooterActions(
            matchingCount: matchingCount,
            onClearAll: () {
              _updateDraft(const FilterState());
              getIt<EventFilterCubit>().applyFilters(const FilterState());
            },
            onApply: () {
              getIt<EventFilterCubit>().applyFilters(_draft);
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
