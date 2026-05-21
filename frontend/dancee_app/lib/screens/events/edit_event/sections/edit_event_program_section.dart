import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../../add_event/components/add_event_form_components.dart';
import '../models/editable_program_models.dart';

class EditEventProgramSection extends StatelessWidget {
  const EditEventProgramSection({
    super.key,
    required this.programDays,
    required this.ungroupedEntries,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onDayDateChanged,
    required this.onStateChanged,
    required this.validationErrors,
  });

  final List<EditableProgramDay> programDays;
  final List<EditableProgramEntry> ungroupedEntries;
  final VoidCallback onAddDay;
  final void Function(int dayId) onRemoveDay;
  final void Function(int dayId) onAddEntry;
  final void Function(int dayId, int entryId) onRemoveEntry;
  final void Function(int dayId, DateTime? date) onDayDateChanged;
  final VoidCallback onStateChanged;
  final List<ProgramValidationError> validationErrors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AddEventSectionHeading(
              icon: FontAwesomeIcons.calendarDays,
              label: t.events.edit.programSection,
            ),
            GestureDetector(
              onTap: onAddDay,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.plus, size: 12, color: appPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    t.events.edit.addDay,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.events.edit.programHint,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
          ),
        ),
        if (programDays.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Column(
            children: programDays
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ProgramDayCard(
                      day: e.value,
                      dayNumber: e.key + 1,
                      onRemove: () => onRemoveDay(e.value.id),
                      onAddEntry: () => onAddEntry(e.value.id),
                      onRemoveEntry: (entryId) => onRemoveEntry(e.value.id, entryId),
                      onDayDateChanged: (date) => onDayDateChanged(e.value.id, date),
                      onStateChanged: onStateChanged,
                      validationErrors: validationErrors,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ProgramDayCard extends StatelessWidget {
  const _ProgramDayCard({
    required this.day,
    required this.dayNumber,
    required this.onRemove,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onDayDateChanged,
    required this.onStateChanged,
    required this.validationErrors,
  });

  final EditableProgramDay day;
  final int dayNumber;
  final VoidCallback onRemove;
  final VoidCallback onAddEntry;
  final void Function(int entryId) onRemoveEntry;
  final void Function(DateTime? date) onDayDateChanged;
  final VoidCallback onStateChanged;
  final List<ProgramValidationError> validationErrors;

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  bool get _hasDateError => validationErrors.any(
        (e) => e.dayId == day.id && e.type == ProgramValidationErrorType.dateRequired,
      );

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: appPrimary, surface: appSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onDayDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = day.date != null ? _formatDate(day.date!) : '';

    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${t.events.edit.dayLabel} $dayNumber',
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const FaIcon(FontAwesomeIcons.trash, size: 14, color: appError),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AddEventFormField(
            label: 'Date',
            child: GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                decoration: BoxDecoration(
                  color: appCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _hasDateError ? appError : appBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateText.isEmpty ? 'dd.mm.yyyy' : dateText,
                        style: TextStyle(
                          color: dateText.isEmpty ? appMutedDark : appText,
                          fontSize: AppTypography.fontSizeMd,
                        ),
                      ),
                    ),
                    const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
                  ],
                ),
              ),
            ),
          ),
          if (_hasDateError) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.events.edit.validationDateRequired,
              style: const TextStyle(
                color: appError,
                fontSize: AppTypography.fontSizeSm,
              ),
            ),
          ],
          if (day.entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              t.events.edit.entryName.replaceAll(' *', ''),
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...day.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ProgramEntryCard(
                  entry: entry,
                  onRemove: () => onRemoveEntry(entry.id),
                  onStateChanged: onStateChanged,
                  validationErrors: validationErrors,
                ),
              ),
            ),
          ] else
            const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onAddEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: appCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: appBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.plus, size: 10, color: appPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    t.events.edit.addEntry,
                    style: const TextStyle(
                      color: appPrimary,
                      fontSize: AppTypography.fontSizeSm,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramEntryCard extends StatefulWidget {
  const _ProgramEntryCard({
    required this.entry,
    required this.onRemove,
    required this.onStateChanged,
    required this.validationErrors,
  });

  final EditableProgramEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onStateChanged;
  final List<ProgramValidationError> validationErrors;

  @override
  State<_ProgramEntryCard> createState() => _ProgramEntryCardState();
}

class _ProgramEntryCardState extends State<_ProgramEntryCard> {
  static const _entryTypes = ['workshop', 'party', 'openLesson'];

  bool get _hasNameError => widget.validationErrors.any(
        (e) =>
            e.entryId == widget.entry.id &&
            e.type == ProgramValidationErrorType.nameRequired,
      );

  bool get _hasTimeRangeError => widget.validationErrors.any(
        (e) =>
            e.entryId == widget.entry.id &&
            e.type == ProgramValidationErrorType.invalidTimeRange,
      );

  String _formatTime(TimeOfDay tod) =>
      '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';

  String _typeLabel(String type) {
    switch (type) {
      case 'party':
        return t.events.edit.typeParty;
      case 'openLesson':
        return t.events.edit.typeOpenLesson;
      default:
        return t.events.edit.typeWorkshop;
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.entry.startTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: appPrimary, surface: appSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      widget.entry.startTime = picked;
      widget.onStateChanged();
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.entry.endTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: appPrimary, surface: appSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      widget.entry.endTime = picked;
      widget.onStateChanged();
    }
  }

  Widget _buildTimeField(String label, TimeOfDay? time, VoidCallback onTap) {
    final text = time != null ? _formatTime(time) : '';
    return Expanded(
      child: AddEventFormField(
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _hasTimeRangeError ? appError : appBorder,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text.isEmpty ? '--:--' : text,
                    style: TextStyle(
                      color: text.isEmpty ? appMutedDark : appText,
                      fontSize: AppTypography.fontSizeSm,
                    ),
                  ),
                ),
                const FaIcon(FontAwesomeIcons.clock, size: 12, color: appMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: (_hasNameError || _hasTimeRangeError) ? appError : appBorder,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: const FaIcon(FontAwesomeIcons.trash, size: 12, color: appError),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AddEventFormField(
            label: t.events.edit.entryName,
            child: AddEventTextInput(
              controller: widget.entry.nameController,
              hintText: t.events.edit.entryNameHint,
              isSmall: true,
            ),
          ),
          if (_hasNameError) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.events.edit.validationNameRequired,
              style: const TextStyle(
                color: appError,
                fontSize: AppTypography.fontSizeSm,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AddEventFormField(
            label: t.events.edit.entryDescription,
            child: AddEventTextAreaInput(
              controller: widget.entry.descriptionController,
              hintText: t.events.edit.entryDescriptionHint,
              minLines: 2,
              isSmall: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AddEventFormField(
            label: t.events.edit.entryType,
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: appBorder),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.entry.type,
                  dropdownColor: appSurface,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeSm,
                  ),
                  isExpanded: true,
                  items: _entryTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.entry.type = value;
                      widget.onStateChanged();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildTimeField(
                t.events.edit.startTime.replaceAll(' *', ''),
                widget.entry.startTime,
                _pickStartTime,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildTimeField(
                t.events.edit.endTime.replaceAll(' *', ''),
                widget.entry.endTime,
                _pickEndTime,
              ),
            ],
          ),
          if (_hasTimeRangeError) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.events.edit.validationInvalidTimeRange,
              style: const TextStyle(
                color: appError,
                fontSize: AppTypography.fontSizeSm,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AddEventFormField(
            label: t.events.edit.lectors,
            child: AddEventTextInput(
              controller: widget.entry.lectorsController,
              hintText: t.events.edit.lectorsHint,
              isSmall: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AddEventFormField(
            label: t.events.edit.djs,
            child: AddEventTextInput(
              controller: widget.entry.djsController,
              hintText: t.events.edit.djsHint,
              isSmall: true,
            ),
          ),
        ],
      ),
    );
  }
}
