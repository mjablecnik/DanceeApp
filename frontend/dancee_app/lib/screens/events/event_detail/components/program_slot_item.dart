import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class SlotExtra {
  final String text;
  final Color color;
  const SlotExtra(this.text, this.color);
}

class ProgramSlotData {
  final String time;
  final String title;
  final String description;
  final List<SlotExtra> extras;

  const ProgramSlotData({
    required this.time,
    required this.title,
    required this.description,
    this.extras = const [],
  });
}

class ProgramSlotItem extends StatelessWidget {
  final ProgramSlotData slot;

  const ProgramSlotItem({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            slot.time,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.title,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              if (slot.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  slot.description,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                ),
              ],
              for (final extra in slot.extras) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  extra.text,
                  style: TextStyle(
                    color: extra.color,
                    fontSize: AppTypography.fontSizeSm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
