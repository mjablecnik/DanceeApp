/// Shared translation extraction utility for Directus CMS entity parsing.
///
/// Applies the standard fallback chain:
/// 1. Try exact [languageCode] match
/// 2. Fall back to English ('en')
/// 3. Fall back to the first available translation
/// 4. Return null if the translations array is empty
Map<String, dynamic>? extractTranslation(
  List<dynamic> translations,
  String languageCode,
) {
  if (translations.isEmpty) return null;

  // 1. Try exact language match
  final match = translations.cast<Map<String, dynamic>>().where(
        (t) => t['languages_code'] == languageCode,
      );
  if (match.isNotEmpty) return match.first;

  // 2. Fallback to English
  final enMatch = translations.cast<Map<String, dynamic>>().where(
        (t) => t['languages_code'] == 'en',
      );
  if (enMatch.isNotEmpty) return enMatch.first;

  // 3. Fallback to first available
  return translations.first as Map<String, dynamic>;
}
