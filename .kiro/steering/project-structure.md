---
inclusion: always
---

# Dancee App - Project Structure

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── .design/                 # HTML design mockups
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code
│       │   ├── core/        # Shared utilities, DI, routing
│       │   ├── design/      # Shared design system
│       │   ├── features/    # Feature modules
│       │   └── i18n/        # Localization (slang)
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── docs/            # Documentation
│       ├── taskfile.yaml    # Task automation
│       └── pubspec.yaml     # Flutter dependencies
├── backend/
│   ├── dancee_api/          # TypeScript API Gateway (Express)
│   ├── dancee_workflow/     # TypeScript workflow service (Restate)
│   └── dancee_cms/          # Directus CMS (headless)
└── shared/                  # Shared resources (currently empty)
```

## Backend Services

### 🔀 dancee_api (TypeScript/Express)
- **Technology**: Node.js with Express framework (TypeScript)
- **Purpose**: API Gateway — centralized routing, OpenAPI spec aggregation, and single source of truth for all API documentation
- **Location**: `backend/dancee_api/`
- **Deployment**: Not yet deployed (local development service)
- **Key Features**:
  - OpenAPI spec aggregation and validation
  - Swagger UI for API documentation
  - Health check and service discovery endpoints
  - CORS middleware

#### dancee_api Structure:
```
backend/dancee_api/
├── src/
│   ├── aggregator/        # OpenAPI spec aggregation & validation
│   ├── config/            # App and services configuration
│   ├── middleware/        # CORS, error handling
│   ├── routes/            # Health, services, spec routes
│   ├── index.ts           # Entry point
│   └── server.ts          # Express server setup
├── specs/                 # OpenAPI specs for all services
│   ├── cms.openapi.yaml
│   ├── combined.openapi.yaml
│   └── workflow.openapi.yaml
├── docs/                  # Documentation
├── taskfile.yaml
└── package.json
```

### ⚙️ dancee_workflow (TypeScript/Restate)
- **Technology**: Node.js with TypeScript, Restate SDK, OpenAI, Zod, Vitest
- **Purpose**: Event processing workflow — scraping, AI-powered parsing/translation, geocoding, batch processing
- **Location**: `backend/dancee_workflow/`
- **Port**: 9080
- **Deployment**: Fly.io (Frankfurt region)
- **Key Features**:
  - Facebook event scraping
  - LLM-based event description parsing and translation (OpenAI)
  - Venue geocoding via Nominatim
  - Directus CMS integration for event storage
  - Restate durable execution for reliable workflows
  - Sentry error monitoring
  - Supervisord for process management in Docker

#### Network Architecture (HTTP Proxy)

The service runs three internal processes managed by supervisord:

1. **HTTP Proxy** (port 9080, exposed to Fly.io) — custom HTTP/1.1 server in `index.ts` that:
   - Maps `/api/*` routes to Restate ingress handler paths (e.g. `/api/event` → `/ApiService/processEvent`)
   - Handles CORS headers
   - Forwards `x-dancee-*` headers to Restate
   - Proxies unknown paths to Restate admin API (port 9070)

2. **Restate Server** (port 8080, internal) — the Restate ingress that executes service/workflow handlers with durable execution guarantees

3. **Restate Worker** (port 9081, internal) — the actual TypeScript endpoint registered with Restate server

**Important**: All API calls go through the HTTP proxy on port 9080. When adding a new handler to `ApiService`, you MUST also add a route mapping in `index.ts` `apiRoutes` object. Direct calls to Restate ingress (port 8080) or the worker (port 9081) are internal only.

#### API Route Mappings (index.ts)

```
/api/event                → /ApiService/processEvent
/api/event/reprocess      → /ApiService/reprocessEvent
/api/event/force-reprocess → /ApiService/forceReprocessEvent
/api/events/process       → /ApiService/processBatch
/api/events/process-group → /ApiService/processGroup
/api/events/list          → /ApiService/listEvents
/api/courses/list         → /ApiService/listCourses
/api/favorites            → /ApiService/createFavorite
/api/favorites/delete     → /ApiService/deleteFavorite
/api/favorites/list       → /ApiService/listFavorites
/api/dance-styles/list    → /ApiService/listDanceStyles
/api/event/retranslate    → /ApiService/retranslateItem
```

#### dancee_workflow Structure:
```
backend/dancee_workflow/
├── src/
│   ├── clients/           # External service clients
│   │   ├── directus-client.ts
│   │   ├── nominatim-client.ts
│   │   └── scraper-client.ts
│   ├── core/              # Configuration, schemas, prompts, utilities
│   │   ├── config.ts
│   │   ├── logger.ts
│   │   ├── openai.ts
│   │   ├── prompts.ts
│   │   ├── schemas.ts
│   │   ├── timezone.ts
│   │   └── utils.ts
│   ├── services/          # Business logic and workflow handlers
│   │   ├── api.ts
│   │   ├── batch.ts
│   │   ├── event-parser.ts
│   │   ├── event-translator.ts
│   │   ├── scraper.ts
│   │   ├── venue-resolver.ts
│   │   └── workflow.ts
│   ├── __tests__/         # Tests (mirrors src structure)
│   └── index.ts           # Entry point
├── scripts/               # Setup and seed scripts
├── docs/                  # Documentation
├── workflow.openapi.yaml  # OpenAPI spec for this service
├── supervisord.conf       # Process management config
├── vitest.config.ts       # Test configuration
├── taskfile.yaml
├── Dockerfile
├── docker-compose.yml
├── fly-secrets.sh         # Push secrets to Fly.io
└── fly.toml
```

### 📦 dancee_cms (Directus)
- **Technology**: Directus (headless CMS) + PostgreSQL (Supabase) + S3 Storage (Supabase)
- **Purpose**: Content management — event data storage, admin interface
- **Location**: `backend/dancee_cms/`
- **Port**: 8055
- **Deployment**: Fly.io (Frankfurt region)
- **Note**: No custom source code — uses official Directus Docker image with configuration scripts

#### dancee_cms Structure:
```
backend/dancee_cms/
├── fly-secrets.sh         # Push secrets to Fly.io
├── get-token.sh           # Get Directus access token
├── start-directus.sh      # Local development startup
├── fly.toml               # Fly.io deployment config
├── .env.example           # Environment template
└── README.md
```

## Frontend — dancee_app (Flutter)

- **Technology**: Flutter (Dart)
- **Purpose**: Mobile and web application for dance event discovery
- **Location**: `frontend/dancee_app/`
- **Platforms**: Android, iOS, Web

### Flutter lib/ Structure:
```
frontend/dancee_app/lib/
├── config.dart            # Sensitive config (gitignored)
├── config.example.dart    # Config template (committed)
├── main.dart              # App entry point
├── core/
│   ├── clients.dart       # API client (Dio)
│   ├── config.dart        # Public config (imports from lib/config.dart)
│   ├── exceptions.dart    # Custom exceptions
│   ├── routing.dart       # Go Router setup
│   └── service_locator.dart  # Dependency injection (get_it)
├── design/
│   ├── colors.dart
│   ├── theme.dart
│   ├── typography.dart
│   └── widgets.dart       # Shared design widgets
├── features/
│   ├── app/               # Core app feature (layouts, initial page, error pages)
│   │   ├── layouts.dart
│   │   └── pages/
│   │       ├── error_page.dart
│   │       ├── initial_page.dart
│   │       └── not_found_page.dart
│   ├── auth/              # Authentication
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── entities.dart
│   │   ├── logic/
│   │   │   └── auth.dart  # AuthCubit + AuthState (freezed)
│   │   └── pages/
│   │       ├── login/
│   │       └── register/
│   ├── events/            # Dance events
│   │   ├── data/
│   │   │   ├── entities.dart
│   │   │   └── event_repository.dart
│   │   ├── logic/
│   │   │   ├── event_detail.dart
│   │   │   ├── event_list.dart  # EventListCubit + State (freezed)
│   │   │   └── favorites.dart   # FavoritesCubit + State (freezed)
│   │   └── pages/
│   │       ├── event_detail/    # Complex page (sections + components)
│   │       ├── event_list/      # Complex page (sections + components)
│   │       ├── event_filters_page.dart  # Simple page
│   │       └── favorites_page.dart      # Simple page
│   └── settings/          # User settings
│       ├── data/
│       │   ├── entities.dart
│       │   └── settings_repository.dart
│       ├── logic/
│       │   └── settings.dart  # SettingsCubit + State (freezed)
│       └── pages/
│           └── settings_page.dart
└── i18n/                  # Translations (slang_flutter)
    ├── strings.i18n.json      # English (base)
    ├── strings_cs.i18n.json   # Czech
    ├── strings_es.i18n.json   # Spanish
    └── strings.g.dart         # Generated translations
```

## Platform Support

The app supports three platforms:
1. **Web** — Progressive web app
2. **Android** — Native Android application
3. **iOS** — Native iOS application
