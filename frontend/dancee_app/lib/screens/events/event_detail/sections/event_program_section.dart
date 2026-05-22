import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/program_day_card.dart';
export '../components/program_day_card.dart' show ProgramDayData;
export '../components/program_slot_item.dart' show ProgramSlotData, SlotExtra;

class EventProgramSection extends StatefulWidget {
  final List<ProgramDayData> days;

  const EventProgramSection({super.key, required this.days});

  @override
  State<EventProgramSection> createState() => _EventProgramSectionState();
}

class _EventProgramSectionState extends State<EventProgramSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.detail.program,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (int i = 0; i < widget.days.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          ProgramDayCard(day: widget.days[i]),
        ],
      ],
    );
  }
}
