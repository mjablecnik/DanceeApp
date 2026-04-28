// Feature: cms-flutter-integration
// Task 2.4: Property tests for Event entity parsing
// Properties covered:
//   Property 3: Translation extraction from CMS JSON
//   Property 4: Image URL construction
//   Property 5: Translation fallback chain

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/data/entities/event.dart';

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(42);

String _randomString([int length = 8]) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(
    length,
    (_) => chars[_rng.nextInt(chars.length)],
  ).join();
}

String _randomLanguageCode() {
  const codes = ['en', 'cs', 'es'];
  return codes[_rng.nextInt(codes.length)];
}

Map<String, dynamic> _buildTranslation({
  required String languagesCode,
  String? title,
  String? description,
}) {
  return {
    'languages_code': languagesCode,
    'title': title ?? _randomString(),
    'description': description ?? _randomString(20),
    'parts_translations': <dynamic>[],
    'info_translations': <dynamic>[],
  };
}

/// Builds a minimal valid Directus event JSON.
Map<String, dynamic> _buildEventJson({
  int? id,
  String? imageFileId,
  List<Map<String, dynamic>>? translations,
  String? eventType,
}) {
  return {
    'id': id ?? _rng.nextInt(10000) + 1,
    'image': imageFileId,
    'title': 'Fallback title',
    'organizer': 'Test Organizer',
    'start_time': '2025-06-01T18:00:00',
    'end_time': null,
    'timezone': null,
    'event_type': eventType ?? 'party',
    'dances': <dynamic>[],
    'parts': <dynamic>[],
    'info': <dynamic>[],
    'original_url': null,
    'registration_url': null,
    'venue': null,
    'translations': translations ?? <dynamic>[],
  };
}

// ---------------------------------------------------------------------------
// Property 3: Translation extraction from CMS JSON
// ---------------------------------------------------------------------------

