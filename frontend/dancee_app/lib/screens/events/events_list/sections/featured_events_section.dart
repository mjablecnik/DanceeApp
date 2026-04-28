import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/entities/dance_style.dart';
import '../../../../data/entities/event.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/favorites_cubit.dart';
import '../../../../shared/components/snap_carousel.dart';
import '../../../../shared/utils/date_format.dart';
import '../components/featured_event_card.dart';
import 'upcoming_events_section.dart' show parentDanceNames;

class FeaturedEventsSection extends StatelessWidget {
  final List<Event> events;
  final List<DanceStyle> allDanceStyles;
  final Set<String> activeFilterCodes;
  final void Function(int eventId)? onEventTap;

  const FeaturedEventsSection({
    super.key,
    required this.events,
    this.allDanceStyles = const [],
    this.activeFilterCodes = const {},
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            t.events.featuredEvents,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize3xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SnapCarousel(
          itemCount: events.length,
          itemBuilder: (context, index, scale) {
            final event = events[index];
            final priceInfo = event.info
                .where((i) => i.type.name == 'price')
                .firstOrNull;
            final price = priceInfo?.value ?? '';
            final isFree = price.toLowerCase() == 'free' || price == '0';

            return FeaturedEventCard(
              imageUrl: event.imageUrl ?? '',
              title: event.title,
              date: formatDate(event.startTime),
              location: event.venue?.town ?? event.venue?.name ?? '',
              price: price.isEmpty ? t.events.detail.admission : price,
              isFree: isFree,
              isFavorited: event.isFavorited,
              tags: parentDanceNames(
                      event.dances, allDanceStyles,
                      activeFilterCodes: activeFilterCodes)
                  .map((tag) => EventTagData(
                      tag.name, tag.isFilterMatch ? appSuccess : appPrimary))
                  .toList(),
              onTap: () => onEventTap?.call(event.id),
              onFavoriteTap: () => context.read<FavoritesCubit>().toggleFavorite(
                    itemType: 'event',
                    itemId: event.id,
                  ),
            );
          },
        ),
      ],
    );
  }
}
