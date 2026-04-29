#!/usr/bin/env sh

# Set Fly.io secrets from .env file
# Usage: ./fly-secrets.sh

set -e

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found."
  exit 1
fi

# Get app name from fly.toml for PUBLIC_URL override
APP_NAME=$(grep '^app' fly.toml 2>/dev/null | cut -d "'" -f2 | tr -d '\r\n ')

# Build secrets file without \r issues
TMPFILE=$(mktemp)

# Strip \r, skip comments/empty lines, skip PORT
tr -d '\r' < "$ENV_FILE" | while IFS='=' read -r KEY VALUE; do
  # Skip comments and empty lines
  case "$KEY" in
    \#*|"") continue ;;
  esac

  # Skip whitespace-only lines
  [ -z "$(echo "$KEY" | tr -d ' \t')" ] && continue

  # Skip PORT
  [ "$KEY" = "PORT" ] && continue

  # Override PUBLIC_URL
  if [ "$KEY" = "PUBLIC_URL" ] && [ -n "$APP_NAME" ]; then
    VALUE="https://${APP_NAME}.fly.dev"
  fi

  echo "${KEY}=${VALUE}" >> "$TMPFILE"
done

echo "Setting secrets..."
fly secrets import < "$TMPFILE"
rm -f "$TMPFILE"
echo "Done."
