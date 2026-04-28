import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class RadiusSelector extends StatelessWidget {
  final List<String> radii;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const RadiusSelector({
    super.key,
    required this.radii,
    required this.selectedIndex,
    required this.onSelected,
  });

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
            t.onboarding.step3.searchRadius,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(radii.length, (index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onSelected(index),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index < radii.length - 1 ? AppSpacing.md : 0,
                ),
                child: Row(
                  children: [
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
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      radii[index],
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
