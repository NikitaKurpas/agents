#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <attachments-dir>" >&2
  exit 1
fi

attachments_dir=$1
manifest_path="$attachments_dir/manifest.json"

if [[ ! -f "$manifest_path" ]]; then
  echo "manifest not found: $manifest_path" >&2
  exit 1
fi

tree_file=$(
  jq -r '
    .[0].attachments[]
    | select(.suggestedHumanReadableName | startswith("App UI hierarchy"))
    | .exportedFileName
  ' "$manifest_path" | head -n 1
)

if [[ -z "$tree_file" ]]; then
  echo "no App UI hierarchy attachment found in $manifest_path" >&2
  exit 1
fi

cat "$attachments_dir/$tree_file"
