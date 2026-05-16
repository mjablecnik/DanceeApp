import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../logic/cubits/course_cubit.dart';
import '../../../../logic/cubits/event_cubit.dart';
import '../../../../logic/cubits/filter_cubit.dart';
import '../../../../logic/states/course_state.dart';
import '../../../../logic/states/event_state.dart';
import '../../../../logic/states/filter_state.dart';

class DanceStyleChipsRow extends StatelessWidget {
  const DanceStyleChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when FilterCubit, EventCubit, or CourseCubit state changes,
    // so that the visible styles list updates when region filters change
    // or when event/course data is loaded.
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        return BlocBuilder<EventCubit, EventState>(
          builder: (context, eventState) {
            return BlocBuilder<CourseCubit, CourseState>(
              builder: (context, courseState) {
                return _buildChips(context, filterState);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChips(BuildContext context, FilterState filterState) {
    final allParentStyles = List.of(filterState.parentDanceStyles)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (allParentStyles.isEmpty) return const SizedBox.shrink();

    final filterCubit = context.read<FilterCubit>();
    final allDanceStyles = filterCubit.allDanceStyles;
    final eventCubit = context.read<EventCubit>();
    final courseCubit = context.read<CourseCubit>();

    // Only show styles that have at least 1 event or course
    // (respecting the current region filter).
    final styles = allParentStyles.where((s) {
      final eventCount =
          eventCubit.countEventsForDanceStyle(s.code, allDanceStyles);
      final courseCount =
          courseCubit.countCoursesForDanceStyle(s.code, allDanceStyles);
      return eventCount > 0 || courseCount > 0;
    }).toList();

    if (styles.isEmpty) return const SizedBox.shrink();

    final selectedCodes = filterState.selectedDanceStyles;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: List.generate(styles.length, (index) {
          final style = styles[index];
          final isSelected = selectedCodes.contains(style.code);
          final isLast = index == styles.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.md),
            child: GestureDetector(
              onTap: () => filterCubit.toggleDanceType(style.code),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? appPrimary : appSurface,
                  border: Border.all(
                    color: isSelected ? appPrimary : appBorder,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: isSelected ? [AppShadows.primary] : null,
                ),
                child: Text(
                  style.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : appText,
                    fontSize: AppTypography.fontSizeMd,
                    fontWeight: AppTypography.fontWeightMedium,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
