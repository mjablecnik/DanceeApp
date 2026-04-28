import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../i18n/translations.g.dart';
import '../events/pages/event_list/event_list_page.dart';
import '../events/pages/favorites_page.dart';

part 'layouts.g.dart';

// ============================================================================
// Shell Route
// ============================================================================

/// Shell route wrapping the main app pages with a shared bottom navigation bar.
///
/// Child routes (EventListRoute, FavoritesRoute) share the same [AppLayout]
/// scaffold, preserving state when switching between tabs.
@TypedShellRoute<AppLayoutRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<EventListRoute>(path: '/events'),
    TypedGoRoute<FavoritesRoute>(path: '/favorites'),
  ],
)
class AppLayoutRoute extends ShellRouteData {
  const AppLayoutRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppLayout(child: navigator);
  }
}

// ============================================================================
// App Layout
// ============================================================================

/// Main layout widget providing a bottom navigation bar shared across pages.
///
/// The [child] widget is the current page rendered by the shell route.
class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigationBar(
        currentPath: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

// ============================================================================
// Bottom Navigation Bar
// ============================================================================

/// Custom bottom navigation bar with Events and Favorites tabs.
///
/// Determines the active tab based on the current route path and navigates
/// using [GoRouter] when a tab is tapped.
class AppBottomNavigationBar extends StatelessWidget {
  final String currentPath;

  const AppBottomNavigationBar({super.key, required this.currentPath});

  int get _currentIndex {
    if (currentPath.startsWith('/favorites')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppBottomNavItem(
              icon: Icons.calendar_today,
              label: t.events,
              isActive: _currentIndex == 0,
              onTap: () => const EventListRoute().go(context),
            ),
            AppBottomNavItem(
              icon: Icons.favorite,
              label: t.favorites,
              isActive: _currentIndex == 1,
              onTap: () => const FavoritesRoute().go(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Bottom Navigation Item
// ============================================================================

/// A single item in the bottom navigation bar.
class AppBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AppBottomNavItem({
    super.key,
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
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
