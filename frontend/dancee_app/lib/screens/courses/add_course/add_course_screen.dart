import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final List<TextEditingController> _contentControllers = [
    TextEditingController(),
  ];

  void _addContentItem() {
    setState(() {
      _contentControllers.add(TextEditingController());
    });
  }

  void _removeContentItem(int index) {
    if (_contentControllers.length <= 1) return;
    setState(() {
      _contentControllers[index].dispose();
      _contentControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final c in _contentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _AddCourseHeader(onBack: () => context.pop()),
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
                  _buildCourseBasicsSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDescriptionSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildScheduleSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildLocationSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildInstructorSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildCourseDetailsSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildPricingSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildCourseContentSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildCourseImageSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildFormActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddCourseBottomNav(),
    );
  }

  Widget _buildCourseBasicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Základní informace'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Název kurzu *',
          child: _TextInput(hintText: 'např. Salsa Cubana pro začátečníky'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Typ tance *',
          child: _SelectInput(
            items: const ['Salsa', 'Bachata', 'Kizomba', 'Tango', 'Swing', 'Waltz', 'Jiný'],
            hint: 'Vyberte typ tance',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Úroveň kurzu *',
          child: _SelectInput(
            items: const ['Začátečníci', 'Pokročilí', 'Pokročilí II', 'Experti'],
            hint: 'Vyberte úroveň',
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Popis kurzu'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Popis kurzu *',
          child: _TextAreaInput(
            hintText: 'Popište váš kurz, co se účastníci naučí, jakou atmosféru nabízíte...',
            minLines: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Termín a čas'),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Začátek kurzu *',
                child: _DateInput(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Konec kurzu *',
                child: _DateInput(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Rozvrh lekcí *',
          child: _TextInput(hintText: 'např. Každé úterý 19:00 - 20:30'),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Místo konání'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Název studia/školy *',
          child: _TextInput(hintText: 'např. Dance Studio Praha'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Adresa *',
          child: _TextInput(hintText: 'Václavské náměstí 14, Praha 1'),
        ),
      ],
    );
  }

  Widget _buildInstructorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Informace o lektorovi'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Jméno lektora *',
          child: _TextInput(hintText: 'např. Carlos Rodriguez'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'O lektorovi',
          child: _TextAreaInput(
            hintText: 'Zkušenosti, certifikace, specializace...',
            minLines: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Roky zkušeností',
                child: _TextInput(
                  hintText: '10',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Počet studentů',
                child: _TextInput(
                  hintText: '500',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Podrobnosti kurzu'),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Počet lekcí *',
                child: _TextInput(
                  hintText: '15',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Délka lekce (min) *',
                child: _TextInput(
                  hintText: '90',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _FormField(
                label: 'Max. počet osob *',
                child: _TextInput(
                  hintText: '20',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FormField(
                label: 'Věková skupina',
                child: _TextInput(hintText: '18+ let'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Cena kurzu'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Cena za celý kurz (Kč) *',
          child: _TextInput(
            hintText: '2500',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Způsob platby',
          child: _TextInput(hintText: 'Platba na místě nebo převodem'),
        ),
      ],
    );
  }

  Widget _buildCourseContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Obsah kurzu'),
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: _contentControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            final isFirst = index == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      controller: controller,
                      hintText: isFirst
                          ? 'Co se účastníci naučí...'
                          : 'Další bod obsahu...',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: isFirst
                        ? _addContentItem
                        : () => _removeContentItem(index),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isFirst ? appPrimary : appSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: FaIcon(
                          isFirst
                              ? FontAwesomeIcons.plus
                              : FontAwesomeIcons.minus,
                          size: 14,
                          color: isFirst ? Colors.white : appMuted,
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

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Dodatečné informace'),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Odkaz na originální zdroj',
          child: _TextInput(
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _FormField(
          label: 'Kontaktní informace',
          child: _TextAreaInput(
            hintText: 'Email, telefon, další kontakty...',
            minLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Obrázek kurzu'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: appBorder,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.cloudArrowUp,
                size: 32,
                color: appMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Nahrajte obrázek kurzu',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'PNG, JPG až 5MB',
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeSm,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: appBorder),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: const Text(
                  'Vybrat soubor',
                  style: TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormActionsSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 14,
                    color: appMuted,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Váš kurz bude odeslán ke schválení',
                    style: TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Administrátor aplikace váš kurz zkontroluje a schválí do 24 hodin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeSm,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                padding: EdgeInsets.symmetric(vertical: 14),
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
                      'Odeslat kurz ke schválení',
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.floppyDisk,
                      size: 16,
                      color: appText,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Uložit jako koncept',
                      style: TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _AddCourseHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AddCourseHeader({required this.onBack});

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
            'Přidat kurz',
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
// Bottom Navigation
// ---------------------------------------------------------------------------

class _AddCourseBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.sm,
        bottom: bottomPad + AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: FontAwesomeIcons.house,
            label: 'Domů',
            isActive: false,
            onTap: () => const EventsRoute().go(context),
          ),
          _NavIcon(
            icon: FontAwesomeIcons.magnifyingGlass,
            label: 'Hledat',
            isActive: false,
            onTap: () {},
          ),
          _NavFab(onTap: () {}),
          _NavIcon(
            icon: FontAwesomeIcons.bookOpen,
            label: 'Kurzy',
            isActive: true,
            onTap: () => const CoursesRoute().go(context),
          ),
          _NavIcon(
            icon: FontAwesomeIcons.user,
            label: 'Profil',
            isActive: false,
            onTap: () => const ProfileRoute().go(context),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 22, color: isActive ? appPrimary : appMuted),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isActive ? appPrimary : appMuted,
                fontSize: AppTypography.fontSizeXs,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavFab extends StatelessWidget {
  final VoidCallback onTap;

  const _NavFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: appPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: appBg, width: 4),
            boxShadow: [AppShadows.primary],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.plus, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section heading (no icon for Add Course)
// ---------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  final String label;

  const _SectionHeading({required this.label});

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

class _TextInput extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const _TextInput({
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
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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

class _TextAreaInput extends StatelessWidget {
  final String? hintText;
  final int minLines;

  const _TextAreaInput({
    this.hintText,
    this.minLines = 4,
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
        maxLines: null,
        minLines: minLines,
        style: const TextStyle(
          color: appText,
          fontSize: AppTypography.fontSizeMd,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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

class _SelectInput extends StatefulWidget {
  final List<String> items;
  final String hint;

  const _SelectInput({required this.items, required this.hint});

  @override
  State<_SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<_SelectInput> {
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
              color: Color(0xFF94A3B8),
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
          isExpanded: true,
          dropdownColor: appSurface,
          icon: const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 12,
            color: appMuted,
          ),
          style: const TextStyle(
            color: appText,
            fontSize: AppTypography.fontSizeMd,
          ),
          onChanged: (value) {
            setState(() => _selected = value);
          },
          items: widget.items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
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
                  color: label.isEmpty ? const Color(0xFF94A3B8) : appText,
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
