# Dancee API Documentation Service

> Centralized API Documentation - Single Source of Truth for all Dancee backend services

## Overview

The Dancee API Documentation Service is a standalone Node.js/TypeScript service that provides a unified Swagger UI interface for exploring and testing APIs from multiple backend services. It runs on port 3003 and serves as the central documentation hub for:

- **dancee_workflow** (Port 8080) - Facebook event processing pipeline: scraping, AI parsing, translation, geocoding
- **dancee_cms** (Port 8055) - Directus headless CMS: event data, venues, groups

## Key Features

- **Single Source of Truth**: All OpenAPI specifications stored in one location
- **Unified Interface**: Access all API documentation through one Swagger UI
- **Multi-Environment Support**: Development and production server URLs
- **Interactive Testing**: Test API endpoints directly from the browser
- **Fast Performance**: In-memory caching for instant spec retrieval

## Quick Start

```bash
# Install dependencies
task install

# Copy environment variables
cp .env.example .env

# Start development server
task dev
```

Access the documentation at: http://localhost:3003

## Documented Services

### Dancee Workflow API (dancee-workflow)

Event processing pipeline built with TypeScript/Restate, fronted by a custom HTTP proxy.

- **Development**: http://localhost:8080
- **Production**: https://dancee-workflow.fly.dev
- **Spec File**: `specs/workflow.openapi.yaml`

**Key Features**:
- Facebook event scraping
- LLM-based event parsing and translation
- Venue geocoding
- Favorites and course listing

### Dancee CMS API (dancee-cms)

Directus headless CMS, including the custom firebase-auth extension.

- **Development**: http://localhost:8055
- **Production**: https://dancee-cms.fly.dev
- **Spec File**: `specs/cms.openapi.yaml`

**Key Features**:
- Event, venue, and group content collections
- Firebase-backed authentication (`/auth`, `/link`)

## Available Tasks

- `task install` - Install dependencies
- `task dev` - Start development server with hot reload
- `task build` - Build TypeScript to JavaScript
- `task start` - Start production server
- `task test` - Run all tests
- `task lint` - Run ESLint
- `task format` - Format code with Prettier

## Documentation

- [Setup Guide](docs/SETUP.md) - Detailed installation and configuration
- [Usage Guide](docs/USAGE.md) - How to use the API documentation service
- [Contributing](docs/CONTRIBUTING.md) - Guidelines for adding new API specs

## Project Structure

```
backend/dancee_api/
├── src/
│   ├── index.ts                 # Application entry point
│   ├── server.ts                # Express server setup
│   ├── config/
│   │   ├── app.config.ts        # Environment configuration
│   │   └── services.config.ts   # Service definitions
│   ├── aggregator/
│   │   └── spec-aggregator.ts   # Spec loading and caching
│   ├── routes/
│   │   ├── services.routes.ts   # Service list endpoints
│   │   └── spec.routes.ts       # Spec retrieval endpoints
│   └── middleware/
│       ├── cors.middleware.ts   # CORS configuration
│       └── error.middleware.ts  # Error handling
├── specs/                       # ⭐ Single Source of Truth
│   ├── workflow.openapi.yaml    # dancee_workflow API spec
│   ├── cms.openapi.yaml         # dancee_cms API spec
│   └── combined.openapi.yaml    # hand-maintained merge of both, for a single Swagger UI view
├── docs/                        # Documentation files
├── .env.example                 # Environment variables template
├── taskfile.yaml                # Task automation
└── README.md                    # This file
```

## API Endpoints

### GET /

Serves the Swagger UI interface with a service selector. This is your main entry point for exploring all API documentation.

**Example**: http://localhost:3003

### GET /api/services

Returns a JSON array of all available backend services with their metadata.

**Response Example**:
```json
[
  {
    "id": "dancee-workflow",
    "name": "Dancee Workflow API",
    "version": "1.0.0",
    "description": "Facebook event processing pipeline — scraping, AI parsing, translation, geocoding",
    "baseUrl": "http://localhost:8080",
    "specPath": "/api/spec/dancee-workflow"
  },
  {
    "id": "dancee-cms",
    "name": "Dancee CMS API",
    "version": "1.0.0",
    "description": "Directus headless CMS — event data, venues, groups",
    "baseUrl": "http://localhost:8055",
    "specPath": "/api/spec/dancee-cms"
  }
]
```

### GET /api/spec/:serviceId

Returns the OpenAPI 3.0 specification for a specific service.

**Parameters**:
- `serviceId` - Service identifier (e.g., "dancee-workflow", "dancee-cms")

**Example**: http://localhost:3003/api/spec/dancee-workflow

**Response**: Full OpenAPI 3.0 specification in JSON format

### GET /health

Health check endpoint for monitoring service availability.

**Response Example**:
```json
{
  "status": "ok",
  "services": {
    "dancee-workflow": "loaded",
    "dancee-cms": "loaded"
  }
}
```

## Single Source of Truth Principle

**Critical Design Decision**: All OpenAPI specifications are stored exclusively in `backend/dancee_api/specs/`. Individual backend services (dancee_workflow, dancee_cms) do NOT maintain their own OpenAPI specs or Swagger UI implementations.

### Why This Matters

1. **Centralized Maintenance**: Update API documentation in one place, not scattered across multiple services
2. **Consistency**: All services documented with the same standards and format
3. **Version Control**: Single repository for all API documentation changes
4. **No Duplication**: Eliminates sync issues between service-level and central docs
5. **Easy Discovery**: Developers know exactly where to find all API documentation

### How It Works

```
┌─────────────────────────────────────────┐
│  Dancee API Documentation Service       │
│  (Port 3003)                            │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  specs/                           │ │
│  │  ├── events.openapi.yaml         │ │  ← Single Source of Truth
│  │  └── scraper.openapi.yaml        │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Swagger UI serves all specs           │
└─────────────────────────────────────────┘
           │                    │
           ▼                    ▼
    ┌─────────────┐      ┌─────────────┐
    │ dancee_events│      │dancee_scraper│
    │ (Port 8080) │      │ (Port 3002) │
    │             │      │             │
    │ No OpenAPI  │      │ No OpenAPI  │
    │ specs here  │      │ specs here  │
    └─────────────┘      └─────────────┘
```

When a backend service's API changes, you only update the corresponding OpenAPI spec in `backend/dancee_api/specs/` - never in the individual service directories.

## Environment Variables

See `.env.example` for all available configuration options.

## Technology Stack

- **Runtime**: Node.js 20+
- **Language**: TypeScript 5.0+
- **Framework**: Express 4.18+
- **Documentation**: Swagger UI Express 5.0+
- **Testing**: Jest 29+
- **Code Quality**: ESLint + Prettier

## Requirements

- Node.js 20 or higher
- npm or yarn package manager
- Backend services running (for API testing):
  - dancee_events on port 8080
  - dancee_scraper on port 3002

## Performance

- **Spec Retrieval**: < 100ms response time
- **Service List**: < 100ms response time
- **Health Check**: < 50ms response time
- **Caching**: All specs loaded into memory on startup for instant access

## License

MIT
