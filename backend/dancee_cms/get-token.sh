#!/usr/bin/env sh

# Get Directus access token using credentials from .env
# Usage: ./get-token.sh

set -e

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found."
  exit 1
fi

EMAIL=$(grep '^ADMIN_EMAIL=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '\r\n ')
PASSWORD=$(grep '^ADMIN_PASSWORD=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '\r\n')

if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ]; then
  echo "Error: ADMIN_EMAIL or ADMIN_PASSWORD not found in $ENV_FILE"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  PAYLOAD=$(jq -n --arg e "$EMAIL" --arg p "$PASSWORD" '{email: $e, password: $p}')
else
  # Fallback without jq - escape special JSON characters
  ESC_EMAIL=$(printf '%s' "$EMAIL" | sed 's/\\/\\\\/g; s/"/\\"/g')
  ESC_PASSWORD=$(printf '%s' "$PASSWORD" | sed 's/\\/\\\\/g; s/"/\\"/g')
  PAYLOAD="{\"email\": \"${ESC_EMAIL}\", \"password\": \"${ESC_PASSWORD}\"}"
fi

RESPONSE=$(curl -s -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d '"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Error: Login failed"
  echo "$RESPONSE"
  exit 1
fi

echo "$TOKEN"
