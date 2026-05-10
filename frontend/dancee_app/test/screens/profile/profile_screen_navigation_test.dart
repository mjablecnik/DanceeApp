// Navigation unit tests for ProfileScreen newly-wired sections
// Optional tests from the profile-page-completion design spec:
//   - AccountSection navigation callbacks route to correct destinations
//     (Edit Profile → /profile/edit, Change Password → /profile/change-password)
//   - PremiumBanner onTap routes to PremiumRoute (/profile/premium)
//   - SupportSection onContactAuthor routes to AuthorContactRoute (/profile/author-contact)
//   - BackButtonHeader trailing edit icon routes to ProfileEditRoute (/profile/edit)
//
// Assertions verify navigation by checking that the destination screen's
// sentinel text becomes visible after tapping (imperative GoRouter push does
// not update routerDelegate.currentConfiguration.fullPath in the same way
// that declarative go() does, so we use visible-content assertions instead).

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
import 'package:dancee_app/screens/profile/profile/components/premium_banner.dart';
import 'package:dancee_app/screens/profile/profile/sections/support_section.dart';

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

class _FakeAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  bool get isEmailProvider => false;

  @override
  User? get currentUser => null;

  void emitUser(User? user) => _controller.add(user);

  Future<void> dispose() => _controller.close();

  @override
  Future<void> ensureDirectusLinked() async {}
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
  notificationPreferences: {},
);

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

/// Builds a [GoRouter] with [ProfileScreen] at `/` and stub destinations for
/// all push targets. Each destination renders a unique sentinel text so tests
/// can verify navigation succeeded by checking `find.text(sentinel)`.
GoRouter _buildRouter(AuthCubit authCubit, SettingsCubit settingsCubit, [ProfileCubit? profileCubit]) {
  final pc = profileCubit ?? _StubProfileCubit();
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<ProfileCubit>.value(value: pc),
          ],
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('DEST_PROFILE_EDIT'))),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('DEST_CHANGE_PASSWORD'))),
      ),
      GoRoute(
        path: '/profile/premium',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('DEST_PREMIUM'))),
      ),
      GoRoute(
        path: '/profile/author-contact',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('DEST_AUTHOR_CONTACT'))),
      ),
    ],
  );
}

/// Pumps the ProfileScreen, emits an authenticated user, and pumps enough
/// frames for post-frame callbacks and UserRepository to complete.
Future<void> _pumpAndAuthenticate(
  WidgetTester tester,
  GoRouter router,
  _FakeAuthRepository fakeAuthRepo,
) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  fakeAuthRepo.emitUser(_FakeUser());
  // Pump 1: auth stream event processed, BlocConsumer rebuilds.
  await tester.pump();
  // Pump 2: first post-frame callback fires, second is registered.
  await tester.pump();
  // pumpAndSettle: second post-frame callback fires, UserRepository future
  // resolves, setState triggers final rebuild with _userData loaded.
  await tester.pumpAndSettle();
}

