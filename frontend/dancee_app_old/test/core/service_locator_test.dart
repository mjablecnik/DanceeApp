import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/auth/data/auth_repository.dart';
import 'package:dancee_app/features/auth/logic/auth.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/features/settings/data/settings_repository.dart';
import 'package:dancee_app/features/settings/logic/settings.dart';
import 'package:dancee_app/features/events/data/filter_persistence_service.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  setUp(() async {
    // Reset GetIt before each test to ensure a clean slate.
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  // =========================================================================
  // TC-L06: setupDependencies() — all registered GetIt types resolve
  // =========================================================================

  test(
    'TC-L06: setupDependencies() resolves all registered types to non-null instances',
    () {
      setupDependencies();

      // Lazy singletons
      expect(getIt<DirectusClient>(), isNotNull);
      expect(getIt<EventRepository>(), isNotNull);
      expect(getIt<AuthRepository>(), isNotNull);
      expect(getIt<SettingsRepository>(), isNotNull);
      expect(getIt<EventListCubit>(), isNotNull);
      expect(getIt<FavoritesCubit>(), isNotNull);

      // Factories (each call returns a new instance, both non-null)
      expect(getIt<AuthCubit>(), isNotNull);
      expect(getIt<SettingsCubit>(), isNotNull);

      // Factory with param
      expect(getIt<EventDetailCubit>(param1: 'test-event-id'), isNotNull);

      // New filter dependencies
      expect(getIt<FilterPersistenceService>(), isNotNull);
      expect(getIt<EventFilterCubit>(), isNotNull);
    },
  );
}
