import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class FilterLocationHeaderSection extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClear;

  const FilterLocationHeaderSection({
    super.key,
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
        color: appBg.withValues(alpha: 0.9),
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
            child: Text(
              t.events.filter.selectLocation,
              style: const TextStyle(
                fontSize: AppTypography.fontSize3xl,
                fontWeight: AppTypography.fontWeightBold,
                color: appText,
              ),
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
