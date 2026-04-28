import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app2/core/clients.dart';
import 'package:dancee_app2/core/service_locator.dart';
import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/cubits/settings_cubit.dart';
import 'package:dancee_app2/main.dart';

/// Inject a fake Firebase app into the MethodChannelFirebase platform and mock
/// all Firebase plugin channels so that tests can run without a real Firebase
/// project or native platform.
void _setupFakeFirebase() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fakeOptions = FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: 'fake:app:id',
    messagingSenderId: '000000000000',
    projectId: 'fake-project',
  );

  // Add a fake [DEFAULT] app so that Firebase.app() succeeds.
  MethodChannelFirebase.appInstances[defaultFirebaseAppName] =
      MethodChannelFirebaseApp(defaultFirebaseAppName, fakeOptions);

  // Mark core as initialized so initializeApp() skips the native round-trip.
  MethodChannelFirebase.isCoreInitialized = true;

  // Mock Firebase Auth Pigeon channels so that auth-state registration does
  // not cause PlatformException channel errors in the test environment.
  //
  // Pigeon expects a non-null ByteData response. For channels that return a
  // String (registerIdTokenListener, registerAuthStateListener), we return
  // an encoded Pigeon success response containing a placeholder channel name.
  // Firebase Auth will then attempt to open an EventChannel on that name to
  // stream auth-state events, so we mock those EventChannel MethodChannels
  // too (listen/cancel always succeed, no events are ever emitted).
  const _pigeonCodec = StandardMessageCodec();

  // Success response for void/null methods.
  final ByteData? nullResponse = _pigeonCodec.encodeMessage(<Object?>[null]);

  const firebaseAuthChannelPrefix =
      'dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.';

  for (final entry in {
    // registerIdTokenListener returns the channel name for the id-token stream.
    'registerIdTokenListener':
        _pigeonCodec.encodeMessage(<Object?>['__fake_id_token_channel__']),
    // registerAuthStateListener returns the channel name for auth-state stream.
    'registerAuthStateListener':
        _pigeonCodec.encodeMessage(<Object?>['__fake_auth_state_channel__']),
    'initializeApp': nullResponse,
    'signOut': nullResponse,
    'currentUser': nullResponse,
  }.entries) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      '$firebaseAuthChannelPrefix${entry.key}',
      (_) async => entry.value,
    );
  }

  // Firebase Auth sets up EventChannels on the channel names returned above.
  // Mock the 'listen' and 'cancel' method calls on those EventChannels so the
  // streams stay open but never emit — simulating an unauthenticated state.
  for (final channelName in [
    '__fake_id_token_channel__',
    '__fake_auth_state_channel__',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel(channelName),
      (call) async => null,
    );
  }
}

/// Creates a [Dio] instance whose interceptor resolves every request
/// immediately with an empty `{"data": []}` Directus envelope, so that
/// [EventCubit], [CourseCubit], etc. complete synchronously in tests without
/// real network calls or long Dio timeouts.
Dio _createMockDio() {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: const <String, dynamic>{'data': <dynamic>[]},
      ));
    },
  ));
  return dio;
}

void main() {
  setUpAll(_setupFakeFirebase);

  setUp(() {
    if (!sl.isRegistered<SettingsCubit>()) {
      setupServiceLocator();
      // Replace the real DirectusClient with one backed by a mock Dio so that
      // HTTP calls resolve immediately and never outlive the test's cubits.
      sl.unregister<DirectusClient>();
      sl.registerLazySingleton<DirectusClient>(
        () => DirectusClient(
          baseUrl: 'http://localhost',
          accessToken: 'test',
          dio: _createMockDio(),
        ),
      );
    }
  });

  testWidgets('App smoke test - renders without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);
    final settingsCubit = sl<SettingsCubit>();
    final authCubit = sl<AuthCubit>();
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(),
        ),
      ],
    );

    // Use runAsync to step outside fakeAsync so Firebase Auth channel
    // registration and mock HTTP completions run as real async operations.
    //
    // sl.reset() is called inside runAsync — after draining the microtask
    // queue — so cubit closes happen only after mock Dio responses have
    // been fully processed by the cubits.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        TranslationProvider(
          child: DanceeApp(
            settingsCubit: settingsCubit,
            authCubit: authCubit,
            router: router,
            // Use a plain theme to avoid Google Fonts asset-loading errors in
            // tests (GoogleFonts.interTextTheme requires font files in assets).
            theme: ThemeData.dark(),
          ),
        ),
      );

      // Pump once to fire addPostFrameCallback (_initialLoad), which triggers
      // EventCubit.loadEvents, CourseCubit.loadCourses, etc. via mock Dio.
      await tester.pump();

      // Drain the microtask queue so all mock Dio response continuations
      // (Dio → Repository → Cubit.emit) complete before sl.reset() closes
      // the cubits — preventing "Cannot emit after close" errors.
      for (var i = 0; i < 20; i++) {
        await Future.microtask(() {});
      }

      await sl.reset();
    });

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
