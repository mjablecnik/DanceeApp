/// Sensitive configuration file - EXAMPLE TEMPLATE.
///
/// This is an example template for config.dart.
///
/// To use:
/// 1. Copy this file to config.dart
/// 2. Update the values with your actual configuration
/// 3. The real config.dart is in .gitignore and won't be committed
class Config {
  /// Base URL for the Directus CMS API.
  ///
  /// Examples:
  /// - Local: 'http://localhost:8055'
  /// - Production: 'https://dancee-directus.fly.dev'
  static const String directusBaseUrl = 'YOUR_DIRECTUS_BASE_URL_HERE';

  /// Directus static access token for API authentication.
  static const String directusAccessToken = 'YOUR_DIRECTUS_ACCESS_TOKEN_HERE';
}
