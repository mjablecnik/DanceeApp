import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class FilterDanceHeaderSection extends StatelessWidget {
  final String selectedCountText;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const FilterDanceHeaderSection({
    super.key,
    required this.selectedCountText,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: appSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.events.danceStyles,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: AppTypography.fontWeightBold,
                    color: appText,
                  ),
                ),
                Text(
                  selectedCountText,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSizeMd,
                    color: appMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(
              t.common.clear,
              style: const TextStyle(
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
                color: appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
