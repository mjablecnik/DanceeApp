import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventLocationSection extends StatelessWidget {
  const AddEventLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddEventSectionHeading(
          icon: FontAwesomeIcons.locationDot,
          label: 'Místo konání',
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Název místa *',
          child: AddEventTextInput(hintText: 'např. Kongresové centrum Praha'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Adresa *',
          child: AddEventTextInput(hintText: 'např. 5. května 65, Praha 4'),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddEventFormField(
                label: 'Město *',
                child: AddEventTextInput(hintText: 'Praha'),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddEventFormField(
                label: 'PSČ',
                child: AddEventTextInput(
                  hintText: '14000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
