import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: appMuted,
        fontSize: AppTypography.fontSizeSm,
        fontWeight: AppTypography.fontWeightSemiBold,
        letterSpacing: 1.0,
      ),
    );
  }
}
