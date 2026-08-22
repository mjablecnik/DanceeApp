# Directus

Directus CMS deployment – local Docker development + production on [Fly.io](https://fly.io).

## Stack

- **Directus** (latest) – headless CMS
- **PostgreSQL** – Supabase-hosted database
- **S3 Storage** – Supabase Storage for file uploads
- **Fly.io** – production hosting (Frankfurt region, shared CPU, 512 MB RAM)

## Prerequisites

- Docker
- [Fly CLI](https://fly.io/docs/flyctl/install/) (for deployment)
- `curl`, optionally `jq`

## Local Development

1. Copy and fill in environment variables:
   ```sh
   cp .env.example .env
   ```

2. Start Directus:
   ```sh
   ./start-directus.sh
   ```

3. Open http://localhost:8055 and log in with your admin credentials.

### Get Access Token

```sh
./get-token.sh
```

Returns an access token using credentials from `.env`.

## Deployment (Fly.io)

1. Update `fly.toml`:
   ```toml
   app = 'your-app-name'
   ```

2. Push secrets from `.env` to Fly.io:
   ```sh
   ./fly-secrets.sh
   ```
   This automatically overrides `PUBLIC_URL` to `https://<app>.fly.dev` (derived from the `app` name set in `fly.toml`, currently `https://dancee-cms.fly.dev`) and skips `PORT`.

3. Deploy:
   ```sh
   fly deploy
   ```

## Configuration

See [`.env.example`](.env.example) for all available environment variables (database, storage, email, Redis).

## Scripts

- `./backup-db.sh` — creates a timestamped `pg_dump` backup of the Supabase database into `./backups/` (requires `DB_CONNECTION_STRING` in `.env`). Run before deploying changes.
- `./test-firebase-auth.sh <email> <password>` — exercises the Firebase Auth extension's `/link` and `/auth` endpoints end-to-end against a running Directus instance.
