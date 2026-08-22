---
inclusion: always
---

# Dancee App - Project Structure

## Project Overview

Dancee App is a Flutter-based mobile and web application for dance enthusiasts. The project is structured as a multi-platform application supporting Android, iOS, and web platforms.

## Project Structure

```
├── frontend/
│   └── dancee_app/          # Main Flutter application
│       ├── lib/             # Dart source code (see "Flutter lib/ Structure" below)
│       ├── .design/         # HTML design mockups
│       ├── android/         # Android-specific files
│       ├── ios/             # iOS-specific files
│       ├── web/             # Web-specific files
│       ├── docs/            # Documentation
│       └── pubspec.yaml     # Flutter dependencies (no Taskfile — use the Flutter CLI directly)
├── backend/
│   ├── dancee_api/          # TypeScript API Gateway (Express)
│   ├── dancee_workflow/     # TypeScript workflow service (Restate)
│   └── dancee_cms/          # Directus CMS (headless)
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

The app is organized by architectural layer (`core`, `data`, `logic`, `services`, `shared`), not by feature — each layer's own subdirectories are what group things by feature/screen.

```
frontend/dancee_app/lib/
├── config.dart            # Sensitive config (gitignored)
├── config.example.dart    # Config template (committed)
├── firebase_options.dart  # Generated Firebase config
├── main.dart              # App entry point
├── core/                  # App-wide infrastructure: routing, DI, API clients, theme
│   ├── app_routes.dart / app_routes.g.dart  # go_router route definitions (generated)
│   ├── clients.dart       # API client setup (Dio)
│   ├── colors.dart / theme.dart  # Design tokens
│   ├── config.dart        # Public config (imports from lib/config.dart)
│   ├── exceptions.dart    # Custom exceptions
│   ├── router_guard.dart  # Auth-gated route guard
│   └── service_locator.dart  # Dependency injection (get_it)
├── data/                  # Models and repositories, shared across screens
│   ├── entities/          # course, event, dance_style, venue, user_profile, favorite, …
│   ├── repositories/      # auth, course, dance_style, event, favorites, profile
│   └── premium_repository.dart
├── logic/                 # State management (flutter_bloc cubits + freezed states)
│   ├── cubits/            # auth, event, course, favorites, filter, profile, settings, add_event, …
│   └── states/            # matching *_state.dart (+ generated *.freezed.dart)
├── screens/                # One directory per screen area, each with its own sub-screens/components
│   ├── auth/              # login, register, forgot_password, email_verification, onboarding
│   ├── courses/           # courses_list, course_detail, add_course, edit_course
│   ├── events/            # events_list, event_detail, add_event, edit_event, filter_location, filter_dance, dance_style_selector
│   ├── profile/           # profile, profile_edit, change_password, author_contact, premium, legal
│   └── saved/             # saved_events_screen.dart + sections
├── services/              # Cross-cutting services: destination_service, directus_auth_service, firebase_auth_service
├── shared/                # Reusable UI shared across screens
│   ├── components/        # app_cached_image, back_button_header, background_circles, snap_carousel
│   ├── elements/          # buttons, forms, labels, navigation
│   ├── pages/             # auth_gate_page.dart
│   ├── sections/          # composed sections used by multiple screens (headers, filter chip rows, …)
│   └── utils/              # formatting/validation helpers (date_format, form_validators, url_launcher, …)
└── i18n/                  # Translations (slang_flutter + slang_build_runner)
    ├── strings.i18n.json      # English (base)
    ├── strings_cs.i18n.json   # Czech
    ├── strings_es.i18n.json   # Spanish
    └── strings.g.dart         # Generated translations — import as `i18n/strings.g.dart`
```

## Platform Support

The app supports three platforms:
1. **Web** — Progressive web app
2. **Android** — Native Android application
3. **iOS** — Native iOS application
