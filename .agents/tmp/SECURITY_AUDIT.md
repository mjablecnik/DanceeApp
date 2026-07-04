# Security Audit — backend/dancee_cms

**Date:** 2026-07-04
**Scope:** `backend/dancee_cms/` (Directus 11.17.3 CMS deployment)

## Project profile

- **Framework:** Directus 11.17.3 (self-hosted headless CMS), deployed on Fly.io, backed by Supabase PostgreSQL + Supabase S3 storage.
- **Custom code:** one Directus *endpoint* extension, `firebase-extension/index.js` (Node.js, ESM), which bridges Firebase Authentication to Directus by minting Directus sessions. Dependencies: `firebase-admin ^13`, `jsonwebtoken ^9`.
- **Supporting files:** deployment/utility shell scripts (`fly-secrets.sh`, `get-token.sh`, `backup-db.sh`, `start-directus.sh`, `test-firebase-auth.sh`), `Dockerfile`, `fly.toml`, `.env.example`.
- No `.env` or private keys are committed; `.gitignore` excludes `.env` and `backups/`.

## Executive summary

**Overall risk level: CRITICAL**

The custom Firebase auth extension contains two independent, chainable authentication-bypass flaws that each allow full account takeover — including of Directus **administrator** accounts:

1. The `/auth` endpoint mints a valid Directus access token + persistent session for a user **given only that user's Firebase UID**, with no proof of identity (no token, no password, no secret). A UID is an identifier, not a credential.
2. The `/link` endpoint verifies a Firebase ID token's signature but **never checks `email_verified`**, and links whatever email the token carries to a pre-existing Directus user with the same email. An attacker can register an unverified Firebase account under a victim's email (e.g. an admin's), link it, then use `/auth` to log in as that victim.

Both endpoints are also unauthenticated and unthrottled, so UIDs can be brute-forced/replayed at will. These must be fixed before the extension is exposed to production. Additional lower-severity issues (DB TLS verification disabled, an insecure CORS default in the example config, PII in logs, a committed API key) are listed below.

---

## Findings (sorted by severity)

### 1. [CRITICAL] `/auth` issues Directus tokens with no authentication — UID is treated as a credential
- **Category:** Authentication & Authorization (broken authentication / account takeover)
- **File:** `firebase-extension/index.js:124-177`
- **Description:** The `/auth` route accepts a JSON body `{ "uid": "..." }`, looks up the Directus user whose `external_identifier` equals that UID, and — with no further verification — signs a Directus access token (`jwt.sign(payload, env.SECRET, ...)`), inserts a real refresh session into `directus_sessions`, and returns both tokens. No Firebase ID token is required or verified; possession of the UID string is sufficient. Firebase UIDs are identifiers, not secrets: they are shared with clients, appear in logs and API responses (this extension even logs them, see finding 6), and here they are the *only* thing gating token issuance.
- **Exploitation scenario:** An attacker who learns any linked user's Firebase UID (from a leaked log, a client bug, another API, or by brute force given no rate limiting) sends `POST /directus-extension-firebase-auth/auth {"uid":"<victim-uid>"}` and receives a fully valid Directus access token acting as that user. If the victim's role has `admin_access`, the attacker gets an admin token. Chained with finding 2, the attacker can take over an existing admin outright.
- **Recommended fix:** Require and verify a Firebase ID token instead of a bare UID; derive the UID from the verified token, exactly like `/link` does:
  ```js
  const idToken = req.body?.id_token;
  if (!idToken) return res.status(400).json({ error: "id_token is required." });
  if (!ensureFirebaseInitialized(env, logger))
    return res.status(500).json({ error: "Firebase not configured." });
  let decoded;
  try { decoded = await admin.auth().verifyIdToken(idToken, true); }
  catch { return res.status(401).json({ error: "Invalid Firebase token." }); }
  if (!decoded.email_verified) return res.status(403).json({ error: "Email not verified." });
  const uid = decoded.uid; // never trust req.body.uid
  // ...look up user by external_identifier === uid, then mint tokens
  ```
  Also add Directus rate limiting for these endpoints.

### 2. [CRITICAL] `/link` does not check `email_verified` — account takeover of existing users by email squatting
- **Category:** Authentication & Authorization (broken authentication / privilege escalation)
- **File:** `firebase-extension/index.js:44-84` (email trust at 50-53, link at 65-84)
- **Description:** `/link` verifies the Firebase ID token's signature via `admin.auth().verifyIdToken(idToken)` but only checks that an `email` claim exists — it never checks `decodedToken.email_verified`. With Firebase Email/Password auth, an account can hold an arbitrary, *unverified* email. When the email matches an existing Directus user, the code overwrites that user's `external_identifier` with the caller's Firebase UID and sets `provider = "firebase"` (lines 69-72), effectively binding the attacker's Firebase identity to the victim's Directus account.
- **Exploitation scenario:** A Directus admin `admin@dancee.app` has never used Firebase. An attacker creates a Firebase Email/Password account with email `admin@dancee.app` (no verification required), obtains a valid `id_token`, and calls `/link`. The extension finds the existing admin by email and sets that admin's `external_identifier` to the attacker's UID. The attacker then calls `/auth` (finding 1) with their own UID and receives an **admin** access token. Full administrative account takeover.
- **Recommended fix:** Reject unverified emails before any linking, and prefer matching by verified UID rather than silently claiming accounts by email:
  ```js
  if (!decodedToken.email_verified) {
    return res.status(403).json({ error: "Firebase email is not verified." });
  }
  ```
  Consider not auto-linking to a pre-existing Directus user by email at all (or gating it behind an explicit, admin-approved verification step), since email match ≠ ownership proof.

### 3. [MEDIUM] Database TLS certificate validation disabled
- **Category:** Cryptography / Configuration
- **File:** `.env.example:9` (`DB_SSL__REJECT_UNAUTHORIZED=false`)
- **Description:** The example configuration (intended to be copied to the deployed `.env`) disables verification of the PostgreSQL server's TLS certificate. The connection may still be encrypted, but with certificate validation off it is vulnerable to man-in-the-middle interception/tampering of all database traffic, including credentials and PII. Supabase provides a valid CA-signed certificate, so disabling verification is unnecessary.
- **Exploitation scenario:** An attacker positioned on the network path between the Fly.io app and Supabase presents a forged certificate; the client accepts it, and the attacker reads/modifies all queries and results.
- **Recommended fix:** Remove `DB_SSL__REJECT_UNAUTHORIZED=false` (or set it to `true`) and, if a custom CA is required, provide it via `DB_SSL__CA`. Verify Supabase's certificate chain works with validation enabled.

### 4. [MEDIUM] Insecure CORS default in example config (`CORS_ORIGIN=true` with credentials)
- **Category:** Data Exposure (CORS misconfiguration)
- **File:** `.env.example:31` (`CORS_ORIGIN=true`) with `.env.example:35` (`CORS_CREDENTIALS=true`)
- **Description:** The shipped example sets `CORS_ORIGIN=true`, which makes Directus reflect the caller's `Origin` header, combined with `CORS_CREDENTIALS=true`. This lets *any* website make credentialed cross-origin requests to the API. The production `fly.toml` correctly pins `CORS_ORIGIN = "https://dancee-app.fly.dev"`, but the example is the template most likely to be copied, and a CSRF/credential-exposure surface opens if it reaches production.
- **Exploitation scenario:** A malicious site loaded in a logged-in user's browser issues credentialed `fetch()` calls to the Directus API; because the origin is reflected and credentials are allowed, the browser exposes the responses to the attacker's script.
- **Recommended fix:** Change the example default to an explicit allow-list and document that `true` is development-only:
  ```sh
  # CORS_ORIGIN=true is DEV ONLY. In production set an explicit allow-list:
  CORS_ORIGIN=https://dancee-app.fly.dev
  ```

### 5. [LOW] Firebase Web API key committed in test script
- **Category:** Authentication & Authorization (credential in source) / Data Exposure
- **File:** `test-firebase-auth.sh:21` (`FIREBASE_API_KEY="AIzaSy..."`)
- **Description:** A Firebase Web API key is hardcoded in a committed script. Firebase Web API keys are designed to be public (they identify the project, not authorize privileged actions), so this is low severity, but committing it still discloses the project and lets anyone exercise the project's Identity Toolkit sign-in/sign-up endpoints, which — combined with findings 1 & 2 — assists the email-squatting attack. Firebase Authentication settings (e.g. disabling public sign-up, App Check, authorized domains) are what actually protect the project.
- **Recommended fix:** Move the key to an environment variable / local untracked config, and harden the Firebase project (restrict the key in Google Cloud, enable App Check, disable open email/password sign-up if not needed).

### 6. [LOW] PII (email addresses and Firebase UIDs) written to logs
- **Category:** Data Exposure (sensitive data in logs)
- **File:** `firebase-extension/index.js:81, 113, 141, 187` (also 46, 144)
- **Description:** The extension logs user email addresses, Firebase UIDs, and update payloads at info level on the normal auth path. UIDs logged here are exactly the value that finding 1 treats as a credential, so log access effectively becomes token-minting access. This is PII and, given the design, security-sensitive.
- **Exploitation scenario:** Anyone with read access to application logs (ops staff, a log aggregation service, a log-exposure bug) harvests UIDs/emails and, via finding 1, mints tokens.
- **Recommended fix:** Drop UIDs/emails from info logs or reduce to counts/opaque internal IDs; keep detailed identifiers at debug level only. Fixing finding 1 also removes the UID-as-credential risk.

### 7. [LOW] Unpinned dependency installation in Dockerfile
- **Category:** Dependency Vulnerabilities / Supply chain
- **File:** `Dockerfile:13` (`RUN pnpm install firebase-admin jsonwebtoken`)
- **Description:** The image installs `firebase-admin` and `jsonwebtoken` with no version constraint and no lockfile, so each rebuild can silently pull a different (potentially malicious or regressed) version. The extension's own `package.json` pins with caret ranges only.
- **Recommended fix:** Pin exact versions and commit a lockfile (`pnpm-lock.yaml`), then `pnpm install --frozen-lockfile`. Prefer installing only inside the extension directory (which already has its deps) rather than globally.

### 8. [LOW] Database password exposed via process arguments during backup
- **Category:** Data Exposure
- **File:** `backup-db.sh:51` (`pg_dump "$DIRECT_URL" ...`)
- **Description:** The full connection string (including the DB password) is passed as a command-line argument to `pg_dump`, so it is visible in the process table (`ps aux`) to any local user for the duration of the dump.
- **Recommended fix:** Pass the password via the `PGPASSWORD` environment variable or a `~/.pgpass` file and give `pg_dump` the host/port/db/user flags separately, keeping the secret out of `argv`.

---

## Notes / things checked and found OK
- No SQL injection in the extension: all DB access goes through Directus services (`readByQuery`, `createOne`, `updateOne`) and parameterized Knex queries.
- No command injection in the shell scripts: `get-token.sh` builds JSON via `jq` (with a safe `sed` escaping fallback), and `fly-secrets.sh` uses `fly secrets import` with no `eval`.
- Access tokens are signed with the real Directus `env.SECRET` (not a hardcoded key) using HS256 with an `expiresIn`; refresh tokens use `crypto.randomBytes(32)` (CSPRNG). Expired sessions are pruned on each `/auth`.
- `force_https = true` in `fly.toml`; no `.env`/private keys committed; `.gitignore`/`.dockerignore` exclude secrets.
