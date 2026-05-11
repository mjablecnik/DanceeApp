import '../../data/entities/user_profile.dart';
import '../../logic/cubits/filter_cubit.dart';
import 'city_region_mapper.dart';

/// Prefills [filterCubit] from [profile] data.
/// Only applies when [filterCubit] has no active filters.
void prefillFiltersFromProfile(UserProfile profile, FilterCubit filterCubit) {
  if (profile.danceTags.isNotEmpty) {
    filterCubit.setDanceStyles(profile.danceTags.toSet());
  }
  final city = profile.city;
  if (city != null && city.trim().isNotEmpty) {
    final region = mapCityToRegion(city);
    if (region != null) {
      filterCubit.setLocations({region});
    }
  }
}
