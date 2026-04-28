import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/colors.dart';
import '../../../../../core/theme.dart';
import '../../../../../i18n/strings.g.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appPrimary.withValues(alpha: 0.1),
              appAccent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
              child: const FaIcon(
                FontAwesomeIcons.solidStarHalfStroke,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.premium.ctaTitle,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.premium.ctaSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [AppShadows.primary],
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  t.premium.ctaButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: AppTypography.fontWeightSemiBold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.premium.ctaNote,
              style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
            ),
          ],
        ),
      ),
    );
  }
}
