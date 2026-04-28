import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_filter.dart';
import '../event_filters/event_filters_page.dart';

// ============================================================================
// EventCard
// ============================================================================

/// Full event card displaying title, venue, time, dance styles, favorite toggle,
/// and optional badge. Migrated from `lib/widgets/event_card.dart`.
///
/// Supports optional swipe-to-dismiss for past events.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool enableDismiss;
  final VoidCallback? onDismissed;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavoriteToggle,
    this.enableDismiss = false,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = EventCardContent(
      event: event,
      onTap: onTap,
      onFavoriteToggle: onFavoriteToggle,
    );

    if (enableDismiss && event.isPast && onDismissed != null) {
      return Dismissible(
        key: Key(event.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => onDismissed!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 32),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Internal card content layout for [EventCard].
class EventCardContent extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const EventCardContent({
    required this.event,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = _formatDate(event.startTime);
    final timeFormat = _formatTime(event.startTime, event.endTime);
    final gradientColors =
        _getGradientColors(event.dances.isNotEmpty ? event.dances.first : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isPast ? Colors.grey[100]! : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: event.isPast ? null : onTap,
          child: Opacity(
            opacity: event.isPast ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EventIconBadge(
                        dances: event.dances,
                        gradientColors: gradientColors,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EventDetails(
                          event: event,
                          dateFormat: dateFormat,
                          timeFormat: timeFormat,
                        ),
                      ),
                      EventActions(
                        event: event,
                        onFavoriteToggle: onFavoriteToggle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EventFooter(event: event),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient icon badge showing a dance-style-specific icon.
class EventIconBadge extends StatelessWidget {
  final List<String> dances;
  final List<Color> gradientColors;

  const EventIconBadge({
    required this.dances,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getEventIcon(dances),
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Title, venue, date, and time details for an event card.
class EventDetails extends StatelessWidget {
  final Event event;
  final String dateFormat;
  final String timeFormat;

  const EventDetails({
    required this.event,
    required this.dateFormat,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: event.isPast
                ? Colors.grey[600]
                : const Color(0xFF0F172A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 12,
              color: event.isPast ? Colors.grey[500] : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                event.venue.name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: event.isPast ? Colors.grey[500] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: event.isPast
                  ? Colors.grey[500]
                  : const Color(0xFF6366F1),
            ),
            const SizedBox(width: 4),
            Text(
              dateFormat,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: event.isPast ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.access_time,
              size: 12,
              color: event.isPast
                  ? Colors.grey[500]
                  : const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 4),
            Text(
              timeFormat,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: event.isPast ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Badge and favorite toggle button column.
class EventActions extends StatelessWidget {
  final Event event;
  final VoidCallback onFavoriteToggle;

  const EventActions({
    required this.event,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (event.badge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getBadgeColor(event.badge!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.badge!,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: event.isPast
                  ? Colors.red[50]
                  : (event.isFavorite ? Colors.red[50] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onFavoriteToggle,
                child: Icon(
                  event.isPast
                      ? Icons.delete
                      : (event.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border),
                  color: event.isPast
                      ? Colors.red[600]
                      : (event.isFavorite
                          ? Colors.red[600]
                          : Colors.grey[400]),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Footer row with dance style tags and detail link.
class EventFooter extends StatelessWidget {
  final Event event;

  const EventFooter({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: event.dances
                .map((dance) => DanceTag(tag: dance, isPast: event.isPast))
                .toList(),
          ),
        ),
        Row(
          children: [
            Text(
              t.detail,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: event.isPast ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: event.isPast ? Colors.grey[400] : Colors.grey[500],
              size: 24,
            ),
          ],
        ),
      ],
    );
  }
}

/// A small colored tag chip for a dance style.
class DanceTag extends StatelessWidget {
  final String tag;
  final bool isPast;

  const DanceTag({required this.tag, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final colors = _getTagColors(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey[200] : colors['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPast ? Colors.grey[600] : colors['text'],
        ),
      ),
    );
  }
}

// ============================================================================
// SectionHeader
// ============================================================================

/// Date section header with icon, title, optional subtitle, and event count.
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String count;
  final IconData icon;
  final Color color;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SearchBar
// ============================================================================

/// Search text field with search icon and clear button.
///
/// Accepts a [TextEditingController] and a flag to show/hide the clear button.
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool showClearButton;

  const SearchBar({
    super.key,
    required this.controller,
    required this.showClearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: t.searchEvents,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: showClearButton
              ? IconButton(
                  onPressed: controller.clear,
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ============================================================================
// FilterChipsRow
// ============================================================================

/// Horizontally scrollable row of [FilterChip] components.
///
/// Reads active filter state from [EventFilterCubit] to display badges
/// and highlight active chips. Navigates to [EventFiltersRoute] on tap.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFilterCubit, EventFilterState>(
      bloc: getIt<EventFilterCubit>(),
      builder: (context, filterState) {
        final filters = filterState.filters;
        final activeCount = getActiveFilterCount(filters);
        final hasDateFilter = filters.dateFrom != null || filters.dateTo != null;
        final hasLocationFilter = filters.selectedRegions.isNotEmpty;

        final dateLabel = _dateChipLabel(filters);
        final locationLabel = _locationChipLabel(filters);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => const EventFiltersRoute().push(context),
                child: FilterChip(
                  label: t.filters,
                  hasNotification: activeCount > 0,
                  notificationCount: activeCount,
                  isActive: activeCount > 0,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => const EventFiltersRoute(scrollTo: 'date').push(context),
                child: FilterChip(
                  label: dateLabel,
                  icon: Icons.calendar_today,
                  isActive: hasDateFilter,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => const EventFiltersRoute(scrollTo: 'location').push(context),
                child: FilterChip(
                  label: locationLabel,
                  icon: Icons.location_on,
                  isActive: hasLocationFilter,
                  hasNotification: filters.selectedRegions.length > 1,
                  notificationCount: filters.selectedRegions.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// FilterChip
// ============================================================================

/// Individual filter chip with optional icon and notification badge.
class FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool hasNotification;
  final int notificationCount;
  final bool isActive;

  const FilterChip({
    super.key,
    required this.label,
    this.icon,
    this.hasNotification = false,
    this.notificationCount = 0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          if (hasNotification) ...[
            const SizedBox(width: 8),
            NotificationBadge(count: notificationCount),
          ],
        ],
      ),
    );
  }
}

/// Small red circle badge showing a count number.
class NotificationBadge extends StatelessWidget {
  final int count;

  const NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Helper functions (private to this file)
// ============================================================================

/// Returns a dynamic label for the date filter chip.
///
/// Shows formatted date range when a date filter is active; falls back to the
/// generic "Date" label when no date filter is set.
String _dateChipLabel(FilterState filters) {
  if (filters.dateFrom == null && filters.dateTo == null) {
    return t.eventFilters.date;
  }
  if (filters.dateFrom != null && filters.dateTo != null) {
    final from = DateFormat('d MMM').format(filters.dateFrom!);
    final to = DateFormat('d MMM').format(filters.dateTo!);
    if (from == to) return from;
    return '$from – $to';
  }
  if (filters.dateFrom != null) {
    return DateFormat('d MMM').format(filters.dateFrom!);
  }
  return DateFormat('d MMM').format(filters.dateTo!);
}

/// Returns a dynamic label for the location filter chip.
///
/// Shows the selected region name for a single selection, the generic
/// "Location" label for multiple selections (count shown via badge), or
/// the generic label when no region is selected.
String _locationChipLabel(FilterState filters) {
  if (filters.selectedRegions.isEmpty) return t.eventFilters.location;
  if (filters.selectedRegions.length == 1) return filters.selectedRegions.first;
  return t.eventFilters.location;
}

String _formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (eventDate == today) {
    return t.today;
  } else if (eventDate == today.add(const Duration(days: 1))) {
    return t.tomorrow;
  } else {
    return DateFormat('MMM d').format(dateTime);
  }
}

String _formatTime(DateTime start, DateTime? end) {
  final startHour = start.hour.toString().padLeft(2, '0');
  final startMinute = start.minute.toString().padLeft(2, '0');
  if (end == null) return '$startHour:$startMinute';
  final endHour = end.hour.toString().padLeft(2, '0');
  final endMinute = end.minute.toString().padLeft(2, '0');
  return '$startHour:$startMinute - $endHour:$endMinute';
}

List<Color> _getGradientColors(String dance) {
  switch (dance.toLowerCase()) {
    case 'salsa':
      return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
    case 'bachata':
      return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
    case 'kizomba':
      return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
    case 'zouk':
    case 'brazilian zouk':
      return [const Color(0xFF14B8A6), const Color(0xFF0D9488)];
    case 'tango':
      return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    default:
      return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
  }
}

Map<String, Color> _getTagColors(String tag) {
  switch (tag.toLowerCase()) {
    case 'salsa':
      return {'background': Colors.red[100]!, 'text': Colors.red[700]!};
    case 'bachata':
      return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
    case 'kizomba':
      return {'background': Colors.purple[100]!, 'text': Colors.purple[700]!};
    case 'zouk':
    case 'brazilian zouk':
      return {'background': Colors.teal[100]!, 'text': Colors.teal[700]!};
    case 'sensual':
      return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
    case 'urban kiz':
      return {
        'background': Colors.deepPurple[100]!,
        'text': Colors.deepPurple[700]!,
      };
    case 'tarraxo':
      return {'background': Colors.indigo[100]!, 'text': Colors.indigo[700]!};
    case 'on2':
      return {'background': Colors.orange[100]!, 'text': Colors.orange[700]!};
    case 'gafieira':
      return {'background': Colors.green[100]!, 'text': Colors.green[700]!};
    case 'merengue':
      return {'background': Colors.amber[100]!, 'text': Colors.amber[700]!};
    case 'reggaeton':
      return {'background': Colors.green[100]!, 'text': Colors.green[700]!};
    case 'romantica':
      return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
    case 'cubana':
      return {'background': Colors.red[100]!, 'text': Colors.red[700]!};
    case 'ladies':
      return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
    default:
      return {'background': Colors.grey[100]!, 'text': Colors.grey[700]!};
  }
}

Color _getBadgeColor(String badge) {
  switch (badge.toLowerCase()) {
    case 'today':
      return Colors.green[500]!;
    case 'in 2 days':
      return Colors.blue[500]!;
    case 'finished':
      return Colors.grey[400]!;
    default:
      return Colors.grey[400]!;
  }
}

IconData _getEventIcon(List<String> dances) {
  if (dances.isEmpty) return Icons.music_note;

  final primaryDance = dances.first.toLowerCase();
  switch (primaryDance) {
    case 'salsa':
      return Icons.local_fire_department;
    case 'bachata':
      return Icons.favorite;
    case 'kizomba':
      return Icons.nightlight_round;
    case 'zouk':
    case 'brazilian zouk':
      return Icons.water_drop;
    case 'tango':
    case 'argentine tango':
      return Icons.wb_sunny;
    case 'merengue':
      return Icons.celebration;
    case 'reggaeton':
      return Icons.music_note;
    default:
      return Icons.music_note;
  }
}
