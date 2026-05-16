import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventOrganizerSection extends StatelessWidget {
  const AddEventOrganizerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddEventSectionHeading(
          icon: FontAwesomeIcons.userTie,
          label: 'Organizátor',
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Název organizátora *',
          child: AddEventTextInput(hintText: 'např. Prague Latin Events'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Kontaktní e-mail',
          child: AddEventTextInput(
            hintText: 'info@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
}
