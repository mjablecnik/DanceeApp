# Security Audit — frontend/dancee_app

**Date:** 2026-07-04
**Scope:** `frontend/dancee_app/` (Flutter/Dart mobile + web client)
**Stack:** Flutter 3.29.x / Dart 3.6, `flutter_bloc`, `dio`, `firebase_auth`, Directus CMS backend, workflow (Restate) service, deployed to Fly.io behind nginx.

## Executive summary

**Overall risk level: MEDIUM**

The app is a well-structured Flutter client. Real authentication is delegated to Firebase, and the sensitive real `lib/config.dart` is correctly git-ignored (only a placeholder is on disk; `git ls-files` confirms it is untracked). No SQL/command/path-injection sinks exist — all data access goes through the Directus REST API with structured query parameters, and no `eval`/shell/file-path construction from user input is present.

The main weaknesses are architectural for a client app:

- A **static Directus API token is compiled into the shipped bundle** and is used for privileged operations (searching all users by `firebase_uid` and re-activating suspended accounts). Anyone can extract it from the web JS bundle or a decompiled APK. This is the top finding (HIGH).
- **Full HTTP error response bodies are printed in production** (`print` runs in release builds), leaking backend internals and potentially PII/tokens (MEDIUM).
- The **nginx config that serves the web build sets no security headers** (no CSP, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`) (MEDIUM).
- Minor **PII/role logging** via `debugPrint`/`print` that also executes in release (LOW).

Note on Firebase config: the API keys in `lib/firebase_options.dart` and the `googleWebClientId` in `lib/core/config.dart` are **public identifiers by design** (Google embeds them in `google-services.json` / client bundles). They are not secrets and are intentionally excluded from the findings below. Firebase project security must instead be enforced by Firebase Auth/Firestore rules and API key restrictions server-side.

---

## Findings (sorted by severity)

### 1. [HIGH] Privileged static Directus API token shipped in the client bundle
**Category:** Authentication & Authorization / Data Exposure / Hardcoded credentials
**Files:**
- `lib/config.dart:5` (`directusAccessToken`, injected at build time)
- `lib/core/config.dart:17` (`AppConfig.directusAccessToken`)
- `lib/core/clients.dart:77-79` (used as fallback `Authorization: Bearer` for every request)
- `lib/services/directus_auth_service.dart:88-111` (used to **search all users** and **PATCH user status → active**)

**Description:**
`AppConfig.directusAccessToken` is a long-lived static Directus token embedded into the compiled app. For the web target it ends up in the JavaScript bundle served by nginx; for mobile it is recoverable from the APK/IPA. Beyond serving as the anonymous read fallback in `DirectusClient`, it is used with elevated privileges in `DirectusAuthService.linkAndAuthenticate`:

```dart
// directus_auth_service.dart:88
final searchResponse = await _dio.get('/users',
  queryParameters: {'filter[firebase_uid][_eq]': firebaseUid, ...},
  options: Options(headers: {
    'Authorization': 'Bearer ${AppConfig.directusAccessToken}',  // token can read the user directory
  }),
);
...
await _dio.patch('/users/$userId', data: {'status': 'active'},   // token can re-activate accounts
  options: Options(headers: {'Authorization': 'Bearer ${AppConfig.directusAccessToken}'}));
```

**Exploitation scenario:**
An attacker opens the deployed web app, greps the JS bundle for the bearer token, then calls the Directus REST API directly with it. Depending on the token's role, they can at minimum enumerate the user directory (`GET /users?filter[firebase_uid][_eq]=...` returns `id`, `status`, and whatever `fields` the role allows) and un-suspend accounts (`PATCH /users/:id {status:'active'}`) — i.e. reverse a user's account deletion. Any collection the token's role can read/write is fully exposed with no Firebase login.

**Recommended fix:**
Move all privileged operations server-side and never ship a write-capable token to clients.
- Perform the "reactivate suspended user" step inside the Directus `firebase-auth` extension (the backend already verifies the Firebase ID token during `/link` per the prior backend audit), not in the Flutter client. Remove the `/users` search + `PATCH /users/:id` block from `linkAndAuthenticate` entirely.
- If an anonymous read token is required for public content, mint a **separate token whose role has read-only access to only the public collections** (events, courses, dance_styles, legal_pages) and nothing else — no `directus_users` access, no writes.
- Consider serving public content through a backend proxy so no token is exposed at all.

```dart
// directus_auth_service.dart — remove client-side privileged reactivation:
Future<void> linkAndAuthenticate({required String firebaseIdToken, required String firebaseUid}) async {
  // Backend /link verifies the Firebase ID token and reactivates if needed.
  await _dio.post('/directus-extension-firebase-auth/link', data: {'id_token': firebaseIdToken});
  final response = await _dio.post('/directus-extension-firebase-auth/auth', data: {'id_token': firebaseIdToken});
  _storeTokens(response.data);
}
```

---

### 2. [MEDIUM] Full HTTP error response bodies logged in production
**Category:** Data Exposure (sensitive data in logs / verbose errors)
**File:** `lib/core/clients.dart:230-235`

**Description:**
On any `badResponse`, the client prints the status and the **entire response body**:

```dart
case DioExceptionType.badResponse:
  // ignore: avoid_print
  print('[DirectusClient] badResponse: status=$statusCode body=${e.response?.data}');
```

`print` is **not stripped in Flutter release builds** — it executes on device and, critically, on the **web target it writes to the browser DevTools console**, visible to anyone. Directus error bodies can echo back submitted field values, validation details exposing schema/internals, and in some flows tokens or PII. This is verbose error/internal exposure reaching the end user's environment.

**Exploitation scenario:**
A user (or attacker) triggers a failing request (e.g. a 4xx on a profile/contact submission) and reads the raw backend error — including field contents and internal schema hints — directly from the browser console of the production web app.

**Recommended fix:**
Gate all diagnostic logging behind `kDebugMode` and never log full bodies in release:

```dart
import 'package:flutter/foundation.dart';
...
case DioExceptionType.badResponse:
  if (kDebugMode) {
    debugPrint('[DirectusClient] badResponse: status=$statusCode');
  }
```

---

### 3. [MEDIUM] Web deployment sends no security response headers
**Category:** Configuration & Deployment (missing security headers)
**File:** `nginx.conf:1-23`

**Description:**
The nginx config that serves the built web app sets no security headers. Missing:
- `Content-Security-Policy` — no XSS/data-exfil mitigation.
- `X-Frame-Options` / `frame-ancestors` — the app can be framed → clickjacking.
- `X-Content-Type-Options: nosniff` — MIME sniffing.
- `Referrer-Policy` — referrer leakage.
- `Strict-Transport-Security` — HSTS (Fly forces HTTPS via `force_https`, but no HSTS header is emitted).

**Exploitation scenario:**
An attacker embeds the production site in an invisible iframe on a lookalike page and overlays UI to trick a logged-in user into clicking actions (clickjacking), since nothing forbids framing.

**Recommended fix:**
Add a headers block to `nginx.conf`:

```nginx
server {
    listen 8080;
    ...
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    # Flutter web needs some inline/eval + wasm; tune connect-src to your API/Firebase hosts.
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://*.googleapis.com https://*.firebaseio.com https://your-directus-host https://your-workflow-host; frame-ancestors 'none'; base-uri 'self'" always;
    ...
}
```
Validate the CSP against the running app (Flutter web + Firebase Auth have specific `connect-src`/`script-src` needs) before enforcing.

---

### 4. [LOW] PII and role data logged via debugPrint/print (runs in release)
**Category:** Data Exposure (sensitive data in logs)
**Files:**
- `lib/main.dart:284, 295, 475` (logs `profile.role`, `editorRoleId`, `danceTags`, `city`)
- `lib/logic/cubits/favorites_cubit.dart:148` (`print('[FavoritesCubit] toggleFavorite FAILED: $e')`)

**Description:**
`debugPrint` and `print` both execute in Flutter release builds (only `assert`/`kDebugMode`-guarded code is stripped). These statements emit user attributes (city, dance tags), the user's role UUID, and the editor role UUID to the console — on web this is the browser DevTools console. It leaks PII and reveals the exact `editorRoleId` value that gates editor privileges.

**Exploitation scenario:**
An attacker opens the production web console, reads the logged `editorRoleId` and a target user's `role`, learning the internal identifier used for privilege checks and observing other users' profile attributes if shared/kiosk devices are used.

**Recommended fix:**
Wrap every diagnostic log in `if (kDebugMode)` (or remove them), and never include role UUIDs or profile PII:

```dart
if (kDebugMode) debugPrint('[EditorMode] isEditor=${s.profile.role == AppConfig.editorRoleId}');
```

---

### 5. [LOW] Editor authorization is enforced only client-side
**Category:** Authentication & Authorization (defense in depth)
**Files:** `lib/core/router_guard.dart:60-65`, `lib/logic/cubits/editor_mode_cubit.dart`, `lib/data/repositories/event_repository.dart:80-87`

**Description:**
Editor-only routes and the "publish/review" actions are gated in the client by comparing `profile.role == AppConfig.editorRoleId`. A modified client (or direct API calls) could attempt `PATCH /items/events/:id {published:true}`. This is only a *real* vulnerability if the Directus role/permission layer does not independently enforce that non-editors cannot write those fields — the client check is not a security boundary.

**Exploitation scenario:**
A non-editor user calls `PATCH /items/events/:id {published:true}` directly with their own session token. If Directus permissions for their role allow the write, they self-publish unreviewed content, bypassing the UI guard.

**Recommended fix:**
Confirm (and this is the actual control) that Directus collection permissions restrict `published`/`reviewed` writes and access to unpublished items to the editor role only. Treat the Flutter guard purely as UX. No client code change is required if the backend already enforces this; verify it explicitly.

---

## Categories checked with no findings

- **SQL / NoSQL / LDAP injection:** No raw queries. All Directus access uses structured `filter[...]` query parameters over REST; user-controlled values (`firebase_uid`, `userId`, item ids) are passed as parameter values, not concatenated into query strings.
- **Command / template injection:** No `Process`, shell, `eval`, or server-side template rendering in the client.
- **Path traversal:** No user-controlled filesystem paths; uploads use `image_picker`/`image_cropper` output paths, not user-typed paths.
- **XSS / unsafe HTML:** Flutter renders via its own widget layer (no DOM injection). Markdown legal content (`legal_page_screen.dart`) is admin-authored CMS content rendered by `flutter_markdown`, which does not execute scripts.
- **URL launching:** `openUrl` (`shared/utils/url_launcher.dart`) forces an `http(s)://` prefix and uses `Uri.tryParse` + `canLaunchUrl`, preventing arbitrary-scheme launches; `openMap` interpolates only numeric lat/lng and URL-encodes the address.
- **Cryptography:** No custom crypto, no weak hashing, no hardcoded IV/keys; password handling is fully delegated to Firebase Auth.
- **JWT handling:** Tokens are opaque to the client; Firebase ID token verification and Directus token issuance happen server-side.
- **Dependencies:** Versions are current (dio 5.9.2, firebase_auth 5.7.0, go_router 14.8.1, url_launcher 6.3.2, image_picker 1.2.0, flutter_markdown 0.7.7+1, shared_preferences 2.5.3, etc.). No known-vulnerable versions identified at audit time. `image_cropper_platform_interface` is pinned to 6.x for SDK compatibility (documented), not a security concern.
- **Committed secrets:** The real `lib/config.dart` is git-ignored and untracked (only a placeholder exists on disk); `.gitignore` also excludes Firebase platform config files. Firebase API keys / OAuth client IDs present in tracked files are public identifiers, not secrets.
