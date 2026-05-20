import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventBasicInfoSection extends StatelessWidget {
  final TextEditingController? titleController;
  final TextEditingController? descriptionController;

  const AddEventBasicInfoSection({
    super.key,
    this.titleController,
    this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddEventSectionHeading(
          icon: FontAwesomeIcons.circleInfo,
          label: 'Základní informace',
        ),
        const SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Název akce *',
          child: AddEventTextInput(
            hintText: 'např. Prague Latin Festival 2025',
            controller: titleController,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Popis akce *',
          child: AddEventTextAreaInput(
            hintText: 'Popište vaši akci, co účastníky čeká...',
            minLines: 4,
            controller: descriptionController,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AddEventFormField(
          label: 'Obrázek akce',
          child: AddEventImageUploadArea(),
        ),
      ],
    );
  }
}
