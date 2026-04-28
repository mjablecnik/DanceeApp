import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';

class EventsHeaderSection extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  const EventsHeaderSection({
    super.key,
    required this.location,
    this.onLocationTap,
    this.hasActiveFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppSpacing.md,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.events.location,
                    style: const TextStyle(
                      color: appMuted,
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.locationDot, color: appPrimary, size: 16),
                        const SizedBox(width: AppSpacing.xs + 2),
                        Flexible(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: appText,
                              fontSize: AppTypography.fontSize2xl,
                              fontWeight: AppTypography.fontWeightSemiBold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        const FaIcon(FontAwesomeIcons.chevronDown, color: appMuted, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasActiveFilters)
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: appPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.filterCircleXmark, size: 14, color: appPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        t.common.clear,
                        style: const TextStyle(
                          color: appPrimary,
                          fontSize: AppTypography.fontSizeMd,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
