import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/widgets.dart';
import '../../app/layouts.dart';
import '../../events/pages/event_list/event_list_page.dart';

part 'initial_page.g.dart';

/// Route for the app entry point that redirects to the events page.
@TypedGoRoute<InitialRoute>(path: '/')
class InitialRoute extends GoRouteData {
  const InitialRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: InitialPage());
  }
}

/// App entry point page that immediately redirects to /events.
class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to events on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        const EventListRoute().go(context);
      }
    });

    return const Scaffold(
      body: AppLoadingIndicator(),
    );
  }
}
