// Preservation property tests for ProfileScreen existing behaviors
// Task 2 from profile-page-completion spec
//
// IMPORTANT: These tests follow observation-first methodology.
// They are written by observing the UNFIXED code and capture existing behaviors.
//
// EXPECTED OUTCOME: Tests PASS on unfixed code (confirms baseline behavior to preserve).
// Tests should continue to PASS after the fix in task 3 (no regressions).
//
// Preserved behaviors:
//   1. Logout button shows confirmation dialog with cancel and logout actions
//   2. Confirming logout calls AuthCubit.signOut()
//   3. Delete account button shows confirmation dialog with cancel and delete actions
//   4. Language picker row is present in SettingsSection and tapping opens language dialog
//   5. Back button in header triggers context.pop()
//   6. Auth error banner renders above Danger Zone when auth state emits error
//   7. AbsorbPointer overlay with CircularProgressIndicator displays during loading
//   8. Unauthenticated auth state causes navigation to LoginRoute

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/i18n/strings.g.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/cubits/settings_cubit.dart';
import 'package:dancee_app/logic/states/auth_state.dart';
import 'package:dancee_app/screens/profile/profile/profile_screen.dart';
import 'package:dancee_app/screens/profile/profile/sections/settings_section.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUserMetadata extends Fake implements UserMetadata {
  @override
  DateTime? get creationTime =>
      DateTime.now().subtract(const Duration(hours: 1));
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  bool get emailVerified => true;

  @override
  UserMetadata get metadata => _FakeUserMetadata();
}

/// Fake [AuthRepository] with controllable auth-state stream and call tracking.
class _FakeAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  int signOutCallCount = 0;
  int deleteAccountCallCount = 0;
  bool hangSignOut = false;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  bool get isEmailProvider => false;

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    if (!hangSignOut) {
      _controller.add(null);
    }
    // If hangSignOut is true, do not emit anything — cubit stays in loading state.
  }

  @override
  Future<void> reauthenticate({String? email, String? password}) async {}

  @override
  Future<void> deleteAccount() async {
    deleteAccountCallCount++;
    _controller.add(null);
  }

  void emitUser(User? user) => _controller.add(user);

  void emitNull() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {
  @override
  Future<void> deleteAllFavoritesForUser(String uid) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [GoRouter] that hosts [ProfileScreen] at `/` with referenced
/// named routes as no-op stubs.
GoRouter _buildRouter(AuthCubit authCubit, SettingsCubit settingsCubit) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const Scaffold()),
      GoRoute(
          path: '/profile/change-password',
          builder: (_, __) => const Scaffold()),
      GoRoute(path: '/profile/premium', builder: (_, __) => const Scaffold()),
      GoRoute(
          path: '/profile/author-contact',
          builder: (_, __) => const Scaffold()),
    ],
  );
}

