/// Returns initials from a user's name.
///
/// - Empty/whitespace → "?"
/// - Single word → first char uppercased
/// - Multi-word → first char of first + last word uppercased
String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
