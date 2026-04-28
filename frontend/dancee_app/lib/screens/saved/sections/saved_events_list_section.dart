import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/course.dart';
import '../../../data/entities/event.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/course_cubit.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/favorites_cubit.dart';
import '../../../shared/utils/auth_translations.dart';
import '../../../shared/utils/date_format.dart';
import '../../courses/courses_list/components/course_list_card.dart';
import '../../events/events_list/components/featured_event_card.dart' show EventTagData;
import '../../events/events_list/components/upcoming_event_card.dart';

class SavedEventsListSection extends StatelessWidget {
  const SavedEventsListSection({super.key});

  String _buildCourseDateRange(Course course) {
    if (course.startDate != null && course.endDate != null) {
      return '${course.startDate} – ${course.endDate}';
    }
    if (course.startDate != null) return course.startDate!;
    if (course.scheduleDay != null) return course.scheduleDay!;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = context.watch<FavoritesCubit>().state;
    final eventState = context.watch<EventCubit>().state;
    final courseState = context.watch<CourseCubit>().state;

    return favoritesState.map(
      initial: (_) => const _SavedLoadingWidget(),
      loading: (_) => const _SavedLoadingWidget(),
      loaded: (_) {
        final allEvents = eventState.maybeMap(
          loaded: (s) => s.allEvents,
          orElse: () => <Event>[],
        );
        final allCourses = courseState.maybeMap(
          loaded: (s) => s.allCourses,
          orElse: () => <Course>[],
        );

        final favoritesCubit = context.read<FavoritesCubit>();
        final resolvedFavorites =
            favoritesCubit.getResolvedFavorites(allEvents, allCourses);

        if (resolvedFavorites.isEmpty) {
          return const _SavedEmptyWidget();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              for (int i = 0; i < resolvedFavorites.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                FavoriteItemCard(
                  favItem: resolvedFavorites[i],
                  buildCourseDateRange: _buildCourseDateRange,
                ),
              ],
            ],
          ),
        );
      },
      error: (s) => _SavedErrorWidget(message: s.message),
    );
  }
}

class FavoriteItemCard extends StatelessWidget {
  final FavoriteItem favItem;
  final String Function(Course) buildCourseDateRange;

  const FavoriteItemCard({
    super.key,
    required this.favItem,
    required this.buildCourseDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesCubit = context.read<FavoritesCubit>();

    if (favItem.itemType == 'event') {
      final event = favItem.item as Event;
      return UpcomingEventCard(
        imageUrl: event.imageUrl ?? '',
        title: event.title,
        location: event.venue?.town ?? event.venue?.name ?? '',
        date: formatDate(event.startTime),
        tags: event.dances.map((d) => EventTagData(d, appPrimary)).toList(),
        isFavorited: event.isFavorited,
        onFavoriteTap: () => favoritesCubit.toggleFavorite(
          itemType: 'event',
          itemId: event.id,
        ),
        onTap: () => EventDetailRoute(id: event.id).push(context),
      );
    } else {
      final course = favItem.item as Course;
      return CourseListCard(
        imageUrl: course.imageUrl ?? '',
        title: course.title,
        instructor: course.instructorName ?? '',
        dateRange: buildCourseDateRange(course),
        tags: course.dances.map((d) => CourseTag(d, appPrimary)).toList(),
        price: course.price ?? '',
        isFavorited: course.isFavorited,
        onFavoriteTap: () => favoritesCubit.toggleFavorite(
          itemType: 'course',
          itemId: course.id,
        ),
        onTap: () => CourseDetailRoute(id: course.id).push(context),
      );
    }
  }
}

class _SavedLoadingWidget extends StatelessWidget {
  const _SavedLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _SavedEmptyWidget extends StatelessWidget {
  const _SavedEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.heart,
            size: 48,
            color: appMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.saved.emptyTitle,
            style: const TextStyle(
              color: appText,
              fontSize: AppTypography.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.saved.emptySubtitle,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeMd,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavedErrorWidget extends StatelessWidget {
  final String message;

  const _SavedErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: appMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              resolveApiErrorKey(message),
              style: const TextStyle(
                color: appMuted,
                fontSize: AppTypography.fontSizeMd,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.read<FavoritesCubit>().loadFavorites(),
              child: Text(t.common.retry),
            ),
          ],
        ),
      ),
    );
  }
}
