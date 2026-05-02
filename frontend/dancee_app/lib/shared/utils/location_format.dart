/// Shortens a location string by taking only the part before the first comma.
/// If there is no comma, returns the full string unchanged.
///
/// Examples:
///   "Prague, Czech Republic" → "Prague"
///   "Grad Rijeka, Croatia"  → "Grad Rijeka"
///   "Praha"                 → "Praha"
String shortLocation(String location) {
  final commaIndex = location.indexOf(',');
  if (commaIndex < 0) return location;
  return location.substring(0, commaIndex).trim();
}
