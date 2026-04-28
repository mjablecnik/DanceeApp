import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/strings.g.dart';
import '../states/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState(languageCode: 'en'));

  static const _localeKey = 'locale';

  /// Reads persisted language from SharedPreferences, sets slang locale, emits state.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'en';
    _applyLocale(code);
    emit(SettingsState(languageCode: code));
  }

  /// Persists [languageCode] to SharedPreferences, updates slang locale, emits new state.
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    _applyLocale(languageCode);
    emit(SettingsState(languageCode: languageCode));
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
