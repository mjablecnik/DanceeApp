import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import 'program_slot_item.dart';

class ProgramDayData {
  final String day;
  final List<ProgramSlotData> slots;

  const ProgramDayData({required this.day, required this.slots});
}

class ProgramDayCard extends StatelessWidget {
  final ProgramDayData day;

  const ProgramDayCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: appCard,
              border: Border(bottom: BorderSide(color: appBorder)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Text(
              day.day,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                for (int i = 0; i < day.slots.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.lg),
                  ProgramSlotItem(slot: day.slots[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
