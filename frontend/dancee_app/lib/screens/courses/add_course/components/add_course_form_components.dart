import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

/// Section heading — plain bold text, no icon.
class AddCourseSectionHeading extends StatelessWidget {
  final String label;

  const AddCourseSectionHeading({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: appText,
        fontSize: AppTypography.fontSize2xl,
        fontWeight: AppTypography.fontWeightBold,
      ),
    );
  }
}

/// Label + input wrapper for form fields.
class AddCourseFormField extends StatelessWidget {
  final String label;
  final Widget child;

  const AddCourseFormField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// Single-line styled text input.
class AddCourseTextInput extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const AddCourseTextInput({
    super.key,
    this.hintText,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeMd,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: appMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Multi-line styled text input.
class AddCourseTextAreaInput extends StatelessWidget {
  final String? hintText;
  final int minLines;

  const AddCourseTextAreaInput({super.key, this.hintText, this.minLines = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      child: TextField(
        maxLines: null,
        minLines: minLines,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeMd,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: appMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Tappable date picker that shows the selected date.
class AddCourseDateInput extends StatefulWidget {
  const AddCourseDateInput({super.key});

  @override
  State<AddCourseDateInput> createState() => _AddCourseDateInputState();
}

class _AddCourseDateInputState extends State<AddCourseDateInput> {
  DateTime? _selectedDate;

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: appPrimary,
            surface: appSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}'
        : '';
    return GestureDetector(
      onTap: _pick,
      child: Container(
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: appBorder),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.isEmpty ? 'dd.mm.rrrr' : label,
                style: TextStyle(
                  color: label.isEmpty ? appMuted : appText,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
            ),
            const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }
}

/// Styled dropdown selector.
class AddCourseSelectInput extends StatefulWidget {
  final List<String> items;
  final String hint;

  const AddCourseSelectInput({super.key, required this.items, required this.hint});

  @override
  State<AddCourseSelectInput> createState() => _AddCourseSelectInputState();
}

class _AddCourseSelectInputState extends State<AddCourseSelectInput> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selected,
          hint: Text(
            widget.hint,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
          isExpanded: true,
          dropdownColor: appSurface,
          icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 12, color: appMuted),
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
          ),
          onChanged: (value) => setState(() => _selected = value),
          items: widget.items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }
}
