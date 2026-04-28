import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/entities/dance_style.dart';
import '../../../../data/entities/event.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/favorites_cubit.dart';
import '../../../../shared/utils/date_format.dart';
import '../components/featured_event_card.dart' show EventTagData;
import '../components/upcoming_event_card.dart';

/// Max number of dance style tags shown per event card.
const _kMaxDanceTags = 6;

/// Tag data with highlight flag for active filter matches.
class ResolvedTag {
  final String name;
  final bool isFilterMatch;
  const ResolvedTag(this.name, {this.isFilterMatch = false});
}

/// Resolves dance codes/names to unique parent display names, limited to [_kMaxDanceTags].
/// Tags matching [activeFilterCodes] are prioritized and marked as filter matches.
/// If a filter match is found via child dance but the parent isn't in the resolved
/// tags yet, it's injected so the user sees why the item matched.
List<ResolvedTag> parentDanceNames(
  List<String> codes,
  List<DanceStyle> allStyles, {
  Set<String> activeFilterCodes = const {},
}) {
  // Build lookup: filter parent code → display name
  final filterParentNames = <String, String>{};
  for (final fc in activeFilterCodes) {
    final parent = allStyles.where((s) => s.code == fc).firstOrNull;
    filterParentNames[fc] = parent?.name ?? fc;
  }

  // Build set of all filter-related codes/names for matching
  final filterMatchSet = <String>{};
  for (final fc in activeFilterCodes) {
    filterMatchSet.add(fc.toLowerCase());
    final parent = allStyles.where((s) => s.code == fc).firstOrNull;
    if (parent != null) filterMatchSet.add(parent.name.toLowerCase());
    for (final child in allStyles.where((s) => s.parentCode == fc)) {
      filterMatchSet.add(child.code.toLowerCase());
      filterMatchSet.add(child.name.toLowerCase());
    }
  }

  // Build per-filter match sets to check which filters this event actually matches
  final perFilterMatchSets = <String, Set<String>>{};
  for (final fc in activeFilterCodes) {
    final matchSet = <String>{fc.toLowerCase()};
    final parent = allStyles.where((s) => s.code == fc).firstOrNull;
    if (parent != null) matchSet.add(parent.name.toLowerCase());
    for (final child in allStyles.where((s) => s.parentCode == fc)) {
      matchSet.add(child.code.toLowerCase());
      matchSet.add(child.name.toLowerCase());
    }
    perFilterMatchSets[fc] = matchSet;
  }

  final tags = <ResolvedTag>[];
  final seen = <String>{};

  // Inject filter parent names only if the event actually has a matching dance
  for (final fc in activeFilterCodes) {
    final matchSet = perFilterMatchSets[fc]!;
    final eventMatches = codes.any((d) => matchSet.contains(d.toLowerCase()));
    if (eventMatches) {
      final name = filterParentNames[fc]!;
      if (seen.add(name)) {
        tags.add(ResolvedTag(name, isFilterMatch: true));
      }
    }
  }

  for (final code in codes) {
    final style = allStyles.where((s) => s.code == code).firstOrNull ??
        allStyles.where((s) => s.name.toLowerCase() == code.toLowerCase()).firstOrNull;

    String displayName;
    if (style != null && style.parentCode != null) {
      final parent = allStyles.where((s) => s.code == style.parentCode).firstOrNull;
      displayName = parent?.name ?? code;
    } else if (style != null) {
      displayName = style.name;
    } else {
      displayName = code;
    }

    if (seen.add(displayName)) {
      final isMatch = filterMatchSet.contains(displayName.toLowerCase()) ||
          filterMatchSet.contains(code.toLowerCase());
      tags.add(ResolvedTag(displayName, isFilterMatch: isMatch));
    }
    if (tags.length >= _kMaxDanceTags) break;
  }

  // Sort: filter matches first
  if (activeFilterCodes.isNotEmpty) {
    tags.sort((a, b) {
      if (a.isFilterMatch && !b.isFilterMatch) return -1;
      if (!a.isFilterMatch && b.isFilterMatch) return 1;
      return 0;
    });
  }

  return tags;
}

class UpcomingEventsSection extends StatelessWidget {
  final List<Event> events;
  final List<DanceStyle> allDanceStyles;
  final Set<String> activeFilterCodes;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final void Function(int eventId)? onEventTap;

  const UpcomingEventsSection({
    super.key,
    required this.events,
    this.allDanceStyles = const [],
    this.activeFilterCodes = const {},
    this.hasActiveFilters = false,
    this.onClearFilters,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t.events.upcomingEvents,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.arrowUpWideShort, size: 14, color: appText),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      t.common.date,
                      style: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (events.isEmpty && hasActiveFilters)
          SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.events.noEventsForFilter,
                      style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: onClearFilters,
                      child: Text(
                        t.common.clearFilters,
                        style: const TextStyle(color: appPrimary, fontSize: AppTypography.fontSizeMd),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: AppSpacing.lg),
                  UpcomingEventCard(
                    imageUrl: event.imageUrl ?? '',
                    title: event.title,
                    location: event.venue?.town ?? event.venue?.name ?? '',
                    date: formatDate(event.startTime),
                    tags: parentDanceNames(
                            event.dances, allDanceStyles,
                            activeFilterCodes: activeFilterCodes)
                        .map((tag) => EventTagData(
                            tag.name, tag.isFilterMatch ? appSuccess : appPrimary))
                        .toList(),
                    isFavorited: event.isFavorited,
                    onTap: () => onEventTap?.call(event.id),
                    onFavoriteTap: () => context.read<FavoritesCubit>().toggleFavorite(
                          itemType: 'event',
                          itemId: event.id,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
