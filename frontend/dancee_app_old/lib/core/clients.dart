import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'config.dart';
import 'exceptions.dart';

/// HTTP client for communicating with the Directus CMS API.
///
/// Handles authentication via Bearer token, the Directus response
/// envelope (`{ "data": ... }`), and standard error handling.
class DirectusClient {
  final Dio _dio;

  /// Creates a DirectusClient configured for the Directus CMS API.
  ///
  /// An optional [dio] instance can be injected for testing purposes.
  DirectusClient({
    required String baseUrl,
    required String accessToken,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout =
        Duration(milliseconds: AppConfig.connectTimeout);
    _dio.options.receiveTimeout =
        Duration(milliseconds: AppConfig.receiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: AppConfig.sendTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => developer.log('$obj', name: 'DirectusClient'),
      ));
    }
  }

  /// Extracts the `data` field from a Directus response envelope.
  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  /// Makes a GET request and returns the unwrapped `data` field.
  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(path, queryParameters: queryParameters);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }

  /// Makes a POST request and returns the unwrapped `data` field.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }

  /// Makes a PATCH request and returns the unwrapped `data` field.
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }

  /// Makes a DELETE request.
  Future<void> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }

  /// Checks if the Directus service is available.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/server/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  ApiException _convertDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please check your connection.',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection error. Please check your internet connection.',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String errorMessage = 'Server error occurred';
        if (data is Map<String, dynamic>) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors.first['message'] ?? errorMessage;
          }
        }
        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalError: e,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          originalError: e,
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred',
          originalError: e,
        );
    }
  }
}
