import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class DescriptionSection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const DescriptionSection({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (final paragraph in paragraphs) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            paragraph,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
