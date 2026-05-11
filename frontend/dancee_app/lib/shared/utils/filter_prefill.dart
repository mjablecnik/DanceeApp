import '../../data/entities/user_profile.dart';
import '../../logic/cubits/filter_cubit.dart';
import 'city_region_mapper.dart';

/// Prefills [filterCubit] from [profile] data.
/// Only applies when [filterCubit] has no active filters.
void prefillFiltersFromProfile(UserProfile profile, FilterCubit filterCubit) {
  if (profile.danceTags.isNotEmpty) {
    // Profile stores dance style display names (e.g. 'Salsa', 'Bachata').
    // FilterCubit uses codes (e.g. 'salsa', 'bachata').
    // Try to match against loaded dance styles first, fall back to lowercase.
    final allStyles = filterCubit.allDanceStyles;
    final codes = <String>{};
    for (final tag in profile.danceTags) {
      final tagLower = tag.toLowerCase();
      // Find matching dance style by name (case-insensitive)
      final match = allStyles.where(
        (s) => s.name.toLowerCase() == tagLower || s.code.toLowerCase() == tagLower,
      ).firstOrNull;
      if (match != null) {
        codes.add(match.code);
      } else {
        // Fallback: use lowercase name as code
        codes.add(tagLower);
      }
    }
    if (codes.isNotEmpty) {
      filterCubit.setDanceStyles(codes);
    }
  }
  final city = profile.city;
  if (city != null && city.trim().isNotEmpty) {
    final region = mapCityToRegion(city);
    if (region != null) {
      filterCubit.setLocations({region});
    }
  }
}
