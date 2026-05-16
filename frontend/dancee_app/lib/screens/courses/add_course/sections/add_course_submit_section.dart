import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class AddCourseSubmitSection extends StatelessWidget {
  const AddCourseSubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.circleInfo, size: 14, color: appMuted),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Váš kurz bude odeslán ke schválení',
                    style: TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Administrátor aplikace váš kurz zkontroluje a schválí do 24 hodin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeSm,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [AppShadows.primary],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.paperPlane, size: 16, color: appWhite),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Odeslat kurz ke schválení',
                      style: TextStyle(
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.floppyDisk, size: 16, color: appText),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Uložit jako koncept',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
