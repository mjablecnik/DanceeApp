import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import 'program_slot_item.dart';

class ProgramDayData {
  final String day;
  final List<ProgramSlotData> slots;

  const ProgramDayData({required this.day, required this.slots});
}

class ProgramDayCard extends StatefulWidget {
  final ProgramDayData day;

  const ProgramDayCard({super.key, required this.day});

  @override
  State<ProgramDayCard> createState() => _ProgramDayCardState();
}

class _ProgramDayCardState extends State<ProgramDayCard> {
  bool _expanded = true;

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
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: appCard,
                border: Border(bottom: BorderSide(color: appBorder)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.day.day,
                    style: const TextStyle(
                      color: appText,
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightBold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: AppDurations.normal,
                    child: const FaIcon(FontAwesomeIcons.chevronDown, size: AppIconSizes.xs, color: appMuted),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  for (int i = 0; i < widget.day.slots.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.lg),
                    ProgramSlotItem(slot: widget.day.slots[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
