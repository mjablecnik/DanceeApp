import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventProgramSection extends StatefulWidget {
  const AddEventProgramSection({super.key});

  @override
  State<AddEventProgramSection> createState() => _AddEventProgramSectionState();
}

class _AddEventProgramSectionState extends State<AddEventProgramSection> {
  final List<_ProgramDay> _programDays = [];
  int _dayCounter = 0;

  void _addDay() {
    setState(() {
      _dayCounter++;
      _programDays.add(_ProgramDay(
        id: _dayCounter,
        dateController: TextEditingController(),
        dayNameController: TextEditingController(),
        items: [],
      ));
    });
  }

  void _removeDay(int id) {
    setState(() {
      final index = _programDays.indexWhere((d) => d.id == id);
      if (index >= 0) {
        _programDays[index].dispose();
        _programDays.removeAt(index);
      }
    });
  }

  void _addItem(int dayId) {
    setState(() {
      final day = _programDays.firstWhere((d) => d.id == dayId);
      day.items.add(_ProgramItem(
        timeController: TextEditingController(),
        titleController: TextEditingController(),
        descController: TextEditingController(),
      ));
    });
  }

  @override
  void dispose() {
    for (final day in _programDays) {
      day.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AddEventSectionHeading(
              icon: FontAwesomeIcons.calendarDays,
              label: 'Program akce',
            ),
            GestureDetector(
              onTap: _addDay,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.plus, size: 12, color: appPrimary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Přidat den',
                    style: TextStyle(
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
        const Text(
          'Nepovinné - přidejte rozvrh jednotlivých dnů',
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
          ),
        ),
        if (_programDays.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Column(
            children: _programDays
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ProgramDayCard(
                        day: entry.value,
                        dayNumber: entry.key + 1,
                        onRemove: () => _removeDay(entry.value.id),
                        onAddItem: () => _addItem(entry.value.id),
                        onStateChanged: () => setState(() {}),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ProgramItem {
  final TextEditingController timeController;
  final TextEditingController titleController;
  final TextEditingController descController;

  _ProgramItem({
    required this.timeController,
    required this.titleController,
    required this.descController,
  });

  void dispose() {
    timeController.dispose();
    titleController.dispose();
    descController.dispose();
  }
}

class _ProgramDay {
  final int id;
  final TextEditingController dateController;
  final TextEditingController dayNameController;
  final List<_ProgramItem> items;

  _ProgramDay({
    required this.id,
    required this.dateController,
    required this.dayNameController,
    required this.items,
  });

  void dispose() {
    dateController.dispose();
    dayNameController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}

class _ProgramDayCard extends StatelessWidget {
  final _ProgramDay day;
  final int dayNumber;
  final VoidCallback onRemove;
  final VoidCallback onAddItem;
  final VoidCallback onStateChanged;

  const _ProgramDayCard({
    required this.day,
    required this.dayNumber,
    required this.onRemove,
    required this.onAddItem,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                'Den $dayNumber',
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
          const AddEventFormField(
            label: 'Datum',
            child: AddEventDateInput(),
          ),
          const SizedBox(height: AppSpacing.md),
          AddEventFormField(
            label: 'Název dne',
            child: AddEventTextInput(
              controller: day.dayNameController,
              hintText: 'např. Pátek 12. Říjen',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Položky programu',
            style: TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...day.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ProgramItemCard(item: item),
              )),
          GestureDetector(
            onTap: onAddItem,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: appCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: appBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.plus, size: 10, color: appPrimary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Přidat položku',
                    style: TextStyle(
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

class _ProgramItemCard extends StatelessWidget {
  final _ProgramItem item;

  const _ProgramItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: appBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                child: AddEventTextInput(
                  controller: item.timeController,
                  hintText: 'Čas',
                  isSmall: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AddEventTextInput(
                  controller: item.titleController,
                  hintText: 'Název aktivity',
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AddEventTextAreaInput(
            controller: item.descController,
            hintText: 'Popis (volitelné)',
            minLines: 2,
            isSmall: true,
          ),
        ],
      ),
    );
  }
}
