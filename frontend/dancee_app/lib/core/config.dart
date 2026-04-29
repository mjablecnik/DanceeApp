// Re-exports sensitive CMS config values and defines public app constants.
// Import this file throughout the app instead of importing lib/config.dart directly.

import '../config.dart' as sensitive;

/// Application configuration.
///
/// Sensitive values ([directusBaseUrl], [directusAccessToken]) are read from
/// the gitignored `lib/config.dart`. All other constants are defined here.
class AppConfig {
  AppConfig._();

  /// Directus CMS base URL (e.g. "https://your-cms.example.com").
  static const String directusBaseUrl = sensitive.directusBaseUrl;

  /// Directus static access token for API requests.
  static const String directusAccessToken = sensitive.directusAccessToken;

  /// HTTP connection timeout in milliseconds.
  static const int connectionTimeoutMs = 10000;

  /// HTTP receive timeout in milliseconds.
  static const int receiveTimeoutMs = 15000;

  /// Google OAuth Web Client ID for Google Sign-In.
  /// This is a public identifier (also present in google-services.json), not a secret.
  static const String googleWebClientId =
      '776014571343-4duso423nt0paq85rtja5hsg4m0tieoq.apps.googleusercontent.com';
}
