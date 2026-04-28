// Feature: cms-flutter-integration
// Task 5.3: Property test for SettingsCubit language persistence
// Properties covered:
//   Property 16: Language persistence round-trip

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/logic/cubits/settings_cubit.dart';

// ---------------------------------------------------------------------------
// Property 16: Language persistence round-trip
// ---------------------------------------------------------------------------

void _propertyLanguagePersistenceRoundTrip() {
  // Feature: cms-flutter-integration, Property 16: Language persistence round-trip
  test(
    'P16: setLanguage then init on a fresh cubit yields the same languageCode',
    () async {
      const validCodes = ['en', 'cs', 'es'];

      for (final code in validCodes) {
        // Reset SharedPreferences to a clean state before each iteration.
        SharedPreferences.setMockInitialValues({});
        LocaleSettings.setLocale(AppLocale.en);

        // Persist the language via the cubit.
        final writerCubit = SettingsCubit();
        await writerCubit.setLanguage(code);

        // A fresh cubit reading from SharedPreferences should recover the value.
        final readerCubit = SettingsCubit();
        await readerCubit.init();

        expect(
          readerCubit.state.languageCode,
          equals(code),
          reason: 'Round-trip failed for language code "$code"',
        );

        await writerCubit.close();
        await readerCubit.close();
      }
    },
  );

  test(
    'P16b: init with no persisted value defaults to "en" (100 iterations)',
    () async {
      for (var i = 0; i < 100; i++) {
        // Empty SharedPreferences — nothing persisted yet.
        SharedPreferences.setMockInitialValues({});
        LocaleSettings.setLocale(AppLocale.en);

        final cubit = SettingsCubit();
        await cubit.init();

        expect(
          cubit.state.languageCode,
          equals('en'),
          reason: 'Iteration $i: default language should be "en"',
        );

        await cubit.close();
      }
    },
  );

  test(
    'P16c: setLanguage emits a state with the new code for all valid codes',
    () async {
      const validCodes = ['en', 'cs', 'es'];

      for (final code in validCodes) {
        SharedPreferences.setMockInitialValues({});
        LocaleSettings.setLocale(AppLocale.en);

        final cubit = SettingsCubit();
        await cubit.setLanguage(code);

        expect(
          cubit.state.languageCode,
          equals(code),
          reason: 'Emitted state should have languageCode == "$code"',
        );

        await cubit.close();
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsCubit — property tests', () {
    group(
      'Property 16: Language persistence round-trip',
      _propertyLanguagePersistenceRoundTrip,
    );
  });
}
