import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/event.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/event_detail_cubit.dart';
import '../../../logic/states/event_detail_state.dart';
import '../add_event/components/add_event_form_components.dart';

class _EditableInfoEntry {
  final TextEditingController keyController;
  final TextEditingController valueController;

  _EditableInfoEntry({String key = '', String value = ''})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

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
  late final TextEditingController _priceController;
  List<_EditableInfoEntry> _infoEntries = [];

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Set<String> _selectedDances = {};
  String _eventType = '';

  bool _initialized = false;
  Event? _originalEvent;
  int? _translationId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _organizerController = TextEditingController();
    _registrationUrlController = TextEditingController();
    _originalUrlController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final locale = Localizations.localeOf(context).languageCode;
      context.read<EventDetailCubit>().loadEvent(widget.eventId, locale);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _registrationUrlController.dispose();
    _originalUrlController.dispose();
    _priceController.dispose();
    for (final entry in _infoEntries) {
      entry.dispose();
    }
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
    _priceController.text = event.price ?? '';
    _infoEntries = event.info
        .map((info) => _EditableInfoEntry(key: info.key, value: info.value))
        .toList();

    final selectedDances = event.dances.map((d) => d.toLowerCase()).toSet();

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

  Future<void> _openDanceStyleSelector() async {
    final result = await DanceStyleSelectorRoute(
      $extra: _selectedDances.toList(),
    ).push<List<String>?>(context);
    if (result != null && mounted) {
      setState(() => _selectedDances = result.toSet());
    }
  }

  void _removeInfoEntry(int index) {
    _infoEntries[index].dispose();
    _infoEntries.removeAt(index);
  }

  bool _infoListsEqual(
    List<Map<String, String>> a,
    List<Map<String, String>> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i]['key'] != b[i]['key'] || a[i]['value'] != b[i]['value']) {
        return false;
      }
    }
    return true;
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

    final normalizedOriginal = original.dances.map((d) => d.toLowerCase()).toSet();
    if (!_setsEqual(_selectedDances, normalizedOriginal)) {
      rootFields['dances'] = _selectedDances.toList();
    }

    final priceVal = _priceController.text.isEmpty ? null : _priceController.text;
    if (priceVal != original.price) {
      rootFields['price'] = priceVal;
    }

    final newInfoList = _infoEntries
        .where((e) => e.keyController.text.isNotEmpty || e.valueController.text.isNotEmpty)
        .map((e) => <String, String>{'key': e.keyController.text, 'value': e.valueController.text})
        .toList();
    final originalInfoList = original.info
        .map((i) => <String, String>{'key': i.key, 'value': i.value})
        .toList();
    if (!_infoListsEqual(newInfoList, originalInfoList)) {
      rootFields['info'] = newInfoList;
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
        AddEventSectionHeading(
          icon: FontAwesomeIcons.tag,
          label: t.events.edit.eventTypeSection,
        ),
        const SizedBox(height: AppSpacing.lg),
        AddEventFormField(
          label: t.events.edit.eventTypeSection,
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
                  _eventType.isNotEmpty ? _eventType : t.events.edit.eventTypeHint,
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

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddEventSectionHeading(
          icon: FontAwesomeIcons.listUl,
          label: t.events.edit.keyInfoSection,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.events.edit.keyInfoHint,
          style: const TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeMd,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._infoEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final infoEntry = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: AddEventTextInput(
                    controller: infoEntry.keyController,
                    hintText: t.events.edit.infoKeyHint,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: AddEventTextInput(
                    controller: infoEntry.valueController,
                    hintText: t.events.edit.infoValueHint,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => setState(() => _removeInfoEntry(index)),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: appBorder),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.trash, size: 12, color: appMuted),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          onTap: () => setState(() => _infoEntries.add(_EditableInfoEntry())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: appBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.plus, size: 12, color: appMuted),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  t.events.edit.addInfoEntry,
                  style: const TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ],
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
              AddEventSectionHeading(
                icon: FontAwesomeIcons.circleInfo,
                label: t.events.edit.basicInfoSection,
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.eventTitle,
                child: AddEventTextInput(
                  controller: _titleController,
                  hintText: t.events.edit.eventTitleHint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.eventDescription,
                child: AddEventTextAreaInput(
                  controller: _descriptionController,
                  hintText: t.events.edit.eventDescriptionHint,
                  minLines: 4,
                ),
              ),
              if (_originalEvent?.imageUrl != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AddEventFormField(
                  label: t.events.edit.eventImage,
                  child: const SizedBox.shrink(),
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
              AddEventSectionHeading(
                icon: FontAwesomeIcons.calendar,
                label: t.events.edit.dateTimeSection,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _buildDateField(t.events.edit.startDate, _startDate, true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDateField(t.events.edit.endDate, _endDate, false)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _buildTimeField(t.events.edit.startTime, _startTime, true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildTimeField(t.events.edit.endTime, _endTime, false)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Organizer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddEventSectionHeading(
                icon: FontAwesomeIcons.userTie,
                label: t.events.edit.organizerSection,
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.organizerName,
                child: AddEventTextInput(
                  controller: _organizerController,
                  hintText: t.events.edit.organizerNameHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Dance styles
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddEventSectionHeading(
                icon: FontAwesomeIcons.music,
                label: t.events.edit.danceStylesSection,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.events.edit.danceStylesHint,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _openDanceStyleSelector,
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
                        child: _selectedDances.isEmpty
                            ? Text(
                                t.events.edit.danceStyleSelector,
                                style: const TextStyle(
                                  color: appMutedDark,
                                  fontSize: AppTypography.fontSizeMd,
                                ),
                              )
                            : Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: _selectedDances
                                    .map((code) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: appPrimary,
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.full),
                                          ),
                                          child: Text(
                                            code,
                                            style: const TextStyle(
                                              color: appWhite,
                                              fontSize: AppTypography.fontSizeSm,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ),
                      const FaIcon(FontAwesomeIcons.chevronRight,
                          size: 12, color: appMuted),
                    ],
                  ),
                ),
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
              AddEventSectionHeading(
                icon: FontAwesomeIcons.circlePlus,
                label: t.events.edit.additionalSection,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.events.edit.optionalData,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.price,
                child: AddEventTextInput(
                  controller: _priceController,
                  hintText: t.events.edit.priceHint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.ticketUrl,
                child: AddEventTextInput(
                  controller: _registrationUrlController,
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddEventFormField(
                label: t.events.edit.originalSourceUrl,
                child: AddEventTextInput(
                  controller: _originalUrlController,
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Additional info entries
          _buildAdditionalInfoSection(),
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
          success: (s) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.events.edit.success)),
            );
            context.read<EventCubit>().replaceEvent(widget.eventId, s.event);
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