/// Pumps the ProfileScreen and emits an authenticated user so it's in
/// the normal authenticated state ready for interaction.
Future<void> _pumpProfileScreen(
  WidgetTester tester,
  GoRouter router,
  _FakeAuthRepository fakeAuthRepo,
) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  fakeAuthRepo.emitUser(_FakeUser());
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
    // Provide a mock SharedPreferences for SettingsCubit.setLanguage()
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileScreen — preservation tests (task 2)', () {
    late _FakeAuthRepository fakeAuthRepo;
    late _FakeFavoritesRepository fakeFavoritesRepo;
    late AuthCubit authCubit;
    late SettingsCubit settingsCubit;
    late GoRouter router;

    setUp(() {
      fakeAuthRepo = _FakeAuthRepository();
      fakeFavoritesRepo = _FakeFavoritesRepository();
      authCubit = AuthCubit(
        authRepository: fakeAuthRepo,
        favoritesRepository: fakeFavoritesRepo,
      );
      settingsCubit = SettingsCubit();
      router = _buildRouter(authCubit, settingsCubit);
    });

    tearDown(() async {
      await authCubit.close();
      await settingsCubit.close();
      await fakeAuthRepo.dispose();
    });

    // ── Preservation 1 & 2: Logout dialog and signOut() call ───────────────

    testWidgets(
      'tapping logout button shows confirmation dialog with cancel and logout actions',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Tap the logout row (find by danger logout text)
        await tester.tap(find.text(t.profile.danger.logout).first);
        await tester.pumpAndSettle();

        // Dialog should appear with cancel and logout action buttons
        expect(
          find.text(t.common.cancel),
          findsOneWidget,
          reason: 'Cancel button should appear in logout confirmation dialog',
        );
        expect(
          find.text(t.profile.danger.logout),
          findsWidgets,
          reason: 'Logout action should appear in logout confirmation dialog',
        );
        expect(
          find.text(t.profile.danger.logoutConfirmBody),
          findsOneWidget,
          reason: 'Logout confirmation message should appear in dialog',
        );
      },
    );

    testWidgets(
      'confirming logout dialog calls AuthCubit.signOut()',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Open logout dialog
        await tester.tap(find.text(t.profile.danger.logout).first);
        await tester.pumpAndSettle();

        // Confirm logout — tap the logout button inside the dialog (the last one)
        final logoutButtons = find.text(t.profile.danger.logout);
        await tester.tap(logoutButtons.last);
        await tester.pumpAndSettle();

        expect(
          fakeAuthRepo.signOutCallCount,
          equals(1),
          reason: 'AuthCubit.signOut() should be called once after confirming logout',
        );
      },
    );

    testWidgets(
      'cancelling logout dialog does NOT call AuthCubit.signOut()',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Open logout dialog
        await tester.tap(find.text(t.profile.danger.logout).first);
        await tester.pumpAndSettle();

        // Cancel logout
        await tester.tap(find.text(t.common.cancel));
        await tester.pumpAndSettle();

        expect(
          fakeAuthRepo.signOutCallCount,
          equals(0),
          reason: 'AuthCubit.signOut() should NOT be called when logout is cancelled',
        );
      },
    );

    // ── Preservation 3: Delete account dialog ──────────────────────────────

    testWidgets(
      'tapping delete account button shows confirmation dialog with cancel and delete actions',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Tap delete account row
        await tester.tap(find.text(t.profile.danger.deleteAccount));
        await tester.pumpAndSettle();

        expect(
          find.text(t.auth.deleteAccount.confirmTitle),
          findsOneWidget,
          reason: 'Delete account confirmation dialog title should appear',
        );
        expect(
          find.text(t.auth.deleteAccount.confirmBody),
          findsOneWidget,
          reason: 'Delete account confirmation body should appear',
        );
        expect(
          find.text(t.common.cancel),
          findsOneWidget,
          reason: 'Cancel button should appear in delete account dialog',
        );
        expect(
          find.text(t.profile.danger.deleteAccount),
          findsWidgets,
          reason: 'Delete account action should appear in dialog',
        );
      },
    );

    testWidgets(
      'cancelling delete account dialog does NOT call AuthCubit.deleteAccount()',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        await tester.tap(find.text(t.profile.danger.deleteAccount));
        await tester.pumpAndSettle();

        await tester.tap(find.text(t.common.cancel));
        await tester.pumpAndSettle();

        expect(
          fakeAuthRepo.deleteAccountCallCount,
          equals(0),
          reason: 'deleteAccount should NOT be called when dialog is cancelled',
        );
      },
    );

    // ── Preservation 4: Language picker ────────────────────────────────────

    testWidgets(
      'language picker row is present in SettingsSection and tapping opens language dialog',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Language row must be visible inside SettingsSection
        final languageRow = find.descendant(
          of: find.byType(SettingsSection),
          matching: find.text(t.profile.settings.language),
        );
        expect(
          languageRow,
          findsOneWidget,
          reason: 'Language row must be present inside SettingsSection',
        );

        // Tapping it opens the language selection dialog
        await tester.tap(languageRow);
        await tester.pumpAndSettle();

        // Dialog shows language options (use findsWidgets since English also
        // appears in SettingsSection as the current language indicator)
        expect(
          find.text(t.profile.settings.english),
          findsWidgets,
          reason: 'Language dialog should show English option',
        );
        expect(
          find.text(t.profile.settings.czech),
          findsOneWidget,
          reason: 'Language dialog should show Czech option',
        );
        expect(
          find.text(t.profile.settings.spanish),
          findsOneWidget,
          reason: 'Language dialog should show Spanish option',
        );
      },
    );

    testWidgets(
      'selecting a language in the dialog calls SettingsCubit.setLanguage()',
      (tester) async {
        await _pumpProfileScreen(tester, router, fakeAuthRepo);

        // Open the language dialog
        final languageRow = find.descendant(
          of: find.byType(SettingsSection),
          matching: find.text(t.profile.settings.language),
        );
        await tester.tap(languageRow);
        await tester.pumpAndSettle();

        // Select Czech
        await tester.tap(find.text(t.profile.settings.czech));
        await tester.pumpAndSettle();

        expect(
          settingsCubit.state.languageCode,
          equals('cs'),
          reason: 'SettingsCubit.setLanguage() should update language to Czech',
        );
      },
    );

    // ── Preservation 5: Back navigation ────────────────────────────────────

    testWidgets(
      'tapping the back button triggers context.pop()',
      (tester) async {
        // Build a router that starts at a previous route so pop() has somewhere to go.
        final popTestRouter = GoRouter(
          initialLocation: '/prev',
          routes: [
            GoRoute(
              path: '/prev',
              builder: (_, __) => Builder(
                builder: (ctx) => Scaffold(
                  body: TextButton(
                    onPressed: () => ctx.push('/profile'),
                    child: const Text('Go to Profile'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<AuthCubit>.value(value: authCubit),
                  BlocProvider<SettingsCubit>.value(value: settingsCubit),
                ],
                child: const ProfileScreen(),
              ),
            ),
            GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
            GoRoute(path: '/profile/edit', builder: (_, __) => const Scaffold()),
            GoRoute(path: '/profile/change-password', builder: (_, __) => const Scaffold()),
            GoRoute(path: '/profile/premium', builder: (_, __) => const Scaffold()),
            GoRoute(path: '/profile/author-contact', builder: (_, __) => const Scaffold()),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: popTestRouter));
        await tester.pump();

        // Navigate to profile screen
        await tester.tap(find.text('Go to Profile'));
        await tester.pumpAndSettle();

        fakeAuthRepo.emitUser(_FakeUser());
        await tester.pump();

        // Find and tap back button using FaIcon with arrowLeft icon
        expect(
          find.byWidgetPredicate(
            (w) => w is FaIcon && w.icon == FontAwesomeIcons.arrowLeft,
          ),
          findsOneWidget,
          reason: 'Back button (FaIcon arrowLeft) should be present in header',
        );
        await tester.tap(find.byWidgetPredicate(
          (w) => w is FaIcon && w.icon == FontAwesomeIcons.arrowLeft,
        ));
        await tester.pumpAndSettle();

        // Should be back at /prev route
        expect(
          find.text('Go to Profile'),
          findsOneWidget,
          reason: 'Back button should pop the route back to previous screen',
        );
      },
    );

    // ── Preservation 6: Error banner ───────────────────────────────────────
    //
    // NOTE: Cubits created in setUp() run outside FakeAsync so their stream
    // events are not controlled by tester.pump(). For tests that need to
    // observe state transitions via pump(), we create fresh cubits inside
    // the testWidgets callback to keep them inside the FakeAsync zone.

    testWidgets(
      'when auth state emits error, error banner renders above Danger Zone',
      (tester) async {
        // Create cubit inside FakeAsync zone so pump() controls its streams.
        final localRepo = _FakeAuthRepository();
        final localCubit = AuthCubit(
          authRepository: localRepo,
          favoritesRepository: _FakeFavoritesRepository(),
        );
        final localSettingsCubit = SettingsCubit();
        final localRouter = _buildRouter(localCubit, localSettingsCubit);

        await tester.pumpWidget(MaterialApp.router(routerConfig: localRouter));
        localRepo.emitUser(_FakeUser());
        await tester.pump();

        // Emit an error state — BlocConsumer listener fires setState → rebuild.
        localCubit.emit(const AuthState.error(message: 'auth.errors.generic'));
        await tester.pump();
        await tester.pump();

        // Error banner should be present (identified by its icon)
        expect(
          find.byIcon(Icons.error_outline),
          findsOneWidget,
          reason: 'Error icon should be shown in error banner',
        );

        await localCubit.close();
        await localSettingsCubit.close();
        await localRepo.dispose();
      },
    );

    // ── Preservation 7: Loading overlay ────────────────────────────────────

    testWidgets(
      'when auth state is loading, AbsorbPointer overlay with CircularProgressIndicator is displayed',
      (tester) async {
        // Create cubit inside FakeAsync zone so pump() controls its streams.
        final localRepo = _FakeAuthRepository();
        final localCubit = AuthCubit(
          authRepository: localRepo,
          favoritesRepository: _FakeFavoritesRepository(),
        );
        final localSettingsCubit = SettingsCubit();
        final localRouter = _buildRouter(localCubit, localSettingsCubit);

        await tester.pumpWidget(MaterialApp.router(routerConfig: localRouter));
        localRepo.emitUser(_FakeUser());
        await tester.pump();

        // Configure signOut to NOT emit completion so cubit stays in loading.
        localRepo.hangSignOut = true;
        // Trigger loading by calling signOut without awaiting.
        localCubit.signOut(); // ignore: unawaited_futures

        // Two pumps: emit(loading) → BlocConsumer stream event → rebuild.
        await tester.pump();
        await tester.pump();

        expect(
          find.byType(AbsorbPointer),
          findsAtLeastNWidgets(1),
          reason: 'AbsorbPointer overlay should be present during loading',
        );
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: 'CircularProgressIndicator should be shown during loading',
        );

        await localCubit.close();
        await localSettingsCubit.close();
        await localRepo.dispose();
      },
    );

    // ── Preservation 8: Unauthenticated → navigate to login ────────────────

    testWidgets(
      'when auth state emits unauthenticated, navigation to LoginRoute occurs',
      (tester) async {
        // Create cubit inside FakeAsync zone so pump() controls its streams.
        final localRepo = _FakeAuthRepository();
        final localCubit = AuthCubit(
          authRepository: localRepo,
          favoritesRepository: _FakeFavoritesRepository(),
        );
        final localSettingsCubit = SettingsCubit();
        final localRouter = _buildRouter(localCubit, localSettingsCubit);

        await tester.pumpWidget(MaterialApp.router(routerConfig: localRouter));
        localRepo.emitUser(_FakeUser());
        await tester.pump();

        // Emit unauthenticated state via stream.
        localRepo.emitNull();
        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        // Should have navigated to /login
        expect(
          localRouter.routerDelegate.currentConfiguration.fullPath,
          equals('/login'),
          reason: 'Unauthenticated state should navigate to /login',
        );

        await localCubit.close();
        await localSettingsCubit.close();
        await localRepo.dispose();
      },
    );
  });
}
