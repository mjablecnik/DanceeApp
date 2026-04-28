/// Typed exception thrown when a CMS API request fails.
///
/// Contains the HTTP [statusCode] (null for network/connection errors),
/// a human-readable [message] describing the failure, and optionally
/// the [originalError] (e.g. a [DioException]) for debugging.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  final String message;
  final int? statusCode;

  /// The original error that caused this exception (e.g. a DioException).
  /// Useful for debugging — preserves the full stack trace and response body.
  final dynamic originalError;

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}
