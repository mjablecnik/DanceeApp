import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PopularCityCard extends StatelessWidget {
  final String name;
  final String eventCount;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final bool isCurrent;
  final VoidCallback? onTap;

  const PopularCityCard({
    super.key,
    required this.name,
    required this.eventCount,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradientStart, gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: appText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eventCount,
                    style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isCurrent) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: appPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      t.common.current,
                      style: const TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightMedium,
                        color: appPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                const Icon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
