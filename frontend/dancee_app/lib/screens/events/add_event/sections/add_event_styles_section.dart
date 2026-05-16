import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/add_event_form_components.dart';

class AddEventStylesSection extends StatefulWidget {
  const AddEventStylesSection({super.key});

  @override
  State<AddEventStylesSection> createState() => _AddEventStylesSectionState();
}

class _AddEventStylesSectionState extends State<AddEventStylesSection> {
  final Set<String> _selectedDances = {};

  static const List<String> _dances = [
    'Salsa',
    'Bachata',
    'Kizomba',
    'Zouk',
    'Semba',
    'Tango',
    'Swing',
    'Jiné',
  ];

  void _toggleDance(String dance) {
    setState(() {
      if (_selectedDances.contains(dance)) {
        _selectedDances.remove(dance);
      } else {
        _selectedDances.add(dance);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          children: _dances
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
}

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? appPrimary : appSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSelected ? appPrimary : appBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? appWhite : appText,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: AppTypography.fontWeightMedium,
          ),
        ),
      ),
    );
  }
}
