import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'clients.dart';
import 'config.dart';
import '../services/destination_service.dart';
import '../services/directus_auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/dance_style_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/editor_mode_cubit.dart';
import '../logic/cubits/event_cubit.dart';
import '../logic/cubits/course_cubit.dart';
import '../logic/cubits/favorites_cubit.dart';
import '../logic/cubits/filter_cubit.dart';
import '../logic/cubits/profile_cubit.dart';
import '../logic/cubits/settings_cubit.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton<DestinationService>(() => DestinationService());
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(
        clientId: kIsWeb ? AppConfig.googleWebClientId : null,
        serverClientId: kIsWeb ? null : AppConfig.googleWebClientId,
      ),
    ),
  );
  sl.registerLazySingleton<DirectusAuthService>(
    () => DirectusAuthService(),
  );

  // Core
  sl.registerLazySingleton<DirectusClient>(
    () => DirectusClient(
      baseUrl: AppConfig.directusBaseUrl,
      accessToken: AppConfig.directusAccessToken,
      directusTokenProvider: () => sl<DirectusAuthService>().getAccessToken(),
      onTokenExpired: () => sl<AuthRepository>().ensureDirectusLinked(),
    ),
  );
  sl.registerLazySingleton<WorkflowClient>(
    () => WorkflowClient(baseUrl: AppConfig.workflowBaseUrl),
  );

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuthService: sl<FirebaseAuthService>(),
      directusAuthService: sl<DirectusAuthService>(),
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
    () => EventRepository(
      client: sl<DirectusClient>(),
      workflowClient: sl<WorkflowClient>(),
    ),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepository(
      client: sl<DirectusClient>(),
      workflowClient: sl<WorkflowClient>(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(client: sl<DirectusClient>()),
  );
  sl.registerLazySingleton<DanceStyleRepository>(
    () => DanceStyleRepository(client: sl<DirectusClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      client: sl<DirectusClient>(),
      directusAuthService: sl<DirectusAuthService>(),
    ),
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
      directusAuthService: sl<DirectusAuthService>(),
    ),
  );
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(
      profileRepository: sl<ProfileRepository>(),
      authCubit: sl<AuthCubit>(),
    ),
  );
  sl.registerLazySingleton<EditorModeCubit>(() => EditorModeCubit());
}
