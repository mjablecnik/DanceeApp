import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_filter.dart';
import 'components.dart';

// ============================================================================
// EventFiltersHeaderSection
// ============================================================================

/// Gradient header with back button, title, and reset button.
class EventFiltersHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onResetPressed;

  const EventFiltersHeaderSection({
    super.key,
    required this.onBackPressed,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  HeaderIconButton(
                    icon: Icons.arrow_back,
                    onPressed: onBackPressed,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          t.eventFilters.title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.eventFilters.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HeaderIconButton(
                    icon: Icons.refresh,
                    onPressed: onResetPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ActiveFiltersSummary
// ============================================================================

/// Summary card showing the number of active filters and matching events.
class ActiveFiltersSummary extends StatelessWidget {
  final int activeCount;
  final int matchingCount;

  const ActiveFiltersSummary({
    super.key,
    required this.activeCount,
    required this.matchingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list,
                        color: Color(0xFF6366F1), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      t.eventFilters.activeFilters,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t.eventFilters.eventsShown(count: matchingCount),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: activeCount > 0
                  ? const Color(0xFF6366F1)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$activeCount',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DanceTypeFilterSection
// ============================================================================

/// Number of dance type items shown before the "Show more" button appears.
const int _kDanceTypeInitialCount = 5;

/// Section with checkboxes for filtering by dance style.
/// Shows the first [_kDanceTypeInitialCount] items with a "Show more" toggle
/// button when the list is longer, matching the design mockup.
class DanceTypeFilterSection extends StatefulWidget {
  final List<String> danceTypes;
  final Set<String> selectedTypes;
  final List<Event> allEvents;
  final FilterState filters;
  final void Function(String) onToggle;
  final VoidCallback onClear;

  const DanceTypeFilterSection({
    super.key,
    required this.danceTypes,
    required this.selectedTypes,
    required this.allEvents,
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  @override
  State<DanceTypeFilterSection> createState() => _DanceTypeFilterSectionState();
}

class _DanceTypeFilterSectionState extends State<DanceTypeFilterSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final hasMore = widget.danceTypes.length > _kDanceTypeInitialCount;
    final visibleTypes = _showAll || !hasMore
        ? widget.danceTypes
        : widget.danceTypes.take(_kDanceTypeInitialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.music_note,
          title: t.eventFilters.danceType,
          onClear: widget.onClear,
        ),
        const SizedBox(height: 12),
        if (widget.danceTypes.isEmpty)
          EmptyOptionMessage(message: t.eventFilters.noResults)
        else ...[
          ...visibleTypes.map((type) {
            final isSelected = widget.selectedTypes.contains(type);
            final count =
                countEventsForDanceType(widget.allEvents, type, widget.filters);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DanceTypeOption(
                label: type,
                icon: danceTypeIcon(type),
                iconColor: danceTypeColor(type),
                isSelected: isSelected,
                count: count,
                onTap: () => widget.onToggle(type),
              ),
            );
          }),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showAll
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showAll
                            ? t.eventFilters.showLessDances
                            : t.eventFilters.showMoreDances,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ============================================================================
// LocationFilterSection
// ============================================================================

/// Section with checkboxes for filtering by Czech region.
///
/// Design deviation (intentional): The design mockup uses radio buttons
/// (single-select), but the requirements spec (Req 4.2) explicitly requires
/// multi-select checkboxes. The implementation follows the spec.
///
/// Known gap (intentionally deferred): The design mockup includes a free-text
/// location search input ("Nebo zadejte vlastní lokalitu") below the region
/// list. This is not implemented because the requirements spec does not require
/// it — only region-based filtering is specified (Req 4.1–4.6). This can be
/// added as a future enhancement.
class LocationFilterSection extends StatelessWidget {
  final List<String> regions;
  final Set<String> selectedRegions;
  final List<Event> allEvents;
  final FilterState filters;
  final void Function(String) onToggle;
  final VoidCallback onClear;

  const LocationFilterSection({
    super.key,
    required this.regions,
    required this.selectedRegions,
    required this.allEvents,
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.location_on,
          title: t.eventFilters.location,
          onClear: onClear,
        ),
        const SizedBox(height: 12),
        if (regions.isEmpty)
          EmptyOptionMessage(message: t.eventFilters.noResults)
        else
          ...regions.map((region) {
            final isSelected = selectedRegions.contains(region);
            final count = countEventsForRegion(allEvents, region, filters);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LocationOption(
                label: region,
                isSelected: isSelected,
                count: count,
                onTap: () => onToggle(region),
              ),
            );
          }),
      ],
    );
  }
}

// ============================================================================
// DateRangeFilterSection
// ============================================================================

/// Section with date pickers and quick-select date buttons.
class DateRangeFilterSection extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final VoidCallback onDateFromTap;
  final VoidCallback onDateToTap;
  final VoidCallback onTodayPreset;
  final VoidCallback onTomorrowPreset;
  final VoidCallback onThisWeekPreset;
  final VoidCallback onWeekendPreset;
  final VoidCallback onClear;

  const DateRangeFilterSection({
    super.key,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromTap,
    required this.onDateToTap,
    required this.onTodayPreset,
    required this.onTomorrowPreset,
    required this.onThisWeekPreset,
    required this.onWeekendPreset,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          icon: Icons.calendar_month,
          title: t.eventFilters.date,
          onClear: onClear,
        ),
        const SizedBox(height: 12),
        DateInputField(
          label: t.eventFilters.dateFrom,
          value: dateFrom,
          onTap: onDateFromTap,
        ),
        const SizedBox(height: 12),
        DateInputField(
          label: t.eventFilters.dateTo,
          value: dateTo,
          onTap: onDateToTap,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.today,
                label: t.eventFilters.dateToday,
                iconColor: const Color(0xFF6366F1),
                gradientColors: const [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                borderColor: const Color(0xFFBFDBFE),
                onPressed: onTodayPreset,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.event,
                label: t.eventFilters.dateTomorrow,
                iconColor: const Color(0xFF8B5CF6),
                gradientColors: const [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
                borderColor: const Color(0xFFD8B4FE),
                onPressed: onTomorrowPreset,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.date_range,
                label: t.eventFilters.dateThisWeek,
                iconColor: const Color(0xFFEC4899),
                gradientColors: const [Color(0xFFFDF2F8), Color(0xFFFFF1F2)],
                borderColor: const Color(0xFFFBCFE8),
                onPressed: onThisWeekPreset,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateQuickSelectButton(
                icon: Icons.event_available,
                label: t.eventFilters.dateWeekend,
                iconColor: Colors.green,
                gradientColors: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
                borderColor: const Color(0xFFBBF7D0),
                onPressed: onWeekendPreset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// SaveFilterSection
// ============================================================================

/// Card prompting the user to save the current filter configuration.
class SaveFilterSection extends StatelessWidget {
  final Future<void> Function() onSave;

  const SaveFilterSection({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.eventFilters.saveFilter,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      t.eventFilters.saveFilterDescription,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSave,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Color(0xFFB45309), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    t.eventFilters.saveFilterButton,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FilterFooterActions
// ============================================================================

/// Fixed bottom bar with "Clear all" and "Apply filters" buttons.
class FilterFooterActions extends StatelessWidget {
  final int matchingCount;
  final VoidCallback onClearAll;
  final VoidCallback onApply;

  const FilterFooterActions({
    super.key,
    required this.matchingCount,
    required this.onClearAll,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClearAllButton(onPressed: onClearAll),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ApplyFiltersButton(
                    onPressed: onApply,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  t.eventFilters.showEvents(count: matchingCount),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FilterSectionHeader
// ============================================================================

/// Reusable header row for each filter section (title + clear button).
class FilterSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClear;

  const FilterSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onClear,
          child: Text(
            t.eventFilters.clear,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }
}
