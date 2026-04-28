import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class PremiumHeroSection extends StatelessWidget {
  const PremiumHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppGradients.premium,
                borderRadius: BorderRadius.circular(48),
                boxShadow: [AppShadows.primary],
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.crown, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => AppGradients.premium.createShader(bounds),
              child: Text(
                t.premium.heroTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSize5xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              t.premium.heroSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
