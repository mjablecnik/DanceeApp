import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class AddEventSubmitSection extends StatelessWidget {
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  const AddEventSubmitSection({
    super.key,
    this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSubmitting ? appMuted : appPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isSubmitting ? [] : [AppShadows.primary],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: isSubmitting ? null : onSubmit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSubmitting)
                      const SizedBox(
                        width: AppIconSizes.xs,
                        height: AppIconSizes.xs,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: appWhite,
                        ),
                      )
                    else
                      const FaIcon(FontAwesomeIcons.paperPlane, size: AppIconSizes.xs, color: appWhite),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      isSubmitting ? 'Odesílám...' : 'Odeslat ke schválení',
                      style: const TextStyle(
                        color: appWhite,
                        fontSize: AppTypography.fontSizeXl,
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Akce bude zkontrolována administrátorem před zveřejněním',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
          ),
        ),
      ],
    );
  }
}
