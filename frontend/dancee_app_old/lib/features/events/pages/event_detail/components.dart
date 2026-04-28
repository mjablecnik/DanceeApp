import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';

// ============================================================================
// HeaderActionButton
// ============================================================================

/// Translucent circular button used in the gradient header (back, share).
class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const HeaderActionButton({
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
// QuickActionButton
// ============================================================================

/// Translucent action button with icon and label (favorite, map).
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
// EventBadge
// ============================================================================

/// Colored badge showing event status (e.g., "TODAY", "IN 2 DAYS").
class EventBadge extends StatelessWidget {
  final String badge;

  const EventBadge({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getBadgeGradient(badge),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        badge.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Color> _getBadgeGradient(String badge) {
    switch (badge.toLowerCase()) {
      case 'today':
        return [const Color(0xFF22C55E), const Color(0xFF10B981)];
      case 'in 2 days':
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      default:
        return [const Color(0xFF94A3B8), const Color(0xFF64748B)];
    }
  }
}

// ============================================================================
// DateTimeInfoCard
// ============================================================================

/// Styled card showing event date and time with a music icon.
class DateTimeInfoCard extends StatelessWidget {
  final Event event;

  const DateTimeInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(event.startTime);
    final timeStr = formatTimeRange(event.startTime, event.endTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SectionTitle
// ============================================================================

/// Reusable section title with icon and text.
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DanceStyleChip
// ============================================================================

/// Colorful gradient chip for a dance style.
class DanceStyleChip extends StatelessWidget {
  final String dance;

  const DanceStyleChip({super.key, required this.dance});

  @override
  Widget build(BuildContext context) {
    final colors = _getDanceGradient(dance);
    final icon = _getDanceIcon(dance);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            dance,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EventInfoCard
// ============================================================================

/// Card displaying a single piece of event info (price, text, url).
///
/// When [onTap] is provided, the card becomes tappable (used for URL-type items).
/// URL-type cards use a vertical layout with truncated URL to prevent overflow.
class EventInfoCard extends StatelessWidget {
  final EventInfo info;
  final VoidCallback? onTap;

  const EventInfoCard({super.key, required this.info, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _getInfoCardColors(info.type);
    final iconColor = _getInfoIconColor(info.type);

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInfoBorderColor(info.type),
          width: 2,
        ),
      ),
      child: info.type == EventInfoType.url
          ? UrlInfoCardContent(info: info, iconColor: iconColor)
          : DefaultInfoCardContent(info: info, iconColor: iconColor),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Default layout for price/text info cards — key left, value right.
class DefaultInfoCardContent extends StatelessWidget {
  final EventInfo info;
  final Color iconColor;

  const DefaultInfoCardContent({
    required this.info,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_getInfoIcon(info.type), size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            info.key,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          info.value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}

/// Vertical layout for URL info cards — label on top, truncated URL below.
class UrlInfoCardContent extends StatelessWidget {
  final EventInfo info;
  final Color iconColor;

  const UrlInfoCardContent({
    required this.info,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_getInfoIcon(info.type), size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.key,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: iconColor,
                  decoration: TextDecoration.underline,
                  decorationColor: iconColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.open_in_new, size: 16, color: iconColor),
      ],
    );
  }
}

// ============================================================================
// EventPartCard
// ============================================================================

/// Card displaying a single event part (workshop, party, open lesson).
class EventPartCard extends StatelessWidget {
  final EventPart part;

  const EventPartCard({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    final colors = _getPartColors(part.type);
    final timeStr = formatTimeRange(part.startTime, part.endTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPartBorderColor(part.type),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPartIcon(part.type),
                size: 18,
                color: _getPartIconColor(part.type),
              ),
              const SizedBox(width: 8),
              Text(
                getPartTypeLabel(part.type),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            part.name,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          if (part.lectors != null && part.lectors!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.school, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    part.lectors!.join(', '),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (part.djs != null && part.djs!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.headphones, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    part.djs!.join(', '),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Helper functions
// ============================================================================

String formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (eventDate == today) {
    return t.today;
  } else if (eventDate == today.add(const Duration(days: 1))) {
    return t.tomorrow;
  } else {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dateTime.day}. ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

String formatTimeRange(DateTime start, DateTime? end) {
  final startHour = start.hour.toString().padLeft(2, '0');
  final startMinute = start.minute.toString().padLeft(2, '0');
  if (end == null) return '$startHour:$startMinute';
  final endHour = end.hour.toString().padLeft(2, '0');
  final endMinute = end.minute.toString().padLeft(2, '0');
  return '$startHour:$startMinute - $endHour:$endMinute';
}

List<Color> _getDanceGradient(String dance) {
  switch (dance.toLowerCase()) {
    case 'salsa':
      return [const Color(0xFFEF4444), const Color(0xFFF97316)];
    case 'bachata':
      return [const Color(0xFFEC4899), const Color(0xFFF43F5E)];
    case 'kizomba':
      return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
    case 'zouk':
    case 'brazilian zouk':
      return [const Color(0xFF14B8A6), const Color(0xFF06B6D4)];
    case 'merengue':
      return [const Color(0xFFF59E0B), const Color(0xFFEAB308)];
    default:
      return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
  }
}

IconData _getDanceIcon(String dance) {
  switch (dance.toLowerCase()) {
    case 'salsa':
      return Icons.local_fire_department;
    case 'bachata':
      return Icons.favorite;
    case 'kizomba':
      return Icons.nightlight_round;
    case 'zouk':
    case 'brazilian zouk':
      return Icons.water_drop;
    case 'merengue':
      return Icons.wb_sunny;
    default:
      return Icons.music_note;
  }
}

List<Color> _getInfoCardColors(EventInfoType type) {
  switch (type) {
    case EventInfoType.price:
      return [Colors.green[50]!, Colors.teal[50]!];
    case EventInfoType.url:
      return [Colors.blue[50]!, Colors.indigo[50]!];
    case EventInfoType.text:
      return [Colors.grey[50]!, Colors.blueGrey[50]!];
  }
}

Color _getInfoBorderColor(EventInfoType type) {
  switch (type) {
    case EventInfoType.price:
      return Colors.green[200]!;
    case EventInfoType.url:
      return Colors.blue[200]!;
    case EventInfoType.text:
      return Colors.grey[200]!;
  }
}

IconData _getInfoIcon(EventInfoType type) {
  switch (type) {
    case EventInfoType.price:
      return Icons.confirmation_number;
    case EventInfoType.url:
      return Icons.link;
    case EventInfoType.text:
      return Icons.info_outline;
  }
}

Color _getInfoIconColor(EventInfoType type) {
  switch (type) {
    case EventInfoType.price:
      return Colors.green[600]!;
    case EventInfoType.url:
      return Colors.blue[600]!;
    case EventInfoType.text:
      return Colors.grey[600]!;
  }
}

List<Color> _getPartColors(EventPartType type) {
  switch (type) {
    case EventPartType.workshop:
      return [Colors.purple[50]!, Colors.pink[50]!];
    case EventPartType.party:
      return [Colors.orange[50]!, Colors.red[50]!];
    case EventPartType.openLesson:
      return [Colors.cyan[50]!, Colors.blue[50]!];
  }
}

Color _getPartBorderColor(EventPartType type) {
  switch (type) {
    case EventPartType.workshop:
      return Colors.purple[200]!;
    case EventPartType.party:
      return Colors.orange[200]!;
    case EventPartType.openLesson:
      return Colors.cyan[200]!;
  }
}

IconData _getPartIcon(EventPartType type) {
  switch (type) {
    case EventPartType.workshop:
      return Icons.school;
    case EventPartType.party:
      return Icons.celebration;
    case EventPartType.openLesson:
      return Icons.menu_book;
  }
}

Color _getPartIconColor(EventPartType type) {
  switch (type) {
    case EventPartType.workshop:
      return Colors.purple[600]!;
    case EventPartType.party:
      return Colors.orange[600]!;
    case EventPartType.openLesson:
      return Colors.cyan[600]!;
  }
}

String getPartTypeLabel(EventPartType type) {
  switch (type) {
    case EventPartType.workshop:
      return t.eventDetail.workshop;
    case EventPartType.party:
      return t.eventDetail.party;
    case EventPartType.openLesson:
      return t.eventDetail.openLesson;
  }
}
