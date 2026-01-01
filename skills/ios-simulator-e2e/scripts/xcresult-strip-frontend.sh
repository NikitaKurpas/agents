#!/bin/bash
# Removes the noisy "Failed frontend command" stanza (first line + next two lines)
# from xcodebuild output. Intended to be used in a pipe.
# Usage: xcodebuild ... 2>&1 | ./scripts/xcresult-strip-frontend.sh
set -euo pipefail

awk 'skip>0 {skip--; next} /^Failed frontend command:/ {skip=1; next} {print}'
