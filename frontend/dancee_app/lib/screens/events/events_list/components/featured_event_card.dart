import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';

class EventTagData {
  final String label;
  final Color color;

  const EventTagData(this.label, this.color);
}

class FeaturedEventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String location;
  final String price;
  final bool isFree;
  final bool isFavorited;
  final List<EventTagData> tags;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const FeaturedEventCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.price,
    required this.isFree,
    required this.isFavorited,
    required this.tags,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: appCard,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            FeaturedEventCardImage(
              imageUrl: imageUrl,
              isFavorited: isFavorited,
              isFree: isFree,
              price: price,
              onFavoriteTap: onFavoriteTap,
            ),
            Expanded(
              child: FeaturedEventCardInfo(
                title: title,
                date: date,
                location: location,
                tags: tags,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedEventCardImage extends StatelessWidget {
  final String imageUrl;
  final bool isFavorited;
  final bool isFree;
  final String price;
  final VoidCallback? onFavoriteTap;

  const FeaturedEventCardImage({
    super.key,
    required this.imageUrl,
    required this.isFavorited,
    required this.isFree,
    required this.price,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.round)),
          child: AppCachedImage(
            imageUrl: imageUrl,
            height: 160,
            width: 280,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.round)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  appCard,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: GestureDetector(
            onTap: onFavoriteTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Center(
                child: FaIcon(
                  isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 14,
                  color: isFavorited ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFree
                  ? appSuccess.withValues(alpha: 0.9)
                  : appPrimary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturedEventCardInfo extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final List<EventTagData> tags;

  const FeaturedEventCardInfo({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                date,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
              ),
              const Spacer(),
              const FaIcon(FontAwesomeIcons.locationDot, size: 14, color: appPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                location,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 52),
            child: ClipRect(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      tag.label,
                      style: TextStyle(
                        color: tag.color,
                        fontSize: AppTypography.fontSizeXs,
                        fontWeight: AppTypography.fontWeightSemiBold,
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
    );
  }
}
