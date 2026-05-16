import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';

enum NavTab { events, courses, saved, profile }

class AppBottomNavBar extends StatelessWidget {
  final NavTab currentTab;

  const AppBottomNavBar({super.key, required this.currentTab});

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
          _NavItem(
            icon: FontAwesomeIcons.calendarDays,
            label: t.nav.events,
            isActive: currentTab == NavTab.events,
            onTap: () => const EventsRoute().go(context),
          ),
          _NavItem(
            icon: FontAwesomeIcons.bookOpen,
            label: t.nav.courses,
            isActive: currentTab == NavTab.courses,
            onTap: () => const CoursesRoute().go(context),
          ),
          _NavFab(
            onTap: () {
              if (currentTab == NavTab.courses) {
                const AddCourseRoute().push(context);
              } else {
                const AddEventRoute().push(context);
              }
            },
          ),
          _NavItem(
            icon: FontAwesomeIcons.heart,
            label: t.nav.saved,
            isActive: currentTab == NavTab.saved,
            onTap: () => const SavedRoute().go(context),
          ),
          _NavItem(
            icon: FontAwesomeIcons.user,
            label: t.nav.profile,
            isActive: currentTab == NavTab.profile,
            onTap: () => const ProfileRoute().go(context),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? appPrimary : appMuted;
    return GestureDetector(
      onTap: isActive ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 22, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
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
            border: Border.all(color: appBg, width: AppBorders.thick),
            boxShadow: [AppShadows.primary],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.plus, size: AppIconSizes.sm, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
