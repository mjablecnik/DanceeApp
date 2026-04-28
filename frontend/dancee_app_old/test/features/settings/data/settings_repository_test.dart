import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/settings/data/entities.dart';
import 'package:dancee_app/features/settings/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusClient extends Mock implements DirectusClient {}

void main() {
  late MockDirectusClient mockClient;
  late SettingsRepository repository;

  setUp(() {
    mockClient = MockDirectusClient();
    repository = SettingsRepository(mockClient);
  });

  // =========================================================================
  // TC-185: All SettingsRepository methods throw UnimplementedError
  // =========================================================================

  group('SettingsRepository placeholder contract', () {
    test('TC-185: getSettings() throws UnimplementedError', () async {
      await expectLater(
        () => repository.getSettings(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('TC-186: updateSettings() throws UnimplementedError', () async {
      const settings = UserSettings(id: 's1', userId: 'u1');
      await expectLater(
        () => repository.updateSettings(settings),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('TC-187: updateSetting() throws UnimplementedError', () async {
      await expectLater(
        () => repository.updateSetting('language', 'cs'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
