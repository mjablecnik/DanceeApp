import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/labels/style_chip.dart';

class CourseTitleSection extends StatelessWidget {
  final String title;
  final List<StyleChipData> styleChips;

  const CourseTitleSection({
    super.key,
    required this.title,
    required this.styleChips,
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
            fontSize: AppTypography.fontSize4xl,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: styleChips
              .map((chip) => StyleChip(label: chip.label, color: chip.color))
              .toList(),
        ),
      ],
    );
  }
}

class StyleChipData {
  final String label;
  final Color color;

  const StyleChipData({required this.label, required this.color});
}
