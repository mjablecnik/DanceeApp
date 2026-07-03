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
| `DIRECTUS_BASE_URL` | Directus instance URL | — |
| `DIRECTUS_ACCESS_TOKEN` | Directus admin access token | — |
| `SCRAPER_BASE_URL` | dancee_scraper API base URL | — |
| `NOMINATIM_BASE_URL` | Nominatim API base URL | `https://nominatim.openstreetmap.org` |
| `SENTRY_DSN` | Sentry DSN for error tracking | — |
| `CORS_ORIGINS` | Allowed CORS origins | `*` |
| `APP_PORT` | Application port | `9080` |

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
| `POST` | `/api/event/reprocess` | Reprocess parts of an existing event |
| `GET` | `/api/events/process` | Trigger batch processing of all groups |
| `GET` | `/api/events/list` | List published events |

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
