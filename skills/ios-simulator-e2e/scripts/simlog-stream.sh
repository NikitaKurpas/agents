#!/bin/bash
# Streams simulator logs for a fixed duration and suppresses noisy lines.
# Usage:
#   ./scripts/simlog-stream.sh <udid> <process-name> [seconds] [--predicate '<expr>']
#   ./scripts/simlog-stream.sh --udid <udid> --process <name> [--duration <seconds>] [--predicate '<expr>']
# If --predicate is provided, it overrides the default process == "<process-name>" filter.
set -euo pipefail

udid=""
process_name=""
duration="3"
predicate=""

usage() {
  echo "Usage: $0 <udid> <process-name> [seconds] [--predicate '<expr>']" >&2
  echo "   or: $0 --udid <udid> --process <name> [--duration <seconds>] [--predicate '<expr>']" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --udid)
      udid="${2:-}"
      shift 2
      ;;
    --process)
      process_name="${2:-}"
      shift 2
      ;;
    --duration)
      duration="${2:-}"
      shift 2
      ;;
    --predicate)
      predicate="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$udid" ]]; then
        udid="$1"
        shift
        continue
      fi
      if [[ -z "$process_name" ]]; then
        process_name="$1"
        shift
        continue
      fi
      if [[ "$duration" == "3" && "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        duration="$1"
        shift
        continue
      fi
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$udid" || -z "$process_name" ]]; then
  usage
  exit 2
fi

if [[ ! "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "Duration must be a positive number (seconds)." >&2
  exit 2
fi

duration_num="${duration%.*}"
if [[ -z "$duration_num" || "$duration_num" -lt 0 ]]; then
  echo "Duration must be non-negative." >&2
  exit 2
fi

if [[ -z "$predicate" ]]; then
  predicate="process == \"$process_name\""
fi

set -m
( xcrun simctl spawn "$udid" log stream --style compact --predicate "$predicate" 2>&1 \
  | rg -v 'getpwuid_r did not find a match' ) &
pid=$!

sleep "$duration"
kill -- -"$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true
