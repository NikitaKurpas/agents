#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <result.xcresult> [--test-id <test-id>] [--output-dir <dir>]" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

result_path=$1
shift
test_id=""
output_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --test-id)
      if [[ $# -lt 2 ]]; then
        usage
        exit 1
      fi
      test_id=$2
      shift 2
      ;;
    --output-dir)
      if [[ $# -lt 2 ]]; then
        usage
        exit 1
      fi
      output_dir=$2
      shift 2
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$result_path" ]]; then
  echo "xcresult not found: $result_path" >&2
  exit 1
fi

if [[ -z "$test_id" ]]; then
  test_id=$(
    xcrun xcresulttool get test-results summary --path "$result_path" \
      | jq -r '.testFailures[0].testIdentifierString // empty'
  )
fi

if [[ -z "$test_id" ]]; then
  echo "no failed test id found in summary" >&2
  exit 1
fi

if [[ -z "$output_dir" ]]; then
  output_dir=$(mktemp -d /tmp/xcresult-ui-failure.XXXXXX)
else
  mkdir -p "$output_dir"
fi

xcrun xcresulttool export attachments \
  --path "$result_path" \
  --output-path "$output_dir" \
  --test-id "$test_id" >/dev/null

manifest_path="$output_dir/manifest.json"
if [[ ! -f "$manifest_path" ]]; then
  echo "manifest not found: $manifest_path" >&2
  exit 1
fi

hierarchy_file=$(
  jq -r '
    .[0].attachments[]
    | select(.suggestedHumanReadableName | startswith("App UI hierarchy"))
    | .exportedFileName
  ' "$manifest_path" | head -n 1
)

snapshot_file=$(
  jq -r '
    .[0].attachments[]
    | select(.suggestedHumanReadableName | startswith("UI Snapshot"))
    | .exportedFileName
  ' "$manifest_path" | head -n 1
)

echo "test_id=$test_id"
echo "output_dir=$output_dir"
if [[ -n "$hierarchy_file" ]]; then
  echo "a11y_tree=$output_dir/$hierarchy_file"
else
  echo "a11y_tree="
fi
if [[ -n "$snapshot_file" ]]; then
  echo "ui_snapshot=$output_dir/$snapshot_file"
else
  echo "ui_snapshot="
fi
echo "attachments:"
jq -r '.[0].attachments[].suggestedHumanReadableName' "$manifest_path"
