import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../components/add_course_form_components.dart';

class AddCourseScheduleSection extends StatelessWidget {
  const AddCourseScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScheduleSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _LocationSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _CourseDetailsSubsection(),
      ],
    );
  }
}

class _ScheduleSubsection extends StatelessWidget {
  const _ScheduleSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Termín a čas'),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddCourseFormField(
                label: 'Začátek kurzu *',
                child: AddCourseDateInput(),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddCourseFormField(
                label: 'Konec kurzu *',
                child: AddCourseDateInput(),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Rozvrh lekcí *',
          child: AddCourseTextInput(hintText: 'např. Každé úterý 19:00 - 20:30'),
        ),
      ],
    );
  }
}

class _LocationSubsection extends StatelessWidget {
  const _LocationSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Místo konání'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Název studia/školy *',
          child: AddCourseTextInput(hintText: 'např. Dance Studio Praha'),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Adresa *',
          child: AddCourseTextInput(hintText: 'Václavské náměstí 14, Praha 1'),
        ),
      ],
    );
  }
}

class _CourseDetailsSubsection extends StatelessWidget {
  const _CourseDetailsSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Podrobnosti kurzu'),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddCourseFormField(
                label: 'Počet lekcí *',
                child: AddCourseTextInput(
                  hintText: '15',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddCourseFormField(
                label: 'Délka lekce (min) *',
                child: AddCourseTextInput(
                  hintText: '90',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AddCourseFormField(
                label: 'Max. počet osob *',
                child: AddCourseTextInput(
                  hintText: '20',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AddCourseFormField(
                label: 'Věková skupina',
                child: AddCourseTextInput(hintText: '18+ let'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
