// Feature: cms-flutter-integration
// Task 3.5 / Property 1: Deep language filter in API queries
// Properties covered:
//   Property 1: deep[translations][_filter][languages_code][_eq] = languageCode
//               is always included in repository GET requests

import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/data/repositories/event_repository.dart';
import 'package:dancee_app2/data/repositories/course_repository.dart';
import 'package:dancee_app2/data/repositories/dance_style_repository.dart';

// ---------------------------------------------------------------------------
// Capturing adapter
// ---------------------------------------------------------------------------

/// An [HttpClientAdapter] that records all captured [RequestOptions] and
/// returns an empty Directus data envelope so the repository can parse results.
class _CapturingAdapter implements HttpClientAdapter {
  final List<RequestOptions> capturedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);
    return ResponseBody.fromString(
      '{"data":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DirectusClient _makeClientWithAdapter(_CapturingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  dio.httpClientAdapter = adapter;
  return DirectusClient(
    baseUrl: 'https://test.local',
    accessToken: 'test-token',
    dio: dio,
  );
}

const _kLanguageFilterKey = 'deep[translations][_filter][languages_code][_eq]';

// ---------------------------------------------------------------------------
// Property 1: Deep language filter
// ---------------------------------------------------------------------------

void _propertyDeepLanguageFilter() {
  // Feature: cms-flutter-integration, Property 1: Deep language filter in API queries

  group('EventRepository', () {
    test(
      'P1: getEvents always sends deep language filter for any language code (100 iterations)',
      () async {
        const languageCodes = ['en', 'cs', 'es'];
        final rng = Random(42);

        for (var i = 0; i < 100; i++) {
          final lang = languageCodes[rng.nextInt(languageCodes.length)];
          final adapter = _CapturingAdapter();
          final client = _makeClientWithAdapter(adapter);
          final repo = EventRepository(client: client);

          await repo.getEvents(lang);

          expect(
            adapter.capturedRequests,
            isNotEmpty,
            reason: 'Iteration $i: expected at least one HTTP request',
          );
          final params = adapter.capturedRequests.first.queryParameters;
          expect(
            params.containsKey(_kLanguageFilterKey),
            isTrue,
            reason: 'Iteration $i: deep language filter key must be present for lang=$lang',
          );
          expect(
            params[_kLanguageFilterKey],
            equals(lang),
            reason: 'Iteration $i: deep language filter value must equal requested language code',
          );
        }
      },
    );

    test('P1: getEvents sends deep filter with exact language code match', () async {
      for (final lang in ['en', 'cs', 'es']) {
        final adapter = _CapturingAdapter();
        final client = _makeClientWithAdapter(adapter);
        final repo = EventRepository(client: client);

        await repo.getEvents(lang);

        final params = adapter.capturedRequests.first.queryParameters;
        expect(
          params[_kLanguageFilterKey],
          equals(lang),
          reason: 'Language filter value must equal "$lang" exactly',
        );
      }
    });

    test('P1: getEvents hits /items/events endpoint', () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithAdapter(adapter);
      final repo = EventRepository(client: client);

      await repo.getEvents('en');

      final uri = adapter.capturedRequests.first.path;
      expect(
        uri,
        equals('/items/events'),
        reason: 'EventRepository must query /items/events',
      );
    });

    test('P1: getEvents always filters to published status', () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithAdapter(adapter);
      final repo = EventRepository(client: client);

      await repo.getEvents('cs');

      final params = adapter.capturedRequests.first.queryParameters;
      expect(
        params['filter[status][_eq]'],
        equals('published'),
        reason: 'EventRepository must filter to published events only',
      );
    });
  });

  group('CourseRepository', () {
    test(
      'P1: getCourses always sends deep language filter for any language code (100 iterations)',
      () async {
        const languageCodes = ['en', 'cs', 'es'];
        final rng = Random(42);

        for (var i = 0; i < 100; i++) {
          final lang = languageCodes[rng.nextInt(languageCodes.length)];
          final adapter = _CapturingAdapter();
          final client = _makeClientWithAdapter(adapter);
          final repo = CourseRepository(client: client);

          await repo.getCourses(lang);

          expect(
            adapter.capturedRequests,
            isNotEmpty,
            reason: 'Iteration $i: expected at least one HTTP request',
          );
          final params = adapter.capturedRequests.first.queryParameters;
          expect(
            params.containsKey(_kLanguageFilterKey),
            isTrue,
            reason: 'Iteration $i: deep language filter key must be present for lang=$lang',
          );
          expect(
            params[_kLanguageFilterKey],
            equals(lang),
            reason: 'Iteration $i: deep language filter value must equal requested language code',
          );
        }
      },
    );

    test('P1: getCourses hits /items/courses endpoint', () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithAdapter(adapter);
      final repo = CourseRepository(client: client);

      await repo.getCourses('en');

      final uri = adapter.capturedRequests.first.path;
      expect(
        uri,
        equals('/items/courses'),
        reason: 'CourseRepository must query /items/courses',
      );
    });
  });

  group('DanceStyleRepository', () {
    test(
      'P1: getDanceStyles always sends deep language filter for any language code (100 iterations)',
      () async {
        const languageCodes = ['en', 'cs', 'es'];
        final rng = Random(42);

        for (var i = 0; i < 100; i++) {
          final lang = languageCodes[rng.nextInt(languageCodes.length)];
          final adapter = _CapturingAdapter();
          final client = _makeClientWithAdapter(adapter);
          final repo = DanceStyleRepository(client: client);

          await repo.getDanceStyles(lang);

          expect(
            adapter.capturedRequests,
            isNotEmpty,
            reason: 'Iteration $i: expected at least one HTTP request',
          );
          final params = adapter.capturedRequests.first.queryParameters;
          expect(
            params.containsKey(_kLanguageFilterKey),
            isTrue,
            reason: 'Iteration $i: deep language filter key must be present for lang=$lang',
          );
          expect(
            params[_kLanguageFilterKey],
            equals(lang),
            reason: 'Iteration $i: deep language filter value must equal requested language code',
          );
        }
      },
    );

    test('P1: getDanceStyles hits /items/dance_styles endpoint', () async {
      final adapter = _CapturingAdapter();
      final client = _makeClientWithAdapter(adapter);
      final repo = DanceStyleRepository(client: client);

      await repo.getDanceStyles('cs');

      final uri = adapter.capturedRequests.first.path;
      expect(
        uri,
        equals('/items/dance_styles'),
        reason: 'DanceStyleRepository must query /items/dance_styles',
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Repository API queries — property tests', () {
    group(
      'Property 1: Deep language filter in API queries',
      _propertyDeepLanguageFilter,
    );
  });
}
