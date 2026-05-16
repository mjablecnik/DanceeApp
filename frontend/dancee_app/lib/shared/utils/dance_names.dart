import '../../data/entities/dance_style.dart';

/// Max number of dance style tags shown per event/course card.
const kMaxDanceTags = 6;

/// Tag data with highlight flag for active filter matches.
class ResolvedTag {
  final String name;
  final bool isFilterMatch;
  const ResolvedTag(this.name, {this.isFilterMatch = false});
}

/// Resolves dance codes/names to unique parent display names, limited to [kMaxDanceTags].
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
    if (tags.length >= kMaxDanceTags) break;
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
