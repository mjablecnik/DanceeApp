import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/settings_cubit.dart';
import '../../../../logic/states/settings_state.dart';
import '../components/profile_menu_item.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  Future<void> _showLanguageDialog(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final currentCode = cubit.state.languageCode;
    final currentLocale = AppLocale.values.firstWhere(
      (l) => l.languageCode == currentCode,
      orElse: () => AppLocale.en,
    );

    await showDialog<AppLocale>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: appSurface,
        title: Text(
          t.profile.settings.language,
          style: const TextStyle(color: appText),
        ),
        children: [
          _LanguageOption(locale: AppLocale.en, label: t.profile.settings.english, current: currentLocale),
          _LanguageOption(locale: AppLocale.cs, label: t.profile.settings.czech, current: currentLocale),
          _LanguageOption(locale: AppLocale.es, label: t.profile.settings.spanish, current: currentLocale),
        ],
      ),
    ).then((selected) {
      if (selected != null && selected.languageCode != currentCode) {
        cubit.setLanguage(selected.languageCode);
      }
    });
  }

  String _currentLanguageName(String languageCode) {
    switch (languageCode) {
      case 'cs':
        return t.profile.settings.czech;
      case 'es':
        return t.profile.settings.spanish;
      default:
        return t.profile.settings.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ProfileMenuItem(
            icon: FontAwesomeIcons.globe,
            iconBgColor: appSuccess.withValues(alpha: 0.2),
            iconColor: appSuccess,
            title: t.profile.settings.language,
            trailing: Text(
              _currentLanguageName(state.languageCode),
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
            onTap: () => _showLanguageDialog(context),
            showDivider: false,
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final AppLocale locale;
  final String label;
  final AppLocale current;

  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale == current;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, locale),
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check, color: appPrimary, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? appPrimary : appText)),
        ],
      ),
    );
  }
}
