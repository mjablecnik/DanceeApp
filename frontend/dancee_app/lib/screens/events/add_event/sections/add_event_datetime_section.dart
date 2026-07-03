import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventDateTimeSection extends StatelessWidget {
  const AddEventDateTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddEventSectionHeading(
          icon: FontAwesomeIcons.calendar,
          label: 'Datum a čas',
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddEventFormField(
                label: 'Datum od *',
                child: AddEventDateInput(),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddEventFormField(
                label: 'Datum do *',
                child: AddEventDateInput(),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddEventFormField(
                label: 'Čas začátku *',
                child: AddEventTimeInput(),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddEventFormField(
                label: 'Čas konce *',
                child: AddEventTimeInput(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
