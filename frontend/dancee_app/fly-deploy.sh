#!/bin/sh
# Deploys the Flutter web app to Fly.io.
# Usage: ./fly-deploy.sh

set -e

APP_NAME=$(grep '^app' fly.toml | sed "s/.*= *['\"]\\(.*\\)['\"].*/\\1/")

echo "Deploying $APP_NAME..."
fly deploy --app "$APP_NAME"
