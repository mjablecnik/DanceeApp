import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/elements/labels/style_chip.dart';

class EventTitleChip {
  final String label;
  final Color color;

  const EventTitleChip({required this.label, required this.color});
}

class EventTitleSection extends StatelessWidget {
  final String title;
  final List<EventTitleChip> chips;

  const EventTitleSection({
    super.key,
    required this.title,
    required this.chips,
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
            fontWeight: AppTypography.fontWeightBold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: chips
              .map((chip) => StyleChip(label: chip.label, color: chip.color))
              .toList(),
        ),
      ],
    );
  }
}
