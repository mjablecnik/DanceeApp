const _cityRegionMap = <String, List<String>>{
  'prague': ['praha', 'prague'],
  'brno': ['brno'],
  'ostrava': ['ostrava'],
  'plzen': ['plzeň', 'plzen'],
  'liberec': ['liberec'],
  'olomouc': ['olomouc'],
  'ceske-budejovice': ['české budějovice', 'ceske budejovice'],
  'hradec-kralove': ['hradec králové', 'hradec kralove'],
  'pardubice': ['pardubice'],
  'zlin': ['zlín', 'zlin'],
  'jihlava': ['jihlava'],
  'karlovy-vary': ['karlovy vary'],
  'usti-nad-labem': ['ústí nad labem', 'usti nad labem'],
};

/// Maps a city name to its corresponding region identifier.
/// Returns null if no mapping is found.
String? mapCityToRegion(String city) {
  final normalized = city.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final entry in _cityRegionMap.entries) {
    if (entry.value.any((c) => normalized.contains(c.toLowerCase()))) {
      return entry.key;
    }
  }
  return null;
}
