# Security Audit — backend/dancee_workflow

**Date:** 2026-07-04
**Scope:** `backend/dancee_workflow/` (TypeScript / Node.js Restate workflow service)
**Stack:** Node.js 20, `@restatedev/restate-sdk` 1.11, `openai` 4 (via OpenRouter), `zod` 3, Directus CMS backend, deployed on Fly.io behind a hand-rolled HTTP proxy.

## Executive Summary

**Overall risk level: CRITICAL**

The service ships a hand-written HTTP proxy (`src/index.ts`) that is the single public entry point on Fly.io (`internal_port = 9080`, `force_https = true`). Two structural problems dominate the risk profile:

1. **The proxy forwards every unmapped path straight to the Restate admin API on `localhost:9070` with no authentication.** The Restate admin API can deregister deployments, cancel/kill/purge invocations, and run introspection SQL over invocation state. This is a full administrative-control and denial-of-service exposure reachable by anyone on the internet.
2. **None of the `/api/*` business endpoints perform any authentication or authorization.** Any client can mutate published content, trigger unbounded paid LLM/image-generation work, and read/modify any user's favorites (IDOR). User identity (`user_id`) is taken directly from the request body.

Secondary issues include path-traversal/parameter injection into the Directus API using the service's privileged static token, a wide-open default CORS policy (explicitly `*` in production `fly.toml`), verbose error messages that leak internal structure, absent rate limiting / body-size limits, and an unpinned GitHub `master` dependency (supply-chain risk).

No hardcoded secrets were found in source; all credentials are read from environment variables, and `.env` is git-ignored. That is the main thing done right.

| # | Severity | Title | Location |
|---|----------|-------|----------|
| 1 | CRITICAL | Restate admin API (port 9070) publicly exposed via unauthenticated catch-all proxy | `src/index.ts:105-118` |
| 2 | HIGH | No authentication/authorization on any `/api/*` endpoint (data mutation + financial DoS) | `src/index.ts:60-73`, `src/services/api.ts` |
| 3 | HIGH | IDOR on favorites — `user_id` trusted from request body, no ownership check | `src/services/api.ts:425-486` |
| 4 | HIGH | Path traversal / parameter injection into Directus API via unvalidated `id`/`translationId` | `src/services/api.ts:137-145`, `src/clients/directus-client.ts:104-116,329-341` |
| 5 | MEDIUM | Permissive CORS — default `*` and production `CORS_ORIGINS='*'` | `src/core/config.ts:14`, `src/index.ts:55-87`, `fly.toml` |
| 6 | MEDIUM | No rate limiting or request-size limits (financial + resource DoS) | `src/index.ts:78-155`, `src/services/api.ts:60-126` |
| 7 | MEDIUM | Verbose error messages leak internal details (Directus URLs, request bodies) to clients | `src/clients/directus-client.ts:52-87`, `src/index.ts:114-136` |
| 8 | MEDIUM | Unpinned GitHub `master` dependency (mutable supply chain) | `package.json` (`facebook-event-scraper`) |
| 9 | LOW | Filter values from `x-dancee-filter` header passed unvalidated into Directus queries | `src/services/api.ts:378-397,668-678` |
| 10 | LOW | `eval` on `.env`-derived values in `fly-secrets.sh` (shell injection) | `fly-secrets.sh` |

---

## Findings

### 1. [CRITICAL] Restate admin API publicly exposed via unauthenticated catch-all proxy
**Category:** Configuration & Deployment / Missing Authentication / Exposed admin endpoint
**File:** `src/index.ts:105-118` (also `:78`, `:157`)

**Description:**
The public HTTP proxy listens on `0.0.0.0:9080` (the port Fly.io exposes as the HTTPS service). Requests whose path is not one of the mapped `/api/*` routes fall through to:

