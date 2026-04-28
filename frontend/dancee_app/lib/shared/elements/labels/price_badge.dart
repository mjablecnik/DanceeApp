import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class PriceBadge extends StatelessWidget {
  final String price;

  const PriceBadge({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        price,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppTypography.fontSizeMd,
          fontWeight: AppTypography.fontWeightBold,
        ),
      ),
    );
  }
}
