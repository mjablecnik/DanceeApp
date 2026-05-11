import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final Set<String> _selectedDances = {};
  final List<_ProgramDay> _programDays = [];
  int _programDayCounter = 0;

  void _toggleDance(String dance) {
    setState(() {
      if (_selectedDances.contains(dance)) {
        _selectedDances.remove(dance);
      } else {
        _selectedDances.add(dance);
      }
    });
  }

  void _addProgramDay() {
    setState(() {
      _programDayCounter++;
      _programDays.add(_ProgramDay(
        id: _programDayCounter,
        dateController: TextEditingController(),
        dayNameController: TextEditingController(),
        items: [],
      ));
    });
  }

  void _removeProgramDay(int id) {
    setState(() {
      final index = _programDays.indexWhere((d) => d.id == id);
      if (index >= 0) {
        _programDays[index].dispose();
        _programDays.removeAt(index);
      }
    });
  }

  void _addProgramItem(int dayId) {
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
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _AddEventHeader(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xxl,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDateTimeSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildLocationSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildOrganizerSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDanceTypesSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildProgramSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSubmitSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: NavTab.events),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: FontAwesomeIcons.circleInfo,
          label: 'Základní informace',
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Název akce *',
          child: _TextInput(hintText: 'např. Prague Latin Festival 2025'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Popis akce *',
          child: _TextAreaInput(
            hintText: 'Popište vaši akci, co účastníky čeká...',
            minLines: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Obrázek akce',
          child: _ImageUploadArea(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: FontAwesomeIcons.calendar,
          label: 'Datum a čas',
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Datum od *',
                child: _DateInput(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Datum do *',
                child: _DateInput(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Čas začátku *',
                child: _TimeInput(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Čas konce *',
                child: _TimeInput(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: FontAwesomeIcons.locationDot,
          label: 'Místo konání',
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Název místa *',
          child: _TextInput(hintText: 'např. Kongresové centrum Praha'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Adresa *',
          child: _TextInput(hintText: 'např. 5. května 65, Praha 4'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Město *',
                child: _TextInput(hintText: 'Praha'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'PSČ',
                child: _TextInput(
                  hintText: '14000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: FontAwesomeIcons.userTie,
          label: 'Organizátor',
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Název organizátora *',
          child: _TextInput(hintText: 'např. Prague Latin Events'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Kontaktní e-mail',
          child: _TextInput(
            hintText: 'info@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }

  Widget _buildDanceTypesSection() {
    const dances = [
      'Salsa',
      'Bachata',
      'Kizomba',
      'Zouk',
      'Semba',
      'Tango',
      'Swing',
      'Jiné',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
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
          children: dances
              .map((dance) => _DanceTag(
                    label: dance,
                    isSelected: _selectedDances.contains(dance),
                    onTap: () => _toggleDance(dance),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
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
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Vstupné od (Kč)',
                child: _TextInput(
                  hintText: '350',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Vstupné do (Kč)',
                child: _TextInput(
                  hintText: '1200',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Dresscode',
          child: _TextInput(hintText: 'např. Elegantní casual'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'URL na nákup vstupenek',
          child: _TextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'URL na původní zdroj',
          child: _TextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }

  Widget _buildProgramSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionHeading(
              icon: FontAwesomeIcons.calendarDays,
              label: 'Program akce',
            ),
            GestureDetector(
              onTap: _addProgramDay,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  FaIcon(
                    FontAwesomeIcons.plus,
                    size: 12,
                    color: appPrimary,
                  ),
                  SizedBox(width: 4),
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
                        onRemove: () => _removeProgramDay(entry.value.id),
                        onAddItem: () => _addProgramItem(entry.value.id),
                        onStateChanged: () => setState(() {}),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitSection() {
    return Column(
      children: [
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
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.paperPlane,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Odeslat ke schválení',
                      style: TextStyle(
                        color: Colors.white,
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
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Akce bude zkontrolována administrátorem před zveřejněním',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appMuted,
            fontSize: AppTypography.fontSizeSm,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _AddEventHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AddEventHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
              ),
            ),
          ),
          const Text(
            'Přidat akci',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightSemiBold,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.question, size: 16, color: appText),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Section heading
// ---------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeading({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 16, color: appPrimary),
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

// ---------------------------------------------------------------------------
// Form helpers
// ---------------------------------------------------------------------------

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

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

class _TextInput extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool isSmall;

  const _TextInput({
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
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
          ),
        ),
        focusNode: _FocusBorderNode(),
      ),
    );
  }
}

class _FocusBorderNode extends FocusNode {}

class _TextAreaInput extends StatelessWidget {
  final String? hintText;
  final int minLines;
  final TextEditingController? controller;
  final bool isSmall;

  const _TextAreaInput({
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
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
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

class _DateInput extends StatefulWidget {
  const _DateInput();

  @override
  State<_DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<_DateInput> {
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
                  color: label.isEmpty ? const Color(0xFF64748B) : appText,
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

class _TimeInput extends StatefulWidget {
  const _TimeInput();

  @override
  State<_TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<_TimeInput> {
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
                  color: label.isEmpty ? const Color(0xFF64748B) : appText,
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

class _ImageUploadArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: appBorder, width: 2, style: BorderStyle.solid),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          FaIcon(
            FontAwesomeIcons.cloudArrowUp,
            size: 40,
            color: appMuted,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Klikněte nebo přetáhněte obrázek',
            style: TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'PNG, JPG do 5MB',
            style: TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dance tag
// ---------------------------------------------------------------------------

class _DanceTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DanceTag({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? appPrimary : appSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? appPrimary : appBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Program day data models
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Program day card
// ---------------------------------------------------------------------------

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
                child: const FaIcon(
                  FontAwesomeIcons.trash,
                  size: 14,
                  color: appError,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Datum',
            child: _DateInput(),
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Název dne',
            child: _TextInput(
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
                  SizedBox(width: 4),
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
                child: _TextInput(
                  controller: item.timeController,
                  hintText: 'Čas',
                  isSmall: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TextInput(
                  controller: item.titleController,
                  hintText: 'Název aktivity',
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _TextAreaInput(
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
