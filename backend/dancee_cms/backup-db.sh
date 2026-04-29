#!/bin/sh
# =============================================================================
# Supabase PostgreSQL Backup Script
# =============================================================================
# Creates a pg_dump backup of the Supabase database before deploying changes.
#
# Prerequisites:
#   - pg_dump installed (comes with PostgreSQL client tools)
#   - .env file in the same directory with DB_CONNECTION_STRING
#
# Usage:
#   ./backup-db.sh
#
# Output:
#   Creates a timestamped .sql.gz file in ./backups/
# =============================================================================

set -e

SCRIPT_DIR="$(dirname "$0")"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found at $ENV_FILE"
  exit 1
fi

# Extract DB_CONNECTION_STRING from .env
DB_URL=$(grep '^DB_CONNECTION_STRING=' "$ENV_FILE" | sed 's/^DB_CONNECTION_STRING=//')

if [ -z "$DB_URL" ]; then
  echo "Error: DB_CONNECTION_STRING not found in .env"
  exit 1
fi

# Create backups directory
BACKUP_DIR="$SCRIPT_DIR/backups"
mkdir -p "$BACKUP_DIR"

# Generate timestamped filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/dancee_db_${TIMESTAMP}.sql.gz"

echo "Starting database backup..."
echo "Output: $BACKUP_FILE"

# Use direct connection (port 5432) instead of pooler (port 6543) for pg_dump
# Supabase pooler (PgBouncer) doesn't support pg_dump
DIRECT_URL=$(echo "$DB_URL" | sed 's/:6543/:5432/' | sed 's/pooler\.supabase\.com/supabase.com/')

pg_dump "$DIRECT_URL" --no-owner --no-privileges --clean --if-exists 2>/dev/null | gzip > "$BACKUP_FILE"

SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
echo "Backup complete: $BACKUP_FILE ($SIZE)"
