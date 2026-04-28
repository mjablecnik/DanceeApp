import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../design/widgets.dart';
import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_filter.dart';
import '../../logic/event_list.dart';
import '../event_detail/event_detail_page.dart';
import 'components.dart' as components;

// ============================================================================
// EventListHeaderSection
// ============================================================================

/// Pinned SliverAppBar with gradient background, animated logo icon, and
/// "Dancee" title. Sizes interpolate between expanded and collapsed states.
class EventListHeaderSection extends StatelessWidget {
  const EventListHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100.0,
      collapsedHeight: 70,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double appBarHeight = constraints.biggest.height;
          const double expandedHeight = 120.0;
          const double collapsedHeight = 60.0;

          final double progress = ((expandedHeight - appBarHeight) /
                  (expandedHeight - collapsedHeight))
              .clamp(0.0, 1.0);

          final double iconSize = 48.0 - (16.0 * progress);
          final double iconInnerSize = 24.0 - (8.0 * progress);
          final double borderRadius = 12.0 - (4.0 * progress);
          final double titleFontSize = 32.0 - (16.0 * progress);

          return HeaderBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    LogoIcon(
                      size: iconSize,
                      innerSize: iconInnerSize,
                      borderRadius: borderRadius,
                      animationProgress: progress,
                    ),
                    SizedBox(width: 12.0 * (1.0 - progress * 0.5)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.dancee,
                            style: GoogleFonts.inter(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Gradient background container used by the header section.
class HeaderBackground extends StatelessWidget {
  final Widget child;

  const HeaderBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: child,
    );
  }
}

/// Animated logo icon with white background and music note.
class LogoIcon extends StatelessWidget {
  final double size;
  final double innerSize;
  final double borderRadius;
  final double animationProgress;

  const LogoIcon({
    required this.size,
    required this.innerSize,
    required this.borderRadius,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0 - (4.0 * animationProgress),
            offset: Offset(0, 2.0 - (1.0 * animationProgress)),
          ),
        ],
      ),
      child: Icon(
        Icons.music_note,
        color: const Color(0xFF6366F1),
        size: innerSize,
      ),
    );
  }
}

// ============================================================================
// SearchAndFiltersSection
// ============================================================================

/// Search bar and filter chips row with gradient background.
///
/// This is a StatefulWidget because it manages a [TextEditingController] for
/// the search input and triggers search/load via [EventListCubit].
class SearchAndFiltersSection extends StatefulWidget {
  const SearchAndFiltersSection({super.key});

  @override
  State<SearchAndFiltersSection> createState() =>
      _SearchAndFiltersSectionState();
}

class _SearchAndFiltersSectionState extends State<SearchAndFiltersSection> {
  late final TextEditingController _searchController;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    final currentQuery = getIt<EventFilterCubit>().state.filters.searchQuery;
    _searchController = TextEditingController(text: currentQuery);
    _showClearButton = currentQuery.isNotEmpty;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });

    getIt<EventFilterCubit>().updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventFilterCubit, EventFilterState>(
      bloc: getIt<EventFilterCubit>(),
      listenWhen: (previous, current) =>
          previous.filters.searchQuery != current.filters.searchQuery,
      listener: (context, state) {
        final newQuery = state.filters.searchQuery;
        if (_searchController.text != newQuery) {
          _searchController.text = newQuery;
          setState(() {
            _showClearButton = newQuery.isNotEmpty;
          });
        }
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            components.SearchBar(
              controller: _searchController,
              showClearButton: _showClearButton,
            ),
            const SizedBox(height: 16),
            const components.FilterChipsRow(),
          ],
        ),
      ),
    );
  }
}

// SearchField, FilterChipsRow, and FilterChip are now in components.dart

// ============================================================================
// EventsByDateSection
// ============================================================================

/// Displays events grouped by date (today, tomorrow, upcoming) as a sliver list.
///
/// Each group has a [SectionHeader] followed by [EventCard] components.
class EventsByDateSection extends StatelessWidget {
  final List<Event> todayEvents;
  final List<Event> tomorrowEvents;
  final List<Event> upcomingEvents;

  const EventsByDateSection({
    super.key,
    required this.todayEvents,
    required this.tomorrowEvents,
    required this.upcomingEvents,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (todayEvents.isNotEmpty) ...[
          components.SectionHeader(
            title: t.today,
            subtitle: DateFormat('(EEEE d.M.yyyy)').format(DateTime.now()),
            count: t.eventsCount(count: todayEvents.length),
            icon: Icons.calendar_today,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          ...todayEvents.map(
            (event) => components.EventCard(
              event: event,
              onTap: () {
                EventDetailRoute(id: event.id).push(context);
              },
              onFavoriteToggle: () =>
                  getIt<EventListCubit>().toggleFavorite(event.id),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (tomorrowEvents.isNotEmpty) ...[
          components.SectionHeader(
            title: t.tomorrow,
            subtitle: DateFormat('(EEEE d.M.yyyy)').format(DateTime.now().add(const Duration(days: 1))),
            count: t.eventsCount(count: tomorrowEvents.length),
            icon: Icons.calendar_month,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          ...tomorrowEvents.map(
            (event) => components.EventCard(
              event: event,
              onTap: () {
                EventDetailRoute(id: event.id).push(context);
              },
              onFavoriteToggle: () =>
                  getIt<EventListCubit>().toggleFavorite(event.id),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (upcomingEvents.isNotEmpty) ...[
          components.SectionHeader(
            title: t.thisWeek,
            subtitle: '',
            count: t.eventsCount(count: upcomingEvents.length),
            icon: Icons.calendar_view_week,
            color: const Color(0xFFEC4899),
          ),
          const SizedBox(height: 16),
          ...upcomingEvents.map(
            (event) => components.EventCard(
              event: event,
              onTap: () {
                EventDetailRoute(id: event.id).push(context);
              },
              onFavoriteToggle: () =>
                  getIt<EventListCubit>().toggleFavorite(event.id),
            ),
          ),
        ],
      ]),
    );
  }
}

// ============================================================================
// LoadingSection
// ============================================================================

/// Loading indicator displayed while events are being fetched.
class LoadingSection extends StatelessWidget {
  const LoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingIndicator();
  }
}

// ============================================================================
// ErrorSection
// ============================================================================

/// Error state with message and retry button.
///
/// Displays an error icon, the error message, and a styled retry button
/// that triggers [EventListCubit.loadEvents].
class ErrorSection extends StatelessWidget {
  final String message;

  const ErrorSection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppErrorMessage(
      message: message,
      onRetry: () => getIt<EventListCubit>().loadEvents(),
      retryLabel: t.retry,
    );
  }
}
