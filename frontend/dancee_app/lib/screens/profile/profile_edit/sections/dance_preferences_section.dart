import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/forms/app_checkbox.dart';

class DancePreferencesSection extends StatefulWidget {
  final Map<String, bool> preferences;
  final ValueChanged<Map<String, bool>>? onChanged;

  const DancePreferencesSection({
    super.key,
    required this.preferences,
    this.onChanged,
  });

  @override
  State<DancePreferencesSection> createState() => _DancePreferencesSectionState();
}

class _DancePreferencesSectionState extends State<DancePreferencesSection> {
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = Map.from(widget.preferences);
  }

  void _toggle(String dance) {
    setState(() => _prefs[dance] = !_prefs[dance]!);
    widget.onChanged?.call(Map.from(_prefs));
  }

  @override
  Widget build(BuildContext context) {
    final dances = _prefs.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.profile.editProfile.selectDanceStyles,
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 5,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: dances.map((dance) {
                return GestureDetector(
                  onTap: () => _toggle(dance),
                  child: Row(
                    children: [
                      AppCheckbox(
                        checked: _prefs[dance]!,
                        onChanged: (_) => _toggle(dance),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        dance,
                        style: const TextStyle(
                          color: appText,
                          fontSize: AppTypography.fontSizeMd,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
