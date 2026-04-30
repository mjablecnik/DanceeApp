// Bug condition exploration test for ProfileScreen missing sections
// Task 1 from profile-page-completion spec
//
// CRITICAL: This test MUST FAIL on unfixed code — failure confirms the bug exists.
// DO NOT fix the test or the code when it fails.
//
// EXPECTED OUTCOME (unfixed): Test FAILS because:
//   - ProfileCardSection not found in widget tree (not imported / not wired)
//   - AccountSection not found in widget tree (not imported / not wired)
//   - PremiumBanner not found in widget tree (not imported / not wired)
//   - SupportSection not found in widget tree (not imported / not wired)
//   - AppInfoSection not found in widget tree (not imported / not wired)
//   - No trailing edit icon in BackButtonHeader (trailing param not passed)
//   - No notifications toggle (Switch) in SettingsSection (only language picker rendered)
//
// EXPECTED OUTCOME (after fix in task 3): Test PASSES — all 7 sections render,
// edit icon present, notifications toggle present.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/data/entities/user_profile.dart';
import 'package:dancee_app/data/repositories/auth_repository.dart';
import 'package:dancee_app/data/repositories/favorites_repository.dart';
import 'package:dancee_app/data/repositories/profile_repository.dart';
import 'package:dancee_app/i18n/strings.g.dart';
import 'package:dancee_app/logic/cubits/auth_cubit.dart';
import 'package:dancee_app/logic/cubits/profile_cubit.dart';
import 'package:dancee_app/logic/cubits/settings_cubit.dart';
import 'package:dancee_app/logic/states/profile_state.dart';
import 'package:dancee_app/screens/profile/profile/profile_screen.dart';
import 'package:dancee_app/screens/profile/profile/sections/account_section.dart';
import 'package:dancee_app/screens/profile/profile/sections/app_info_section.dart';
import 'package:dancee_app/screens/profile/profile/sections/logout_section.dart';
import 'package:dancee_app/screens/profile/profile/sections/profile_card_section.dart';
import 'package:dancee_app/screens/profile/profile/sections/settings_section.dart';
import 'package:dancee_app/screens/profile/profile/sections/support_section.dart';
import 'package:dancee_app/screens/profile/profile/components/premium_banner.dart';

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

/// Fake [AuthRepository] that provides a controllable auth-state stream
/// without touching Firebase platform channels.
class _FakeAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  bool get isEmailProvider => false;

  void emitUser(User? user) => _controller.add(user);

  Future<void> dispose() => _controller.close();
}

class _FakeFavoritesRepository extends Fake implements FavoritesRepository {}

class _FakeProfileRepository extends Fake implements ProfileRepository {
  @override
  Future<String> getAppVersion() async => '1.0.0+1';
}

const _kFakeProfile = UserProfile(
  directusUserId: 'dir-1',
  firebaseUid: 'test-uid',
  firstName: 'Test',
  lastName: 'User',
  email: 'test@example.com',
  danceTags: [],
  experienceLevel: 'beginner',
);

/// Stub [ProfileCubit] that immediately emits a loaded profile — avoids real API calls in tests.
class _StubProfileCubit extends ProfileCubit {
  _StubProfileCubit()
      : super(
          profileRepository: _FakeProfileRepository(),
          authCubit: AuthCubit(
            authRepository: _FakeAuthRepository(),
            favoritesRepository: _FakeFavoritesRepository(),
          ),
        );

  @override
  Future<void> loadProfile() async {
    emit(const ProfileState.loaded(profile: _kFakeProfile));
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [GoRouter] that hosts [ProfileScreen] at `/` with all referenced
/// named routes defined as no-op stubs so GoRouter does not throw on navigate.
GoRouter _buildRouter(
  AuthCubit authCubit,
  SettingsCubit settingsCubit,
  ProfileCubit profileCubit,
) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
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
      GoRoute(path: '/profile/legal', builder: (_, __) => const Scaffold()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    // Set a default locale so slang translation getters return strings
    // instead of throwing during widget build.
    LocaleSettings.setLocale(AppLocale.en);
    // Register fakes in service locator for widgets that access sl<> directly.
    if (!sl.isRegistered<ProfileRepository>()) {
      sl.registerLazySingleton<ProfileRepository>(() => _FakeProfileRepository());
    }
  });

  tearDownAll(() async {
    await sl.reset();
  });

  group('ProfileScreen — bug condition exploration (task 1)', () {
    late _FakeAuthRepository fakeAuthRepo;
    late _FakeFavoritesRepository fakeFavoritesRepo;
    late AuthCubit authCubit;
    late SettingsCubit settingsCubit;
    late _StubProfileCubit profileCubit;

    setUp(() {
      fakeAuthRepo = _FakeAuthRepository();
      fakeFavoritesRepo = _FakeFavoritesRepository();
      authCubit = AuthCubit(
        authRepository: fakeAuthRepo,
        favoritesRepository: fakeFavoritesRepo,
      );
      settingsCubit = SettingsCubit();
      profileCubit = _StubProfileCubit();
    });

    tearDown(() async {
      await authCubit.close();
      await settingsCubit.close();
      await profileCubit.close();
      await fakeAuthRepo.dispose();
    });

    testWidgets(
      'renders all 7 required sections, a trailing edit icon, and a notifications toggle',
      (tester) async {
        final router = _buildRouter(authCubit, settingsCubit, profileCubit);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        // Emit authenticated user so AuthCubit reaches authenticated state.
        fakeAuthRepo.emitUser(_FakeUser());
        await tester.pump();

        // ── Section presence assertions ──────────────────────────────────
        // FAULT CONDITION: The following 5 expect calls FAIL on unfixed code
        // because these widgets are not imported / not wired in build().

        expect(
          find.byType(ProfileCardSection),
          findsOneWidget,
          reason: 'Counterexample: ProfileCardSection not in widget tree',
        );

        expect(
          find.byType(AccountSection),
          findsOneWidget,
          reason: 'Counterexample: AccountSection not in widget tree',
        );

        // PremiumBanner is intentionally commented out (task 7.3 / Requirement 9):
        // the Premium section is hidden until the feature is ready.
        expect(
          find.byType(PremiumBanner),
          findsNothing,
          reason: 'PremiumBanner must be absent from the widget tree (commented out per Requirement 9)',
        );

        expect(
          find.byType(SupportSection),
          findsOneWidget,
          reason: 'Counterexample: SupportSection not in widget tree',
        );

        expect(
          find.byType(AppInfoSection),
          findsOneWidget,
          reason: 'Counterexample: AppInfoSection not in widget tree',
        );

        // Sanity checks — already present in unfixed code.
        expect(find.byType(SettingsSection), findsOneWidget);
        expect(find.byType(LogoutSection), findsOneWidget);

        // ── Header trailing edit icon ────────────────────────────────────
        // FAULT CONDITION: BackButtonHeader is called without `trailing`,
        // so no FaIcon(FontAwesomeIcons.pen) exists in the header.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is FaIcon && widget.icon == FontAwesomeIcons.pen,
          ),
          findsAtLeastNWidgets(1),
          reason:
              'Counterexample: No trailing edit icon (FaIcon pen) found in header',
        );

        // ── Notifications toggle in SettingsSection ──────────────────────
        // FAULT CONDITION: SettingsSection only renders the language picker,
        // no Switch widget is present.
        expect(
          find.descendant(
            of: find.byType(SettingsSection),
            matching: find.byType(Switch),
          ),
          findsOneWidget,
          reason:
              'Counterexample: No notifications toggle (Switch) inside SettingsSection',
        );
      },
    );
  });
}
