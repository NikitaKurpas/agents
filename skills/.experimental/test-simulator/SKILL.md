---
name: test-simulator
description: Run iOS simulator tests and summarize xcresult output. Use when validating test suites on a simulator.
---

# Test on Simulator

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcresult-summary.sh`: emit an xcresult summary JSON.

## Steps

1. Run tests with a result bundle (pipe output).

```bash
LOG=/tmp/xcodebuild-sim-test.log
RESULT=/tmp/Tests.xcresult
xcodebuild test -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'platform=iOS Simulator,id=<UDID>,arch=arm64' \
  -resultBundlePath "$RESULT" >"$LOG" 2>&1
status=$?
```

2. If tests fail, surface the failures quickly.

```bash
rg -n -i "Test Case|failed|error:" "$LOG"
```

3. Parse the xcresult summary.

```bash
scripts/xcresult-summary.sh "$RESULT"
```

## Notes

- Always pipe `xcodebuild` output to a temp file; only read via `rg`/`tail`.
- Keep the result bundle path stable for tooling that re-reads it.
