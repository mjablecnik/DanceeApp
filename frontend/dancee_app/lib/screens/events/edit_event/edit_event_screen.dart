import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/event.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/event_detail_cubit.dart';
import '../../../logic/states/event_detail_state.dart';
import '../add_event/components/add_event_form_components.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _organizerController;
  late final TextEditingController _registrationUrlController;
  late final TextEditingController _originalUrlController;

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Set<String> _selectedDances = {};
  String _eventType = '';

  bool _initialized = false;
  Event? _originalEvent;
  int? _translationId;

  static const _allDances = [
    'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Semba', 'Tango', 'Swing', 'Jiné',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _organizerController = TextEditingController();
    _registrationUrlController = TextEditingController();
    _originalUrlController = TextEditingController();
    final locale = Localizations.localeOf(context).languageCode;
    context.read<EventDetailCubit>().loadEvent(widget.eventId, locale);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _registrationUrlController.dispose();
    _originalUrlController.dispose();
    super.dispose();
  }

  void _initFromEvent(Event event, int? translationId) {
    if (_initialized) return;
    _initialized = true;
    _originalEvent = event;
    _translationId = translationId;

    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _organizerController.text = event.organizer;
    _registrationUrlController.text = event.registrationUrl ?? '';
    _originalUrlController.text = event.originalUrl ?? '';

    final selectedDances = <String>{};
    for (final eventDance in event.dances) {
      final match = _allDances.where((d) {
        if (eventDance.toLowerCase() == 'other') return d == 'Jiné';
        return d.toLowerCase() == eventDance.toLowerCase();
      }).firstOrNull;
      if (match != null) selectedDances.add(match);
    }

    setState(() {
      _startDate = event.startTime;
      _endDate = event.endTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endTime = event.endTime != null ? TimeOfDay.fromDateTime(event.endTime!) : null;
      _selectedDances = selectedDances;
      _eventType = event.eventType;
    });
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _formatTime(TimeOfDay tod) =>
      '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: appPrimary, surface: appSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: appPrimary, surface: appSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _toggleDance(String dance) {
    setState(() {
      if (_selectedDances.contains(dance)) {
        _selectedDances.remove(dance);
      } else {
        _selectedDances.add(dance);
      }
    });
  }

  Map<String, dynamic> _buildPayload(String languageCode) {
    final original = _originalEvent;
    if (original == null) return {};

    final Map<String, dynamic> rootFields = {};
    final Map<String, dynamic> translationFields = {};

    if (_titleController.text != original.title) {
      translationFields['title'] = _titleController.text;
    }
    if (_descriptionController.text != original.description) {
      translationFields['description'] = _descriptionController.text;
    }

    if (_eventType != original.eventType && _eventType.isNotEmpty) {
      rootFields['event_type'] = _eventType;
    }
    if (_organizerController.text != original.organizer) {
      rootFields['organizer'] = _organizerController.text;
    }
    final regUrl = _registrationUrlController.text.isEmpty
        ? null
        : _registrationUrlController.text;
    if (regUrl != original.registrationUrl) {
      rootFields['registration_url'] = regUrl;
    }
    final origUrl = _originalUrlController.text.isEmpty
        ? null
        : _originalUrlController.text;
    if (origUrl != original.originalUrl) {
      rootFields['original_url'] = origUrl;
    }

    if (_startDate != null && _startTime != null) {
      final newStart = DateTime(
        _startDate!.year, _startDate!.month, _startDate!.day,
        _startTime!.hour, _startTime!.minute,
      );
      if (newStart != original.startTime) {
        rootFields['start_time'] = newStart.toIso8601String();
      }
    }
    if (_endDate != null) {
      final endTime = _endTime ?? const TimeOfDay(hour: 0, minute: 0);
      final newEnd = DateTime(
        _endDate!.year, _endDate!.month, _endDate!.day,
        endTime.hour, endTime.minute,
      );
      if (newEnd != original.endTime) {
        rootFields['end_time'] = newEnd.toIso8601String();
      }
    }

    final normalizedSelected = _selectedDances.map((d) {
      if (d == 'Jiné') return 'other';
      return d.toLowerCase();
    }).toSet();
    final normalizedOriginal = original.dances.map((d) => d.toLowerCase()).toSet();
    if (!_setsEqual(normalizedSelected, normalizedOriginal)) {
      rootFields['dances'] = normalizedSelected.toList();
    }

    final payload = Map<String, dynamic>.from(rootFields);
    if (translationFields.isNotEmpty) {
      payload['translations'] = [
        {
          if (_translationId != null) 'id': _translationId,
          'languages_code': languageCode,
          ...translationFields,
        }
      ];
    }

    return payload;
  }

  Map<String, String> _extractTextFields(Map<String, dynamic> payload) {
    final textFields = <String, String>{};
    final translations = payload['translations'] as List?;
    if (translations != null && translations.isNotEmpty) {
      final first = translations.first as Map<String, dynamic>;
      for (final key in ['title', 'description']) {
        if (first.containsKey(key)) {
          textFields[key] = first[key] as String;
        }
      }
    }
    return textFields;
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }

  void _submit() {
    final locale = Localizations.localeOf(context).languageCode;
    final payload = _buildPayload(locale);
    if (payload.isEmpty) {
      context.pop();
      return;
    }
    context.read<EventDetailCubit>().submitEdit(
      widget.eventId,
      payload,
      locale,
      modifiedTextFields: _extractTextFields(payload),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: AppOpacity.high),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: AppSizes.iconButtonMd,
              height: AppSizes.iconButtonMd,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: AppIconSizes.xs, color: appText),
              ),
            ),
          ),
          Text(
            t.events.edit.header,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
          const SizedBox(width: AppSizes.iconButtonMd),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStart) {
    final text = date != null ? _formatDate(date) : '';
    return AddEventFormField(
      label: label,
      child: GestureDetector(
        onTap: () => _pickDate(isStart),
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
                  text.isEmpty ? 'dd.mm.rrrr' : text,
                  style: TextStyle(
                    color: text.isEmpty ? appMutedDark : appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ),
              const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? tod, bool isStart) {
    final text = tod != null ? _formatTime(tod) : '';
    return AddEventFormField(
      label: label,
      child: GestureDetector(
        onTap: () => _pickTime(isStart),
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
                  text.isEmpty ? '--:--' : text,
                  style: TextStyle(
                    color: text.isEmpty ? appMutedDark : appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ),
              const FaIcon(FontAwesomeIcons.clock, size: 14, color: appMuted),
            ],
          ),
        ),
      ),
    );
  }

  static const _eventTypes = ['social', 'festival', 'holiday', 'workshop'];

  Widget _buildEventTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AddEventSectionHeading(
          icon: FontAwesomeIcons.tag,
          label: 'Typ akce',
        ),
        const SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: 'Typ akce',
          child: Container(
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
                value: _eventTypes.contains(_eventType) ? _eventType : null,
                hint: Text(
                  _eventType.isNotEmpty ? _eventType : 'Vyberte typ akce',
                  style: const TextStyle(
                    color: appMutedDark,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
                dropdownColor: appSurface,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                ),
                isExpanded: true,
                items: _eventTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _eventType = value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isSubmitting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xxl,
        bottom: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info
          Column(
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
                  controller: _titleController,
                  hintText: 'např. Prague Latin Festival 2025',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: 'Popis akce *',
                child: AddEventTextAreaInput(
                  controller: _descriptionController,
                  hintText: 'Popište vaši akci, co účastníky čeká...',
                  minLines: 4,
                ),
              ),
              if (_originalEvent?.imageUrl != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const AddEventFormField(
                  label: 'Obrázek akce',
                  child: SizedBox.shrink(),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.network(
                    _originalEvent!.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Date/time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddEventSectionHeading(
                icon: FontAwesomeIcons.calendar,
                label: 'Datum a čas',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _buildDateField('Datum od *', _startDate, true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDateField('Datum do *', _endDate, false)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _buildTimeField('Čas začátku *', _startTime, true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildTimeField('Čas konce *', _endTime, false)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Organizer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddEventSectionHeading(
                icon: FontAwesomeIcons.userTie,
                label: 'Organizátor',
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: 'Název organizátora *',
                child: AddEventTextInput(
                  controller: _organizerController,
                  hintText: 'např. Prague Latin Events',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Dance styles
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddEventSectionHeading(
                icon: FontAwesomeIcons.music,
                label: 'Typy tanců *',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Vyberte taneční styly, které se na akci objeví',
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _allDances.map((dance) {
                  final isSelected = _selectedDances.contains(dance);
                  return GestureDetector(
                    onTap: () => _toggleDance(dance),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? appPrimary : appSurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: isSelected ? appPrimary : appBorder),
                      ),
                      child: Text(
                        dance,
                        style: TextStyle(
                          color: isSelected ? appWhite : appText,
                          fontSize: AppTypography.fontSizeMd,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Event type
          _buildEventTypeSection(),
          const SizedBox(height: AppSpacing.xxl),
          // URLs
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddEventSectionHeading(
                icon: FontAwesomeIcons.circlePlus,
                label: 'Dodatečné informace',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Nepovinné údaje',
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: 'URL na nákup vstupenek',
                child: AddEventTextInput(
                  controller: _registrationUrlController,
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: 'URL na původní zdroj',
                child: AddEventTextInput(
                  controller: _originalUrlController,
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Submit
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [AppShadows.primary],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: isSubmitting ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: appWhite,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const FaIcon(
                          FontAwesomeIcons.floppyDisk,
                          size: AppIconSizes.xs,
                          color: appWhite,
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        t.events.edit.submit,
                        style: const TextStyle(
                          color: appWhite,
                          fontSize: AppTypography.fontSizeXl,
                          fontWeight: AppTypography.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventDetailCubit, EventDetailState>(
      listener: (context, state) {
        state.maybeMap(
          loaded: (s) {
            _initFromEvent(s.event, s.translationId);
            context.read<EventDetailCubit>().startEditing();
          },
          editing: (s) => _initFromEvent(s.event, s.translationId),
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.events.edit.success)),
            );
            context.pop();
          },
          error: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.events.edit.error)),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        if (!_initialized) {
          return Scaffold(
            backgroundColor: appBg,
            body: Column(
              children: [
                _buildHeader(),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: appPrimary),
                  ),
                ),
              ],
            ),
          );
        }

        final isSubmitting = state.maybeMap(
          submitting: (_) => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: appBg,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildForm(isSubmitting)),
            ],
          ),
        );
      },
    );
  }
}
