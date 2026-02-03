#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  xcresult-summary.sh <path/to/Tests.xcresult> [output.json]

Outputs:
  SUMMARY_PATH
EOF
}

result_path="${1:-}"
out_path="${2:-}"

if [[ -z "$result_path" ]]; then
  usage
  exit 1
fi

if [[ -z "$out_path" ]]; then
  out_path="/tmp/xcresult-summary.$(date +%s).json"
fi

xcrun xcresulttool get test-results summary --path "$result_path" >"$out_path"
echo "SUMMARY_PATH=$out_path"