/// Scrolls the [SingleChildScrollView] inside the screen down by [dy] logical
/// pixels so that widgets below the initial viewport become hittable.
Future<void> _scrollDown(WidgetTester tester, double dy) async {
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    Offset(0, -dy),
  );
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
    if (!sl.isRegistered<ProfileRepository>()) {
      sl.registerLazySingleton<ProfileRepository>(() => _FakeProfileRepository());
    }
  });

  tearDownAll(() async {
    await sl.reset();
  });

  group('ProfileScreen — navigation tests (optional unit tests)', () {
    late _FakeAuthRepository fakeAuthRepo;
    late AuthCubit authCubit;
    late SettingsCubit settingsCubit;
    late _StubProfileCubit profileCubit;
    late GoRouter router;

    setUp(() {
      fakeAuthRepo = _FakeAuthRepository();
      authCubit = AuthCubit(
        authRepository: fakeAuthRepo,
        favoritesRepository: _FakeFavoritesRepository(),
      );
      settingsCubit = SettingsCubit();
      profileCubit = _StubProfileCubit();
      router = _buildRouter(authCubit, settingsCubit, profileCubit);
    });

    tearDown(() async {
      await authCubit.close();
      await settingsCubit.close();
      await profileCubit.close();
      await fakeAuthRepo.dispose();
    });

    // ── Header trailing edit icon ─────────────────────────────────────────

    testWidgets(
      'tapping the header trailing edit icon navigates to ProfileEditRoute',
      (tester) async {
        await _pumpAndAuthenticate(tester, router, fakeAuthRepo);

        // The trailing edit icon is a FaIcon(FontAwesomeIcons.pen) in the header.
        final editIcon = find.byWidgetPredicate(
          (w) => w is FaIcon && w.icon == FontAwesomeIcons.pen,
        );
        expect(editIcon, findsAtLeastNWidgets(1),
            reason: 'Header trailing edit icon (FaIcon pen) must be present');

        await tester.tap(editIcon.first);
        await tester.pumpAndSettle();

        expect(
          find.text('DEST_PROFILE_EDIT'),
          findsOneWidget,
          reason:
              'Tapping the header edit icon should push to /profile/edit '
              '(DEST_PROFILE_EDIT sentinel text should appear)',
        );
      },
    );

    // ── AccountSection: Edit Profile ──────────────────────────────────────

    testWidgets(
      'tapping AccountSection Edit Profile navigates to ProfileEditRoute',
      (tester) async {
        await _pumpAndAuthenticate(tester, router, fakeAuthRepo);

        final editProfileRow = find.text(t.profile.account.editProfile);
        expect(editProfileRow, findsOneWidget,
            reason: 'Edit Profile row must be present in AccountSection');

        await tester.ensureVisible(editProfileRow);
        await tester.pump();
        await tester.tap(editProfileRow);
        await tester.pumpAndSettle();

        expect(
          find.text('DEST_PROFILE_EDIT'),
          findsOneWidget,
          reason:
              'Tapping Edit Profile should push to /profile/edit '
              '(DEST_PROFILE_EDIT sentinel text should appear)',
        );
      },
    );

    // ── AccountSection: Change Password ───────────────────────────────────

    testWidgets(
      'tapping AccountSection Change Password navigates to ChangePasswordRoute',
      (tester) async {
        await _pumpAndAuthenticate(tester, router, fakeAuthRepo);

        final changePasswordRow = find.text(t.profile.account.changePassword);
        expect(changePasswordRow, findsOneWidget,
            reason: 'Change Password row must be present in AccountSection');

        await tester.ensureVisible(changePasswordRow);
        await tester.pump();
        await tester.tap(changePasswordRow);
        await tester.pumpAndSettle();

        expect(
          find.text('DEST_CHANGE_PASSWORD'),
          findsOneWidget,
          reason:
              'Tapping Change Password should push to /profile/change-password '
              '(DEST_CHANGE_PASSWORD sentinel text should appear)',
        );
      },
    );

    // ── PremiumBanner ─────────────────────────────────────────────────────
    // Requirement 9: PremiumBanner is commented out (task 7.3) — must NOT be visible

    testWidgets(
      'PremiumBanner is NOT displayed (commented out per Requirement 9)',
      (tester) async {
        await _pumpAndAuthenticate(tester, router, fakeAuthRepo);

        // Scroll down to check for PremiumBanner.
        await _scrollDown(tester, 400);

        final premiumBanner = find.byType(PremiumBanner);
        expect(premiumBanner, findsNothing,
            reason: 'PremiumBanner must NOT be present in the widget tree (commented out per Requirement 9)');
      },
    );

    // ── SupportSection: Contact Author ────────────────────────────────────

    testWidgets(
      'tapping SupportSection Contact Author navigates to AuthorContactRoute',
      (tester) async {
        await _pumpAndAuthenticate(tester, router, fakeAuthRepo);

        // Scroll down to bring SupportSection into the viewport.
        await _scrollDown(tester, 600);

        final contactAuthorRow = find.descendant(
          of: find.byType(SupportSection),
          matching: find.text(t.profile.support.contactAuthor),
        );
        expect(contactAuthorRow, findsOneWidget,
            reason: 'Contact Author row must be present in SupportSection');

        await tester.ensureVisible(contactAuthorRow);
        await tester.pump();
        await tester.tap(contactAuthorRow);
        await tester.pumpAndSettle();

        expect(
          find.text('DEST_AUTHOR_CONTACT'),
          findsOneWidget,
          reason:
              'Tapping Contact Author should push to /profile/author-contact '
              '(DEST_AUTHOR_CONTACT sentinel text should appear)',
        );
      },
    );
  });
}
