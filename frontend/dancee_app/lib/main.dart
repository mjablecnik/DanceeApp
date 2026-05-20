import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/app_routes.dart';
import 'core/config.dart';
import 'core/router_guard.dart';
import 'core/service_locator.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'i18n/strings.g.dart';
import 'logic/cubits/auth_cubit.dart';
import 'logic/cubits/editor_mode_cubit.dart';
import 'logic/cubits/event_cubit.dart';
import 'logic/cubits/course_cubit.dart';
import 'logic/cubits/favorites_cubit.dart';
import 'logic/cubits/filter_cubit.dart';
import 'logic/cubits/profile_cubit.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/states/course_state.dart';
import 'logic/states/editor_mode_state.dart';
import 'services/directus_auth_service.dart';
import 'shared/utils/auth_translations.dart';
import 'shared/utils/filter_prefill.dart';
import 'logic/states/auth_state.dart';
import 'logic/states/event_state.dart';
import 'logic/states/favorites_state.dart';
import 'logic/states/filter_state.dart';
import 'logic/states/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(_FirebaseErrorApp(message: e.toString()));
    return;
  }
  setupServiceLocator();
  final settingsCubit = sl<SettingsCubit>();
  await settingsCubit.init();

  // Create AuthCubit singleton and a ChangeNotifier that triggers GoRouter
  // re-evaluation whenever auth state changes.
  final authCubit = sl<AuthCubit>();
  final authRefreshNotifier = _GoRouterRefreshNotifier(authCubit.stream);

  final router = _buildRouter(authRefreshNotifier);

  runApp(TranslationProvider(
    child: DanceeApp(
      settingsCubit: settingsCubit,
      authCubit: authCubit,
      router: router,
    ),
  ));
}

