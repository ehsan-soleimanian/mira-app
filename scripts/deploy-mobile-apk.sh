#!/usr/bin/env bash
# Upload Flutter APK + version.json to miramind.io/downloads (called from CI or locally).
set -euo pipefail

APK_PATH="${1:-build/app/outputs/flutter-apk/app-release.apk}"
MANIFEST_PATH="${2:-version.json}"
REMOTE_DIR="${MOBILE_REMOTE_DIR:-/var/www/miramind/downloads}"
SSH_HOST="${DEPLOY_USER:?}@${DEPLOY_HOST:?}"
SSH_PORT="${DEPLOY_PORT:-22}"
KEY_FILE="${DEPLOY_SSH_KEY_FILE:-$HOME/.ssh/deploy_key}"

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found: $APK_PATH" >&2
  exit 1
fi
if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "Manifest not found: $MANIFEST_PATH" >&2
  exit 1
fi

SSH_OPTS=(-i "$KEY_FILE" -o StrictHostKeyChecking=no)

ssh "${SSH_OPTS[@]}" -p "$SSH_PORT" "$SSH_HOST" "mkdir -p '${REMOTE_DIR}'"
scp "${SSH_OPTS[@]}" -P "$SSH_PORT" "$APK_PATH" "${SSH_HOST}:${REMOTE_DIR}/mira-latest.apk"
scp "${SSH_OPTS[@]}" -P "$SSH_PORT" "$MANIFEST_PATH" "${SSH_HOST}:${REMOTE_DIR}/version.json"

echo "Uploaded to https://miramind.io/downloads/mira-latest.apk"
