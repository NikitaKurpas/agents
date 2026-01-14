#!/bin/bash
# Prints app path, bundle id, and executable name from xcodebuild settings.
# Usage: ./scripts/xcodebuild-app-info.sh -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Device>'
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <xcodebuild-args>"
  echo "Example: $0 -scheme MyApp -destination 'generic/platform=iOS'"
  exit 2
fi

tmp="$(mktemp -t xcodebuild-app-info.XXXXXX)"
trap 'rm -f "$tmp"' EXIT

set +e
xcodebuild "$@" -quiet -hideShellScriptEnvironment -showBuildSettings >"$tmp" 2>&1
status=$?
set -e

app_info="$(
  (rg 'TARGET_BUILD_DIR|FULL_PRODUCT_NAME|PRODUCT_BUNDLE_IDENTIFIER|EXECUTABLE_NAME' "$tmp" || true) \
    | awk -F' = ' '
      $1 ~ /TARGET_BUILD_DIR/ {dir=$2}
      $1 ~ /FULL_PRODUCT_NAME/ {name=$2}
      $1 ~ /PRODUCT_BUNDLE_IDENTIFIER/ {bundle=$2}
      $1 ~ /EXECUTABLE_NAME/ {execname=$2}
      END {
        if (dir && name) print "APP_PATH=" dir "/" name
        if (bundle) print "BUNDLE_ID=" bundle
        if (execname) print "EXECUTABLE_NAME=" execname
      }'
)"

if [[ -n "$app_info" ]]; then
  printf '%s\n' "$app_info"
  exit 0
fi

if [[ $status -ne 0 ]]; then
  echo "xcodebuild failed (exit $status)"
  # rg -n -m 24 -i 'error:|error domain|unable to find a device|coresimulatorservice|simulator device support disabled|failed to initialize simulator device set|simdiskimaged' "$tmp" || true
  # echo "--- tail ---"
  cat "$tmp" || true
fi
exit "$status"
