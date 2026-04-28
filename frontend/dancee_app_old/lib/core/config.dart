import '../config.dart';

/// Application configuration.
///
/// This file consolidates all configuration values:
/// - Sensitive values are imported from lib/config.dart (gitignored)
/// - Public non-sensitive values are defined directly here
///
/// All code should import this file for configuration access.
class AppConfig {
  /// Base URL for the Directus CMS API.
  static const String directusBaseUrl = Config.directusBaseUrl;

  /// Directus access token for API authentication.
  static const String directusAccessToken = Config.directusAccessToken;

  /// Hardcoded user ID for initial implementation.
  ///
  /// This will be replaced with actual authentication in the future.
  static const String userId = 'user123';

  /// Connection timeout in milliseconds.
  static const int connectTimeout = 10000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeout = 10000;

  /// Send timeout in milliseconds.
  static const int sendTimeout = 10000;
}
