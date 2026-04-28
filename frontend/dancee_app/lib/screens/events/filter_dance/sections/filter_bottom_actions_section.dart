import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class FilterBottomActionsSection extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onApply;

  const FilterBottomActionsSection({
    super.key,
    required this.selectedCount,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appBg.withValues(alpha: 0),
            appBg,
            appBg,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
      ),
      child: GestureDetector(
        onTap: onApply,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: appPrimary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [AppShadows.primaryLg],
          ),
          child: Text(
            selectedCount > 0 ? t.events.filter.applyCount(count: selectedCount) : t.events.filter.apply,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeXl,
              fontWeight: AppTypography.fontWeightBold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
