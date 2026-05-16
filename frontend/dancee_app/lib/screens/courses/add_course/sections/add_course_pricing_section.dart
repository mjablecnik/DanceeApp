import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/add_course_form_components.dart';

class AddCoursePricingSection extends StatelessWidget {
  const AddCoursePricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PricingSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _CourseContentSubsection(),
        SizedBox(height: AppSpacing.xxl),
        _AdditionalInfoSubsection(),
      ],
    );
  }
}

class _PricingSubsection extends StatelessWidget {
  const _PricingSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Cena kurzu'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Cena za celý kurz (Kč) *',
          child: AddCourseTextInput(
            hintText: '2500',
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Způsob platby',
          child: AddCourseTextInput(hintText: 'Platba na místě nebo převodem'),
        ),
      ],
    );
  }
}

class _CourseContentSubsection extends StatefulWidget {
  const _CourseContentSubsection();

  @override
  State<_CourseContentSubsection> createState() => _CourseContentSubsectionState();
}

class _CourseContentSubsectionState extends State<_CourseContentSubsection> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _add() => setState(() => _controllers.add(TextEditingController()));

  void _remove(int index) {
    if (_controllers.length <= 1) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddCourseSectionHeading(label: 'Obsah kurzu'),
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: _controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            final isFirst = index == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: AddCourseTextInput(
                      controller: controller,
                      hintText: isFirst
                          ? 'Co se účastníci naučí...'
                          : 'Další bod obsahu...',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: isFirst ? _add : () => _remove(index),
                    child: Container(
                      width: AppSizes.iconButtonMd,
                      height: AppSizes.iconButtonMd,
                      decoration: BoxDecoration(
                        color: isFirst ? appPrimary : appSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: FaIcon(
                          isFirst ? FontAwesomeIcons.plus : FontAwesomeIcons.minus,
                          size: 14,
                          color: isFirst ? appWhite : appMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AdditionalInfoSubsection extends StatelessWidget {
  const _AdditionalInfoSubsection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddCourseSectionHeading(label: 'Dodatečné informace'),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Odkaz na originální zdroj',
          child: AddCourseTextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AddCourseFormField(
          label: 'Kontaktní informace',
          child: AddCourseTextAreaInput(
            hintText: 'Email, telefon, další kontakty...',
            minLines: 2,
          ),
        ),
      ],
    );
  }
}
