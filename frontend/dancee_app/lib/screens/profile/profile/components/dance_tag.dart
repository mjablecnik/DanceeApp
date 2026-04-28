import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class DanceTag extends StatelessWidget {
  final String label;
  final Color color;

  const DanceTag({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemiBold,
        ),
      ),
    );
  }
}
