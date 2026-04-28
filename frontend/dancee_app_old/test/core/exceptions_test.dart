import 'package:dancee_app/core/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException', () {
    // =========================================================================
    // TC-007: Stores message, statusCode, and originalError
    // =========================================================================

    test('TC-007: stores message, statusCode, and originalError', () {
      final original = Exception('root cause');
      final exception = ApiException(
        message: 'Not found',
        statusCode: 404,
        originalError: original,
      );

      expect(exception.message, equals('Not found'));
      expect(exception.statusCode, equals(404));
      expect(exception.originalError, same(original));
    });

    // =========================================================================
    // TC-008: statusCode is nullable (network errors have no HTTP code)
    // =========================================================================

    test('TC-008: statusCode is null when not provided', () {
      final exception = ApiException(message: 'timeout');

      expect(exception.statusCode, isNull);
      expect(exception.message, equals('timeout'));
    });

    // =========================================================================
    // Task 68: ApiException with empty message stores it correctly
    // =========================================================================

    test('TC-T68: ApiException with empty message stores it without error', () {
      final exception = ApiException(message: '');

      expect(exception.message, equals(''));
      expect(exception.statusCode, isNull);
    });
  });
}
