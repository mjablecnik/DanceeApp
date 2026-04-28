import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Returns true if the current user's primary sign-in provider is email/password.
  bool get isEmailProvider =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName('$firstName $lastName');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await _auth.signInWithCredential(credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) rethrow;
      throw mapFirebaseError(
        FirebaseAuthException(code: 'unknown', message: e.message),
      );
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<bool> reloadAndCheckVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> reauthenticate({String? email, String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'auth.errors.generic';

      final providerIds = user.providerData.map((p) => p.providerId).toList();

      if (providerIds.contains('password') && email != null && password != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providerIds.contains('google.com')) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw 'auth.errors.generic';
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providerIds.contains('apple.com')) {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw 'auth.errors.generic';
      }
      throw mapFirebaseError(
        FirebaseAuthException(code: 'unknown', message: e.message),
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  /// Maps a [FirebaseAuthException] to a translation key.
  ///
  /// Returns a dot-separated key string (e.g. `'auth.errors.invalidCredential'`)
  /// that the UI layer resolves via [resolveAuthErrorKey] from
  /// `shared/utils/auth_translations.dart`. Keeping key resolution out of the
  /// repository decouples the data layer from the current locale (design
  /// Property 1 — Req 2.10, 14.1–14.7).
  String mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'auth.errors.invalidCredential';
      case 'user-disabled':
        return 'auth.errors.userDisabled';
      case 'email-already-in-use':
        return 'auth.errors.emailAlreadyInUse';
      case 'weak-password':
        return 'auth.errors.weakPassword';
      case 'too-many-requests':
        return 'auth.errors.tooManyRequests';
      case 'network-request-failed':
        return 'auth.errors.networkError';
      default:
        return 'auth.errors.generic';
    }
  }
}
