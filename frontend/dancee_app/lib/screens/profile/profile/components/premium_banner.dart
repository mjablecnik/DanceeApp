import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PremiumBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.premiumSubtle,
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.crown, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.premium.title,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.premium.bannerSubtitle,
                    style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                  ),
                ],
              ),
            ),
            const FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }
}
