import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../logic/cubits/filter_cubit.dart';
import '../../../../logic/states/filter_state.dart';

class DanceStyleChipsRow extends StatelessWidget {
  const DanceStyleChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        final styles = filterState.parentDanceStyles;
        if (styles.isEmpty) return const SizedBox.shrink();

        final selectedCodes = filterState.selectedDanceStyles;
        final cubit = context.read<FilterCubit>();

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
                  onTap: () => cubit.toggleDanceType(style.code),
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
      },
    );
  }
}
