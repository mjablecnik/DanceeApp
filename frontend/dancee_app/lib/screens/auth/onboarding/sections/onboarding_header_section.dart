import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class OnboardingHeaderSection extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onSkip;

  const OnboardingHeaderSection({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [AppShadows.primaryLg],
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.music,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            TextButton(
              onPressed: onSkip,
              child: Text(
                t.common.skip,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? AppSpacing.sm : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  gradient: isActive ? AppGradients.primary : null,
                  color: isActive ? null : appBorder,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
