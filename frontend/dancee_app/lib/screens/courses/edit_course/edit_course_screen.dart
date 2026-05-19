import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/course.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/course_detail_cubit.dart';
import '../../../logic/states/course_detail_state.dart';
import '../add_course/components/add_course_form_components.dart';

class EditCourseScreen extends StatefulWidget {
  const EditCourseScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructorNameController;
  late final TextEditingController _instructorBioController;
  late final TextEditingController _priceController;
  late final TextEditingController _priceNoteController;
  late final TextEditingController _originalUrlController;
  late final TextEditingController _registrationUrlController;
  late final TextEditingController _lessonCountController;
  late final TextEditingController _lessonDurationController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _scheduleTimeController;
  List<TextEditingController> _learningItemControllers = [];

  DateTime? _startDate;
  DateTime? _endDate;
  String _danceType = '';
  String _level = '';
  String _scheduleDay = '';

  bool _initialized = false;
  Course? _originalCourse;
  int? _translationId;

  static const _danceTypes = [
    'salsa', 'bachata', 'kizomba', 'tango', 'swing', 'waltz', 'other',
  ];

  static const _levels = [
    'beginner', 'intermediate', 'advanced', 'expert',
  ];

  static const _scheduleDays = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _instructorNameController = TextEditingController();
    _instructorBioController = TextEditingController();
    _priceController = TextEditingController();
    _priceNoteController = TextEditingController();
    _originalUrlController = TextEditingController();
    _registrationUrlController = TextEditingController();
    _lessonCountController = TextEditingController();
    _lessonDurationController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _scheduleTimeController = TextEditingController();
    final locale = Localizations.localeOf(context).languageCode;
    context.read<CourseDetailCubit>().loadCourse(widget.courseId, locale);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    _instructorBioController.dispose();
    _priceController.dispose();
    _priceNoteController.dispose();
    _originalUrlController.dispose();
    _registrationUrlController.dispose();
    _lessonCountController.dispose();
    _lessonDurationController.dispose();
    _maxParticipantsController.dispose();
    _scheduleTimeController.dispose();
    for (final c in _learningItemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initFromCourse(Course course, int? translationId) {
    if (_initialized) return;
    _initialized = true;
    _originalCourse = course;
    _translationId = translationId;

    _titleController.text = course.title;
    _descriptionController.text = course.description;
    _instructorNameController.text = course.instructorName ?? '';
    _instructorBioController.text = course.instructorBio ?? '';
    _priceController.text = course.price ?? '';
    _priceNoteController.text = course.priceNote ?? '';
    _originalUrlController.text = course.originalUrl ?? '';
    _registrationUrlController.text = course.registrationUrl ?? '';
    _lessonCountController.text = course.lessonCount?.toString() ?? '';
    _lessonDurationController.text = course.lessonDurationMinutes?.toString() ?? '';
    _maxParticipantsController.text = course.maxParticipants?.toString() ?? '';
    _scheduleTimeController.text = course.scheduleTime ?? '';

    final items = course.learningItems.isNotEmpty ? course.learningItems : [''];
    _learningItemControllers = items.map((item) {
      final c = TextEditingController();
      c.text = item;
      return c;
    }).toList();

    DateTime? parsedStart;
    DateTime? parsedEnd;
    if (course.startDate != null) {
      try {
        parsedStart = DateTime.parse(course.startDate!);
      } catch (_) {}
    }
    if (course.endDate != null) {
      try {
        parsedEnd = DateTime.parse(course.endDate!);
      } catch (_) {}
    }

    setState(() {
      _startDate = parsedStart;
      _endDate = parsedEnd;
      _danceType = course.dances.isNotEmpty ? course.dances.first.toLowerCase() : '';
      _level = course.level ?? '';
      _scheduleDay = course.scheduleDay ?? '';
    });
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  String _formatDateForApi(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

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

  void _addLearningItem() {
    setState(() => _learningItemControllers.add(TextEditingController()));
  }

  void _removeLearningItem(int index) {
    if (_learningItemControllers.length <= 1) return;
    setState(() {
      _learningItemControllers[index].dispose();
      _learningItemControllers.removeAt(index);
    });
  }

  Map<String, dynamic> _buildPayload(String languageCode) {
    final original = _originalCourse;
    if (original == null) return {};

    final Map<String, dynamic> rootFields = {};
    final Map<String, dynamic> translationFields = {};

    // Translation fields
    if (_titleController.text != original.title) {
      translationFields['title'] = _titleController.text;
    }
    if (_descriptionController.text != original.description) {
      translationFields['description'] = _descriptionController.text;
    }
    final learningItems = _learningItemControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (!_listsEqual(learningItems, original.learningItems)) {
      translationFields['learning_items'] = learningItems;
    }

    // Root-level fields
    final instructorName = _instructorNameController.text.isEmpty
        ? null
        : _instructorNameController.text;
    if (instructorName != original.instructorName) {
      rootFields['instructor_name'] = instructorName;
    }

    final instructorBio = _instructorBioController.text.isEmpty
        ? null
        : _instructorBioController.text;
    if (instructorBio != original.instructorBio) {
      rootFields['instructor_bio'] = instructorBio;
    }

    final price = _priceController.text.isEmpty ? null : _priceController.text;
    if (price != original.price) {
      rootFields['price'] = price;
    }

    final priceNote = _priceNoteController.text.isEmpty ? null : _priceNoteController.text;
    if (priceNote != original.priceNote) {
      rootFields['price_note'] = priceNote;
    }

    final origUrl = _originalUrlController.text.isEmpty ? null : _originalUrlController.text;
    if (origUrl != original.originalUrl) {
      rootFields['original_url'] = origUrl;
    }

    final regUrl = _registrationUrlController.text.isEmpty ? null : _registrationUrlController.text;
    if (regUrl != original.registrationUrl) {
      rootFields['registration_url'] = regUrl;
    }

    final lessonCount = int.tryParse(_lessonCountController.text);
    if (lessonCount != original.lessonCount) {
      rootFields['lesson_count'] = lessonCount;
    }

    final lessonDuration = int.tryParse(_lessonDurationController.text);
    if (lessonDuration != original.lessonDurationMinutes) {
      rootFields['lesson_duration_minutes'] = lessonDuration;
    }

    final maxParticipants = int.tryParse(_maxParticipantsController.text);
    if (maxParticipants != original.maxParticipants) {
      rootFields['max_participants'] = maxParticipants;
    }

    if (_scheduleDay.isNotEmpty && _scheduleDay != (original.scheduleDay ?? '')) {
      rootFields['schedule_day'] = _scheduleDay;
    }

    final scheduleTime = _scheduleTimeController.text.isEmpty
        ? null
        : _scheduleTimeController.text;
    if (scheduleTime != original.scheduleTime) {
      rootFields['schedule_time'] = scheduleTime;
    }

    if (_level.isNotEmpty && _level != (original.level ?? '')) {
      rootFields['level'] = _level;
    }

    if (_danceType.isNotEmpty) {
      final originalDance = original.dances.isNotEmpty
          ? original.dances.first.toLowerCase()
          : '';
      if (_danceType != originalDance) {
        rootFields['dances'] = [_danceType];
      }
    }

    if (_startDate != null) {
      final newStart = _formatDateForApi(_startDate!);
      if (newStart != original.startDate) {
        rootFields['start_date'] = newStart;
      }
    }

    if (_endDate != null) {
      final newEnd = _formatDateForApi(_endDate!);
      if (newEnd != original.endDate) {
        rootFields['end_date'] = newEnd;
      }
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
        if (first.containsKey(key) && first[key] is String) {
          textFields[key] = first[key] as String;
        }
      }
    }
    return textFields;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _submit() {
    final locale = Localizations.localeOf(context).languageCode;
    final payload = _buildPayload(locale);
    if (payload.isEmpty) {
      context.pop();
      return;
    }
    context.read<CourseDetailCubit>().submitEdit(
      widget.courseId,
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
            t.courses.edit.header,
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
    return AddCourseFormField(
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

  Widget _buildDropdown(
    String label,
    String current,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return AddCourseFormField(
      label: label,
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
            value: options.contains(current) ? current : null,
            hint: Text(
              current.isNotEmpty ? current : 'Vyberte...',
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
            items: options
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
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
              const AddCourseSectionHeading(label: 'Základní informace'),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Název kurzu *',
                child: AddCourseTextInput(
                  controller: _titleController,
                  hintText: 'např. Salsa Cubana pro začátečníky',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDropdown(
                'Typ tance',
                _danceType,
                _danceTypes,
                (v) {
                  if (v != null) setState(() => _danceType = v);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDropdown(
                'Úroveň kurzu',
                _level,
                _levels,
                (v) {
                  if (v != null) setState(() => _level = v);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Popis kurzu'),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Popis kurzu *',
                child: AddCourseTextAreaInput(
                  controller: _descriptionController,
                  hintText: 'Popište váš kurz, co se účastníci naučí...',
                  minLines: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Instructor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Informace o lektorovi'),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Jméno lektora',
                child: AddCourseTextInput(
                  controller: _instructorNameController,
                  hintText: 'např. Carlos Rodriguez',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'O lektorovi',
                child: AddCourseTextAreaInput(
                  controller: _instructorBioController,
                  hintText: 'Zkušenosti, certifikace, specializace...',
                  minLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Schedule
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Termín a čas'),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: _buildDateField('Začátek kurzu', _startDate, true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDateField('Konec kurzu', _endDate, false)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDropdown(
                'Den v týdnu',
                _scheduleDay,
                _scheduleDays,
                (v) {
                  if (v != null) setState(() => _scheduleDay = v);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Čas lekce',
                child: AddCourseTextInput(
                  controller: _scheduleTimeController,
                  hintText: '19:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Course details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Podrobnosti kurzu'),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AddCourseFormField(
                      label: 'Počet lekcí',
                      child: AddCourseTextInput(
                        controller: _lessonCountController,
                        hintText: '15',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AddCourseFormField(
                      label: 'Délka lekce (min)',
                      child: AddCourseTextInput(
                        controller: _lessonDurationController,
                        hintText: '90',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Max. počet osob',
                child: AddCourseTextInput(
                  controller: _maxParticipantsController,
                  hintText: '20',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Pricing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Cena kurzu'),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Cena za celý kurz (Kč)',
                child: AddCourseTextInput(
                  controller: _priceController,
                  hintText: '2500',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Poznámka k ceně',
                child: AddCourseTextInput(
                  controller: _priceNoteController,
                  hintText: 'Platba na místě nebo převodem',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Learning items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Obsah kurzu'),
              const SizedBox(height: AppSpacing.lg),
              ..._learningItemControllers.asMap().entries.map((entry) {
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
                        onTap: isFirst ? _addLearningItem : () => _removeLearningItem(index),
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
              }),
            ],
          ),
          if (_originalCourse?.imageUrl != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AddCourseSectionHeading(label: 'Obrázek kurzu'),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.network(
                    _originalCourse!.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          // URLs
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddCourseSectionHeading(label: 'Dodatečné informace'),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Odkaz na originální zdroj',
                child: AddCourseTextInput(
                  controller: _originalUrlController,
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AddCourseFormField(
                label: 'Odkaz na registraci',
                child: AddCourseTextInput(
                  controller: _registrationUrlController,
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
                        t.courses.edit.submit,
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
    return BlocConsumer<CourseDetailCubit, CourseDetailState>(
      listener: (context, state) {
        state.maybeMap(
          loaded: (s) {
            _initFromCourse(s.course, s.translationId);
            context.read<CourseDetailCubit>().startEditing();
          },
          editing: (s) => _initFromCourse(s.course, s.translationId),
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.courses.edit.success)),
            );
            context.pop();
          },
          error: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.courses.edit.error)),
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
