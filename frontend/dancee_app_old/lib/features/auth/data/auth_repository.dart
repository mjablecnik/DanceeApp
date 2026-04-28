import '../../../core/clients.dart';
import '../../../core/exceptions.dart';
import 'entities.dart';

/// Repository for managing authentication data.
///
/// This is a placeholder implementation for the auth feature.
/// Methods throw [UnimplementedError] until backend integration is added.
///
/// Responsibilities:
/// - Authenticate users (login, register, logout)
/// - Fetch current user data
/// - Convert JSON to User entity via User.fromJson()
/// - Throw custom exceptions on errors
class AuthRepository {
  final DirectusClient _client;

  /// Creates an AuthRepository with the provided Directus client.
  AuthRepository(this._client);

  /// Authenticates a user with email and password.
  ///
  /// Returns the authenticated [User] on success.
  /// Throws [ApiException] on failure.
  Future<User> login(String email, String password) async {
    // TODO: Implement when backend auth endpoints are available
    throw UnimplementedError('Login not yet implemented');
  }

  /// Registers a new user account.
  ///
  /// Returns the newly created [User] on success.
  /// Throws [ApiException] on failure.
  Future<User> register(String email, String password, String displayName) async {
    // TODO: Implement when backend auth endpoints are available
    throw UnimplementedError('Register not yet implemented');
  }

  /// Logs out the current user.
  ///
  /// Throws [ApiException] on failure.
  Future<void> logout() async {
    // TODO: Implement when backend auth endpoints are available
    throw UnimplementedError('Logout not yet implemented');
  }

  /// Returns the currently authenticated user.
  ///
  /// Returns the [User] if authenticated, null otherwise.
  /// Throws [ApiException] on failure.
  Future<User?> getCurrentUser() async {
    // TODO: Implement when backend auth endpoints are available
    throw UnimplementedError('getCurrentUser not yet implemented');
  }
}