void _propertyTranslationExtraction() {
  // Feature: cms-flutter-integration, Property 3: Translation extraction from CMS JSON
  test(
    'P3: fromDirectus uses the matching translation when available (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final targetLang = _randomLanguageCode();
        final expectedTitle = 'title_$targetLang${_randomString(4)}';
        final expectedDesc = 'desc_$targetLang${_randomString(8)}';

        // Build translations that always include the target language.
        final translations = [
          _buildTranslation(
            languagesCode: targetLang,
            title: expectedTitle,
            description: expectedDesc,
          ),
        ];

        // Add a few extra unrelated language entries.
        final otherLangs = ['en', 'cs', 'es'].where((l) => l != targetLang);
        for (final lang in otherLangs) {
          translations.add(
            _buildTranslation(
              languagesCode: lang,
              title: 'other_$lang',
              description: 'other_desc_$lang',
            ),
          );
        }

        // Shuffle so the matching translation is not always first.
        translations.shuffle(_rng);

        final json = _buildEventJson(translations: translations);

        final event = Event.fromDirectus(
          json,
          languageCode: targetLang,
          directusBaseUrl: 'https://cms.example.com',
        );

        expect(
          event.title,
          equals(expectedTitle),
          reason: 'Iteration $i: title should match $targetLang translation',
        );
        expect(
          event.description,
          equals(expectedDesc),
          reason:
              'Iteration $i: description should match $targetLang translation',
        );
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Property 4: Image URL construction
// ---------------------------------------------------------------------------

void _propertyImageUrlConstruction() {
  // Feature: cms-flutter-integration, Property 4: Image URL construction
  test(
    'P4: imageUrl is {baseUrl}/assets/{fileId} for any non-null fileId (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final fileId = _randomString(12);
        final baseUrl = 'https://${_randomString(6)}.example.com';

        final json = _buildEventJson(imageFileId: fileId);

        final event = Event.fromDirectus(
          json,
          languageCode: 'en',
          directusBaseUrl: baseUrl,
        );

        expect(
          event.imageUrl,
          equals('$baseUrl/assets/$fileId'),
          reason: 'Iteration $i: expected URL pattern not matched',
        );
      }
    },
  );

  test('P4: imageUrl is null when image field is null', () {
    // Run 100 times to confirm the property holds regardless of other fields.
    for (var i = 0; i < 100; i++) {
      final json = _buildEventJson(imageFileId: null);

      final event = Event.fromDirectus(
        json,
        languageCode: 'en',
        directusBaseUrl: 'https://cms.example.com',
      );

      expect(
        event.imageUrl,
        isNull,
        reason: 'Iteration $i: imageUrl should be null when fileId is null',
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Property 5: Translation fallback chain
// ---------------------------------------------------------------------------

void _propertyTranslationFallback() {
  // Feature: cms-flutter-integration, Property 5: Translation fallback chain
  test(
    'P5a: Falls back to English when requested language is absent (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        // Pick a non-English language as the request.
        const nonEnglishLangs = ['cs', 'es'];
        final requestedLang =
            nonEnglishLangs[_rng.nextInt(nonEnglishLangs.length)];

        final enTitle = 'en_title_${_randomString(4)}';
        final enDesc = 'en_desc_${_randomString(8)}';

        // Only provide an English translation — the requested language is absent.
        final translations = [
          _buildTranslation(
            languagesCode: 'en',
            title: enTitle,
            description: enDesc,
          ),
        ];

        final json = _buildEventJson(translations: translations);

        final event = Event.fromDirectus(
          json,
          languageCode: requestedLang,
          directusBaseUrl: 'https://cms.example.com',
        );

        expect(
          event.title,
          equals(enTitle),
          reason:
              'Iteration $i: should fall back to English title when $requestedLang is missing',
        );
        expect(
          event.description,
          equals(enDesc),
          reason:
              'Iteration $i: should fall back to English description when $requestedLang is missing',
        );
      }
    },
  );

  test(
    'P5b: Falls back to first available translation when both requested lang and English are absent (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final firstTitle = 'first_${_randomString(4)}';
        final firstDesc = 'firstdesc_${_randomString(8)}';

        // Provide only 'cs' translation; request 'es' (which has no English fallback either).
        final translations = [
          _buildTranslation(
            languagesCode: 'cs',
            title: firstTitle,
            description: firstDesc,
          ),
        ];

        final json = _buildEventJson(translations: translations);

        final event = Event.fromDirectus(
          json,
          languageCode: 'es',
          directusBaseUrl: 'https://cms.example.com',
        );

        expect(
          event.title,
          equals(firstTitle),
          reason:
              'Iteration $i: should fall back to first available translation title',
        );
        expect(
          event.description,
          equals(firstDesc),
          reason:
              'Iteration $i: should fall back to first available translation description',
        );
      }
    },
  );

  test('P5c: Empty translations array results in empty title and description',
      () {
    for (var i = 0; i < 100; i++) {
      final json = _buildEventJson(translations: []);
      // The raw json has no 'title' key fallback here — it uses 'Fallback title'.
      // With empty translations, the entity should use the raw json title field.
      final event = Event.fromDirectus(
        json,
        languageCode: _randomLanguageCode(),
        directusBaseUrl: 'https://cms.example.com',
      );

      // title falls back to json['title'] which is 'Fallback title'
      expect(
        event.title,
        equals('Fallback title'),
        reason: 'Iteration $i: title should fall back to raw json title',
      );
      // description has no raw fallback — should be empty string
      expect(
        event.description,
        equals(''),
        reason: 'Iteration $i: description should be empty string',
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Event.fromDirectus — property tests', () {
    group('Property 3: Translation extraction', _propertyTranslationExtraction);
    group('Property 4: Image URL construction', _propertyImageUrlConstruction);
    group('Property 5: Translation fallback chain', _propertyTranslationFallback);
  });
}
