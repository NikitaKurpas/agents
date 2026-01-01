#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="${PUPPETEER_CACHE_DIR:-$HOME/.cache/puppeteer}"

if [ -d "$CACHE_DIR" ] && find "$CACHE_DIR" -maxdepth 6 -type f \( -name "Chromium" -o -name "chrome" -o -name "Chrome" \) -print -quit | grep -q .; then
  echo "Puppeteer Chrome runtime already present in: $CACHE_DIR"
  exit 0
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Install Node.js or set PUPPETEER_EXECUTABLE_PATH to an existing Chrome."
  exit 1
fi

echo "Installing Puppeteer Chrome runtime into: $CACHE_DIR"
PUPPETEER_CACHE_DIR="$CACHE_DIR" npx puppeteer browsers install chrome
echo "Done."
