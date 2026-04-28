import 'package:dancee_app/features/auth/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    // =========================================================================
    // TC-024: fromJson / toJson round-trip is lossless
    // =========================================================================

    test('TC-024: fromJson/toJson round-trip is lossless', () {
      final json = {
        'id': 'user-123',
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'photoUrl': 'https://example.com/photo.jpg',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('user-123'));
      expect(user.email, equals('alice@example.com'));
      expect(user.displayName, equals('Alice'));
      expect(user.photoUrl, equals('https://example.com/photo.jpg'));

      final roundTripped = User.fromJson(user.toJson());
      expect(roundTripped, equals(user));
    });

    test('TC-024: fromJson/toJson round-trip with null photoUrl', () {
      final json = {
        'id': 'user-456',
        'email': 'bob@example.com',
        'displayName': 'Bob',
        'photoUrl': null,
      };

      final user = User.fromJson(json);
      expect(user.photoUrl, isNull);

      final roundTripped = User.fromJson(user.toJson());
      expect(roundTripped, equals(user));
    });

    // =========================================================================
    // TC-120: copyWith() updates only specified fields
    // =========================================================================

    test('TC-120: copyWith updates only specified fields, preserves others', () {
      const original = User(
        id: '1',
        email: 'a@b.com',
        displayName: 'Old',
        photoUrl: null,
      );

      final updated = original.copyWith(displayName: 'New Name');

      expect(updated.displayName, equals('New Name'));
      expect(updated.id, equals('1'));
      expect(updated.email, equals('a@b.com'));
      expect(updated.photoUrl, isNull);
    });
  });
}
