import 'package:dancee_app/screens/events/events_list/components/dance_style_chips_row.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../i18n/strings.g.dart';

class DanceStylesFilterSection extends StatelessWidget {

  /// When provided, shows a large bold heading with a "Zobrazit vše" link.
  /// When null, shows a compact uppercase muted label instead.
  final VoidCallback? onShowAll;

  /// Determines which items to count for filtering visible styles:
  /// 'events', 'courses', or 'both' (default).
  final String source;

  const DanceStylesFilterSection({
    super.key,
    this.onShowAll,
    this.source = 'both',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DanceStylesFilterHeader(onShowAll: onShowAll),
        SizedBox(height: onShowAll != null ? AppSpacing.lg : AppSpacing.md),
        DanceStyleChipsRow(source: source),
      ],
    );
  }
}

class DanceStylesFilterHeader extends StatelessWidget {
  final VoidCallback? onShowAll;

  const DanceStylesFilterHeader({super.key, this.onShowAll});

  @override
  Widget build(BuildContext context) {
    if (onShowAll != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t.events.danceStyles,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            GestureDetector(
              onTap: onShowAll,
              child: Text(
                t.common.showAll,
                style: const TextStyle(
                  color: appMuted,
                  fontSize: AppTypography.fontSizeMd,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        t.events.danceStylesLabel,
        style: const TextStyle(
          color: appMuted,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightSemiBold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
