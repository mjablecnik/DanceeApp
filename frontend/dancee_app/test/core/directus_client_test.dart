// Feature: cms-flutter-integration
// Task 3.4 / Property 2: HTTP error to ApiException mapping
// Properties covered:
//   Property 2: HTTP error codes and network failures map to typed ApiException

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/core/exceptions.dart';

// ---------------------------------------------------------------------------
// Fake adapters
// ---------------------------------------------------------------------------

/// An [HttpClientAdapter] that always throws the provided [DioException].
class _ThrowingAdapter implements HttpClientAdapter {
  final DioException Function(RequestOptions) makeException;

  _ThrowingAdapter(this.makeException);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw makeException(options);
  }

  @override
  void close({bool force = false}) {}
}

/// An [HttpClientAdapter] that returns a fixed status code with an empty data envelope.
class _StatusCodeAdapter implements HttpClientAdapter {
  final int statusCode;

  _StatusCodeAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Return an error response body — Dio validates and throws badResponse for 4xx/5xx.
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: {'error': 'test error'},
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

DirectusClient _makeClient(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  dio.httpClientAdapter = adapter;
  return DirectusClient(
    baseUrl: 'https://test.local',
    accessToken: 'test-token',
    dio: dio,
  );
}

// ---------------------------------------------------------------------------
// Property 2: HTTP error to ApiException mapping
// ---------------------------------------------------------------------------

void _propertyErrorMapping() {
  // Feature: cms-flutter-integration, Property 2: Error-to-ApiException mapping

  test('P2: connectionTimeout maps to ApiException without statusCode', () async {
    final client = _makeClient(
      _ThrowingAdapter(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
    );

    expect(
      () => client.get('/items/test'),
      throwsA(
        predicate<ApiException>(
          (e) =>
              e.statusCode == null &&
              e.message.toLowerCase().contains('timed out'),
          'should map connectionTimeout to ApiException with null statusCode',
        ),
      ),
    );
  });

  test('P2: receiveTimeout maps to ApiException without statusCode', () async {
    final client = _makeClient(
      _ThrowingAdapter(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.receiveTimeout,
        ),
      ),
    );

    expect(
      () => client.get('/items/test'),
      throwsA(
        predicate<ApiException>(
          (e) =>
              e.statusCode == null &&
              e.message.toLowerCase().contains('respond'),
          'should map receiveTimeout to ApiException with null statusCode',
        ),
      ),
    );
  });

  test('P2: sendTimeout maps to ApiException without statusCode', () async {
    final client = _makeClient(
      _ThrowingAdapter(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.sendTimeout,
        ),
      ),
    );

    expect(
      () => client.get('/items/test'),
      throwsA(
        predicate<ApiException>(
          (e) =>
              e.statusCode == null &&
              e.message.toLowerCase().contains('sending'),
          'should map sendTimeout to ApiException with null statusCode',
        ),
      ),
    );
  });

  test('P2: connectionError maps to ApiException without statusCode', () async {
    final client = _makeClient(
      _ThrowingAdapter(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionError,
        ),
      ),
    );

    expect(
      () => client.get('/items/test'),
      throwsA(
        predicate<ApiException>(
          (e) =>
              e.statusCode == null &&
              e.message.toLowerCase().contains('internet'),
          'should map connectionError to ApiException about network',
        ),
      ),
    );
  });

  test('P2: cancel maps to ApiException without statusCode', () async {
    final client = _makeClient(
      _ThrowingAdapter(
        (opts) => DioException(
          requestOptions: opts,
          type: DioExceptionType.cancel,
        ),
      ),
    );

    expect(
      () => client.get('/items/test'),
      throwsA(
        predicate<ApiException>(
          (e) =>
              e.statusCode == null &&
              e.message.toLowerCase().contains('cancel'),
          'should map cancel to ApiException about cancellation',
        ),
      ),
    );
  });

  group('P2: HTTP status codes map to ApiException with correct statusCode', () {
    for (final statusCode in [400, 401, 403, 404, 409, 500, 502, 503]) {
      test('P2: status $statusCode maps to ApiException(statusCode: $statusCode)', () async {
        final client = _makeClient(_StatusCodeAdapter(statusCode));

        expect(
          () => client.get('/items/test'),
          throwsA(
            predicate<ApiException>(
              (e) => e.statusCode == statusCode,
              'should map HTTP $statusCode to ApiException with statusCode $statusCode',
            ),
          ),
        );
      });
    }

    test('P2: 401 response includes authentication message', () async {
      final client = _makeClient(_StatusCodeAdapter(401));

      expect(
        () => client.get('/items/test'),
        throwsA(
          predicate<ApiException>(
            (e) =>
                e.statusCode == 401 &&
                e.message.toLowerCase().contains('auth'),
            'should include authentication info in 401 message',
          ),
        ),
      );
    });

    test('P2: 404 response includes not found message', () async {
      final client = _makeClient(_StatusCodeAdapter(404));

      expect(
        () => client.get('/items/test'),
        throwsA(
          predicate<ApiException>(
            (e) =>
                e.statusCode == 404 &&
                e.message.toLowerCase().contains('not found'),
            'should include not found info in 404 message',
          ),
        ),
      );
    });

    test('P2: generic 4xx range maps to ApiException with statusCode', () async {
      final client = _makeClient(_StatusCodeAdapter(422));

      expect(
        () => client.get('/items/test'),
        throwsA(
          predicate<ApiException>(
            (e) => e.statusCode == 422,
            'should map 422 to ApiException with statusCode 422',
          ),
        ),
      );
    });

    test('P2: generic 5xx range maps to ApiException with statusCode', () async {
      final client = _makeClient(_StatusCodeAdapter(504));

      expect(
        () => client.get('/items/test'),
        throwsA(
          predicate<ApiException>(
            (e) => e.statusCode == 504,
            'should map 504 to ApiException with statusCode 504',
          ),
        ),
      );
    });
  });

  test('P2: thrown exception is always ApiException, never raw DioException (100 iterations)', () async {
    // Property: every DioException type maps to an ApiException — no leakage of DioException.
    final types = [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.cancel,
    ];

    for (var i = 0; i < 100; i++) {
      final type = types[i % types.length];
      final client = _makeClient(
        _ThrowingAdapter(
          (opts) => DioException(requestOptions: opts, type: type),
        ),
      );

      Object? thrown;
      try {
        await client.get('/items/test');
      } catch (e) {
        thrown = e;
      }

      expect(
        thrown,
        isA<ApiException>(),
        reason: 'Iteration $i: DioExceptionType.$type must produce ApiException, not DioException',
      );
      expect(
        thrown,
        isNot(isA<DioException>()),
        reason: 'Iteration $i: raw DioException must not leak through the client',
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('DirectusClient — property tests', () {
    group('Property 2: HTTP error to ApiException mapping', _propertyErrorMapping);
  });
}
