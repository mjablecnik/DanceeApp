import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class AddEventSubmitSection extends StatelessWidget {
  const AddEventSubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.paperPlane, size: 16, color: appWhite),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Odeslat ke schválení',
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
