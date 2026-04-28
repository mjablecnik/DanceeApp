import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/forms/app_radio_button.dart';

class ExperienceLevelSection extends StatefulWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String>? onChanged;

  const ExperienceLevelSection({
    super.key,
    required this.levels,
    required this.selectedLevel,
    this.onChanged,
  });

  @override
  State<ExperienceLevelSection> createState() => _ExperienceLevelSectionState();
}

class _ExperienceLevelSectionState extends State<ExperienceLevelSection> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedLevel;
  }

  void _select(String level) {
    setState(() => _selected = level);
    widget.onChanged?.call(level);
  }

  @override
  Widget build(BuildContext context) {
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
              t.profile.editProfile.yourLevel,
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...widget.levels.map((level) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GestureDetector(
                  onTap: () => _select(level),
                  child: Row(
                    children: [
                      AppRadioButton(
                        selected: _selected == level,
                        onTap: () => _select(level),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        level,
                        style: const TextStyle(
                          color: appText,
                          fontSize: AppTypography.fontSizeMd,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
