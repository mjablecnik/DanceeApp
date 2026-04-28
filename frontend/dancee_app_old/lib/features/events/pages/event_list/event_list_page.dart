import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_filter.dart';
import '../../logic/event_list.dart';
import 'sections.dart';

/// Route definition for the event list page.
///
/// Uses [NoTransitionPage] to disable page transition animations,
/// following the app's routing convention.
///
/// Note: The @TypedGoRoute annotation is defined in the shell route
/// (AppLayoutRoute in layouts.dart), not here.
class EventListRoute extends GoRouteData {
  const EventListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: EventListPage());
  }
}

/// Main page displaying a list of dance events grouped by date.
///
/// Uses [BlocBuilder] to reactively render UI based on [EventListCubit] state:
/// - initial: empty placeholder
/// - loading: centered loading indicator
/// - loaded: scrollable list with header, search/filters, and events by date
/// - error: error message with retry action
class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<EventListCubit, EventListState>(
          bloc: getIt<EventListCubit>(),
          builder: (context, listState) {
            return listState.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const LoadingSection(),
              loaded: (allEvents, _, __, ___) {
                return BlocBuilder<EventFilterCubit, EventFilterState>(
                  bloc: getIt<EventFilterCubit>(),
                  builder: (context, filterState) {
                    final filters = filterState.filters;
                    final activeFilterCount = getActiveFilterCount(filters);
                    final hasActiveFilters = activeFilterCount > 0;
                    final isEmpty = filterState.filteredEvents.isEmpty;

                    final emptyMessage = hasActiveFilters
                        ? t.eventFilters.noEventsMatch
                        : t.eventFilters.noEvents;

                    return CustomScrollView(
                      slivers: [
                        const EventListHeaderSection(),
                        const SliverToBoxAdapter(
                          child: SearchAndFiltersSection(),
                        ),
                        if (isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  emptyMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                            sliver: EventsByDateSection(
                              todayEvents: filterState.todayEvents,
                              tomorrowEvents: filterState.tomorrowEvents,
                              upcomingEvents: filterState.upcomingEvents,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              error: (message) => ErrorSection(message: message),
            );
          },
        ),
      ),
    );
  }
}
