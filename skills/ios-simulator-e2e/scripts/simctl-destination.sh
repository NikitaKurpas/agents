#!/bin/bash
# Picks a simulator device and prints UDID/NAME/STATE/DESTINATION.
# Prefers a booted iPhone, then any available iPhone, then any available device.
# Usage: ./scripts/simctl-destination.sh
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required (used by other project scripts too)." >&2
  exit 1
fi

devices_json="$(xcrun simctl list devices --json)"

pick() {
  echo "$devices_json" | jq -r "$1" | head -n1
}

candidate="$(
  pick '.devices | to_entries[] | .value[] | select(.isAvailable == true)
    | select(.state == "Booted") | select(.name | test("^iPhone"))
    | [.udid, .name, .state] | @tsv'
)"

if [[ -z "$candidate" ]]; then
  candidate="$(
    pick '.devices | to_entries[] | .value[] | select(.isAvailable == true)
      | select(.name | test("^iPhone"))
      | [.udid, .name, .state] | @tsv'
  )"
fi

if [[ -z "$candidate" ]]; then
  candidate="$(
    pick '.devices | to_entries[] | .value[] | select(.isAvailable == true)
      | [.udid, .name, .state] | @tsv'
  )"
fi

if [[ -z "$candidate" ]]; then
  echo "No available simulator devices found." >&2
  exit 1
fi

IFS=$'\t' read -r udid name state <<<"$candidate"
echo "UDID=$udid"
echo "NAME=$name"
echo "STATE=$state"
echo "DESTINATION=platform=iOS Simulator,id=$udid,arch=arm64"
