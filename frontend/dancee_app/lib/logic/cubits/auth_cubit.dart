import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../states/auth_state.dart';

// ignore: constant_identifier_names
enum AuthOperation { passwordReset, emailVerification, userReloaded }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required FavoritesRepository favoritesRepository,
  })  : _authRepository = authRepository,
        _favoritesRepository = favoritesRepository,
        super(const AuthState.unauthenticated()) {
    _authStateSubscription = authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthRepository _authRepository;
  final FavoritesRepository _favoritesRepository;
  late final StreamSubscription<User?> _authStateSubscription;

  final _operationSuccessController =
      StreamController<AuthOperation>.broadcast();

  /// Stream that emits when a non-auth-changing operation completes successfully.
  /// Listen to this for one-shot success signals (e.g. password reset sent,
  /// verification email sent) without polling global [AuthState].
  Stream<AuthOperation> get operationSuccess =>
      _operationSuccessController.stream;

  /// Loading indicator for non-auth-changing operations
  /// (`sendPasswordReset`, `sendEmailVerification`, `reloadUser`).
  ///
  /// These operations do not emit [AuthState.loading()] because they do not
  /// change the global auth state and should not cause router re-evaluations
  /// or UI flicker in unrelated screens. Use [operationInProgress] instead to
  /// show a local loading indicator inside the affected screen.
  final operationInProgress = ValueNotifier<bool>(false);

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    _operationSuccessController.close();
    operationInProgress.dispose();
    return super.close();
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        emailVerified: user.emailVerified,
        isNewUser: _checkIsNewUser(user),
      ));
      // Ensure Directus session tokens are available after app restart.
      // On fresh sign-in this is a no-op (tokens already obtained).
      _authRepository.ensureDirectusLinked();
    }
  }

  bool _checkIsNewUser(User user) {
    final creationTime = user.metadata.creationTime;
    if (creationTime == null) return false;
    final diff = DateTime.now().difference(creationTime).abs();
    return diff.inSeconds <= 60;
  }

  String? get currentUid => state.maybeMap(
        authenticated: (s) => s.uid,
        orElse: () => null,
      );

  String? get currentEmail => state.maybeMap(
        authenticated: (s) => s.email,
        orElse: () => null,
      );

  bool get isEmailProvider => _authRepository.isEmailProvider;

  /// Returns a translation key from [e].
  ///
  /// If [e] is a [String] it is assumed to be a translation key already
  /// emitted by [FirebaseAuthService.mapFirebaseError] and is returned as-is.
  /// Otherwise the generic error key is used to avoid exposing raw exception
  /// class names to the user.
  String _errorMessage(Object e) =>
      e is String ? e : 'auth.errors.generic';

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithEmail(email, password);
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }

  Future<void> signInWithGoogle() async {
    final previousState = state;
    emit(const AuthState.loading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      if (credential == null) {
        // User cancelled — restore previous state
        emit(previousState);
        return;
      }
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }

  Future<void> signInWithApple() async {
    final previousState = state;
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithApple();
      // authStateChanges stream will emit the authenticated state
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        emit(previousState);
      } else {
        emit(const AuthState.error(message: 'auth.errors.generic'));
      }
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }

  Future<void> sendEmailVerification() async {
    operationInProgress.value = true;
    try {
      await _authRepository.sendEmailVerification();
      _operationSuccessController.add(AuthOperation.emailVerification);
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    } finally {
      operationInProgress.value = false;
    }
  }

  Future<void> reloadUser() async {
    operationInProgress.value = true;
    try {
      await _authRepository.reloadAndCheckVerified();
      _onAuthStateChanged(_authRepository.currentUser);
      _operationSuccessController.add(AuthOperation.userReloaded);
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    } finally {
      operationInProgress.value = false;
    }
  }

  /// Sends a password reset email. Errors are suppressed and success is always
  /// signalled to prevent email enumeration (Req 9.3).
  Future<void> sendPasswordReset(String email) async {
    operationInProgress.value = true;
    try {
      await _authRepository.sendPasswordReset(email);
    } catch (_) {
      // Suppress all errors — we always show success to prevent revealing
      // whether an email address is registered (email enumeration protection).
    } finally {
      _operationSuccessController.add(AuthOperation.passwordReset);
      operationInProgress.value = false;
    }
  }

  Future<void> _clearOnboardingPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_dance_styles');
      await prefs.remove('onboarding_level');
      await prefs.remove('onboarding_radius');
      await prefs.remove('onboarding_completed');
    } catch (_) {
      // Non-critical cleanup; ignore if SharedPreferences is unavailable.
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      // authStateChanges stream will emit unauthenticated
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }

  /// Changes the password for the current email/password user.
  ///
  /// Returns `null` on success, or a translation key string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    operationInProgress.value = true;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return _errorMessage(e);
    } finally {
      operationInProgress.value = false;
    }
  }

  Future<void> deleteAccount({String? email, String? password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.reauthenticate(email: email, password: password);
      final uid = currentUid;
      if (uid != null) {
        await _favoritesRepository.deleteAllFavoritesForUser(uid);
      }
      await _clearOnboardingPrefs();
      await _authRepository.deleteAccount();
      // authStateChanges stream will emit unauthenticated
    } catch (e) {
      emit(AuthState.error(message: _errorMessage(e)));
    }
  }
}
