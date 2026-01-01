#!/bin/bash
# Filters xcodebuild output down to concise suite/case status lines but preserves
# any other diagnostics verbatim (e.g. compilation errors).
# Usage: xcodebuild ... | ./scripts/xcresult-trim-log.sh
# Special handling:
#   Test suite '<name>' started on ...   -> "Test suite <name> - started"
#   Test case '<name>' passed|failed|skipped on ... -> "Test case <name> - <result>"
#   All other lines are emitted unchanged.
set -euo pipefail
shopt -s nocasematch

while IFS= read -r line; do
  # Suite start
  if [[ "$line" =~ ^Test\ suite\ \'([^\']+)\'\ started\ on ]]; then
    echo "Test suite ${BASH_REMATCH[1]} - started"
    continue
  fi

  # Case result: passed/failed/skipped
  if [[ "$line" =~ ^Test\ case\ \'([^\']+)\'\ (passed|failed|skipped)\ on ]]; then
    echo "Test case ${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}"
    continue
  fi

  # Everything else (including compilation errors) is passed through verbatim.
  echo "$line"
done