```ts
// Proxy everything else to Restate admin UI/API (port 9070)
const targetUrl = `http://localhost:9070${pathname}${queryString ? "?" + queryString : ""}`;
const proxyReq = http.request(targetUrl, { method: req.method, headers: { ...req.headers, host: "localhost:9070" } }, ...);
```

Port 9070 is the Restate **admin** API/UI. It exposes deployment management, service management, invocation management (cancel / kill / purge), and an introspection SQL query engine over service and invocation state. The proxy forwards **any HTTP method** (`method: req.method`) and pipes the request body through, so an unauthenticated internet client can issue arbitrary admin calls. There is no auth layer anywhere in front of it. `src/__tests__/index.test.ts:116-121` even asserts this pass-through behavior as intended.

**Exploitation scenario:**
- `DELETE https://<app>.fly.dev/deployments/<id>` — deregister the service, taking down every endpoint (denial of service).
- `POST https://<app>.fly.dev/query` (Restate introspection SQL) — read invocation inputs/state, which can contain scraped content and any data passed through workflows.
- Cancel or purge in-flight invocations, corrupting processing state.

**Recommended fix:**
Never proxy to the admin port from a public listener. Remove the catch-all entirely and return `404` for unmapped paths, or restrict it to an authenticated/internal-only path. On Fly.io, keep 9070 bound to the internal interface only.

```ts
if (!mappedPath) {
  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Not found" }));
  return;
}
```

If admin access is genuinely required remotely, put it behind a separate authenticated route (bearer token / mTLS) and never behind the same public proxy as the user API.

---

### 2. [HIGH] No authentication or authorization on any `/api/*` endpoint
**Category:** Authentication & Authorization / Missing authentication
**File:** `src/index.ts:60-73` (route map), all handlers in `src/services/api.ts`

**Description:**
The proxy maps public paths (`/api/event`, `/api/event/force-reprocess`, `/api/events/process`, `/api/favorites`, `/api/event/retranslate`, …) directly to Restate handlers and forwards them to the ingress on `localhost:8080`. No token, session, or signature is checked at any layer. Every write and every expensive operation is anonymous.

**Exploitation scenario:**
- `POST /api/events/process` triggers a full batch scrape + LLM classification/extraction/translation + AI image generation across all configured groups. Each processed event spends OpenRouter LLM tokens and Flux image-generation credits. An attacker can loop this to run up unbounded third-party billing (financial DoS).
- `POST /api/event/force-reprocess` with `{ "id": <n> }` re-scrapes and **overwrites** an existing event's fields and status (`src/services/api.ts:303-376`).
- `POST /api/event` with any URL enqueues arbitrary scraping/processing work.

