/// Maps city names to Directus region values.
/// The keys are the exact region strings stored in Directus venue data.
/// The values are lists of city name variants (lowercase) that belong to that region.
const _cityRegionMap = <String, List<String>>{
  'Praha': ['praha', 'prague'],
  'Brno': ['brno'],
  'Ostrava': ['ostrava'],
  'Plzeň': ['plzeň', 'plzen'],
  'Liberec': ['liberec'],
  'Olomouc': ['olomouc'],
  'České Budějovice': ['české budějovice', 'ceske budejovice', 'budějovice', 'budejovice'],
  'Hradec Králové': ['hradec králové', 'hradec kralove'],
  'Pardubice': ['pardubice'],
  'Zlín': ['zlín', 'zlin'],
  'Jihlava': ['jihlava'],
  'Karlovy Vary': ['karlovy vary'],
  'Ústí nad Labem': ['ústí nad labem', 'usti nad labem'],
};

/// Maps a city name to its corresponding Directus region value.
/// Returns null if no mapping is found.
String? mapCityToRegion(String city) {
  final normalized = city.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final entry in _cityRegionMap.entries) {
    if (entry.value.any((c) => normalized.contains(c))) {
      return entry.key;
    }
  }
  return null;
}
