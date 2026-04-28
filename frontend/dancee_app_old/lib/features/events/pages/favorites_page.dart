import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design/colors.dart';
import '../../../design/typography.dart';
import '../../../design/widgets.dart';
import '../../../core/service_locator.dart';
import '../../../i18n/translations.g.dart';
import '../data/entities.dart';
import '../logic/favorites.dart';
import '../../app/layouts.dart';
import 'event_detail/event_detail_page.dart';
import 'event_list/event_list_page.dart';
import 'event_list/components.dart';

// ============================================================================
// Route
// ============================================================================

/// Route definition for the favorites page.
///
/// Simple page (no folder) with [NoTransitionPage] to disable animations.
///
/// Note: The @TypedGoRoute annotation is defined in the shell route
/// (AppLayoutRoute in layouts.dart), not here.
class FavoritesRoute extends GoRouteData {
  const FavoritesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: FavoritesPage());
  }
}

// ============================================================================
// Page
// ============================================================================

/// Page displaying the user's favorite dance events.
///
/// Shows favorite events separated into upcoming and past tabs.
/// Supports toggling favorites and dismissing past events.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    getIt<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: getIt<FavoritesCubit>(),
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const FavoritesLoadingSection(),
              loaded: (upcomingEvents, pastEvents) {
                final totalEvents =
                    upcomingEvents.length + pastEvents.length;

                if (totalEvents == 0) {
                  return const FavoritesEmptySection();
                }

                return FavoritesListSection(
                  upcomingEvents: upcomingEvents,
                  pastEvents: pastEvents,
                  totalEvents: totalEvents,
                );
              },
              error: (message) => FavoritesErrorSection(message: message),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Loading Section
// ============================================================================

/// Loading indicator shown while favorites are being fetched.
class FavoritesLoadingSection extends StatelessWidget {
  const FavoritesLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingIndicator();
  }
}

// ============================================================================
// Error Section
// ============================================================================

/// Error state with message and retry button.
class FavoritesErrorSection extends StatelessWidget {
  final String message;

  const FavoritesErrorSection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppErrorMessage(
      message: message,
      onRetry: () => getIt<FavoritesCubit>().loadFavorites(),
      retryLabel: t.retry,
    );
  }
}

// ============================================================================
// Empty Section
// ============================================================================

/// Empty state shown when the user has no favorite events.
class FavoritesEmptySection extends StatelessWidget {
  const FavoritesEmptySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppEmptyState(
          icon: Icons.heart_broken,
          title: t.noFavoriteEvents,
          description: t.noFavoriteEventsDescription,
        ),
        BrowseEventsButton(
          onPressed: () => const EventListRoute().go(context),
        ),
      ],
    );
  }
}

/// Gradient circle icon for the empty favorites state.
class FavoritesEmptyIcon extends StatelessWidget {
  const FavoritesEmptyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[100]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.heart_broken,
        color: Colors.grey[400],
        size: 48,
      ),
    );
  }
}

/// Gradient button to navigate to the events list.
class BrowseEventsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BrowseEventsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                t.browseEvents,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Favorites List Section
// ============================================================================

/// Main content section showing favorite events grouped by upcoming and past.
class FavoritesListSection extends StatelessWidget {
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;
  final int totalEvents;

  const FavoritesListSection({
    super.key,
    required this.upcomingEvents,
    required this.pastEvents,
    required this.totalEvents,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        FavoritesHeaderSection(totalEvents: totalEvents),
        const SliverToBoxAdapter(child: SizedBox.shrink()),
        if (upcomingEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: FavoritesSectionHeader(title: t.upcomingEvents),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = upcomingEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      EventDetailRoute(id: event.id).push(context);
                    },
                    onFavoriteToggle: () {
                      getIt<FavoritesCubit>().toggleFavorite(event.id);
                    },
                  );
                },
                childCount: upcomingEvents.length,
              ),
            ),
          ),
        ],
        if (pastEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: FavoritesSectionHeader(title: t.pastEvents),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = pastEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      EventDetailRoute(id: event.id).push(context);
                    },
                    onFavoriteToggle: () {
                      getIt<FavoritesCubit>().removePastEvent(event.id);
                    },
                    enableDismiss: true,
                    onDismissed: () {
                      getIt<FavoritesCubit>().removePastEvent(event.id);
                    },
                  );
                },
                childCount: pastEvents.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// Header Section
// ============================================================================

/// Gradient header showing the favorites title and event count.
class FavoritesHeaderSection extends StatelessWidget {
  final int totalEvents;

  const FavoritesHeaderSection({super.key, required this.totalEvents});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      collapsedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.favoriteEvents,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.savedEvents(count: totalEvents),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Filter Section
// ============================================================================

/// Horizontal filter chips row on the gradient background.
class FavoritesFilterSection extends StatelessWidget {
  const FavoritesFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FavoritesFilterChip(label: t.all, isSelected: true),
              const SizedBox(width: 8),
              FavoritesFilterChip(label: t.today, isSelected: false),
              const SizedBox(width: 8),
              FavoritesFilterChip(label: t.thisWeek, isSelected: false),
              const SizedBox(width: 8),
              FavoritesFilterChip(label: t.thisMonth, isSelected: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single filter chip for the favorites filter row.
class FavoritesFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FavoritesFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, color: Color(0xFF6366F1), size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Section Header
// ============================================================================

/// Text header for upcoming/past event sections.
class FavoritesSectionHeader extends StatelessWidget {
  final String title;

  const FavoritesSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}
