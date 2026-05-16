import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/strings.g.dart';
import '../states/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState(languageCode: 'en'));

  static const _localeKey = 'locale';
  static const _notificationsKey = 'notifications_enabled';

  /// Reads persisted settings from SharedPreferences, sets slang locale, emits state.
  /// If no locale is persisted, detects the device language and uses it if supported,
  /// otherwise falls back to English.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final persisted = prefs.getString(_localeKey);
    final code = persisted ?? _detectDeviceLanguage();
    final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _applyLocale(code);
    emit(SettingsState(
      languageCode: code,
      notificationsEnabled: notificationsEnabled,
    ));
  }

  /// Returns the device language code if it matches a supported locale, otherwise 'en'.
  String _detectDeviceLanguage() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final supported = AppLocale.values.map((l) => l.languageCode).toSet();
    if (supported.contains(deviceLocale.languageCode)) {
      return deviceLocale.languageCode;
    }
    return 'en';
  }

  /// Persists [languageCode] to SharedPreferences, updates slang locale, emits new state.
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    _applyLocale(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }

  /// Persists notifications preference to SharedPreferences and emits new state.
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  String get currentLanguageCode => state.languageCode;

  void _applyLocale(String code) {
    final locale = AppLocale.values.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => AppLocale.en,
    );
    LocaleSettings.setLocale(locale);
  }
}
