import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/components/app_cached_image.dart';

class CourseTag {
  final String label;
  final Color color;

  const CourseTag(this.label, this.color);
}

class CourseListCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String instructor;
  final String dateRange;
  final String? time;
  final List<CourseTag> tags;
  final String price;
  final bool isFavorited;
  final bool isEditorMode;
  final bool isReviewed;
  final bool isPublished;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const CourseListCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.instructor,
    required this.dateRange,
    this.time,
    required this.tags,
    required this.price,
    this.isFavorited = false,
    this.isEditorMode = false,
    this.isReviewed = false,
    this.isPublished = true,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(
            color: isEditorMode && !isPublished
                ? appError.withValues(alpha: 0.4)
                : appBorder,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseCardTopRow(
              title: title,
              instructor: instructor,
              imageUrl: imageUrl,
            ),
            const SizedBox(height: AppSpacing.md),
            CourseCardDateRow(dateRange: dateRange, time: time),
            const SizedBox(height: AppSpacing.sm),
            CourseCardBottomRow(
              tags: tags,
              price: price,
              isFavorited: isFavorited,
              isEditorMode: isEditorMode,
              isReviewed: isReviewed,
              isPublished: isPublished,
              onFavoriteTap: onFavoriteTap,
            ),
          ],
        ),
      ),
    );

    if (isEditorMode && !isPublished) {
      return Opacity(opacity: 0.65, child: card);
    }
    return card;
  }
}

class CourseCardTopRow extends StatelessWidget {
  final String title;
  final String instructor;
  final String imageUrl;

  const CourseCardTopRow({
    super.key,
    required this.title,
    required this.instructor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: FontWeight.bold,
                  height: AppLineHeights.tight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.userTie, size: 12, color: appPrimary),
                  const SizedBox(width: AppSpacing.sm - 2),
                  Flexible(
                    child: Text(
                      instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AppCachedImage(
            imageUrl: imageUrl,
            width: AppSizes.avatarLg,
            height: AppSizes.avatarLg,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class CourseCardDateRow extends StatelessWidget {
  final String dateRange;
  final String? time;

  const CourseCardDateRow({
    super.key,
    required this.dateRange,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FaIcon(FontAwesomeIcons.calendar, size: 12, color: appMuted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          dateRange,
          style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
        ),
        if (time != null && time!.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.lg),
          const FaIcon(FontAwesomeIcons.clock, size: 12, color: appMuted),
          const SizedBox(width: AppSpacing.sm),
          Text(
            time!,
            style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
          ),
        ],
      ],
    );
  }
}

class CourseCardBottomRow extends StatelessWidget {
  final List<CourseTag> tags;
  final String price;
  final bool isFavorited;
  final bool isEditorMode;
  final bool isReviewed;
  final bool isPublished;
  final VoidCallback? onFavoriteTap;

  const CourseCardBottomRow({
    super.key,
    required this.tags,
    required this.price,
    required this.isFavorited,
    this.isEditorMode = false,
    this.isReviewed = false,
    this.isPublished = true,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ...tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: appCard,
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
                  )),
              if (isEditorMode) ...[
                _StatusBadge(
                  label: isPublished ? 'pub' : 'unpub',
                  color: isPublished ? appSuccess : appError,
                ),
                _StatusBadge(
                  label: isReviewed ? 'rev' : '!rev',
                  color: isReviewed ? appSuccess : appWarning,
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            Text(
              price,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (isEditorMode)
              FaIcon(
                isReviewed
                    ? FontAwesomeIcons.solidSquareCheck
                    : FontAwesomeIcons.square,
                size: AppIconSizes.xs,
                color: isReviewed ? appSuccess : appMuted,
              )
            else if (onFavoriteTap != null)
              GestureDetector(
                onTap: onFavoriteTap,
                child: FaIcon(
                  isFavorited
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  size: AppIconSizes.xs,
                  color: isFavorited ? Colors.red : appMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: AppTypography.fontWeightBold,
        ),
      ),
    );
  }
}
