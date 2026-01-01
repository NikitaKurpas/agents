#!/bin/bash
# Filters xcodebuild output to errors, warnings, and high-signal status lines.
# Usage: xcodebuild ... 2>&1 | ./scripts/xcbuild-trim-log.sh
set -euo pipefail

while IFS= read -r line; do
  case "$line" in
    "=== BUILD TARGET"*|"** BUILD SUCCEEDED **"|"** BUILD FAILED **")
      echo "$line"
      ;;
    *" error:"*|*" warning:"*|*" note:"*)
      echo "$line"
      ;;
    *"The following build commands failed:"*)
      echo "$line"
      ;;
    *)
      # Pass through anything unexpected to avoid hiding useful diagnostics.
      echo "$line"
      ;;
  esac
done
