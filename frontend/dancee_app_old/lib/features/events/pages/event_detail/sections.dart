import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import 'components.dart';

// ============================================================================
// EventDetailHeaderSection (pinned SliverAppBar)
// ============================================================================

/// Pinned SliverAppBar with gradient background, back button, and title.
/// Stays visible during scrolling, matching the event list header pattern.
class EventDetailHeaderSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const EventDetailHeaderSection({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF6366F1),
      toolbarHeight: 56,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                HeaderActionButton(
                  icon: Icons.arrow_back,
                  onPressed: onBackPressed,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      t.eventDetail.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// QuickActionsSection (scrollable, scrolls away like search/filters)
// ============================================================================

/// Quick action buttons (favorite, map) with gradient background.
/// Scrolls away during scrolling, similar to SearchAndFiltersSection
/// on the event list page.
class QuickActionsSection extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onMapPressed;

  const QuickActionsSection({
    super.key,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onMapPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: QuickActionButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              label: t.eventDetail.favorite,
              onPressed: onFavoritePressed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: QuickActionButton(
              icon: Icons.map,
              label: t.eventDetail.map,
              onPressed: onMapPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EventTitleSection
// ============================================================================

/// Displays event title, organizer name, badge, and date/time info card.
class EventTitleSection extends StatelessWidget {
  final Event event;

  const EventTitleSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 16,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.venue.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (event.badge != null) EventBadge(badge: event.badge!),
          ],
        ),
        const SizedBox(height: 16),
        DateTimeInfoCard(event: event),
      ],
    );
  }
}

// ============================================================================
// DanceStylesSection
// ============================================================================

/// Displays dance style tags with colorful gradient chips.
class DanceStylesSection extends StatelessWidget {
  final List<String> dances;

  const DanceStylesSection({super.key, required this.dances});

  @override
  Widget build(BuildContext context) {
    if (dances.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.queue_music,
          title: t.eventDetail.dancesAtEvent,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dances.map((dance) => DanceStyleChip(dance: dance)).toList(),
        ),
      ],
    );
  }
}

// ============================================================================
// EventVenueSection
// ============================================================================

/// Displays venue information with name, description, address, and
/// a navigate button.
class EventVenueSection extends StatelessWidget {
  final Venue venue;
  final VoidCallback onNavigatePressed;

  const EventVenueSection({
    super.key,
    required this.venue,
    required this.onNavigatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.location_on,
          title: t.eventDetail.venue,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[50]!, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (venue.description.isNotEmpty)
                          Text(
                            venue.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.pin_drop,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.eventDetail.address}:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          venue.address.street,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        Text(
                          '${venue.address.postalCode} ${venue.address.city}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onNavigatePressed,
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text(
                    t.eventDetail.navigateToVenue,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ============================================================================
// EventOrganizerSection
// ============================================================================

/// Displays the event organizer in a styled card.
class EventOrganizerSection extends StatelessWidget {
  final String organizer;

  const EventOrganizerSection({super.key, required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.person,
          title: t.eventDetail.organizer,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[50]!, Colors.pink[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  organizer,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EventDescriptionSection
// ============================================================================

/// Displays the event description text in a styled card.
class EventDescriptionSection extends StatelessWidget {
  final String description;

  const EventDescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.subject,
          title: t.eventDetail.description,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[50]!, Colors.blueGrey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 2),
          ),
          child: Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EventInfoSection
// ============================================================================

/// Displays additional event information (prices, URLs, etc.) as info cards.
class EventInfoSection extends StatelessWidget {
  final List<EventInfo> info;
  final void Function(String url)? onUrlTapped;

  const EventInfoSection({
    super.key,
    required this.info,
    this.onUrlTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.info_outline,
          title: t.eventDetail.additionalInfo,
        ),
        const SizedBox(height: 12),
        ...info.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EventInfoCard(
                info: item,
                onTap: item.type == EventInfoType.url
                    ? () => onUrlTapped?.call(item.value)
                    : null,
              ),
            )),
      ],
    );
  }
}

// ============================================================================
// EventPartsSection
// ============================================================================

/// Displays event parts (workshops, parties, open lessons) as timeline cards.
class EventPartsSection extends StatelessWidget {
  final List<EventPart> parts;

  const EventPartsSection({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          icon: Icons.schedule,
          title: t.eventDetail.eventParts,
        ),
        const SizedBox(height: 12),
        ...parts.map((part) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EventPartCard(part: part),
            )),
      ],
    );
  }
}

// ============================================================================
// EventSourceSection
// ============================================================================

/// Tappable link to the original event source (e.g. Facebook).
/// Only shown when [sourceUrl] is not null.
class EventSourceSection extends StatelessWidget {
  final String sourceUrl;
  final VoidCallback onTap;

  const EventSourceSection({
    super.key,
    required this.sourceUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[200]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.launch, size: 20, color: Colors.indigo[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.eventDetail.originalSource,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sourceUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.indigo[600],
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.indigo[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 16, color: Colors.indigo[600]),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EventNotFoundSection
// ============================================================================

/// Displayed when the event cannot be found by ID.
class EventNotFoundSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const EventNotFoundSection({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_busy,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 24),
              Text(
                t.eventDetail.eventNotFound,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.eventDetail.eventNotFoundDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onBackPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  t.eventDetail.backToEvents,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
