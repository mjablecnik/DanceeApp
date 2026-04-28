import '../../../core/clients.dart';
import '../../../core/exceptions.dart';
import 'entities.dart';

/// Repository for managing user settings data.
///
/// This is a placeholder implementation for the settings feature.
/// Methods throw [UnimplementedError] until backend integration is added.
///
/// Responsibilities:
/// - Fetch user settings from API
/// - Update user settings via API
/// - Convert JSON to UserSettings entity via UserSettings.fromJson()
/// - Throw custom exceptions on errors
class SettingsRepository {
  final DirectusClient _client;

  /// Creates a SettingsRepository with the provided Directus client.
  SettingsRepository(this._client);

  /// Returns the current user's settings.
  ///
  /// Returns [UserSettings] on success.
  /// Throws [ApiException] on failure.
  Future<UserSettings> getSettings() async {
    // TODO: Implement when backend settings endpoints are available
    throw UnimplementedError('getSettings not yet implemented');
  }

  /// Updates the current user's settings.
  ///
  /// Returns the updated [UserSettings] on success.
  /// Throws [ApiException] on failure.
  Future<UserSettings> updateSettings(UserSettings settings) async {
    // TODO: Implement when backend settings endpoints are available
    throw UnimplementedError('updateSettings not yet implemented');
  }

  /// Updates a single setting field.
  ///
  /// [key] is the setting field name, [value] is the new value.
  /// Returns the updated [UserSettings] on success.
  /// Throws [ApiException] on failure.
  Future<UserSettings> updateSetting(String key, dynamic value) async {
    // TODO: Implement when backend settings endpoints are available
    throw UnimplementedError('updateSetting not yet implemented');
  }
}
