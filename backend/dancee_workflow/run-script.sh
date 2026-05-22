#!/bin/bash
set -euo pipefail

# Run any script inside the dancee-workflow Docker container with bun.
# Scripts are mounted from the local scripts/ directory.
# Usage: ./run-script.sh scripts/test-share-url.ts [args...]

APP_NAME=$(grep '^app\s*=' fly.toml | sed "s/^app\s*=\s*['\"]\\(.*\\)['\"]$/\\1/")
IMAGE_NAME="${APP_NAME}-dev"
SCRIPT="${1:?Usage: ./run-script.sh scripts/<script-name>.ts [args...]}"
shift

# Build using the build stage only (has bun + source + node_modules)
# Use --build-arg to allow unfrozen lockfile when lockfile is out of sync
docker build --target build -t "$IMAGE_NAME" --build-arg BUN_INSTALL_FLAGS="" .

# Run the script with scripts/ mounted and .env loaded
docker run --rm \
  --env-file .env \
  -v "$(pwd)/scripts:/app/scripts" \
  "$IMAGE_NAME" \
  bun "$SCRIPT" "$@"
