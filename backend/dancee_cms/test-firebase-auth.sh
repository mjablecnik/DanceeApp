#!/usr/bin/env sh

# Test Firebase Auth integration with Directus.
#
# Prerequisites:
#   - Directus running (locally or on Fly.io) with the Firebase extension
#   - A Firebase user created (via Firebase Console or the app)
#   - jq installed (brew install jq)
#
# Usage:
#   ./test-firebase-auth.sh <email> <password>
#
# Example:
#   ./test-firebase-auth.sh test@example.com MyPassword123

set -e

# ---------------------------------------------------------------------------
# Configuration — set these via environment variables or a local .env.test file
# ---------------------------------------------------------------------------
if [ -z "$FIREBASE_API_KEY" ]; then
  echo "Error: FIREBASE_API_KEY environment variable is not set."
  echo "  export FIREBASE_API_KEY=<your-firebase-web-api-key>"
  exit 1
fi
DIRECTUS_URL="${DIRECTUS_URL:-https://dancee-cms.fly.dev}"
FIREBASE_ENDPOINT_PREFIX="/directus-extension-firebase-auth"

# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./test-firebase-auth.sh <email> <password>"
  exit 1
fi

EMAIL="$1"
PASSWORD="$2"

echo "=== Step 1: Sign in to Firebase ==="
echo "Email: $EMAIL"
echo ""

FIREBASE_RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"returnSecureToken\":true}")

# Check for Firebase error
FIREBASE_ERROR=$(echo "$FIREBASE_RESPONSE" | jq -r '.error.message // empty')
if [ -n "$FIREBASE_ERROR" ]; then
  echo "Firebase sign-in FAILED: $FIREBASE_ERROR"
  echo ""
  echo "If USER_NOT_FOUND, create a test user first:"
  echo "  1. Firebase Console → Authentication → Add user"
  echo "  2. Or use: ./test-firebase-auth.sh with signUp endpoint"
  exit 1
fi

ID_TOKEN=$(echo "$FIREBASE_RESPONSE" | jq -r '.idToken')
LOCAL_ID=$(echo "$FIREBASE_RESPONSE" | jq -r '.localId')

echo "Firebase sign-in OK"
echo "UID: $LOCAL_ID"
echo "ID Token: ${ID_TOKEN:0:50}..."
echo ""

echo "=== Step 2: Link Firebase user to Directus ==="
echo "POST $DIRECTUS_URL${FIREBASE_ENDPOINT_PREFIX}/link"
echo ""

LINK_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$DIRECTUS_URL${FIREBASE_ENDPOINT_PREFIX}/link" \
  -H "Content-Type: application/json" \
  -d "{\"id_token\":\"${ID_TOKEN}\"}")

LINK_HTTP_CODE=$(echo "$LINK_RESPONSE" | tail -1)
LINK_BODY=$(echo "$LINK_RESPONSE" | sed '$d')

if [ "$LINK_HTTP_CODE" -ge 200 ] && [ "$LINK_HTTP_CODE" -lt 300 ]; then
  echo "Link OK (HTTP $LINK_HTTP_CODE)"
  echo "$LINK_BODY" | jq . 2>/dev/null || echo "$LINK_BODY"
else
  echo "Link FAILED (HTTP $LINK_HTTP_CODE)"
  echo "$LINK_BODY" | jq . 2>/dev/null || echo "$LINK_BODY"
  exit 1
fi
echo ""

echo "=== Step 3: Get Directus tokens ==="
echo "POST $DIRECTUS_URL${FIREBASE_ENDPOINT_PREFIX}/auth"
echo ""

AUTH_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$DIRECTUS_URL${FIREBASE_ENDPOINT_PREFIX}/auth" \
  -H "Content-Type: application/json" \
  -d "{\"id_token\":\"${ID_TOKEN}\"}")

AUTH_HTTP_CODE=$(echo "$AUTH_RESPONSE" | tail -1)
AUTH_BODY=$(echo "$AUTH_RESPONSE" | sed '$d')

if [ "$AUTH_HTTP_CODE" -ge 200 ] && [ "$AUTH_HTTP_CODE" -lt 300 ]; then
  echo "Auth OK (HTTP $AUTH_HTTP_CODE)"
  echo "$AUTH_BODY" | jq . 2>/dev/null || echo "$AUTH_BODY"
else
  echo "Auth FAILED (HTTP $AUTH_HTTP_CODE)"
  echo "$AUTH_BODY" | jq . 2>/dev/null || echo "$AUTH_BODY"
  exit 1
fi
echo ""

ACCESS_TOKEN=$(echo "$AUTH_BODY" | jq -r '.data.access_token // empty')

if [ -n "$ACCESS_TOKEN" ]; then
  echo "=== Step 4: Test Directus API with token ==="
  echo "GET $DIRECTUS_URL/users/me"
  echo ""

  ME_RESPONSE=$(curl -s -w "\n%{http_code}" \
    "$DIRECTUS_URL/users/me" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

  ME_HTTP_CODE=$(echo "$ME_RESPONSE" | tail -1)
  ME_BODY=$(echo "$ME_RESPONSE" | sed '$d')

  if [ "$ME_HTTP_CODE" -ge 200 ] && [ "$ME_HTTP_CODE" -lt 300 ]; then
    echo "API call OK (HTTP $ME_HTTP_CODE)"
    echo "$ME_BODY" | jq '.data | {id, email, role}' 2>/dev/null || echo "$ME_BODY"
  else
    echo "API call FAILED (HTTP $ME_HTTP_CODE)"
    echo "$ME_BODY" | jq . 2>/dev/null || echo "$ME_BODY"
  fi
else
  echo "Skipping Step 4 — no access_token received."
fi

echo ""
echo "=== Done ==="
