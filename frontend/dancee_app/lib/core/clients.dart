import 'package:dio/dio.dart';

import 'config.dart';
import 'exceptions.dart';

/// Dio-based HTTP client for the Directus CMS REST API.
///
/// Handles authentication, Directus envelope unwrapping (`data` field
/// extraction), and maps HTTP errors and network failures to [ApiException].
class DirectusClient {
  DirectusClient({
    required String baseUrl,
    required String accessToken,
    Future<String?> Function()? idTokenProvider,
    Dio? dio,
  })  : _accessToken = accessToken,
        _idTokenProvider = idTokenProvider,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                },
                connectTimeout:
                    const Duration(milliseconds: AppConfig.connectionTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConfig.receiveTimeoutMs),
              ),
            ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;
        if (_idTokenProvider != null) {
          try {
            token = await _idTokenProvider();
          } catch (_) {
            // fall back to static token on error
          }
        }
        options.headers['Authorization'] = 'Bearer ${token ?? _accessToken}';
        handler.next(options);
      },
    ));
  }

  final Dio _dio;
  final String _accessToken;
  final Future<String?> Function()? _idTokenProvider;

  /// Performs a GET request and returns the unwrapped `data` field from the
  /// Directus response envelope.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Performs a POST request and returns the unwrapped `data` field.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Performs a DELETE request.
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.delete<void>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  dynamic _unwrap(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) return null;
    return body['data'];
  }

  ApiException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'api.errors.connectionTimeout',
          originalError: e,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'api.errors.receiveTimeout',
          originalError: e,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'api.errors.sendTimeout',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'api.errors.noConnection',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        // ignore: avoid_print
        print(
          '[DirectusClient] badResponse: status=$statusCode '
          'body=${e.response?.data}',
        );
        return ApiException(
          statusCode: statusCode,
          message: _keyForStatusCode(statusCode),
          originalError: e,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'api.errors.requestCancelled',
          originalError: e,
        );
      default:
        return ApiException(
          statusCode: statusCode,
          message: 'api.errors.generic',
          originalError: e,
        );
    }
  }

  String _keyForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'api.errors.badRequest';
      case 401:
        return 'api.errors.unauthorized';
      case 403:
        return 'api.errors.forbidden';
      case 404:
        return 'api.errors.notFound';
      case 409:
        return 'api.errors.conflict';
      case 500:
        return 'api.errors.internalServerError';
      case 502:
        return 'api.errors.badGateway';
      case 503:
        return 'api.errors.serviceUnavailable';
      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return 'api.errors.clientError';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'api.errors.serverError';
        }
        return 'api.errors.generic';
    }
  }
}
