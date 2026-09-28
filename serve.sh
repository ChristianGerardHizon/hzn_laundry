#!/bin/bash
# Cross-platform PocketBase server launcher
# Works on Linux and macOS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"

# Load repo-root .env so pb_hooks can read RESEND_API_KEY / APP_BASE_URL.
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi
export APP_BASE_URL="${APP_BASE_URL:-http://127.0.0.1:8088}"
export APP_ENV="${APP_ENV:-dev}"

# Find pocketbase binary
if command -v pocketbase &>/dev/null; then
  PB_BIN="pocketbase"
elif [ -f "$SCRIPT_DIR/server/pocketbase" ]; then
  PB_BIN="$SCRIPT_DIR/server/pocketbase"
else
  echo "Error: pocketbase binary not found in PATH or server/"
  exit 1
fi

echo "Starting PocketBase server (dev mode)..."
echo "Data dir:    $SERVER_DIR/pb_data"
echo "Hooks dir:   $SERVER_DIR/pb_hooks"
PUBLIC_DIR="$SERVER_DIR/pb_public"
if [ ! -d "$PUBLIC_DIR" ]; then
  PUBLIC_DIR="$SCRIPT_DIR/web"
fi
echo "Public dir:  $PUBLIC_DIR"
if [ -n "${RESEND_API_KEY:-}" ]; then
  echo "Resend:      RESEND_API_KEY set"
else
  echo "Resend:      RESEND_API_KEY missing (invite/history emails will skip)"
fi
echo "App URL:     $APP_BASE_URL"
exec "$PB_BIN" serve \
  --http=127.0.0.1:8088 \
  --dir "$SERVER_DIR/pb_data" \
  --hooksDir "$SERVER_DIR/pb_hooks" \
  --migrationsDir "$SERVER_DIR/pb_migrations" \
  --publicDir "$PUBLIC_DIR" \
  --dev
