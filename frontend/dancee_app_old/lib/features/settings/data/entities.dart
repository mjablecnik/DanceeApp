import 'package:equatable/equatable.dart';

/// Represents user settings and preferences.
///
/// This is a placeholder entity for the settings feature.
/// Fields will be expanded when backend integration is implemented.
///
/// Immutable class using Equatable for value equality comparison.
class UserSettings extends Equatable {
  /// Unique identifier for the settings record
  final String id;

  /// The user ID these settings belong to
  final String userId;

  /// Preferred language code (e.g., 'en', 'cs', 'es')
  final String language;

  /// Theme mode preference ('light', 'dark', 'system')
  final String themeMode;

  /// Whether push notifications are enabled
  final bool notificationsEnabled;

  /// Whether email notifications are enabled
  final bool emailNotificationsEnabled;

  /// Creates UserSettings with all required and optional fields.
  const UserSettings({
    required this.id,
    required this.userId,
    this.language = 'en',
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
  });

  /// Creates UserSettings from a JSON map.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      userId: json['userId'] as String,
      language: json['language'] as String? ?? 'en',
      themeMode: json['themeMode'] as String? ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? true,
    );
  }

  /// Converts this UserSettings to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'language': language,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
    };
  }

  /// Creates a copy of this UserSettings with the given fields replaced.
  UserSettings copyWith({
    String? id,
    String? userId,
    String? language,
    String? themeMode,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        language,
        themeMode,
        notificationsEnabled,
        emailNotificationsEnabled,
      ];
}
