import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_routes.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/entities/course.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/auth_cubit.dart';
import '../../../../logic/cubits/course_cubit.dart';
import '../../../../logic/cubits/favorites_cubit.dart';
import '../../../../logic/cubits/filter_cubit.dart';
import '../../../../logic/cubits/settings_cubit.dart';
import '../../../../logic/states/course_state.dart';
import '../../../../shared/sections/dance_styles_filter_section.dart';
import '../../../../shared/utils/auth_translations.dart';
import '../../../../shared/utils/dance_names.dart';
import '../../../../shared/utils/date_format.dart';
import '../components/course_list_card.dart';

String _courseDisplayDate(Course course) {
  return formatDateRange(course.startDate, course.endDate);
}

String? _courseDisplayTime(Course course) {
  final isSameDate = course.startDate != null &&
      course.endDate != null &&
      course.startDate == course.endDate;
  if (isSameDate && course.scheduleTime != null && course.scheduleTime!.isNotEmpty) {
    return course.scheduleTime;
  }
  return null;
}

class CoursesListSection extends StatelessWidget {
  const CoursesListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => const SizedBox.shrink(),
          loading: (_) => const Center(
            child: CircularProgressIndicator(color: appPrimary),
          ),
          loaded: (loaded) => SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16, top: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DanceStylesFilterSection(
                  onShowAll: () => const FilterDanceRoute(source: 'courses').push(context),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                _CoursesListContent(
                  courses: loaded.filteredCourses,
                  hasActiveFilters: context.read<FilterCubit>().state.hasActiveFilters,
                  onClearFilters: () => context.read<FilterCubit>().clearAll(),
                ),
              ],
            ),
          ),
          error: (err) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  resolveApiErrorKey(err.message),
                  style: const TextStyle(color: appMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: () {
                    final lang = context.read<SettingsCubit>().currentLanguageCode;
                    context.read<CourseCubit>().loadCourses(lang);
                  },
                  child: Text(
                    t.common.retry,
                    style: const TextStyle(color: appPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoursesListContent extends StatelessWidget {
  final List<Course> courses;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  const _CoursesListContent({
    required this.courses,
    this.hasActiveFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t.courses.allCourses,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm - 2,
                ),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 14, color: appText),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      t.common.date,
                      style: const TextStyle(
                        color: appText,
                        fontSize: AppTypography.fontSizeMd,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (courses.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasActiveFilters
                          ? t.courses.noCoursesForFilter
                          : t.courses.noCoursesFound,
                      style: const TextStyle(color: appMuted),
                      textAlign: TextAlign.center,
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                        onPressed: onClearFilters,
                        child: Text(
                          t.common.clearFilters,
                          style: const TextStyle(
                            color: appPrimary,
                            fontSize: AppTypography.fontSizeMd,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        else
          Builder(
            builder: (context) {
              final isAuthenticated = context.read<AuthCubit>().state.maybeMap(
                    authenticated: (_) => true,
                    orElse: () => false,
                  );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: courses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final course = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const SizedBox(height: AppSpacing.md),
                        CourseListCard(
                          imageUrl: course.imageUrl ?? '',
                          title: course.title,
                          instructor: course.instructorName ?? '',
                          dateRange: _courseDisplayDate(course),
                          time: _courseDisplayTime(course),
                          tags: parentDanceNames(
                            course.dances,
                            context.read<FilterCubit>().allDanceStyles,
                            activeFilterCodes:
                                context.read<FilterCubit>().state.selectedDanceStyles,
                          )
                              .map((tag) => CourseTag(
                                    tag.name,
                                    tag.isFilterMatch ? appSuccess : appPrimary,
                                  ))
                              .toList(),
                          price: course.price ?? '',
                          isFavorited: course.isFavorited,
                          onTap: () => CourseDetailRoute(id: course.id).push(context),
                          onFavoriteTap: isAuthenticated
                              ? () => context.read<FavoritesCubit>().toggleFavorite(
                                    itemType: 'course',
                                    itemId: course.id,
                                  )
                              : null,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }
}
