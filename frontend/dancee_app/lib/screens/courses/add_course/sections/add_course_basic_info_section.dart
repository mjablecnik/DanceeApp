import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/add_course_form_components.dart';

class AddCourseBasicInfoSection extends StatelessWidget {
  const AddCourseBasicInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseBasicsSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _CourseDescriptionSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _CourseInstructorSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _CourseImageSubsection(),
      ],
    );
  }
}

class _CourseBasicsSubsection extends StatelessWidget {
  const _CourseBasicsSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Základní informace'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Název kurzu *',
          child: AddCourseTextInput(hintText: 'např. Salsa Cubana pro začátečníky'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Typ tance *',
          child: AddCourseSelectInput(
            items: ['Salsa', 'Bachata', 'Kizomba', 'Tango', 'Swing', 'Waltz', 'Jiný'],
            hint: 'Vyberte typ tance',
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Úroveň kurzu *',
          child: AddCourseSelectInput(
            items: ['Začátečníci', 'Pokročilí', 'Pokročilí II', 'Experti'],
            hint: 'Vyberte úroveň',
          ),
        ),
      ],
    );
  }
}

class _CourseDescriptionSubsection extends StatelessWidget {
  const _CourseDescriptionSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Popis kurzu'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Popis kurzu *',
          child: AddCourseTextAreaInput(
            hintText: 'Popište váš kurz, co se účastníci naučí, jakou atmosféru nabízíte...',
            minLines: 4,
          ),
        ),
      ],
    );
  }
}

class _CourseInstructorSubsection extends StatelessWidget {
  const _CourseInstructorSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Informace o lektorovi'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Jméno lektora *',
          child: AddCourseTextInput(hintText: 'např. Carlos Rodriguez'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'O lektorovi',
          child: AddCourseTextAreaInput(
            hintText: 'Zkušenosti, certifikace, specializace...',
            minLines: 3,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddCourseFormField(
                label: 'Roky zkušeností',
                child: AddCourseTextInput(
                  hintText: '10',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddCourseFormField(
                label: 'Počet studentů',
                child: AddCourseTextInput(
                  hintText: '500',
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

class _CourseImageSubsection extends StatelessWidget {
  const _CourseImageSubsection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddCourseSectionHeading(label: 'Obrázek kurzu'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder, width: 2),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.cloudArrowUp, size: AppIconSizes.lg, color: appMuted),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Nahrajte obrázek kurzu',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'PNG, JPG až 5MB',
                style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: appBorder),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: const Text(
                  'Vybrat soubor',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
