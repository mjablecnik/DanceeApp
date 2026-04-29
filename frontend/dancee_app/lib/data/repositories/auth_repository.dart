import 'package:firebase_auth/firebase_auth.dart';

import '../../services/directus_auth_service.dart';
import '../../services/firebase_auth_service.dart';

/// Orchestrates authentication across Firebase and Directus.
///
/// Every sign-in / register method:
///  1. Authenticates with Firebase via [FirebaseAuthService].
///  2. Exchanges the Firebase ID token for Directus session tokens via
///     [DirectusAuthService].
///
/// If the Directus link fails, the sign-in is considered failed — the user
/// would have no data to display anyway.
class AuthRepository {
  AuthRepository({
    required FirebaseAuthService firebaseAuthService,
    required DirectusAuthService directusAuthService,
  })  : _firebase = firebaseAuthService,
        _directus = directusAuthService;

  final FirebaseAuthService _firebase;
  final DirectusAuthService _directus;

  // ---------------------------------------------------------------------------
  // Passthrough — Firebase state
  // ---------------------------------------------------------------------------

  Stream<User?> get authStateChanges => _firebase.authStateChanges;

  User? get currentUser => _firebase.currentUser;

  bool get isEmailProvider => _firebase.isEmailProvider;

  // ---------------------------------------------------------------------------
  // Sign-in methods
  // ---------------------------------------------------------------------------

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _firebase.signInWithEmail(email, password);
    await _linkDirectus();
    return credential;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final credential = await _firebase.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    await _linkDirectus();
    return credential;
  }

  /// Returns `null` when the user cancels the Google sign-in flow.
  Future<UserCredential?> signInWithGoogle() async {
    final credential = await _firebase.signInWithGoogle();
    if (credential == null) return null;
    await _linkDirectus();
    return credential;
  }

  Future<UserCredential> signInWithApple() async {
    final credential = await _firebase.signInWithApple();
    await _linkDirectus();
    return credential;
  }

  // ---------------------------------------------------------------------------
  // Token access
  // ---------------------------------------------------------------------------

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _firebase.getIdToken(forceRefresh: forceRefresh);
  }

  // ---------------------------------------------------------------------------
  // Account management (delegated to Firebase)
  // ---------------------------------------------------------------------------

  Future<void> sendEmailVerification() => _firebase.sendEmailVerification();

  Future<bool> reloadAndCheckVerified() => _firebase.reloadAndCheckVerified();

  Future<void> sendPasswordReset(String email) =>
      _firebase.sendPasswordReset(email);

  Future<void> reauthenticate({String? email, String? password}) =>
      _firebase.reauthenticate(email: email, password: password);

  Future<void> deleteAccount() => _firebase.deleteAccount();

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    _directus.clear();
    await _firebase.signOut();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Exchanges the current Firebase user's ID token for Directus session
  /// tokens. Throws on failure — callers treat this as a sign-in failure.
  Future<void> _linkDirectus() async {
    final user = _firebase.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();
    if (idToken == null) throw 'auth.errors.generic';

    await _directus.linkAndAuthenticate(
      firebaseIdToken: idToken,
      firebaseUid: user.uid,
    );
  }
}
