import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/outline_action_button.dart';
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
          child: OutlineActionButton(
            icon: FontAwesomeIcons.shareNodes,
            label: t.courses.detail.shareCourse,
            onTap: onShare,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlineActionButton(
            icon: FontAwesomeIcons.arrowUpRightFromSquare,
            label: t.events.detail.originalSource,
            onTap: onSource,
          ),
        ),
      ],
    );
  }
}
