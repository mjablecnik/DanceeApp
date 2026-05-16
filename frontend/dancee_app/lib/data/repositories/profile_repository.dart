import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/clients.dart';
import '../../core/config.dart';
import '../../core/exceptions.dart';
import '../../services/directus_auth_service.dart';
import '../entities/contact_message.dart';
import '../entities/translation_utils.dart';
import '../entities/user_profile.dart';

class ProfileRepository {
  ProfileRepository({
    required DirectusClient client,
    required DirectusAuthService directusAuthService,
  })  : _client = client,
        _directusAuthService = directusAuthService;

  final DirectusClient _client;
  final DirectusAuthService _directusAuthService;

  /// Fetches the user profile from Directus for the currently authenticated user.
  /// Uses /users/me which works with the user's own Directus session token.
  Future<UserProfile> getUserProfile(String firebaseUid) async {
    final data = await _client.get(
      '/users/me',
      queryParameters: {
        'fields': '*,avatar.id',
      },
    );

    if (data == null) {
      throw Exception('User profile not found');
    }

    return UserProfile.fromDirectus(
      data as Map<String, dynamic>,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
  }

  /// Updates the user profile in Directus for the currently authenticated user.
  Future<UserProfile> updateUserProfile(
    String directusUserId,
    Map<String, dynamic> fields,
  ) async {
    final data = await _client.patch(
      '/users/me',
      data: fields,
    );

    return UserProfile.fromDirectus(
      data as Map<String, dynamic>,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
  }

  /// Fetches legal page content (Markdown) from Directus for [slug] and
  /// [languageCode], with language fallback via [extractTranslation].
  Future<String> getLegalContent(String slug, String languageCode) async {
    final data = await _client.get(
      '/items/legal_pages',
      queryParameters: {
        'filter[slug][_eq]': slug,
        'filter[status][_eq]': 'published',
        'fields': '*,translations.*',
        'limit': '1',
      },
    );

    final items = (data as List<dynamic>?) ?? [];
    if (items.isEmpty) {
      throw Exception('Legal page not found for slug=$slug');
    }

    final page = items.first as Map<String, dynamic>;
    final rawTranslations = page['translations'];
    final translations =
        rawTranslations is List ? rawTranslations : <dynamic>[];

    final translation = extractTranslation(translations, languageCode);
    if (translation == null) {
      throw Exception('No translation found for slug=$slug lang=$languageCode');
    }

    return (translation['content'] as String?) ?? '';
  }

  /// Submits a [ContactMessage] to Directus.
  Future<void> submitContactMessage(ContactMessage message) async {
    await _client.post(
      '/items/contact_messages',
      data: message.toDirectus(),
    );
  }

  /// Uploads an avatar image to Directus and links it to the current user's profile.
  /// Returns the updated [UserProfile] with the new avatar URL.
  Future<UserProfile> uploadAvatar(String filePath, String fileName) async {
    // Step 1: Upload file to /files
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final fileData = await _client.uploadFile('/files', formData: formData);
    final fileId = (fileData as Map<String, dynamic>)['id'] as String;

    // Step 2: Link avatar to user profile
    final userData = await _client.patch('/users/me', data: {'avatar': fileId});
    return UserProfile.fromDirectus(
      userData as Map<String, dynamic>,
      directusBaseUrl: AppConfig.directusBaseUrl,
    );
  }

  /// Deactivates the currently authenticated Directus user and clears their data.
  /// Must be called BEFORE deleting the Firebase account (needs valid token).
  /// Note: Directus does not allow users to delete themselves via DELETE /users/me,
  /// so we suspend the account, label it, and wipe personal data instead.
  ///
  /// Throws [ApiException] if no authenticated Directus session is available,
  /// preventing accidental suspension of the public token user.
  Future<void> deleteDirectusUser() async {
    if (!_directusAuthService.hasTokens) {
      throw const ApiException(
        message: 'api.errors.unauthorized',
        statusCode: 401,
      );
    }
    await _client.patch('/users/me', data: {
      'status': 'suspended',
      'first_name': 'Deleted',
      'last_name': 'Account',
      'phone': null,
      'city': null,
      'bio': null,
      'dance_tags': null,
      'experience_level': null,
      'notification_preferences': null,
      'avatar': null,
    });
  }

  /// Returns the real app version string (version+build).
  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  /// Returns real device information using platform plugins.
  Future<DeviceInfoData> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    final devicePlugin = DeviceInfoPlugin();
    String device = 'unknown';
    String os = 'unknown';

    if (kIsWeb) {
      final webInfo = await devicePlugin.webBrowserInfo;
      device = webInfo.browserName.name;
      os = webInfo.platform ?? 'web';
    } else {
      try {
        final androidInfo = await devicePlugin.androidInfo;
        device = '${androidInfo.manufacturer} ${androidInfo.model}';
        os = 'Android ${androidInfo.version.release}';
      } catch (_) {
        try {
          final iosInfo = await devicePlugin.iosInfo;
          device = iosInfo.model;
          os = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        } catch (_) {
          // leave defaults
        }
      }
    }

    return DeviceInfoData(appVersion: appVersion, device: device, os: os);
  }
}
