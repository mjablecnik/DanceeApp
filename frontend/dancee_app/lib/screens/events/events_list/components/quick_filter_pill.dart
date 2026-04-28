import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class QuickFilterPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const QuickFilterPill({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              FaIcon(icon!, size: 12, color: appText),
              const SizedBox(width: AppSpacing.xs + 2),
            ],
            Text(
              label,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