**Recommended fix:**
Introduce an authentication gate in the proxy before forwarding mapped routes — validate a bearer token / API key (or verify the caller's Directus session/JWT) and reject unauthenticated requests with `401`. Separate read-only public endpoints from privileged ones (`process`, `reprocess`, `force-reprocess`, `retranslate`) and require elevated auth for the latter.

```ts
const auth = req.headers["authorization"];
if (!isValidApiToken(auth)) {
  res.writeHead(401, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Unauthorized" }));
  return;
}
```

---

### 3. [HIGH] IDOR on favorites — user identity trusted from request body
**Category:** Authentication & Authorization / IDOR (broken object-level authorization)
**File:** `src/services/api.ts:425-486`

**Description:**
`createFavorite`, `deleteFavorite`, and `listFavorites` take `user_id` straight from the request payload and act on it with no verification that the caller *is* that user:

```ts
listFavorites: async (ctx, request: { user_id?: string }) => {
  if (!request?.user_id) throw new restate.TerminalError("Missing required field: 'user_id'", { errorCode: 400 });
  return ctx.run("listFavorites", () => listFavorites(request.user_id!));
}
```

Combined with Finding 2 (no auth at all), any anonymous client can enumerate or tamper with any user's favorites.

**Exploitation scenario:**
- `POST /api/favorites/list` with `{"user_id":"<victim-id>"}` returns the victim's favorited events/courses (data exposure of user activity).
- `POST /api/favorites/delete` with a victim's `user_id` removes their favorites.
- `POST /api/favorites` writes favorites into another user's account.

**Recommended fix:**
Derive `user_id` from the authenticated principal (validated token/session), never from the request body. Reject any request where the body `user_id` does not match the authenticated user.

```ts
const userId = getAuthenticatedUserId(ctx); // from verified token, not the body
return ctx.run("listFavorites", () => listFavorites(userId));
```

---

### 4. [HIGH] Path traversal / parameter injection into Directus API via unvalidated identifiers
**Category:** Injection / Path traversal
**File:** `src/services/api.ts:137-145`; `src/clients/directus-client.ts:104-116`, `:329-341`, `:113-116`

**Description:**
Identifier values from request bodies are interpolated directly into Directus API URL **paths** without validation or encoding, then handed to `fetch`, which normalizes `..` segments. Because these calls use the service's privileged static `DIRECTUS_ACCESS_TOKEN`, an attacker who controls the identifier can redirect the request to arbitrary Directus endpoints under that token's authority.

`reprocessEvent` (`api.ts:137-145`):
```ts
const res = await fetch(
  `${config.directusBaseUrl}/items/events_translations/${request.translationId}?fields=events_id,languages_code`,
  { headers: { Authorization: `Bearer ${config.directusAccessToken}`, ... } },
);
```
`getEventById` / `getCourseById` / `updateEvent` (`directus-client.ts:104-116,329-341`) interpolate `${id}` the same way. `reprocessEvent.request.id` and `forceReprocessEvent.request.id` are typed `string | number` and never validated numeric.

**Exploitation scenario:**
`POST /api/event/reprocess` with `{"translationId":"../../users"}` resolves to `${directusBaseUrl}/users?fields=events_id,languages_code`, issued with the privileged token — potentially reading the Directus user collection. More generally, `id`/`translationId` values containing `../` or `?`/`&` let an attacker reach other collections or inject query parameters into Directus requests made with elevated privileges.

**Recommended fix:**
Validate every identifier as a strict positive integer (or the exact expected format) before use, and reject anything else. Apply the same `z.number()`/regex guard already used in `retranslateItem` (`api.ts:496-501`) to `reprocessEvent`, `forceReprocessEvent`, and the client functions.

```ts
const idNum = z.number().int().positive().parse(Number(request.id));
// build path from idNum only
```

---

### 5. [MEDIUM] Permissive CORS configuration (default and production `*`)
**Category:** Data Exposure / CORS misconfiguration
**File:** `src/core/config.ts:14`, `src/index.ts:55-87`, `fly.toml` (`CORS_ORIGINS='*'`)

**Description:**
`corsOrigins` defaults to `"*"` and production `fly.toml` sets `CORS_ORIGINS='*'`. When `*`, the proxy sets `Access-Control-Allow-Origin` to `*` (or reflects any origin), allowing any website to call the API from a victim's browser. This meaningfully widens the blast radius of the missing-auth findings: any page on the web can drive the (unauthenticated) mutation/favorites endpoints on behalf of a visitor.

**Exploitation scenario:**
A malicious site loaded by any user issues cross-origin `fetch` calls to `/api/events/process` or `/api/favorites/delete`; the browser permits them because the origin is reflected/allowed.

**Recommended fix:**
Set an explicit allow-list of trusted front-end origins in production (`CORS_ORIGINS=https://app.dancee.example`). Change the code default away from `*` so a misconfiguration fails closed rather than open, and never combine `*` with credentialed requests.

---

### 6. [MEDIUM] No rate limiting or request-size limits
**Category:** Data Exposure / Input Validation (DoS)
**File:** `src/index.ts:78-155`, `src/services/api.ts:60-126`

**Description:**
Neither the proxy nor the handlers enforce per-client rate limits or maximum request body sizes. Request bodies are piped to the upstream unbounded (`req.pipe(proxyReq)`). Combined with unauthenticated, cost-incurring endpoints (LLM + image generation), this permits both financial abuse and resource exhaustion.

**Exploitation scenario:**
An attacker scripts thousands of `POST /api/event` / `/api/events/process` calls, each fanning out to paid LLM/image APIs and Directus writes, exhausting quota/budget and backlogging the queue.

**Recommended fix:**
Add IP/token-based rate limiting in the proxy and a request-body size cap (reject bodies over a small threshold for JSON endpoints). Apply stricter limits to processing endpoints. Consider a queue/concurrency cap on batch triggering.

---

### 7. [MEDIUM] Verbose error messages leak internal details to clients
**Category:** Data Exposure / Verbose errors
**File:** `src/clients/directus-client.ts:52-57,66-72,74-87`; `src/index.ts:114-116,133-136`

**Description:**
Directus helper errors embed the internal path, HTTP status, raw response body, and a preview of the outgoing request body:

```ts
throw new Error(`Directus POST ${path} error ${response.status}: ${text} (body: ${bodyPreview})`);
```

These messages propagate up and, for terminal errors, are surfaced in the API response (and the proxy's 502 handler returns `details: err.message`). This leaks backend URL structure, Directus error text, and request payloads to unauthenticated callers, aiding reconnaissance.

**Exploitation scenario:**
A crafted request that triggers a Directus 4xx returns the internal collection path and Directus's error body to the client, revealing schema/configuration details.

**Recommended fix:**
Log full detail server-side only; return a generic message + correlation id to clients. Strip `details`/`body`/upstream text from client-facing responses.

```ts
log({ level: "error", message: "Directus POST failed", path, status, text });
throw new Error("Upstream request failed"); // generic for the client
```

---

### 8. [MEDIUM] Unpinned GitHub `master` dependency (mutable supply chain)
**Category:** Dependency Vulnerabilities / Supply chain
**File:** `package.json` — `"facebook-event-scraper": "github:mjablecnik/facebook-event-scraper#master"`

**Description:**
A core dependency is installed from a GitHub fork's `master` branch with no version/commit pin and no integrity hash. Any push to that branch (or a compromise of the fork) is pulled into the next build. The Dockerfile compiles it from source (`tsc`) and executes it in-process, so a malicious change would run with the service's full privileges and network access (including the Directus token and outbound scraping).

**Exploitation scenario:**
If the fork is compromised or its owner pushes malicious code, the next image build silently ships and runs it — a classic supply-chain compromise vector.

**Recommended fix:**
Pin to an immutable commit SHA (`github:mjablecnik/facebook-event-scraper#<full-sha>`) or, better, publish a vetted, versioned package and rely on the lockfile integrity hash. Review upstream changes before bumping.

---

### 9. [LOW] Filter values from `x-dancee-filter` header passed unvalidated into Directus queries
**Category:** Input Validation / NoSQL-style filter injection
**File:** `src/services/api.ts:378-397` (`listCourses`), `:668-678` / `:43-55` (`listEvents` / `sanitizeFilter`)

**Description:**
Only the top-level filter *keys* are allow-listed; the *values* are forwarded verbatim into the Directus filter object (`{_and:[publishedFilter, extraFilter]}`). The published-only restriction is preserved by the `_and` wrapper, but arbitrary operator objects as values allow crafting expensive relational/deep queries against the CMS.

**Exploitation scenario:**
A client sets `x-dancee-filter: {"venue":{<deep relational / expensive operator tree>}}` to force costly Directus query plans (mild DoS).

**Recommended fix:**
Validate filter values with a schema (allowed operators + scalar value types per field) in addition to the key allow-list; reject unexpected shapes.

---

### 10. [LOW] `eval` on `.env`-derived values in `fly-secrets.sh`
**Category:** Injection / Command injection (deploy tooling)
**File:** `fly-secrets.sh` (`eval fly secrets set $secrets ...`)

**Description:**
Secret values read from `.env` are concatenated into a string and passed to `eval`. A value containing shell metacharacters (`$(...)`, `;`, backticks) executes on the developer's machine during deployment. Scope is limited to whoever runs the script with their own `.env`, hence LOW, but it is an avoidable injection sink.

**Recommended fix:**
Avoid `eval`; pass key/value pairs as proper arguments (e.g. build an array and call `fly secrets set "$key=$value" ...`), quoting values.

---

## Notes / Positives
- No hardcoded credentials, API keys, or tokens in source; all secrets come from environment variables. `.env` is git-ignored and excluded from the Docker image (`.dockerignore`).
- Inputs to workflow handlers are largely validated with Zod schemas; scraped data is schema-parsed.
- Directus filter keys are allow-listed to prevent trivially bypassing the published-only restriction.
- `force_https = true` is set in `fly.toml`.
- Restate's deterministic RNG (`ctx.rand.uuidv4()`) is used only for workflow keys, not security tokens — acceptable.
