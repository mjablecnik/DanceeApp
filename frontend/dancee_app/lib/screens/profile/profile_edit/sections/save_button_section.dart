import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class SaveButtonSection extends StatelessWidget {
  final VoidCallback onSave;

  const SaveButtonSection({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBg,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: appPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            elevation: 0,
          ),
          child: Text(
            t.common.saveChanges,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeXl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
        ),
      ),
    );
  }
}
