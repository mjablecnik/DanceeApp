import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/elements/buttons/gradient_button.dart';

class _DanceStyleItem {
  final IconData icon;
  final String name;
  const _DanceStyleItem({required this.icon, required this.name});
}

const _kDanceStyles = [
  _DanceStyleItem(icon: FontAwesomeIcons.fire, name: 'Salsa'),
  _DanceStyleItem(icon: FontAwesomeIcons.heart, name: 'Bachata'),
  _DanceStyleItem(icon: FontAwesomeIcons.water, name: 'Zouk'),
  _DanceStyleItem(icon: FontAwesomeIcons.moon, name: 'Kizomba'),
  _DanceStyleItem(icon: FontAwesomeIcons.spa, name: 'Tango'),
  _DanceStyleItem(icon: FontAwesomeIcons.music, name: 'Swing'),
  _DanceStyleItem(icon: FontAwesomeIcons.bolt, name: 'Hip Hop'),
  _DanceStyleItem(icon: FontAwesomeIcons.star, name: 'Jiné'),
];

class OnboardingStep1Section extends StatelessWidget {
  final List<bool> selectedDances;
  final ValueChanged<int> onDanceTap;
  final VoidCallback onNext;

  const OnboardingStep1Section({
    super.key,
    required this.selectedDances,
    required this.onDanceTap,
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
            t.onboarding.step1.title,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize4xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.onboarding.step1.subtitle,
            style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.6,
              ),
              itemCount: _kDanceStyles.length,
              itemBuilder: (context, index) {
                final dance = _kDanceStyles[index];
                final selected = index < selectedDances.length && selectedDances[index];
                return GestureDetector(
                  onTap: () => onDanceTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          dance.icon,
                          size: 24,
                          color: selected ? appPrimary : appMuted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          dance.name,
                          style: TextStyle(
                            color: selected ? appPrimary : appText,
                            fontSize: AppTypography.fontSizeMd,
                            fontWeight: AppTypography.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: t.common.continue_,
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
