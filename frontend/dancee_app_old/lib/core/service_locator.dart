import 'package:get_it/get_it.dart';

import 'clients.dart';
import 'config.dart';

// Feature repositories
import '../features/events/data/event_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/settings/data/settings_repository.dart';

// Feature cubits
import '../features/events/logic/event_list.dart';
import '../features/events/logic/favorites.dart';
import '../features/auth/logic/auth.dart';
import '../features/settings/logic/settings.dart';
import '../features/events/logic/event_detail.dart';
import '../features/events/data/filter_persistence_service.dart';
import '../features/events/logic/event_filter.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register DirectusClient as lazy singleton
  getIt.registerLazySingleton<DirectusClient>(
    () => DirectusClient(
      baseUrl: AppConfig.directusBaseUrl,
      accessToken: AppConfig.directusAccessToken,
    ),
  );

  // Register repositories as lazy singletons
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(getIt<DirectusClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DirectusClient>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(getIt<DirectusClient>()),
  );

  // Register cubits
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>()),
  );

  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>(), getIt<EventListCubit>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepository>()),
  );

  getIt.registerFactoryParam<EventDetailCubit, String, void>(
    (eventId, _) => EventDetailCubit(
      eventListCubit: getIt<EventListCubit>(),
      eventId: eventId,
    ),
  );

  getIt.registerLazySingleton<FilterPersistenceService>(
    () => FilterPersistenceService(),
  );

  // Use registerSingleton (eager) since the cubit is accessed immediately for
  // restoreFilters() — using lazySingleton here would be misleading.
  getIt.registerSingleton<EventFilterCubit>(
    EventFilterCubit(
      getIt<EventListCubit>(),
      getIt<FilterPersistenceService>(),
    ),
  );

  // Await restoreFilters so saved filters are in place before the UI renders.
  await getIt<EventFilterCubit>().restoreFilters();
}
