/// Exception thrown when API calls fail.
///
/// This is part of the core exceptions module.
/// Future exception types (ValidationException, BusinessLogicException, etc.)
/// can be added to this file or split into a core/exceptions/ directory if needed.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });
  
  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
