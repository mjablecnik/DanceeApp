import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.events.detail.program,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize2xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 300),
                child: const FaIcon(FontAwesomeIcons.chevronDown, size: 16, color: appText),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < widget.days.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            ProgramDayCard(day: widget.days[i]),
          ],
        ],
      ],
    );
  }
}
