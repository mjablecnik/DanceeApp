import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventAdditionalInfoSection extends StatelessWidget {
  const AddEventAdditionalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddEventSectionHeading(
          icon: FontAwesomeIcons.circlePlus,
          label: 'Dodatečné informace',
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Nepovinné údaje',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddEventFormField(
                label: 'Vstupné od (Kč)',
                child: AddEventTextInput(
                  hintText: '350',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddEventFormField(
                label: 'Vstupné do (Kč)',
                child: AddEventTextInput(
                  hintText: '1200',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Dresscode',
          child: AddEventTextInput(hintText: 'např. Elegantní casual'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'URL na nákup vstupenek',
          child: AddEventTextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'URL na původní zdroj',
          child: AddEventTextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }
}
