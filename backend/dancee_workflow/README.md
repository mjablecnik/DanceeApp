# dancee_workflow

Restate-based event processing workflow service for Dancee. Automates the pipeline: scrape Facebook events → classify via LLM → extract parts & info → translate to multiple languages → resolve venues → store in Directus CMS.

## Overview

- **Runtime**: Node.js (Bun as package manager)
- **Workflow engine**: [Restate](https://restate.dev/) for durable workflow orchestration
- **Data store**: Directus CMS (REST API)
- **LLM provider**: OpenRouter (via OpenAI SDK)
- **Geocoding**: Nominatim (OpenStreetMap)
- **Error monitoring**: Sentry

## Prerequisites

- [Bun](https://bun.sh/) >= 1.0
- [Docker](https://www.docker.com/) and Docker Compose
- A running Directus instance (external, configured via `.env`)
- A running Restate server (bundled in Docker image)

## Setup

1. Copy the example environment file and fill in your values:
   ```bash
   cp .env.example .env
   ```

2. Install dependencies:
   ```bash
   bun install
   ```

3. Run the Directus setup script to create collections and seed languages:
   ```bash
   bun scripts/setup-directus.ts
   ```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `OPENROUTER_API_KEY` | OpenRouter API key for LLM calls | — |
| `OPENROUTER_MODEL` | Model to use (e.g. `openai/gpt-4o-mini`) | — |
| `IMAGE_GENERATION_MODEL` | Model used for AI image generation | `black-forest-labs/flux.2-pro` |
| `DIRECTUS_BASE_URL` | Directus instance URL | — |
| `DIRECTUS_ACCESS_TOKEN` | Directus admin access token | — |
| `DIRECTUS_TIMEOUT_MS` | Timeout for Directus API requests (ms) | `30000` |
| `NOMINATIM_BASE_URL` | Nominatim API base URL | `https://nominatim.openstreetmap.org` |
| `NOMINATIM_TIMEOUT_MS` | Timeout for Nominatim API requests (ms) | `10000` |
| `LLM_TEMPERATURE` | LLM sampling temperature | `0.1` |
| `SENTRY_DSN` | Sentry DSN for error tracking | — |
| `CORS_ORIGINS` | Allowed CORS origins | `*` |
| `APP_PORT` | Application port | `9080` |
| `AUTHOR_EMAIL` | Email address to receive contact form notifications | — |
| `INTERNAL_API_KEY` | Bearer token required by privileged/admin routes (e.g. force-reprocess) | — |
| `WORKFLOW_BASE_URL` | Base URL used by `scripts/setup-directus-flows.ts` for callback flows | `https://dancee-workflow.fly.dev` |
| `FB_COOKIES` | Raw Facebook cookie string (`"c_user=...; xs=..."`) for authenticated scraping | — |
| `SCRAPE_DELAY_MIN_MS` | Minimum delay between consecutive Facebook scrape requests (ms) | `4000` |
| `SCRAPE_DELAY_MAX_MS` | Maximum delay between consecutive Facebook scrape requests (ms) | `10000` |

## Development

```bash
# Start with hot reload
bun run dev

# Run tests
bun run test

# Build TypeScript
bun run build
```

## Docker

```bash
# Build and start the service (includes embedded Restate server)
docker compose up --build
```

The container exposes:
- `8080` — Restate ingress (client-facing API)
- `9070` — Restate admin interface
- `9080` — Application service (internal)

## API Endpoints

All endpoints are exposed via the HTTP proxy on `APP_PORT` (default 9080).

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/event` | Process a single Facebook event by URL |
| `POST` | `/api/event/reprocess` | Reprocess selected steps of an existing event |
| `POST` | `/api/event/force-reprocess` | Re-scrape an event from Facebook and reprocess it from scratch |
| `POST` | `/api/event/retranslate` | Retranslate a modified event or course to the other languages |
| `GET` | `/api/events/process` | Trigger batch processing of all groups |
| `POST` | `/api/events/process-group` | Trigger processing of a single Facebook group |
| `GET` | `/api/events/list` | List published events |
| `POST` | `/api/courses/list` | List published courses |
| `POST` | `/api/favorites` | Add an event or course to a user's favorites |
| `POST` | `/api/favorites/delete` | Remove an item from a user's favorites |
| `POST` | `/api/favorites/list` | List favorites for a user |
| `GET` | `/api/dance-styles/list` | List the dance styles catalogue |

### POST /api/event

```json
{ "url": "https://www.facebook.com/events/123456789" }
```

Uses a deterministic workflow key — repeated calls with the same URL return the existing result.

### POST /api/event/reprocess

```json
{ "id": 70, "steps": ["translations"], "lang": "en" }
```

Re-runs selected processing steps on an existing event. Valid steps: `parts`, `info`, `translations`, `dances`. Omit `steps` to reprocess everything. Use `lang` to translate a single language. Supports `translationId` instead of `id` when called from translation detail.

### GET /api/events/list

Custom headers:
- `x-dancee-lang: cs` — flatten translation for a specific language onto each event
- `x-dancee-include: original_description` — include the original Facebook description
- `x-dancee-filter: {"dances":{"_contains":"Salsa"}}` — Directus filter (allowed fields: dances, start_time, end_time, venue, organizer, translation_status)

## Scripts

See [docs/SCRIPTS.md](docs/SCRIPTS.md) for documentation on all available scripts.

## Testing

```bash
bun run test
```

Tests use [Vitest](https://vitest.dev/) with [fast-check](https://fast-check.io/) for property-based testing. Test files are located in `src/__tests__/`.
