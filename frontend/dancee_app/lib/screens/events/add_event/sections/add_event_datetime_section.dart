import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventDateTimeSection extends StatelessWidget {
  const AddEventDateTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddEventSectionHeading(
          icon: FontAwesomeIcons.calendar,
          label: 'Datum a čas',
        ),
        const SizedBox(height: AppSpacing.lg),
        const Row(
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
        const SizedBox(height: AppSpacing.lg),
        const Row(
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
