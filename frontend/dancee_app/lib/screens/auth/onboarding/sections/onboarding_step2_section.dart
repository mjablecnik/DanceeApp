import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';
import '../../../../shared/elements/buttons/outline_button.dart';

class _ExperienceLevelItem {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String description;
  const _ExperienceLevelItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
  });
}

const _kExperienceLevels = [
  _ExperienceLevelItem(
    icon: FontAwesomeIcons.seedling,
    iconColor: appSuccess,
    name: 'Začátečník',
    description: 'Teprve začínám s tancem',
  ),
  _ExperienceLevelItem(
    icon: FontAwesomeIcons.chartLine,
    iconColor: appPrimary,
    name: 'Mírně pokročilý',
    description: 'Mám základní zkušenosti',
  ),
  _ExperienceLevelItem(
    icon: FontAwesomeIcons.fire,
    iconColor: appAccent,
    name: 'Pokročilý',
    description: 'Tančím pravidelně několik let',
  ),
  _ExperienceLevelItem(
    icon: FontAwesomeIcons.crown,
    iconColor: appYellow,
    name: 'Expert',
    description: 'Profesionální úroveň',
  ),
];

class OnboardingStep2Section extends StatelessWidget {
  final int selectedLevel;
  final ValueChanged<int> onLevelSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const OnboardingStep2Section({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.onboarding.step2.title,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.onboarding.step2.subtitle,
            style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: _kExperienceLevels.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final level = _kExperienceLevels[index];
                final selected = selectedLevel == index;
                return GestureDetector(
                  onTap: () => onLevelSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: selected
                          ? appPrimary.withValues(alpha: 0.1)
                          : appSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: selected ? appPrimary : appBorder,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: appCard,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Center(
                            child: FaIcon(level.icon, size: 20, color: level.iconColor),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.name,
                                style: const TextStyle(
                                  color: appText,
                                  fontSize: AppTypography.fontSizeLg,
                                  fontWeight: AppTypography.fontWeightSemiBold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                level.description,
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: AppTypography.fontSizeSm,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? appPrimary : appBorder,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appPrimary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                  label: t.common.continue_,
                  onTap: onNext,
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
