import 'dart:convert';
import 'dart:typed_data';

import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: directus-client, Property 1 & 2
//
// Property 1: Deep language filter in API queries
//   For any valid language code, query parameters containing the deep language
//   filter key `deep[translations][_filter][languages_code][_eq]` must be
//   forwarded verbatim to the underlying HTTP request.
//
// Property 2: HTTP error to ApiException mapping
//   For any HTTP error status code (4xx or 5xx), DirectusClient must throw an
//   ApiException whose `message` is non-empty (never blank).
//
// Validates: Requirements 1.5, 1.7, 15.1, 15.2
// ---------------------------------------------------------------------------

// ============================================================================
// Test infrastructure — same helpers as clients_test.dart
// ============================================================================

class _FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;

  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(dynamic body, {int statusCode = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody(
    Stream.fromIterable([Uint8List.fromList(bytes)]),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

DirectusClient _clientWithAdapter(
  Future<ResponseBody> Function(RequestOptions) handler,
) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeAdapter(handler);
  return DirectusClient(
    baseUrl: 'https://example.com',
    accessToken: 'test-token',
    dio: dio,
  );
}

// ============================================================================
// Property 1: Deep language filter query parameter forwarding
//
// The DirectusClient.get() method must forward any query parameters it receives
// to the underlying HTTP request — including the Directus deep-filter key
// `deep[translations][_filter][languages_code][_eq]` that repositories use to
// request only the translations for a given locale.
//
// We test a representative set of valid language codes (en, cs, es) plus an
// arbitrary well-formed BCP-47 tag (pt-BR) to show the property is language-
// code agnostic.
// ============================================================================

void main() {
  group('Property 1: Deep language filter forwarded for any language code', () {
    // The Directus deep-filter query key used by event/course repositories.
    const deepFilterKey = 'deep[translations][_filter][languages_code][_eq]';

    // Supported language codes as defined in the app (Requirements 15.1, 15.2).
    const languageCodes = ['en', 'cs', 'es', 'pt-BR'];

    for (final langCode in languageCodes) {
      // -----------------------------------------------------------------------
      // Sub-property: deep filter key with language code '$langCode' is forwarded
      // -----------------------------------------------------------------------
      test(
          'deep filter key with language code "$langCode" is forwarded to HTTP layer',
          () async {
        Map<String, dynamic>? capturedParams;

        final client = _clientWithAdapter((options) async {
          capturedParams = options.queryParameters;
          return _jsonResponse({'data': []});
        });

        await client.get(
          '/items/events',
          queryParameters: {
            'fields': '*,venue.*,translations.*',
            'filter[status][_eq]': 'published',
            deepFilterKey: langCode,
          },
        );

        expect(
          capturedParams,
          isNotNull,
          reason: 'HTTP adapter must receive query parameters',
        );
        expect(
          capturedParams!.containsKey(deepFilterKey),
          isTrue,
          reason:
              'The deep filter key "$deepFilterKey" must be present in the '
              'forwarded query parameters for language "$langCode"',
        );
        expect(
          capturedParams![deepFilterKey],
          equals(langCode),
          reason:
              'The forwarded deep filter value must equal the language code '
              '"$langCode" exactly — no transformation applied',
        );
      });
    }

    // -----------------------------------------------------------------------
    // Sub-property: deep filter is forwarded alongside other query parameters
    // -----------------------------------------------------------------------
    test(
        'deep filter key is forwarded together with other query parameters',
        () async {
      Map<String, dynamic>? capturedParams;

      final client = _clientWithAdapter((options) async {
        capturedParams = options.queryParameters;
        return _jsonResponse({'data': []});
      });

      await client.get(
        '/items/events',
        queryParameters: {
          'fields': '*,venue.*,translations.*',
          'filter[status][_eq]': 'published',
          'sort': 'start_time',
          'limit': '-1',
          deepFilterKey: 'cs',
        },
      );

      expect(capturedParams!['fields'], equals('*,venue.*,translations.*'));
      expect(capturedParams!['filter[status][_eq]'], equals('published'));
      expect(capturedParams!['sort'], equals('start_time'));
      expect(capturedParams![deepFilterKey], equals('cs'));
    });

    // -----------------------------------------------------------------------
    // Sub-property: deep filter value is not modified by the client
    // -----------------------------------------------------------------------
    test('deep filter value is passed through unchanged (case-sensitive)',
        () async {
      // Language codes are case-sensitive (e.g. 'cs' ≠ 'CS').
      // The client must not normalise or transform the value.
      const cases = ['en', 'cs', 'es', 'EN', 'CS'];
      for (final langCode in cases) {
        String? capturedValue;

        final client = _clientWithAdapter((options) async {
          capturedValue =
              options.queryParameters[deepFilterKey] as String?;
          return _jsonResponse({'data': []});
        });

        await client.get(
          '/items/events',
          queryParameters: {deepFilterKey: langCode},
        );

        expect(
          capturedValue,
          equals(langCode),
          reason:
              'Client must not transform language code "$langCode" — '
              'received "$capturedValue"',
        );
      }
    });
  });

  // ==========================================================================
  // Property 2: HTTP error status codes map to ApiException with non-empty message
  //
  // For every 4xx or 5xx HTTP response code that Directus may return,
  // DirectusClient must throw an ApiException. The exception's `message`
  // field must never be blank so that the UI has something meaningful to
  // display or log.
  //
  // We test a representative sample covering client errors (4xx) and server
  // errors (5xx). The list deliberately includes both well-known codes (403,
  // 404, 500) and less common ones (409 Conflict, 429 Too Many Requests,
  // 502 Bad Gateway) to demonstrate the property is code-agnostic.
  // ==========================================================================

  group('Property 2: Any HTTP error status throws ApiException with non-empty message',
      () {
    // Representative 4xx client-error codes.
    const clientErrorCodes = [400, 401, 403, 404, 409, 422, 429];

    // Representative 5xx server-error codes.
    const serverErrorCodes = [500, 502, 503, 504];

    final allErrorCodes = [...clientErrorCodes, ...serverErrorCodes];

    for (final statusCode in allErrorCodes) {
      // -----------------------------------------------------------------------
      // Sub-property: status $statusCode → ApiException with non-empty message
      // -----------------------------------------------------------------------
      test(
          'HTTP $statusCode on get() throws ApiException with non-empty message',
          () async {
        final client = _clientWithAdapter((_) async => _jsonResponse(
              {
                'errors': [
                  {'message': 'Error for status $statusCode'}
                ]
              },
              statusCode: statusCode,
            ));

        await expectLater(
          client.get('/items/events'),
          throwsA(
            isA<ApiException>()
                .having(
                  (e) => e.statusCode,
                  'statusCode',
                  equals(statusCode),
                )
                .having(
                  (e) => e.message,
                  'message',
                  isNotEmpty,
                ),
          ),
          reason:
              'HTTP $statusCode must produce an ApiException with a '
              'non-empty message field',
        );
      });
    }

    // -----------------------------------------------------------------------
    // Sub-property: 4xx with no errors array still produces non-empty message
    // -----------------------------------------------------------------------
    test(
        'HTTP 400 with no "errors" key in body still throws ApiException with non-empty message',
        () async {
      final client = _clientWithAdapter(
        (_) async => _jsonResponse({'status': 'bad'}, statusCode: 400),
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            isNotEmpty,
          ),
        ),
        reason:
            'Missing "errors" key must not produce a blank message — '
            'client falls back to a generic non-empty error string',
      );
    });

    // -----------------------------------------------------------------------
    // Sub-property: 5xx with empty errors array still produces non-empty message
    // -----------------------------------------------------------------------
    test(
        'HTTP 500 with empty "errors" array still throws ApiException with non-empty message',
        () async {
      final client = _clientWithAdapter(
        (_) async =>
            _jsonResponse({'errors': <dynamic>[]}, statusCode: 500),
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            isNotEmpty,
          ),
        ),
        reason:
            'Empty "errors" array must not produce a blank message — '
            'client falls back to a generic non-empty error string',
      );
    });

    // -----------------------------------------------------------------------
    // Sub-property: all error codes also throw on post() and delete()
    // -----------------------------------------------------------------------
    for (final statusCode in [403, 500]) {
      test(
          'HTTP $statusCode on post() throws ApiException with non-empty message',
          () async {
        final client = _clientWithAdapter(
          (_) async => _jsonResponse(
            {
              'errors': [
                {'message': 'Error $statusCode'}
              ]
            },
            statusCode: statusCode,
          ),
        );

        await expectLater(
          client.post('/items/foo', data: {'name': 'test'}),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(statusCode))
                .having((e) => e.message, 'message', isNotEmpty),
          ),
        );
      });

      test(
          'HTTP $statusCode on delete() throws ApiException with non-empty message',
          () async {
        final client = _clientWithAdapter(
          (_) async => _jsonResponse(
            {
              'errors': [
                {'message': 'Error $statusCode'}
              ]
            },
            statusCode: statusCode,
          ),
        );

        await expectLater(
          client.delete('/items/foo/1'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(statusCode))
                .having((e) => e.message, 'message', isNotEmpty),
          ),
        );
      });
    }
  });
}
