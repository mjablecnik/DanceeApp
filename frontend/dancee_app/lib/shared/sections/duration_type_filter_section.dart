import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';
import '../../logic/cubits/filter_cubit.dart';
import '../../logic/states/filter_state.dart';

class _ChipDef {
  final String? code;
  final String label;
  const _ChipDef(this.code, this.label);
}

class ChipRow extends StatelessWidget {
  final List<_ChipDef> chips;
  final Set<String> selected;
  final void Function(String?) onTap;

  const ChipRow({
    super.key,
    required this.chips,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isActive =
              chip.code == null ? selected.isEmpty : selected.contains(chip.code);
          return GestureDetector(
            onTap: () => onTap(chip.code),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? appPrimary : appSurface,
                border: Border.all(color: isActive ? appPrimary : appBorder),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Text(
                chip.label,
                style: TextStyle(
                  color: isActive ? Colors.white : appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EventDurationTypeFilterSection extends StatelessWidget {
  const EventDurationTypeFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _ChipDef(null, t.events.filters.all),
      _ChipDef('evening', t.events.filters.evening),
      _ChipDef('weekend', t.events.filters.weekend),
      _ChipDef('multiDay', t.events.filters.multiDay),
    ];
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) => ChipRow(
        chips: chips,
        selected: state.selectedEventDurationTypes,
        onTap: (code) {
          final cubit = context.read<FilterCubit>();
          if (code == null) {
            cubit.clearEventDurationTypes();
          } else {
            cubit.toggleEventDurationType(code);
          }
        },
      ),
    );
  }
}

class CourseTypeFilterSection extends StatelessWidget {
  const CourseTypeFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _ChipDef(null, t.courses.courseTypes.all),
      _ChipDef('regular', t.courses.courseTypes.regular),
      _ChipDef('workshop', t.courses.courseTypes.workshop),
    ];
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) => ChipRow(
        chips: chips,
        selected: state.selectedCourseTypes,
        onTap: (code) {
          final cubit = context.read<FilterCubit>();
          if (code == null) {
            cubit.clearCourseTypes();
          } else {
            cubit.toggleCourseType(code);
          }
        },
      ),
    );
  }
}
