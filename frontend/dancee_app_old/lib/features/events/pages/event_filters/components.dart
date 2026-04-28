import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../i18n/translations.g.dart';

// ============================================================================
// HeaderIconButton
// ============================================================================

/// Circular icon button used in the header.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ============================================================================
// DanceTypeOption
// ============================================================================

/// A single dance type checkbox option row.
class DanceTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const DanceTypeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF2FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LocationOption
// ============================================================================

/// A single location checkbox-style option row.
class LocationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const LocationOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DateInputField
// ============================================================================

/// A labeled date input field with calendar icon and optional selected date.
class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const DateInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = value != null
        ? DateFormat('dd.MM.yyyy').format(value!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value != null
                    ? const Color(0xFF6366F1)
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.calendar_today,
                    color: value != null
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade400,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatted ?? t.eventFilters.datePlaceholder,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: value != null
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DateQuickSelectButton
// ============================================================================

/// A quick-select button for common date ranges (today, tomorrow, etc.).
class DateQuickSelectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final VoidCallback onPressed;

  const DateQuickSelectButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.gradientColors,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ClearAllButton
// ============================================================================

/// "Clear all" button in the footer.
class ClearAllButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearAllButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, size: 16),
            const SizedBox(width: 6),
            Text(
              t.eventFilters.clearAll,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ApplyFiltersButton
// ============================================================================

/// "Apply filters" gradient button in the footer.
class ApplyFiltersButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyFiltersButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              t.eventFilters.applyFilters,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EmptyOptionMessage
// ============================================================================

/// Small message shown when there are no options to display.
class EmptyOptionMessage extends StatelessWidget {
  final String message;

  const EmptyOptionMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ============================================================================
// Dance type icon/color helpers
// ============================================================================

IconData danceTypeIcon(String danceType) {
  switch (danceType.toLowerCase()) {
    case 'salsa':
      return Icons.local_fire_department;
    case 'bachata':
      return Icons.favorite;
    case 'kizomba':
      return Icons.nightlight_round;
    case 'zouk':
      return Icons.water;
    case 'tango':
      return Icons.local_florist;
    case 'swing':
      return Icons.face;
    case 'forró':
    case 'forro':
      return Icons.album;
    case 'merengue':
      return Icons.wb_sunny;
    case 'reggaeton':
      return Icons.bolt;
    case 'urban kiz':
      return Icons.location_city;
    case 'lindy hop':
      return Icons.album;
    default:
      return Icons.music_note;
  }
}

Color danceTypeColor(String danceType) {
  switch (danceType.toLowerCase()) {
    case 'salsa':
      return Colors.red;
    case 'bachata':
      return Colors.pink;
    case 'kizomba':
      return Colors.purple;
    case 'zouk':
      return Colors.teal;
    case 'tango':
      return Colors.blueGrey;
    case 'swing':
      return Colors.orange;
    case 'forró':
    case 'forro':
      return Colors.green;
    case 'merengue':
      return Colors.amber;
    case 'reggaeton':
      return Colors.lime;
    case 'urban kiz':
      return Colors.deepPurple;
    case 'lindy hop':
      return Colors.yellow;
    default:
      return const Color(0xFF6366F1);
  }
}
