import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
      ],
    );
  }
}
