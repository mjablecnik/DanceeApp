#!/usr/bin/env sh

# Start Directus using a custom Docker image with .env configuration.
# Usage: ./start-directus.sh

set -e

CONTAINER_NAME="directus"
IMAGE_NAME="dancee-directus"
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Create it first and fill in your values."
  exit 1
fi

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing existing '${CONTAINER_NAME}' container..."
  docker rm -f "$CONTAINER_NAME"
fi

echo "Building custom Directus image..."
docker build -t "$IMAGE_NAME" .

echo "Starting Directus..."

docker run -d \
  --name "$CONTAINER_NAME" \
  --env-file "$ENV_FILE" \
  -p 8055:8055 \
  -v directus-uploads:/directus/uploads \
  -v directus-extensions:/directus/extensions \
  -v directus-database:/directus/database \
  "$IMAGE_NAME"

echo ""
echo "Directus is starting at http://localhost:8055"
echo "Logs: docker logs -f $CONTAINER_NAME"
