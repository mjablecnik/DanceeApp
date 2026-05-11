import 'package:dio/dio.dart';

import 'config.dart';
import 'exceptions.dart';

/// Dio-based HTTP client for the Directus CMS REST API.
///
/// Handles authentication, Directus envelope unwrapping (`data` field
/// extraction), and maps HTTP errors and network failures to [ApiException].
///
/// Token priority:
///  1. Directus session token from [DirectusAuthService] (obtained via
///     Firebase token exchange).
///  2. Static [_accessToken] from config (fallback for unauthenticated or
///     pre-login requests).
class DirectusClient {
  DirectusClient({
    required String baseUrl,
    required String accessToken,
    Future<String?> Function()? directusTokenProvider,
    Future<void> Function()? onTokenExpired,
    Dio? dio,
  })  : _accessToken = accessToken,
        _directusTokenProvider = directusTokenProvider,
        _onTokenExpired = onTokenExpired,
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
        if (_directusTokenProvider != null) {
          try {
            token = await _directusTokenProvider();
          } catch (_) {
            // fall back to static token on error
          }
        }
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        } else if (_accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        } else {
          // No token available — rely on Directus public role.
          options.headers.remove('Authorization');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // On 401, try to refresh the token and retry the request once.
        // Skip retry for anonymous users (no token provider result).
        if (error.response?.statusCode == 401 &&
            _onTokenExpired != null &&
            error.requestOptions.extra['_retried'] != true) {
          try {
            await _onTokenExpired();
            // Get fresh token
            String? newToken;
            if (_directusTokenProvider != null) {
              newToken = await _directusTokenProvider();
            }
            if (newToken != null) {
              // Retry the original request with the new token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              opts.extra['_retried'] = true;
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          } catch (_) {
            // Refresh failed — fall through to original error
          }
        }
        handler.next(error);
      },
    ));
  }

  final Dio _dio;
  final String _accessToken;
  final Future<String?> Function()? _directusTokenProvider;
  final Future<void> Function()? _onTokenExpired;

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

  /// Performs a PATCH request and returns the unwrapped `data` field.
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Uploads a file via multipart/form-data and returns the unwrapped response.
  Future<dynamic> uploadFile(String path, {required FormData formData}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
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
