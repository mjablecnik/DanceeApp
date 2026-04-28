import 'package:dancee_app/features/settings/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings', () {
    // =========================================================================
    // TC-026: fromJson / toJson round-trip is lossless
    // =========================================================================

    test('TC-026: fromJson/toJson round-trip is lossless', () {
      final json = {
        'id': 'settings-1',
        'userId': 'user-123',
        'language': 'cs',
        'themeMode': 'dark',
        'notificationsEnabled': false,
        'emailNotificationsEnabled': true,
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.id, equals('settings-1'));
      expect(settings.userId, equals('user-123'));
      expect(settings.language, equals('cs'));
      expect(settings.themeMode, equals('dark'));
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.emailNotificationsEnabled, isTrue);

      final roundTripped = UserSettings.fromJson(settings.toJson());
      expect(roundTripped, equals(settings));
    });

    // =========================================================================
    // TC-027: Default values are applied for missing JSON keys
    // =========================================================================

    test('TC-027: missing optional fields resolve to documented defaults', () {
      final minimalJson = {
        'id': 'settings-2',
        'userId': 'user-456',
        // language, themeMode, notifications omitted
      };

      final settings = UserSettings.fromJson(minimalJson);

      expect(settings.language, equals('en'));
      expect(settings.themeMode, equals('system'));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.emailNotificationsEnabled, isTrue);
    });

    // =========================================================================
    // TC-121: copyWith() updates only specified fields, leaving defaults intact
    // =========================================================================

    test('TC-121: copyWith updates only specified fields, preserves others', () {
      const original = UserSettings(id: '1', userId: 'u1');

      final updated = original.copyWith(language: 'cs');

      expect(updated.language, equals('cs'));
      expect(updated.id, equals('1'));
      expect(updated.userId, equals('u1'));
      expect(updated.themeMode, equals('system'));
      expect(updated.notificationsEnabled, isTrue);
      expect(updated.emailNotificationsEnabled, isTrue);
    });

    // =========================================================================
    // TC-190: copyWith(language: 'es') changes only language, preserves others
    // =========================================================================

    test(
        "TC-190: copyWith(language: 'es') changes only language and "
        'preserves all other fields', () {
      const original = UserSettings(
        id: 'settings-99',
        userId: 'user-99',
        language: 'en',
        themeMode: 'dark',
        notificationsEnabled: false,
        emailNotificationsEnabled: false,
      );

      final updated = original.copyWith(language: 'es');

      expect(updated.language, equals('es'),
          reason: 'language should be updated to "es"');
      expect(updated.id, equals(original.id));
      expect(updated.userId, equals(original.userId));
      expect(updated.themeMode, equals(original.themeMode));
      expect(updated.notificationsEnabled, equals(original.notificationsEnabled));
      expect(updated.emailNotificationsEnabled,
          equals(original.emailNotificationsEnabled));
    });
  });
}