/// Wraps a [Stream] as a [ChangeNotifier] so GoRouter can listen for changes.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _FirebaseErrorApp extends StatelessWidget {
  const _FirebaseErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: AppIconSizes.xl, color: Colors.red),
                const SizedBox(height: 16),
                // Hard-coded English string is intentional: this widget is
                // shown when Firebase.initializeApp() throws, which means the
                // app never reached TranslationProvider setup. Slang's `t`
                // accessor is unavailable at this point, so a raw string is
                // the only viable option (Requirement 15.2 accepted exception).
                const Text(
                  'Firebase initialization failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

GoRouter _buildRouter(_GoRouterRefreshNotifier authRefreshNotifier) {
  return GoRouter(
    initialLocation: '/events',
    refreshListenable: authRefreshNotifier,
    redirect: routerGuard,
    routes: $appRoutes,
  );
}

final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class DanceeApp extends StatelessWidget {
  const DanceeApp({
    super.key,
    required this.settingsCubit,
    required this.authCubit,
    required this.router,
    this.theme,
  });

  final SettingsCubit settingsCubit;
  final AuthCubit authCubit;
  final GoRouter router;
  /// Optional theme override — used in tests to avoid Google Fonts asset loading.
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<FilterCubit>(create: (_) => sl<FilterCubit>()),
        BlocProvider<EventCubit>(create: (_) => sl<EventCubit>()),
        BlocProvider<CourseCubit>(create: (_) => sl<CourseCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<EditorModeCubit>(create: (_) => sl<EditorModeCubit>()),
      ],
      child: _AppListeners(
        child: MaterialApp.router(
          title: t.common.appName,
          theme: theme ?? AppTheme.theme,
          routerConfig: router,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocale.values.map((l) => l.flutterLocale).toList(),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}

/// Coordinates cross-cubit reactions:
/// - Language changes → re-fetch events, courses, dance styles
/// - Filter changes → apply filters on EventCubit and CourseCubit
class _AppListeners extends StatefulWidget {
  const _AppListeners({required this.child});

  final Widget child;

  @override
  State<_AppListeners> createState() => _AppListenersState();
}

class _AppListenersState extends State<_AppListeners> with WidgetsBindingObserver {
  StreamSubscription<String>? _favErrorSub;
  bool _initialLoadDone = false;
  DateTime _lastLoadTime = DateTime.now();

  /// Minimum time in background before auto-refreshing data on resume.
  static final _staleThreshold =
      Duration(minutes: AppConfig.staleDataThresholdMinutes);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();

      // If user is already authenticated, wait for Directus tokens before
      // loading data. On unauthenticated start, load immediately (public data
      // uses the static fallback token).
      final isAuthenticated = authCubit.state.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      if (isAuthenticated && !authCubit.directusLinkedNotifier.value) {
        // Directus token exchange is in progress — wait for it.
        void onLinked() {
          if (!_initialLoadDone) {
            _initialLoadDone = true;
            _initialLoad();
          }
        }
        authCubit.directusLinkedNotifier.addListener(onLinked);
        // Safety net: if token exchange takes too long, load anyway with
        // whatever token is available (static fallback).
        Future.delayed(const Duration(seconds: 10), () {
          if (!_initialLoadDone) {
            _initialLoadDone = true;
            _initialLoad();
          }
        });
      } else {
        _initialLoadDone = true;
        _initialLoad();
      }

      _favErrorSub = context.read<FavoritesCubit>().toggleErrors.listen(
        (message) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(resolveApiErrorKey(message))),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _favErrorSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final elapsed = DateTime.now().difference(_lastLoadTime);
      if (elapsed >= _staleThreshold && _initialLoadDone) {
        _initialLoad();
      }
    }
  }

  void _initialLoad() {
    _lastLoadTime = DateTime.now();
    final languageCode = context.read<SettingsCubit>().currentLanguageCode;
    context.read<EventCubit>().loadEvents(languageCode);
    context.read<CourseCubit>().loadCourses(languageCode);
    context.read<FilterCubit>().loadDanceStyles(languageCode);
    // Only load favorites if user is authenticated (requires Directus user token)
    final isAuthenticated = context.read<AuthCubit>().state.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    );
    if (isAuthenticated) {
      context.read<FavoritesCubit>().loadFavorites();
      _prefillFiltersFromProfile();
    }
  }

  /// Loads the user profile and prefills filters from dance tags and city.
  /// Only applies if no filters are currently active.
  Future<void> _prefillFiltersFromProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final filterCubit = context.read<FilterCubit>();

    await profileCubit.loadProfile();

    // Initialize editor mode with the user's role so editor users see all content.
    profileCubit.state.maybeMap(
      loaded: (s) {
        sl<EditorModeCubit>().init(isEditor: s.profile.role == 'editor');
      },
      orElse: () {},
    );

    if (!filterCubit.state.hasActiveFilters) {
      profileCubit.state.maybeMap(
        loaded: (s) {
          debugPrint('[FilterPrefill] Cold start prefill: '
              'danceTags=${s.profile.danceTags}, city=${s.profile.city}');
          prefillFiltersFromProfile(s.profile, filterCubit);
          if (context.mounted) {
            final fs = filterCubit.state;
            context.read<EventCubit>().applyFilters(fs, fs.danceStyles);
            context.read<CourseCubit>().applyFilters(fs, fs.danceStyles);
          }
        },
        orElse: () {},
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 7.3 — Language change: re-fetch all data in the new language
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (prev, curr) => prev.languageCode != curr.languageCode,
          listener: (context, state) {
            final code = state.languageCode;
            context.read<EventCubit>().loadEvents(code);
            context.read<CourseCubit>().loadCourses(code);
            context.read<FilterCubit>().loadDanceStyles(code);
          },
        ),
        // Editor mode change: reload data so the correct set (all vs. published-only) is fetched
        BlocListener<EditorModeCubit, EditorModeState>(
          listenWhen: (prev, curr) {
            final prevEffective = prev.isEditorMode && prev.isEditor;
            final currEffective = curr.isEditorMode && curr.isEditor;
            return prevEffective != currEffective;
          },
          listener: (context, state) {
            final code = context.read<SettingsCubit>().currentLanguageCode;
            context.read<EventCubit>().loadEvents(code);
            context.read<CourseCubit>().loadCourses(code);
          },
        ),
        // 7.4 — Filter change: apply new filters to events and courses
        BlocListener<FilterCubit, FilterState>(
          listener: (context, filterState) {
            context.read<EventCubit>().applyFilters(filterState, filterState.danceStyles);
            context.read<CourseCubit>().applyFilters(filterState, filterState.danceStyles);
          },
        ),
        // 11.2 — Favorites change: sync isFavorited on EventCubit and CourseCubit
        BlocListener<FavoritesCubit, FavoritesState>(
          listenWhen: (prev, curr) =>
              curr.maybeMap(loaded: (_) => true, orElse: () => false) && prev != curr,
          listener: (context, state) {
            state.maybeMap(
              loaded: (s) {
                final eventCubit = context.read<EventCubit>();
                final courseCubit = context.read<CourseCubit>();
                eventCubit.state.maybeMap(
                  loaded: (es) {
                    for (final event in es.allEvents) {
                      final shouldBeFavorited = s.eventIds.contains(event.id);
                      if (event.isFavorited != shouldBeFavorited) {
                        eventCubit.updateFavoriteStatus(event.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
                courseCubit.state.maybeMap(
                  loaded: (cs) {
                    for (final course in cs.allCourses) {
                      final shouldBeFavorited = s.courseIds.contains(course.id);
                      if (course.isFavorited != shouldBeFavorited) {
                        courseCubit.updateFavoriteStatus(course.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
              },
              orElse: () {},
            );
          },
        ),
        // 11.3 — Events loaded: sync favorites in case FavoritesCubit loaded first
        BlocListener<EventCubit, EventState>(
          listenWhen: (prev, curr) =>
              curr.maybeMap(loaded: (_) => true, orElse: () => false) &&
              prev.maybeMap(loaded: (_) => false, orElse: () => true),
          listener: (context, state) {
            state.maybeMap(
              loaded: (es) {
                context.read<FavoritesCubit>().state.maybeMap(
                  loaded: (s) {
                    final eventCubit = context.read<EventCubit>();
                    for (final event in es.allEvents) {
                      final shouldBeFavorited = s.eventIds.contains(event.id);
                      if (event.isFavorited != shouldBeFavorited) {
                        eventCubit.updateFavoriteStatus(event.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
              },
              orElse: () {},
            );
          },
        ),
        // 11.4 — Courses loaded: sync favorites in case FavoritesCubit loaded first
        BlocListener<CourseCubit, CourseState>(
          listenWhen: (prev, curr) =>
              curr.maybeMap(loaded: (_) => true, orElse: () => false) &&
              prev.maybeMap(loaded: (_) => false, orElse: () => true),
          listener: (context, state) {
            state.maybeMap(
              loaded: (cs) {
                context.read<FavoritesCubit>().state.maybeMap(
                  loaded: (s) {
                    final courseCubit = context.read<CourseCubit>();
                    for (final course in cs.allCourses) {
                      final shouldBeFavorited = s.courseIds.contains(course.id);
                      if (course.isFavorited != shouldBeFavorited) {
                        courseCubit.updateFavoriteStatus(course.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
              },
              orElse: () {},
            );
          },
        ),
        // 9.3 — Auth sign-in: prefill filters from profile if no filters active
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              !prev.maybeMap(authenticated: (_) => true, orElse: () => false) &&
              curr.maybeMap(authenticated: (_) => true, orElse: () => false),
          listener: (context, state) async {
            final authCubit = context.read<AuthCubit>();
            final profileCubit = context.read<ProfileCubit>();
            final filterCubit = context.read<FilterCubit>();

            // Wait for Directus token exchange to complete.
            // Check if tokens are already available (fast path for fresh sign-in
            // where linkAndAuthenticate already obtained tokens).
            final directusAuth = sl<DirectusAuthService>();
            if (!directusAuth.hasTokens) {
              final completer = Completer<void>();
              void onLinked() {
                if (!completer.isCompleted) completer.complete();
              }
              authCubit.directusLinkedNotifier.addListener(onLinked);
              await completer.future.timeout(
                const Duration(seconds: 10),
                onTimeout: () {},
              );
              authCubit.directusLinkedNotifier.removeListener(onLinked);
            }

            // Load favorites now that user is authenticated
            if (context.mounted) {
              context.read<FavoritesCubit>().loadFavorites();
            }

            await profileCubit.loadProfile();

            // Initialize editor mode with the user's role after sign-in.
            profileCubit.state.maybeMap(
              loaded: (s) {
                sl<EditorModeCubit>().init(isEditor: s.profile.role == 'editor');
              },
              orElse: () {},
            );

            if (!filterCubit.state.hasActiveFilters) {
              profileCubit.state.maybeMap(
                loaded: (s) {
                  debugPrint('[FilterPrefill] Prefilling from profile: '
                      'danceTags=${s.profile.danceTags}, city=${s.profile.city}');
                  prefillFiltersFromProfile(s.profile, filterCubit);
                  // Explicitly re-apply filters so EventCubit/CourseCubit update
                  if (context.mounted) {
                    final fs = filterCubit.state;
                    context.read<EventCubit>().applyFilters(fs, fs.danceStyles);
                    context.read<CourseCubit>().applyFilters(fs, fs.danceStyles);
                  }
                },
                orElse: () {
                  debugPrint('[FilterPrefill] Profile not loaded, skipping prefill');
                },
              );
            } else {
              debugPrint('[FilterPrefill] Filters already active, skipping prefill');
            }
          },
        ),
        // 10.1 — Auth sign-out: clear all filters and reset editor mode
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev.maybeMap(authenticated: (_) => true, orElse: () => false) &&
              curr.maybeMap(unauthenticated: (_) => true, orElse: () => false),
          listener: (context, state) {
            context.read<FilterCubit>().clearAll();
            sl<EditorModeCubit>().init(isEditor: false);
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text(t.common.logoutSuccess)),
            );
          },
        ),
      ],
      child: widget.child,
    );
  }
}
