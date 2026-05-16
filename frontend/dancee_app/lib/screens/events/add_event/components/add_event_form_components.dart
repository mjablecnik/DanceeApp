import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

/// Section heading with an icon and label.
class AddEventSectionHeading extends StatelessWidget {
  final IconData icon;
  final String label;

  const AddEventSectionHeading({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: AppIconSizes.xs, color: appPrimary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
      ],
    );
  }
}

/// Label + input wrapper for form fields.
class AddEventFormField extends StatelessWidget {
  final String label;
  final Widget child;

  const AddEventFormField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: appMuted,
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
class AddEventTextInput extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool isSmall;

  const AddEventTextInput({
    super.key,
    this.hintText,
    this.keyboardType,
    this.controller,
    this.isSmall = false,
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
        style: TextStyle(
          color: appText,
          fontSize: isSmall ? AppTypography.fontSizeSm : AppTypography.fontSizeMd,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: appMutedDark),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Multi-line styled text input.
class AddEventTextAreaInput extends StatelessWidget {
  final String? hintText;
  final int minLines;
  final TextEditingController? controller;
  final bool isSmall;

  const AddEventTextAreaInput({
    super.key,
    this.hintText,
    this.minLines = 4,
    this.controller,
    this.isSmall = false,
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
        maxLines: null,
        minLines: minLines,
        style: TextStyle(
          color: appText,
          fontSize: isSmall ? AppTypography.fontSizeSm : AppTypography.fontSizeMd,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: appMutedDark),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Tappable date picker that shows the selected date.
class AddEventDateInput extends StatefulWidget {
  const AddEventDateInput({super.key});

  @override
  State<AddEventDateInput> createState() => _AddEventDateInputState();
}

class _AddEventDateInputState extends State<AddEventDateInput> {
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
                  color: label.isEmpty ? appMutedDark : appText,
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

/// Tappable time picker that shows the selected time.
class AddEventTimeInput extends StatefulWidget {
  const AddEventTimeInput({super.key});

  @override
  State<AddEventTimeInput> createState() => _AddEventTimeInputState();
}

class _AddEventTimeInputState extends State<AddEventTimeInput> {
  TimeOfDay? _selectedTime;

  Future<void> _pick() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
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
                label.isEmpty ? '--:--' : label,
                style: TextStyle(
                  color: label.isEmpty ? appMutedDark : appText,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
            ),
            const FaIcon(FontAwesomeIcons.clock, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }
}

/// Image upload drop-zone placeholder.
class AddEventImageUploadArea extends StatelessWidget {
  const AddEventImageUploadArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder, width: 2),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.cloudArrowUp, size: 40, color: appMuted),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Klikněte nebo přetáhněte obrázek',
            style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'PNG, JPG do 5MB',
            style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
          ),
        ],
      ),
    );
  }
}
