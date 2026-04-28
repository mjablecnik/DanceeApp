import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/buttons/outline_button.dart';
import '../components/radius_selector.dart';

class OnboardingStep3Section extends StatelessWidget {
  final int selectedRadius;
  final ValueChanged<int> onRadiusSelected;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const OnboardingStep3Section({
    super.key,
    required this.selectedRadius,
    required this.onRadiusSelected,
    required this.onBack,
    required this.onFinish,
  });

  List<String> get _radii => [
        t.onboarding.step3.radius10km,
        t.onboarding.step3.radius25km,
        t.onboarding.step3.radius50km,
        t.onboarding.step3.radiusAll,
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.onboarding.step3.title,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.onboarding.step3.subtitle,
            style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CityInputField(),
                  const SizedBox(height: AppSpacing.md),
                  RadiusSelector(
                    radii: _radii,
                    selectedIndex: selectedRadius,
                    onSelected: onRadiusSelected,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UseCurrentLocationButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  label: t.common.back,
                  onTap: onBack,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: t.common.finish,
                  onTap: onFinish,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _CityInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.common.form.city,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: appCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: appBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.lg),
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: appPrimary,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: appText),
                    decoration: InputDecoration(
                      hintText: t.onboarding.step3.cityHint,
                      hintStyle: const TextStyle(color: appMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UseCurrentLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: appPrimary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.locationCrosshairs,
              color: appPrimary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              t.onboarding.step3.useCurrentLocation,
              style: const TextStyle(
                color: appPrimary,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
