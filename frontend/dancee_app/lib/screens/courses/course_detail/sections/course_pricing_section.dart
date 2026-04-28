import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/pricing_option_card.dart';

class CoursePricingSection extends StatelessWidget {
  final String price;
  final String priceNote;
  final String spotsAvailable;
  final String spotsTotal;
  final VoidCallback? onRegister;
  final VoidCallback? onShare;
  final VoidCallback? onSource;

  const CoursePricingSection({
    super.key,
    required this.price,
    required this.priceNote,
    required this.spotsAvailable,
    required this.spotsTotal,
    this.onRegister,
    this.onShare,
    this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegistrationCta(
          price: price,
          priceNote: priceNote,
          spotsAvailable: spotsAvailable,
          spotsTotal: spotsTotal,
          onRegister: onRegister,
        ),
        const SizedBox(height: AppSpacing.lg),
        CourseAdditionalActions(onShare: onShare, onSource: onSource),
      ],
    );
  }
}

class RegistrationCta extends StatelessWidget {
  final String price;
  final String priceNote;
  final String spotsAvailable;
  final String spotsTotal;
  final VoidCallback? onRegister;

  const RegistrationCta({
    super.key,
    required this.price,
    required this.priceNote,
    required this.spotsAvailable,
    required this.spotsTotal,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return PricingOptionCard(
      price: price,
      priceNote: priceNote,
      spotsAvailable: spotsAvailable,
      spotsTotal: spotsTotal,
      onRegister: onRegister,
    );
  }
}

class CourseAdditionalActions extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onSource;

  const CourseAdditionalActions({
    super.key,
    this.onShare,
    this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onShare,
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                border: Border.all(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.shareNodes, size: 14, color: appText),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      t.courses.detail.shareCourse,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: onSource,
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                border: Border.all(color: appBorder),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14, color: appText),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      t.events.detail.originalSource,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
