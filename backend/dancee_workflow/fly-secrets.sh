#!/bin/sh

# Sets Fly.io secrets from .env file.
# Only sets secrets — does not create the app or skip any keys.
#
# Usage:
#   cd backend/dancee_workflow
#   chmod +x fly-secrets.sh
#   ./fly-secrets.sh

set -e

ENV_FILE=".env"
TOML_FILE="fly.toml"

if [ ! -f "$TOML_FILE" ]; then
  echo "Error: $TOML_FILE not found. Run this script from the service directory."
  exit 1
fi

APP_NAME=$(grep '^app\s*=' "$TOML_FILE" | sed "s/^app[[:space:]]*=[[:space:]]*['\"]//;s/['\"].*$//" | tr -d '\r')

if [ -z "$APP_NAME" ]; then
  echo "Error: Could not parse app name from $TOML_FILE"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Copy from .env.example and fill in values."
  exit 1
fi

if ! command -v fly > /dev/null 2>&1; then
  echo "Error: fly CLI not found. Install it: https://fly.io/docs/hands-on/install-flyctl/"
  exit 1
fi

# Build an argument list without eval to prevent shell injection from .env values.
set --

while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  case "$line" in
    ""|\#*) continue ;;
  esac

  key="${line%%=*}"
  value="${line#*=}"

  # Skip empty values
  if [ -z "$value" ]; then
    echo "Skipping $key (empty value)"
    continue
  fi

  set -- "$@" "${key}=${value}"
done < "$ENV_FILE"

if [ "$#" -eq 0 ]; then
  echo "No secrets to set."
  exit 0
fi

echo "Setting secrets on $APP_NAME..."
fly secrets set "$@" --app "$APP_NAME"
echo "Done."
