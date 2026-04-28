import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_routes.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/filter_cubit.dart';
import '../../../logic/cubits/settings_cubit.dart';
import '../../../logic/states/event_state.dart';
import '../../../shared/utils/auth_translations.dart';
import '../../../logic/states/filter_state.dart';
import '../../../shared/sections/dance_styles_filter_section.dart';
import '../../../shared/sections/duration_type_filter_section.dart';
import '../../../shared/utils/region_label.dart';
import 'sections/events_header_section.dart';
import 'sections/featured_events_section.dart';
import 'sections/upcoming_events_section.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appBg,
      child: Column(
        children: [
          BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              final regions = filterState.selectedRegions;
              final location = regions.isEmpty
                  ? t.events.filter.allCities
                  : regions.map(regionLabel).join(', ');
              return EventsHeaderSection(
                location: location,
                onLocationTap: () => const FilterLocationRoute().push(context),
                hasActiveFilters: filterState.hasActiveFilters,
                onClearFilters: () => context.read<FilterCubit>().clearAll(),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<EventCubit, EventState>(
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
                        const EventDurationTypeFilterSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        BlocBuilder<FilterCubit, FilterState>(
                          builder: (context, filterState) {
                            return DanceStylesFilterSection(
                              onShowAll: () => const FilterDanceRoute().push(context),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        FeaturedEventsSection(
                          events: loaded.featuredEvents,
                          allDanceStyles: context.read<FilterCubit>().allDanceStyles,
                          activeFilterCodes: context.read<FilterCubit>().state.selectedDanceStyles,
                          onEventTap: (id) => EventDetailRoute(id: id).push(context),
                        ),
                        if (loaded.featuredEvents.isNotEmpty)
                          const SizedBox(height: AppSpacing.xxxl),
                        UpcomingEventsSection(
                          events: loaded.filteredEvents,
                          allDanceStyles: context.read<FilterCubit>().allDanceStyles,
                          activeFilterCodes: context.read<FilterCubit>().state.selectedDanceStyles,
                          hasActiveFilters: context.read<FilterCubit>().state.hasActiveFilters,
                          onClearFilters: () => context.read<FilterCubit>().clearAll(),
                          onEventTap: (id) => EventDetailRoute(id: id).push(context),
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
                            final cubit = context.read<EventCubit>();
                            final lang = context.read<SettingsCubit>().currentLanguageCode;
                            cubit.loadEvents(lang);
                          },
                          child: Text(t.common.retry, style: const TextStyle(color: appPrimary)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
