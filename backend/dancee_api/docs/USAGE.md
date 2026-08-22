# Usage Guide - Dancee API Documentation Service

This guide provides practical examples and instructions for using the Centralized API Documentation Service to explore and test backend APIs.

## Table of Contents

- [Quick Start](#quick-start)
- [Accessing Swagger UI](#accessing-swagger-ui)
- [Switching Between Services](#switching-between-services)
- [Exploring API Endpoints](#exploring-api-endpoints)
- [Testing API Endpoints](#testing-api-endpoints)
- [Using the REST API](#using-the-rest-api)
- [Common Workflows](#common-workflows)
- [Tips and Best Practices](#tips-and-best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

### 1. Start the Documentation Service

```bash
# Navigate to the project directory
cd backend/dancee_api

# Start the development server
task dev
```

### 2. Open Swagger UI

Open your web browser and navigate to:

```
http://localhost:3003
```

You should see the Swagger UI interface with a service selector at the top.

### 3. Select a Service

Click the service selector dropdown in the top-right corner and choose a service:
- **Dancee Workflow API** - Facebook event processing pipeline (scraping, AI parsing, translation, geocoding)
- **Dancee CMS API** - Directus headless CMS (event data, venues, groups, Firebase-backed auth)

### 4. Explore and Test

Browse the available endpoints, expand them to see details, and use the "Try it out" button to test API calls.

## Accessing Swagger UI

### Main Interface

The Swagger UI is your primary interface for exploring API documentation. Access it at:

```
http://localhost:3003
```

### Interface Components

**Service Selector (Top-Right)**
- Dropdown menu to switch between different backend services
- Shows service name and version
- Persists your selection across page reloads

**Endpoint List (Left Side)**
- Organized by tags/categories
- Color-coded by HTTP method:
  - 🟢 **GET** - Retrieve data
  - 🟡 **POST** - Create new resources
  - 🔵 **PUT** - Update existing resources
  - 🟣 **PATCH** - Partial update
  - 🔴 **DELETE** - Remove resources

**Endpoint Details (Main Area)**
- Summary and description
- Parameters (path, query, headers)
- Request body schema
- Response schemas with examples
- "Try it out" interactive testing

**Models Section (Bottom)**
- Data model schemas
- Object properties and types
- Example values

### Navigation Tips

1. **Collapse/Expand All**: Use the buttons at the top to collapse or expand all endpoints
2. **Search**: Use Ctrl+F (Cmd+F on Mac) to search for specific endpoints or terms
3. **Direct Links**: Bookmark specific endpoints by copying the URL after expanding them

## Switching Between Services

### Using the Service Selector

1. **Locate the Selector**: Look for the dropdown in the top-right corner of the Swagger UI
2. **Click to Open**: Click the dropdown to see all available services
3. **Select Service**: Click on the service you want to explore
4. **Wait for Load**: The interface will reload with the selected service's documentation

### Available Services

#### Dancee Workflow API (dancee-workflow)

**Purpose**: Facebook event processing pipeline — scraping, AI parsing, translation, geocoding

**Base URLs**:
- Development: `http://localhost:8080`
- Production: `https://dancee-workflow.fly.dev`

**Key Endpoints**:
- `POST /api/event` - Process a single Facebook event
- `POST /api/events/process` - Process a batch of events
- `GET /api/events/list` - List processed events
- `POST /api/favorites` - Add event to favorites
- `GET /api/favorites/list` - Get favorite events
- `GET /api/courses/list` - List courses

**Use Cases**:
- Trigger Facebook event scraping and AI processing
- Browse processed dance events and courses
- Manage user favorites

**Important**: this API is an HTTP proxy in front of a Restate service, not a plain REST server. It filters `GET`-style list requests by custom headers (`x-dancee-filter`, `x-dancee-lang`, `x-dancee-include`) rather than query parameters, and it has **no `/health` endpoint** — see [Troubleshooting](#troubleshooting).

#### Dancee CMS API (dancee-cms)

**Purpose**: Directus headless CMS — event data, venues, groups, and Firebase-backed authentication

**Base URLs**:
- Development: `http://localhost:8055`
- Production: `https://dancee-cms.fly.dev`

**Key Endpoints**:
- `GET /items/{collection}` - List items in a Directus collection (e.g. `events`, `venues`, `courses`, `dance_styles`, `favorites`)
- `GET /items/{collection}/{id}` - Get a single item
- `POST /directus-extension-firebase-auth/auth` - Authenticate with a Firebase ID token
- `POST /directus-extension-firebase-auth/link` - Link a Firebase account to a Directus user

**Use Cases**:
- Browse and manage CMS content collections
- Authenticate app users via Firebase

## Exploring API Endpoints

### Understanding Endpoint Information

When you expand an endpoint, you'll see:

#### 1. Summary and Description

```
GET /items/events
Summary: List events
Description: Supports standard Directus query parameters — filter, sort, limit, offset, fields.
```

#### 2. Parameters

**Path Parameters** (part of the URL):
```
GET /items/events/{id}
  id: integer | string (required) - Event ID
```

**Query Parameters** (Directus endpoints, e.g. `dancee-cms`, use standard Directus query syntax):
```
GET /items/events?filter[organizer][_eq]=Prague Salsa Club&limit=10
  filter: object (optional) - Directus filter expression
  limit: integer (optional) - Number of results
```

**Header Parameters** (`dancee-workflow` list endpoints use custom headers instead of query parameters for filtering):
```
GET /api/events/list
  Authorization: Bearer <token>       - required only on privileged/favorites routes, see below
  x-dancee-filter: {"organizer":"Prague Salsa Club"}   - JSON filter object
  x-dancee-lang: cs                   - flattens the matching translation onto each event
  x-dancee-include: original_description  - include the untranslated source text
```

#### 3. Request Body

For POST requests, you'll see the expected request body schema. Example — `POST /api/favorites` (dancee-workflow):

```json
{
  "item_type": "event",
  "item_id": 42
}
```

The favorited item's owner (`user_id`) is derived server-side from the caller's verified Directus JWT — it is never read from the request body.

#### 4. Responses

Each endpoint shows possible responses. Directus collection endpoints (`dancee-cms`) wrap results in a `data` envelope:

**200 OK** - Success response with data
```json
{
  "data": {
    "id": 42,
    "title": "Pražská Salsa Noc",
    "organizer": "Prague Salsa Club",
    "venue": 7,
    "start_time": "2026-07-15T20:00:00Z"
  }
}
```

**400 Bad Request** - Invalid input
```json
{
  "error": "Missing required fields: 'item_type', 'item_id'"
}
```

**404 Not Found** - Resource not found (unmapped path on `dancee-workflow`, or missing item on `dancee-cms`)
```json
{
  "error": "Not found"
}
```

**500 Internal Server Error** - Server error
```json
{
  "error": "Internal server error"
}
```

### Reading Data Models

Scroll to the **Models** section at the bottom to see detailed schemas. Example models from `dancee-cms` (`DirectusEvent`/`DirectusVenue`):

**DirectusEvent Model**:
```
DirectusEvent {
  id: integer | string
  title: string           # e.g. "Pražská Salsa Noc"
  original_description: string
  organizer: string       # e.g. "Prague Salsa Club"
  venue: integer | string | DirectusVenue | null
  start_time: string (date-time, nullable)
}
```

**DirectusVenue Model**:
```
DirectusVenue {
  id: integer | string
  name: string     # e.g. "Lucerna Music Bar"
  street: string   # e.g. "Vodičkova"
  number: string   # e.g. "36"
}
```

## Testing API Endpoints

### Interactive Testing with "Try it out"

#### Step 1: Expand an Endpoint

Click on any endpoint to expand its details.

#### Step 2: Click "Try it out"

Look for the blue "Try it out" button in the top-right of the endpoint section.

#### Step 3: Fill in Parameters

**Example: GET /items/events with query parameters (dancee-cms)**

1. Click "Try it out"
2. Fill in optional parameters:
   - `filter`: `{"organizer":{"_eq":"Prague Salsa Club"}}`
   - `limit`: 10
3. Click "Execute"

**Example: POST /api/favorites (dancee-workflow — add to favorites)**

1. Click "Try it out"
2. Click "Authorize" first and provide a valid Directus user JWT (see [Testing with Authentication](#testing-with-authentication))
3. Edit the request body:
   ```json
   {
     "item_type": "event",
     "item_id": 42
   }
   ```
4. Click "Execute"

**Example: GET /items/events/{id} (dancee-cms — get a specific event)**

1. Click "Try it out"
2. Fill in path parameter:
   - `id`: 42
3. Click "Execute"

#### Step 4: View Response

After clicking "Execute", you'll see:

**Request Details**:
```
Curl command:
curl -X GET "http://localhost:8055/items/events?limit=10" -H "accept: application/json"

Request URL:
http://localhost:8055/items/events?limit=10
```

**Response**:
```
Code: 200
Response body:
{
  "data": [
    {
      "id": 42,
      "title": "Pražská Salsa Noc",
      "organizer": "Prague Salsa Club"
    }
  ]
}

Response headers:
content-type: application/json
```

### Testing Different HTTP Methods

#### GET Requests (Retrieve Data)

```
GET /items/events              (dancee-cms)
GET /items/events/{id}         (dancee-cms)
GET /api/events/list           (dancee-workflow — filtered via headers, not query params)
GET /api/favorites/list        (dancee-workflow — requires a Directus user JWT)
```

**No request body needed** - just fill in path/query parameters, or headers on `dancee-workflow`

#### POST Requests (Create/Trigger)

```
POST /api/favorites             (dancee-workflow)
POST /api/event                 (dancee-workflow — triggers scraping/processing, requires INTERNAL_API_KEY)
POST /items/events              (dancee-cms — create an event directly in Directus)
```

**Requires request body**, e.g. for `POST /api/favorites`:
```json
{
  "item_type": "event",
  "item_id": 42
}
```

#### DELETE-style Requests (Remove Resources)

`dancee-workflow` does not expose a DELETE HTTP method — removal is a dedicated POST endpoint instead:

```
POST /api/favorites/delete
```
```json
{
  "item_type": "event",
  "item_id": 42
}
```

`dancee-cms` (Directus) does support standard `DELETE /items/{collection}/{id}`.

### Testing with Authentication

Two different auth schemes are in play, depending on the endpoint:

- **`dancee-workflow` privileged routes** (`/api/event`, `/api/event/reprocess`, `/api/event/force-reprocess`, `/api/events/process`, `/api/events/process-group`, `/api/event/retranslate`) require `Authorization: Bearer <INTERNAL_API_KEY>` — the shared server-side secret, not a per-user token.
- **`dancee-workflow` favorites routes** (`/api/favorites`, `/api/favorites/delete`, `/api/favorites/list`) require `Authorization: Bearer <directus-user-jwt>` — a real Directus user session token; the proxy verifies it against `dancee-cms`'s `/users/me` before forwarding the request.
- **`dancee-cms`** collection endpoints follow standard Directus authentication (a Directus access token, obtainable via `./get-token.sh` in local development).

To test an authenticated endpoint in Swagger UI:

1. Look for the 🔒 lock icon next to the endpoint
2. Click "Authorize" button at the top of the page
3. Enter the appropriate token for that endpoint (see above — they are not interchangeable)
4. Click "Authorize"
5. Now matching requests will include the authentication header

## Using the REST API

### Programmatic Access

You can access the documentation service programmatically using its REST API.

### Get Service List

**Endpoint**: `GET /api/services`

**Example**:
```bash
curl http://localhost:3003/api/services
```

**Response**:
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

### Get OpenAPI Specification

**Endpoint**: `GET /api/spec/:serviceId`

**Example**:
```bash
# Get dancee-workflow spec
curl http://localhost:3003/api/spec/dancee-workflow

# Get dancee-cms spec
curl http://localhost:3003/api/spec/dancee-cms
```

**Response**: Full OpenAPI 3.0 specification in JSON format

**Use Cases**:
- Generate API clients automatically
- Import into Postman or Insomnia
- Validate API contracts in CI/CD
- Generate documentation in other formats

### Health Check

This is the documentation service's own health check (port 3003) — it reports whether each backend service's OpenAPI spec loaded successfully, not whether the backend services themselves are reachable.

**Endpoint**: `GET /health`

**Example**:
```bash
curl http://localhost:3003/health
```

**Response**:
```json
{
  "status": "ok",
  "services": {
    "dancee-workflow": "loaded",
    "dancee-cms": "loaded"
  }
}
```

## Common Workflows

### Workflow 1: Exploring a New API

**Goal**: Understand what endpoints are available and how to use them

1. **Open Swagger UI**: Navigate to `http://localhost:3003`
2. **Select Service**: Choose the service you want to explore
3. **Browse Endpoints**: Scroll through the endpoint list
4. **Read Descriptions**: Expand endpoints to read summaries and descriptions
5. **Check Models**: Scroll to the Models section to understand data structures
6. **Test Simple Endpoint**: Try a GET endpoint with no parameters
7. **Test with Parameters**: Try endpoints with query, path, or (on `dancee-workflow`) header parameters
8. **Review Responses**: Examine response schemas and examples

### Workflow 2: Testing an API Integration

**Goal**: Verify API behavior before integrating into your application

1. **Start Backend Service**: Ensure the backend service is running
   ```bash
   # For dancee_workflow
   cd backend/dancee_workflow
   task dev

   # For dancee_cms
   cd backend/dancee_cms
   ./start-directus.sh
   ```

2. **Open Swagger UI**: Navigate to `http://localhost:3003`

3. **Select Service**: Choose the service you're integrating with

4. **Test Endpoints**:
   - Start with simple GET requests
   - Test with different parameter/header values
   - Try edge cases (empty values, invalid IDs)
   - Test error scenarios

5. **Document Results**: Note the actual responses for your integration code

6. **Copy curl Commands**: Use the generated curl commands in your tests

### Workflow 3: Debugging API Issues

**Goal**: Investigate why an API call is failing

1. **Reproduce in Swagger UI**: Try the same request in Swagger UI

2. **Check Request Format**:
   - Verify parameter names and types
   - Check request body structure
   - Ensure required fields are present
   - On `dancee-workflow`, confirm you're using the right auth scheme for the route (INTERNAL_API_KEY vs. user JWT — see [Testing with Authentication](#testing-with-authentication))

3. **Examine Response**:
   - Check HTTP status code
   - Read error message
   - Review response headers

4. **Compare with Documentation**:
   - Verify you're using the correct endpoint
   - Check parameter requirements
   - Validate request body schema

5. **Test Variations**:
   - Try with minimal parameters
   - Test with example values from docs
   - Isolate the problematic parameter

### Workflow 4: Generating API Client Code

**Goal**: Create a client library for your application

1. **Get OpenAPI Spec**:
   ```bash
   curl http://localhost:3003/api/spec/dancee-workflow > events-api.json
   ```

2. **Use Code Generator**:
   ```bash
   # Install OpenAPI Generator
   npm install -g @openapitools/openapi-generator-cli

   # Generate TypeScript client
   openapi-generator-cli generate \
     -i events-api.json \
     -g typescript-axios \
     -o ./src/api/events-client

   # Generate Python client
   openapi-generator-cli generate \
     -i events-api.json \
     -g python \
     -o ./api/events_client
   ```

3. **Import and Use**:
   ```typescript
   import { ApiEventsListApi } from './api/events-client';

   const api = new ApiEventsListApi();
   const events = await api.getEventsList();
   ```

### Workflow 5: Importing into Postman

**Goal**: Use Postman for API testing

1. **Get OpenAPI Spec URL**:
   ```
   http://localhost:3003/api/spec/dancee-workflow
   ```

2. **Open Postman**

3. **Import**:
   - Click "Import" button
   - Select "Link" tab
   - Paste the spec URL
   - Click "Continue"
   - Click "Import"

4. **Use Collection**:
   - All endpoints are now in a Postman collection
   - Edit environment variables for base URL
   - Test endpoints with Postman's interface

## Tips and Best Practices

### Efficient API Exploration

1. **Start with GET Endpoints**: They're safe to test and don't modify data
2. **Use Example Values**: Copy example values from the documentation
3. **Test in Order**: Test simple endpoints before complex ones
4. **Read Error Messages**: They often explain exactly what's wrong
5. **Check Response Schemas**: Understand the data structure before integrating

### Testing Best Practices

1. **Test Happy Path First**: Verify the endpoint works with valid data
2. **Test Edge Cases**: Try boundary values, empty strings, null values
3. **Test Error Scenarios**: Intentionally send invalid data to see error handling
4. **Document Findings**: Keep notes on actual behavior vs. documented behavior
5. **Use curl Commands**: Copy generated curl commands for automated testing

### Working with Multiple Services

1. **Keep Services Running**: Start all backend services you're testing
2. **Use Separate Terminals**: Run each service in its own terminal window
3. **Check Service Health**: Verify services are running before testing (see [Troubleshooting](#troubleshooting) — the two backend services expose health differently)
4. **Switch Services Frequently**: Compare similar endpoints across services
5. **Bookmark URLs**: Save direct links to frequently used endpoints

### Performance Tips

1. **Use Filters**: Apply Directus query filters (`dancee-cms`) or the `x-dancee-filter` header (`dancee-workflow`) to limit response size
2. **Paginate Results**: Use `limit`/`offset` on `dancee-cms`
3. **Cache Responses**: The documentation service caches specs in memory
4. **Test Locally First**: Use localhost URLs before testing production

### Security Considerations

1. **Don't Use Production Data**: Test with development/staging environments
2. **Protect API Keys**: Don't share the `INTERNAL_API_KEY` or user JWTs
3. **Use HTTPS in Production**: Always use secure connections for production APIs
4. **Validate Input**: Test with malicious input to verify validation
5. **Check CORS**: Ensure CORS is properly configured for your frontend

## Troubleshooting

### Issue: "Failed to fetch" Error

**Symptom**: Swagger UI shows "Failed to fetch" when executing requests

**Causes**:
- Backend service is not running
- Wrong base URL in OpenAPI spec
- CORS issues

**Solutions**:

1. **Verify Backend Service is Running**:
   ```bash
   # Check dancee_workflow — no /health route; hitting any unmapped path returns
   # a 404 JSON body from the proxy itself, which still proves the process is up
   curl -i http://localhost:8080/api/events/list

   # Check dancee_cms (Directus' own health check path, not /health)
   curl http://localhost:8055/server/health
   ```

2. **Check Base URL**: Ensure the service URL in `.env` matches the running service

3. **Check CORS**: Verify CORS is enabled on the backend service

### Issue: 404 Not Found

**Symptom**: API returns 404 error

**Causes**:
- Wrong endpoint URL
- Missing path parameters
- Service not running

**Solutions**:

1. **Verify Endpoint Path**: Check the exact path in the documentation. On `dancee-workflow`, a 404 with `{"error": "Not found"}` means the path isn't one of the twelve routes it proxies — it isn't a generic "not running" signal.
2. **Check Path Parameters**: Ensure all required path parameters are filled
3. **Verify Service**: Confirm the backend service is running and accessible

### Issue: 400 Bad Request

**Symptom**: API returns 400 error with validation message

**Causes**:
- Invalid parameter format
- Missing required fields
- Wrong data type

**Solutions**:

1. **Check Parameter Types**: Ensure strings are strings, numbers are numbers
2. **Verify Required Fields**: Fill in all required parameters
3. **Match Schema**: Compare your request body with the schema
4. **Check Examples**: Use example values from the documentation

### Issue: 401 Unauthorized

**Symptom**: API returns 401 error

**Causes**:
- Missing authentication
- Wrong token type for the route (see [Testing with Authentication](#testing-with-authentication) — `INTERNAL_API_KEY` and a Directus user JWT are not interchangeable)
- Invalid or expired token

**Solutions**:

1. **Click Authorize**: Use the Authorize button at the top
2. **Enter the Correct Token Type**: Privileged `dancee-workflow` routes need `INTERNAL_API_KEY`; favorites routes need a real Directus user JWT; `dancee-cms` needs a Directus access token
3. **Check Token Format**: Ensure correct format (e.g., "Bearer <token>")

### Issue: 500 Internal Server Error

**Symptom**: API returns 500 error

**Causes**:
- Backend service error
- Database connection issue
- Unexpected input

**Solutions**:

1. **Check Backend Logs**: Look at the backend service console output
2. **Try Different Input**: Test with simpler or different values
3. **Report Bug**: If persistent, report to the development team

### Issue: Slow Response Times

**Symptom**: Requests take a long time to complete

**Causes**:
- Large dataset without pagination
- Backend service performance issue
- Network latency

**Solutions**:

1. **Use Pagination**: Add `limit`/`offset` parameters on `dancee-cms`
2. **Filter Results**: Use Directus filters or the `x-dancee-filter` header to reduce data size
3. **Check Backend**: Verify backend service performance
4. **Test Locally**: Ensure you're testing against localhost

### Issue: CORS Error in Browser

**Symptom**: Browser console shows CORS policy error

**Causes**:
- Backend service doesn't allow origin
- Missing CORS headers
- Preflight request failing

**Solutions**:

1. **Check Backend CORS**: Verify backend service has CORS enabled
2. **Update CORS Origins**: Add your origin to allowed origins
3. **Use Proxy**: Consider using a proxy for development

### Getting Help

If you encounter issues not covered here:

1. **Check Backend Service Logs**: Look for error messages
2. **Verify Configuration**: Review `.env` file settings
3. **Test with curl**: Try the same request with curl to isolate the issue
4. **Check Health Endpoint**: Verify the documentation service is healthy
5. **Review Setup Guide**: Ensure all setup steps were completed
6. **Contact Team**: Reach out to the development team with specific error details

## Next Steps

Now that you know how to use the API documentation service:

1. **Explore All Services**: Try each available backend service
2. **Test Your Use Cases**: Verify the APIs support your requirements
3. **Generate Client Code**: Create API clients for your applications
4. **Integrate APIs**: Start building your application with the APIs
5. **Provide Feedback**: Report any documentation issues or suggestions

## Additional Resources

- [Setup Guide](./SETUP.md) - Installation and configuration
- [Project README](../README.md) - Project overview
- [Contributing Guide](./CONTRIBUTING.md) - How to add new API specs
- [OpenAPI Specification](https://swagger.io/specification/) - OpenAPI 3.0 docs
- [Swagger UI Guide](https://swagger.io/tools/swagger-ui/) - Swagger UI documentation
- [curl Documentation](https://curl.se/docs/) - curl command reference

## Feedback

Have suggestions for improving this guide? Found an error? Please let the development team know!
