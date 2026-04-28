# Dancee App

A Flutter mobile and web application for discovering and browsing dance events in Czech Republic.

## Features

- Multi-language support (English, Czech, Spanish)
- Event discovery with search and filtering
- Event detail pages with venue, schedule, and dance style info
- Favorites management
- Clean architecture with feature-based organization
- Type-safe routing with go_router
- Immutable state management with Cubit + freezed

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- [Task](https://taskfile.dev/) runner

### Installation

1. Clone the repository and navigate to the project:
   ```bash
   cd frontend/dancee_app_old
   ```

2. Install dependencies:
   ```bash
   task get-deps
   ```

3. Copy the config template and fill in your values:
   ```bash
   cp lib/config.example.dart lib/config.dart
   ```

4. Generate code (routes, freezed classes, translations):
   ```bash
   task build-runner
   task slang
   ```

5. Run the app:
   ```bash
   task run-web       # Web (localhost:3000)
   task run-android   # Android
   task run-ios       # iOS
   ```

## Architecture

The app follows clean architecture with feature-based organization. Each feature is self-contained with its own data, logic, and presentation layers.

### Project Structure

```
lib/
├── core/                           # Shared utilities and configuration
│   ├── service_locator.dart        # Dependency injection (get_it)
│   ├── clients.dart                # API client (Dio wrapper)
│   ├── config.dart                 # Public config (imports from lib/config.dart)
│   ├── exceptions.dart             # Custom exceptions (ApiException)
│   ├── auth_redirect.dart          # Authentication redirect logic
│   └── routing.dart                # GoRouter configuration
├── design/                         # Shared design system
│   ├── widgets.dart                # Shared widgets (loading, error, empty state)
│   ├── colors.dart                 # Color constants (AppColors)
│   ├── typography.dart             # Text styles (AppTypography)
│   └── theme.dart                  # App theme (AppTheme)
├── features/                       # Feature modules
│   ├── app/                        # Core app (layouts, error pages)
│   ├── auth/                       # Authentication (login, register)
│   ├── events/                     # Event management (list, detail, filters, favorites)
│   └── settings/                   # User settings
├── i18n/                           # Translations (slang_flutter)
├── config.dart                     # Sensitive config (gitignored)
├── config.example.dart             # Config template
└── main.dart                       # App entry point
```

### Feature Module Structure

Each feature follows the same internal layout:

```
features/<feature_name>/
├── data/
│   ├── entities.dart              # All domain entities (fromJson/toJson)
│   └── <feature>_repository.dart  # Data access layer
├── pages/
│   ├── <simple_page>.dart         # Simple page (< 500 lines, no sections)
│   └── <complex_page>/            # Complex page (has sections/components)
│       ├── <page>_page.dart       # Page widget + route definition
│       ├── sections.dart          # All page sections in one file
│       └── components.dart        # All page components in one file
└── logic/
    └── <cubit_name>.dart          # Cubit + State in one file (freezed)
```

**Single file = no folder rule**: If a directory would contain only one file, use a single file instead. For example, `core/clients/api_client.dart` becomes `core/clients.dart`.

### Data Layer

The data layer uses an entities-only approach — no separate DTOs or Models.

**Entities** (`data/entities.dart`):
- All domain entities for a feature live in a single file
- Each entity has `fromJson(Map<String, dynamic>)` and `toJson()` methods
- Entities use `Equatable` for value equality and include `copyWith()`
- Entity class names have no `Entity` suffix (use `Event`, not `EventEntity`)

**Repositories** (`data/<feature>_repository.dart`):
- Accept `ApiClient` via dependency injection
- Receive `Map<String, dynamic>` from the API client
- Convert to entities via `Entity.fromJson()`
- Always return entity types (`Event`, `List<Event>`)
- Throw custom `ApiException` on errors

```dart
// Example: lib/features/events/data/entities.dart
class Event extends Equatable {
  final String id;
  final String title;
  final Venue venue;
  // ...

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      venue: Venue.fromJson(json['venue'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => { 'id': id, 'title': title, ... };
}
```

```dart
// Example: lib/features/events/data/event_repository.dart
class EventRepository {
  final ApiClient _apiClient;

  EventRepository(this._apiClient);

  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiClient.get('/api/events/list');
      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }
      return response
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException(message: 'Failed to load events', originalError: e);
    }
  }
}
```

### State Management

Cubits use `freezed` for immutable state. Each cubit and its state live in a single file.

```dart
// Example: lib/features/events/logic/event_list.dart
part 'event_list.freezed.dart';

@freezed
class EventListState with _$EventListState {
  const factory EventListState.initial() = EventListInitial;
  const factory EventListState.loading() = EventListLoading;
  const factory EventListState.loaded({
    required List<Event> allEvents,
    required List<Event> todayEvents,
  }) = EventListLoaded;
  const factory EventListState.error(String message) = EventListError;
}

class EventListCubit extends Cubit<EventListState> {
  final EventRepository _repository;
  EventListCubit(this._repository) : super(const EventListState.initial());

  Future<void> loadEvents() async {
    emit(const EventListState.loading());
    try {
      final events = await _repository.getAllEvents();
      emit(EventListState.loaded(allEvents: events, todayEvents: ...));
    } on ApiException {
      emit(EventListState.error(t.errors.loadEventsError));
    }
  }
}
```

### Routing

The app uses `go_router` with `go_router_builder` for type-safe, code-generated routes.

- Route classes are defined in each page file using `@TypedGoRoute` annotations
- All pages use `NoTransitionPage` by default (no transition animations)
- Routes override `buildPage` (not `build`)
- Shell routes wrap pages that share a layout (e.g., bottom navigation)
- Router configuration lives in `lib/core/routing.dart`

```dart
// Example: lib/features/events/pages/event_list/event_list_page.dart
part 'event_list_page.g.dart';

@TypedGoRoute<EventListRoute>(path: '/events')
class EventListRoute extends GoRouteData {
  const EventListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: EventListPage());
  }
}
```

```dart
// Route with parameters
@TypedGoRoute<EventDetailRoute>(path: '/events/:id')
class EventDetailRoute extends GoRouteData {
  final String id;
  const EventDetailRoute({required this.id});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: EventDetailPage(eventId: id));
  }
}
```

```dart
// Navigation
const EventDetailRoute(id: '123').go(context);
const LoginRoute().push(context);
```

### UI Component Hierarchy

Every UI element is its own class — no private `_build` methods.

| Level | Description | Location |
|-------|-------------|----------|
| Page | Complete screen | `pages/<page_name>_page.dart` |
| Section | Major area within a page | `pages/<page_name>/sections.dart` |
| Component | Complex, app-specific element | `pages/<page_name>/components.dart` |
| Widget | Simple, reusable element | `design/widgets.dart` |

Pages are composed of Sections, Sections contain Components and Widgets, Components contain Widgets.

### Dependency Injection

Uses `get_it` as a service locator, configured in `lib/core/service_locator.dart`.

- Repositories are registered as lazy singletons
- Cubits are registered as factories
- ApiClient is a lazy singleton

### Configuration

| File | Purpose | Committed |
|------|---------|-----------|
| `lib/config.dart` | Sensitive values (API keys, URLs) | No (gitignored) |
| `lib/config.example.dart` | Template for config.dart | Yes |
| `lib/core/config.dart` | Public config (timeouts, flags) + imports from config.dart | Yes |

New developers: `cp lib/config.example.dart lib/config.dart` and fill in values.

### Translations

Uses `slang_flutter` for type-safe i18n. Supported locales: English (base), Czech, Spanish.

- Translation files: `lib/i18n/strings.i18n.json`, `strings_cs.i18n.json`, `strings_es.i18n.json`
- Access via global `t` variable: `Text(t.events.title)`
- With parameters: `Text(t.events.count(count: 5))`
- Never hardcode user-facing strings
- Run `task slang` after modifying translation files

## Creating a New Feature

Step-by-step guide for adding a new feature module (e.g., `notifications`):

### 1. Create the directory structure

```
lib/features/notifications/
├── data/
│   ├── entities.dart
│   └── notification_repository.dart
├── pages/
│   └── notification_list_page.dart   # or folder if complex
└── logic/
    └── notification_list.dart
```

### 2. Define entities

```dart
// lib/features/notifications/data/entities.dart
import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const Notification({
    required this.id,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  @override
  List<Object?> get props => [id, message, createdAt, isRead];
}
```

### 3. Create the repository

```dart
// lib/features/notifications/data/notification_repository.dart
import '../../../core/clients.dart';
import '../../../core/exceptions.dart';
import 'entities.dart';

class NotificationRepository {
  final ApiClient _apiClient;
  NotificationRepository(this._apiClient);

  Future<List<Notification>> getAll() async {
    try {
      final response = await _apiClient.get('/api/notifications');
      if (response is! List) {
        throw ApiException(message: 'Invalid response format');
      }
      return response
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException(message: 'Failed to load notifications', originalError: e);
    }
  }
}
```

### 4. Create the cubit

```dart
// lib/features/notifications/logic/notification_list.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/notification_repository.dart';
import '../data/entities.dart';

part 'notification_list.freezed.dart';

@freezed
class NotificationListState with _$NotificationListState {
  const factory NotificationListState.initial() = _Initial;
  const factory NotificationListState.loading() = _Loading;
  const factory NotificationListState.loaded(List<Notification> items) = _Loaded;
  const factory NotificationListState.error(String message) = _Error;
}

class NotificationListCubit extends Cubit<NotificationListState> {
  final NotificationRepository _repository;
  NotificationListCubit(this._repository)
      : super(const NotificationListState.initial());

  Future<void> load() async {
    emit(const NotificationListState.loading());
    try {
      final items = await _repository.getAll();
      emit(NotificationListState.loaded(items));
    } catch (e) {
      emit(NotificationListState.error(t.errors.genericError));
    }
  }
}
```

### 5. Create the page with route

```dart
// lib/features/notifications/pages/notification_list_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'notification_list_page.g.dart';

@TypedGoRoute<NotificationListRoute>(path: '/notifications')
class NotificationListRoute extends GoRouteData {
  const NotificationListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: NotificationListPage());
  }
}

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.notifications.title)),
      body: BlocBuilder<NotificationListCubit, NotificationListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index].message),
              ),
            ),
            error: (msg) => Center(child: Text(msg)),
          );
        },
      ),
    );
  }
}
```

### 6. Register dependencies

Add to `lib/core/service_locator.dart`:

```dart
getIt.registerLazySingleton<NotificationRepository>(
  () => NotificationRepository(getIt<ApiClient>()),
);
getIt.registerFactory<NotificationListCubit>(
  () => NotificationListCubit(getIt<NotificationRepository>()),
);
```

### 7. Add translations

Add keys to all three language files (`strings.i18n.json`, `strings_cs.i18n.json`, `strings_es.i18n.json`) and run `task slang`.

### 8. Generate code

```bash
task build-runner    # Generates route (.g.dart) and freezed (.freezed.dart) files
```

## Task Commands

```bash
# Development
task get-deps              # Install Flutter dependencies
task run-web               # Run on web (port 3000)
task run-android           # Run on Android
task run-ios               # Run on iOS

# Code generation
task build-runner          # Generate routes + freezed classes
task build-runner-watch    # Watch mode for code generation
task build-runner-force    # Delete conflicting outputs first
task build-runner-clean    # Clean generated files

# Translations
task slang                 # Generate translations
task slang-watch           # Auto-regenerate on changes
task slang-analyze         # Check for missing keys

# Build
task build-web             # Production web build
task build-android         # Production Android build
task build-ios             # Production iOS build

# Maintenance
task clean                 # Clean project
```

## Testing

Tests mirror the `lib/` structure under `test/`:

```
test/
├── core/                  # Core module tests
├── features/
│   ├── events/
│   │   ├── data/          # Repository and entity tests
│   │   └── logic/         # Cubit tests
│   ├── auth/
│   └── settings/
├── helpers/               # Test utilities and mock factories
└── i18n/                  # Translation tests
```

Run tests:
```bash
flutter test
```

## Dependencies

- `flutter_bloc` — State management (Cubit)
- `freezed_annotation` / `freezed` — Immutable state classes
- `go_router` / `go_router_builder` — Type-safe routing
- `get_it` — Dependency injection
- `equatable` — Value equality for entities
- `slang_flutter` — Type-safe translations
- `google_fonts` — Typography (Inter font)
- `dio` — HTTP client (via ApiClient wrapper)
