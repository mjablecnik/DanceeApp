import 'dart:convert';
import 'dart:typed_data';

import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/core/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A simple [HttpClientAdapter] that returns a predefined [ResponseBody].
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

void main() {
  group('DirectusClient', () {
    // -----------------------------------------------------------------------
    // TC-001: Constructor injects correct base URL and auth header
    // -----------------------------------------------------------------------
    test('TC-001: sets baseUrl and Authorization header on Dio options', () {
      final dio = Dio();
      DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'test-token',
        dio: dio,
      );

      expect(dio.options.baseUrl, equals('https://example.com'));
      expect(
        dio.options.headers['Authorization'],
        equals('Bearer test-token'),
      );
    });

    // -----------------------------------------------------------------------
    // TC-002: get() unwraps the Directus `data` envelope
    // -----------------------------------------------------------------------
    test('TC-002: get() returns unwrapped data from Directus envelope', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async =>
          _jsonResponse({'data': {'id': 1, 'title': 'Event'}}));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final result = await client.get('/items/events');
      expect(result, equals({'id': 1, 'title': 'Event'}));
    });

    // -----------------------------------------------------------------------
    // TC-003: get() throws ApiException on non-2xx status
    // -----------------------------------------------------------------------
    test('TC-003: get() throws ApiException with statusCode 403 on 403 response',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Forbidden'}]},
            statusCode: 403,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      expect(
        () => client.get('/items/events'),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          403,
        )),
      );
    });

    // -----------------------------------------------------------------------
    // TC-004: get() throws ApiException on connection timeout
    // -----------------------------------------------------------------------
    test('TC-004: get() wraps DioException connectionTimeout into ApiException',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', isNotEmpty)),
      );
    });

    // -----------------------------------------------------------------------
    // TC-005: checkHealth() returns true on 200
    // -----------------------------------------------------------------------
    test('TC-005: checkHealth() returns true when server responds 200', () async {
      final dio = Dio();
      dio.httpClientAdapter =
          _FakeAdapter((_) async => _jsonResponse({'status': 'ok'}));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      expect(await client.checkHealth(), isTrue);
    });

    // -----------------------------------------------------------------------
    // TC-006: checkHealth() returns false on any exception
    // -----------------------------------------------------------------------
    test('TC-006: checkHealth() returns false when server is unreachable',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      expect(await client.checkHealth(), isFalse);
    });

    // -----------------------------------------------------------------------
    // TC-101: post() sends request body and returns unwrapped data
    // -----------------------------------------------------------------------
    test('TC-101: post() sends body and returns unwrapped data envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'data': {'id': '1', 'name': 'test'}},
            statusCode: 201,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final result = await client.post('/items/foo', data: {'name': 'test'});
      expect(result, equals({'id': '1', 'name': 'test'}));
    });

    // -----------------------------------------------------------------------
    // TC-101 (auth header): post() includes Authorization header
    // -----------------------------------------------------------------------
    test('TC-101b: post() includes Authorization header in request', () async {
      String? authHeader;
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        authHeader = options.headers['Authorization'] as String?;
        return _jsonResponse({'data': {}}, statusCode: 201);
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'test-token',
        dio: dio,
      );

      await client.post('/items/foo', data: {'name': 'test'});
      expect(authHeader, equals('Bearer test-token'));
    });

    // -----------------------------------------------------------------------
    // TC-102: patch() sends updated data and returns unwrapped response
    // -----------------------------------------------------------------------
    test('TC-102: patch() returns unwrapped data from Directus envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'data': {'id': '1', 'name': 'updated'}},
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final result =
          await client.patch('/items/foo/1', data: {'name': 'updated'});
      expect(result, equals({'id': '1', 'name': 'updated'}));
    });

    // -----------------------------------------------------------------------
    // TC-103: delete() sends DELETE request and completes without error
    // -----------------------------------------------------------------------
    test('TC-103: delete() completes without error on 204 response', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'data': null},
            statusCode: 204,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(client.delete('/items/foo/1'), completes);
    });

    // -----------------------------------------------------------------------
    // TC-104: _convertDioException() maps receiveTimeout → ApiException
    // -----------------------------------------------------------------------
    test(
        'TC-104: get() wraps receiveTimeout DioException into ApiException with null statusCode',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', isNotEmpty)),
      );
    });

    // -----------------------------------------------------------------------
    // TC-105: _convertDioException() maps sendTimeout → ApiException
    // -----------------------------------------------------------------------
    test(
        'TC-105: get() wraps sendTimeout DioException into ApiException with null statusCode',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.sendTimeout,
        );
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', isNotEmpty)),
      );
    });

    // -----------------------------------------------------------------------
    // TC-106: _convertDioException() maps unknown/connectionError → ApiException
    // -----------------------------------------------------------------------
    test(
        'TC-106: get() wraps unknown DioException into ApiException preserving originalError',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
        );
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', isNotEmpty)
            .having((e) => e.originalError, 'originalError', isNotNull)),
      );
    });

    // -----------------------------------------------------------------------
    // TC-107: get() throws ApiException with statusCode=500 on server error
    // -----------------------------------------------------------------------
    test('TC-107: get() throws ApiException with statusCode 500 on 500 response',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Internal Server Error'}]},
            statusCode: 500,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.get('/items/events'),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          500,
        )),
      );
    });

    // -----------------------------------------------------------------------
    // TC-M19: checkHealth() returns false when server responds with non-200
    // -----------------------------------------------------------------------
    test(
        'TC-M19: checkHealth() returns false when server responds with 500',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Internal Server Error'}]},
            statusCode: 500,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      expect(await client.checkHealth(), isFalse);
    });

    // -----------------------------------------------------------------------
    // TC-M20: get() returns list when Directus data envelope contains an array
    // -----------------------------------------------------------------------
    test('TC-M20: get() returns list when data field contains an array',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse({
            'data': [
              {'id': 1},
              {'id': 2}
            ]
          }));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final result = await client.get('/items/events');
      expect(result, isA<List>());
      expect(result, equals([
        {'id': 1},
        {'id': 2}
      ]));
    });

    // -----------------------------------------------------------------------
    // TC-H02: post() throws ApiException with statusCode 422 on 422 response
    // -----------------------------------------------------------------------
    test('TC-H02: post() throws ApiException with statusCode 422 on 422 response',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Unprocessable Entity'}]},
            statusCode: 422,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.post('/items/foo', data: {'name': 'test'}),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          422,
        )),
      );
    });

    // -----------------------------------------------------------------------
    // TC-H03: patch() throws ApiException with statusCode 404 on 404 response
    // -----------------------------------------------------------------------
    test('TC-H03: patch() throws ApiException with statusCode 404 on 404 response',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Not Found'}]},
            statusCode: 404,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.patch('/items/foo/1', data: {'name': 'updated'}),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          404,
        )),
      );
    });

    // -----------------------------------------------------------------------
    // TC-H04: delete() throws ApiException with statusCode 403 on 403 response
    // -----------------------------------------------------------------------
    test('TC-H04: delete() throws ApiException with statusCode 403 on 403 response',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((_) async => _jsonResponse(
            {'errors': [{'message': 'Forbidden'}]},
            statusCode: 403,
          ));

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      await expectLater(
        client.delete('/items/foo/1'),
        throwsA(isA<ApiException>().having(
          (e) => e.statusCode,
          'statusCode',
          403,
        )),
      );
    });

    // -----------------------------------------------------------------------
    // TC-M03: delete() forwards queryParameters to Dio
    // -----------------------------------------------------------------------
    test('TC-M03: delete() forwards queryParameters to Dio', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        capturedParams = options.queryParameters;
        return _jsonResponse({'data': null}, statusCode: 204);
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final queryParameters = {'filter[id][_in]': '1,2,3'};
      await client.delete('/items/foo', queryParameters: queryParameters);

      expect(capturedParams, equals(queryParameters));
    });

    // -----------------------------------------------------------------------
    // TC-108: get() passes queryParameters to Dio
    // -----------------------------------------------------------------------
    test('TC-108: get() forwards queryParameters to Dio', () async {
      Map<String, dynamic>? capturedParams;
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter((options) async {
        capturedParams = options.queryParameters;
        return _jsonResponse({'data': []});
      });

      final client = DirectusClient(
        baseUrl: 'https://example.com',
        accessToken: 'token',
        dio: dio,
      );

      final queryParameters = {
        'fields': '*',
        'filter[status]': 'published',
      };
      await client.get('/items/events', queryParameters: queryParameters);

      expect(capturedParams, equals(queryParameters));
    });
  });
}
