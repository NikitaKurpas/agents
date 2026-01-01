#!/bin/bash
set -euo pipefail

bundle_path="${1:-}"

if [[ -z "${bundle_path}" ]]; then
  echo "Usage: $0 <path-to-xcresult-bundle>" >&2
  exit 1
fi

if [[ ! -d "${bundle_path}" ]]; then
  echo "No xcresult bundle found at ${bundle_path}" >&2
  exit 0
fi

# Prefer the concise Xcode 16+ summary format; no legacy fallback needed.
json=$(xcrun xcresulttool get test-results summary --path "${bundle_path}" --format json 2>/dev/null || true)

if [[ -z "${json}" ]]; then
  echo "xcresulttool returned no data for ${bundle_path}" >&2
  exit 0
fi

failures=$(echo "${json}" | jq -r '
  (.testFailures // [])
  | map("- " + (.testIdentifierString // .testName // "unknown test") + ": " + (.failureText // "No message"))
  | unique
  | .[]
')

if [[ -z "${failures}" ]]; then
  echo "No parsed test failures found in ${bundle_path}" >&2
  exit 0
fi

echo "---- xcodebuild test failures ----"
echo "${failures}"
echo "----------------------------------"
