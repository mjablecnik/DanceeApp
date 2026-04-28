import 'package:bloc_test/bloc_test.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/settings/data/entities.dart';
import 'package:dancee_app/features/settings/data/settings_repository.dart';
import 'package:dancee_app/features/settings/logic/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusClient extends Mock implements DirectusClient {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepo;

  setUp(() {
    mockRepo = MockSettingsRepository();
  });

  // =========================================================================
  // TC-188: loadSettings() emits loading → initial (placeholder behavior)
  // =========================================================================

  blocTest<SettingsCubit, SettingsState>(
    'TC-188: loadSettings emits loading → initial (placeholder)',
    build: () => SettingsCubit(mockRepo),
    act: (cubit) => cubit.loadSettings(),
    expect: () => [
      isA<SettingsLoading>(),
      isA<SettingsInitial>(),
    ],
  );

  // =========================================================================
  // TC-189: loadSettings() does not throw
  // =========================================================================

  test('TC-189: loadSettings completes without throwing', () async {
    final cubit = SettingsCubit(mockRepo);
    await expectLater(cubit.loadSettings(), completes);
    await cubit.close();
  });

  // =========================================================================
  // TC-M01: updateSettings() emits loading → initial (placeholder contract)
  // =========================================================================

  blocTest<SettingsCubit, SettingsState>(
    'TC-M01: updateSettings emits loading → initial (placeholder)',
    build: () => SettingsCubit(mockRepo),
    act: (cubit) => cubit.updateSettings(
      const UserSettings(id: 'u1', userId: 'user1', language: 'en'),
    ),
    expect: () => [
      isA<SettingsLoading>(),
      isA<SettingsInitial>(),
    ],
  );

  // =========================================================================
  // TC-M02: updateSetting() emits loading → initial (placeholder contract)
  // =========================================================================

  blocTest<SettingsCubit, SettingsState>(
    'TC-M02: updateSetting emits loading → initial (placeholder)',
    build: () => SettingsCubit(mockRepo),
    act: (cubit) => cubit.updateSetting('language', 'cs'),
    expect: () => [
      isA<SettingsLoading>(),
      isA<SettingsInitial>(),
    ],
  );

  // =========================================================================
  // Task 70: SettingsCubit initial state is SettingsInitial before any method
  // =========================================================================

  test('TC-T70: SettingsCubit initial state is SettingsInitial', () {
    final cubit = SettingsCubit(mockRepo);
    expect(cubit.state, isA<SettingsInitial>());
  });
}
