import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../i18n/translations.g.dart';
import '../layouts.dart';
import '../../events/pages/event_list/event_list_page.dart';

/// Page displayed when the user navigates to an undefined route.
///
/// Used via [GoRouter.errorBuilder] — does not have its own route annotation.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                t.errors.pageNotFound,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.errors.pageNotFoundDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => const EventListRoute().go(context),
                child: Text(t.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
