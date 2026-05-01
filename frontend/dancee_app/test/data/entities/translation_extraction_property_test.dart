// Feature: profile-page-features
// Task 3.2: Property test for translation extraction language fallback
// Properties covered:
//   Property 3: Translation extraction language fallback

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/data/entities/translation_utils.dart';

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(42);

String _randomLangCode() {
  const codes = ['en', 'cs', 'es', 'de', 'fr', 'pt', 'it', 'pl', 'sk', 'ru'];
  return codes[_rng.nextInt(codes.length)];
}

String _randomString([int length = 8]) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(
    length,
    (_) => chars[_rng.nextInt(chars.length)],
  ).join();
}

Map<String, dynamic> _makeTranslation(String langCode, {String? content}) {
  return {
    'languages_code': langCode,
    'content': content ?? _randomString(20),
    'title': _randomString(10),
  };
}

List<Map<String, dynamic>> _randomTranslationList({
  required List<String> languageCodes,
}) {
  return languageCodes.map((code) => _makeTranslation(code)).toList();
}

// ---------------------------------------------------------------------------
// Property 3: Translation extraction language fallback
// ---------------------------------------------------------------------------

void _propertyTranslationFallback() {
  // P3a: exact match is returned when present
  test(
    'P3a: returns exact language match when present (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final targetLang = _randomLangCode();
        final otherLangs = ['en', 'cs', 'es', 'fr', 'de']
            .where((c) => c != targetLang)
            .take(2)
            .toList();

        final translations = _randomTranslationList(
          languageCodes: [...otherLangs, targetLang],
        )..shuffle(_rng);

        final result = extractTranslation(translations, targetLang);

        expect(
          result,
          isNotNull,
          reason: 'Iteration $i: should find a translation for $targetLang',
        );
        expect(
          result!['languages_code'],
          equals(targetLang),
          reason: 'Iteration $i: exact match for $targetLang should be returned',
        );
      }
    },
  );

  // P3b: falls back to English when exact match is absent
  test(
    'P3b: falls back to English when exact language is absent (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        // Pick a target language that is never 'en'
        const nonEnCodes = ['cs', 'es', 'de', 'fr', 'pt', 'it', 'pl', 'sk'];
        final targetLang = nonEnCodes[_rng.nextInt(nonEnCodes.length)];

        // Build translations without the target language, but with English
        final translations = _randomTranslationList(
          languageCodes: ['en', 'cs', 'es']
              .where((c) => c != targetLang)
              .toList(),
        );

        final result = extractTranslation(translations, targetLang);

        expect(
          result,
          isNotNull,
          reason: 'Iteration $i: should fall back to English for $targetLang',
        );
        expect(
          result!['languages_code'],
          equals('en'),
          reason: 'Iteration $i: English fallback expected when $targetLang absent',
        );
      }
    },
  );

  // P3c: falls back to first available when neither exact nor English present
  test(
    'P3c: falls back to first available when exact and English are both absent (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        const nonEnCodes = ['cs', 'es', 'de', 'fr', 'pt', 'it', 'pl', 'sk', 'ru'];
        final targetLang = nonEnCodes[_rng.nextInt(nonEnCodes.length)];

        // Build translations without the target language AND without English
        final availableCodes = nonEnCodes
            .where((c) => c != targetLang)
            .take(3)
            .toList();

        expect(
          availableCodes,
          isNotEmpty,
          reason: 'Iteration $i: test setup must have at least one other code',
        );

        final translations = _randomTranslationList(languageCodes: availableCodes);

        final result = extractTranslation(translations, targetLang);

        expect(
          result,
          isNotNull,
          reason: 'Iteration $i: should fall back to first available',
        );
        expect(
          result!['languages_code'],
          equals(availableCodes.first),
          reason: 'Iteration $i: first available translation should be returned',
        );
      }
    },
  );

  // P3d: returns null for empty translation list
  test(
    'P3d: returns null when translations list is empty',
    () {
      const languageCodes = ['en', 'cs', 'es', 'de', 'fr'];
      for (final lang in languageCodes) {
        final result = extractTranslation([], lang);
        expect(
          result,
          isNull,
          reason: 'Empty translations should always return null (lang=$lang)',
        );
      }
    },
  );

  // P3e: exact match takes precedence over English even when English is present
  test(
    'P3e: exact match takes priority over English fallback (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        const nonEnCodes = ['cs', 'es', 'de', 'fr', 'pt'];
        final targetLang = nonEnCodes[_rng.nextInt(nonEnCodes.length)];

        final targetContent = 'target_${_randomString(8)}';
        final enContent = 'english_${_randomString(8)}';

        final translations = [
          _makeTranslation('en', content: enContent),
          _makeTranslation(targetLang, content: targetContent),
        ]..shuffle(_rng);

        final result = extractTranslation(translations, targetLang);

        expect(
          result,
          isNotNull,
          reason: 'Iteration $i: result should not be null',
        );
        expect(
          result!['content'],
          equals(targetContent),
          reason: 'Iteration $i: exact match content should win over English',
        );
        expect(
          result['languages_code'],
          equals(targetLang),
          reason: 'Iteration $i: exact language code should be returned',
        );
      }
    },
  );

  // P3f: single translation is always returned regardless of language
  test(
    'P3f: single-entry list always returns that entry regardless of requested language (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        const codes = ['cs', 'es', 'de', 'fr', 'pt', 'it', 'ru'];
        final storedLang = codes[_rng.nextInt(codes.length)];
        final requestedLang = codes[_rng.nextInt(codes.length)];
        final content = _randomString(15);

        final translations = [_makeTranslation(storedLang, content: content)];
        final result = extractTranslation(translations, requestedLang);

        expect(
          result,
          isNotNull,
          reason: 'Iteration $i: single-entry list should always return something',
        );
        // If exact match, content matches; otherwise falls back to first (only) entry
        expect(
          result!['content'],
          equals(content),
          reason: 'Iteration $i: the only available translation should be returned',
        );
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Translation extraction — property tests', () {
    group('Property 3: Language fallback chain', _propertyTranslationFallback);
  });
}
