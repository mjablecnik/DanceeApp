import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'clients.dart';
import 'config.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/dance_style_repository.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/event_cubit.dart';
import '../logic/cubits/course_cubit.dart';
import '../logic/cubits/favorites_cubit.dart';
import '../logic/cubits/filter_cubit.dart';
import '../logic/cubits/settings_cubit.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Core
  sl.registerLazySingleton<DirectusClient>(
    () => DirectusClient(
      baseUrl: AppConfig.directusBaseUrl,
      accessToken: AppConfig.directusAccessToken,
      idTokenProvider: () => sl<AuthRepository>().getIdToken(),
    ),
  );

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    ),
  );
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      favoritesRepository: sl<FavoritesRepository>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepository(client: sl<DirectusClient>()),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepository(client: sl<DirectusClient>()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(client: sl<DirectusClient>()),
  );
  sl.registerLazySingleton<DanceStyleRepository>(
    () => DanceStyleRepository(client: sl<DirectusClient>()),
  );

  // Cubits
  sl.registerFactory<SettingsCubit>(() => SettingsCubit());
  sl.registerFactory<FilterCubit>(
    () => FilterCubit(danceStyleRepository: sl<DanceStyleRepository>()),
  );
  sl.registerFactory<EventCubit>(
    () => EventCubit(eventRepository: sl<EventRepository>()),
  );
  sl.registerFactory<CourseCubit>(
    () => CourseCubit(courseRepository: sl<CourseRepository>()),
  );
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(
      favoritesRepository: sl<FavoritesRepository>(),
      authCubit: sl<AuthCubit>(),
    ),
  );
}
