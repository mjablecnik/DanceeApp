import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';
import 'featured_event_card.dart' show EventTagData;

class UpcomingEventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final List<EventTagData> tags;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const UpcomingEventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.tags,
    required this.isFavorited,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side — image + date below
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: AppCachedImage(
                          imageUrl: imageUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 96,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: appCard,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          date,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: appText,
                            fontSize: AppTypography.fontSizeSm,
                            fontWeight: AppTypography.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Info column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: appText,
                              fontSize: AppTypography.fontSizeXl,
                              fontWeight: AppTypography.fontWeightBold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Location
                          Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.locationDot,
                                  size: 12, color: appPrimary),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    color: appMuted,
                                    fontSize: AppTypography.fontSizeSm,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Spacer pushes tags to bottom
                          const Spacer(),
                          // Dance style tags — clipped to 2 lines
                          if (tags.isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 52),
                              child: ClipRect(
                                child: Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: tags
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: appCard,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Text(
                                        tag.label,
                                        style: TextStyle(
                                          color: tag.color,
                                          fontSize: AppTypography.fontSizeXs,
                                          fontWeight:
                                              AppTypography.fontWeightSemiBold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Heart button — absolute top right
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Center(
                      child: FaIcon(
                        isFavorited
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        size: 14,
                        color: isFavorited ? Colors.red : appMuted,
                      ),
                    ),
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
