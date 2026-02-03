---
name: test-device
description: Run tests on a connected device and summarize xcresult output. Use when validating on physical hardware.
---

# Test on Device

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcresult-summary.sh`: emit an xcresult summary JSON.

## Steps

1. Run tests with a result bundle (pipe output).

```bash
LOG=/tmp/xcodebuild-device-test.log
RESULT=/tmp/DeviceTests.xcresult
xcodebuild test -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'id=<UDID>' -resultBundlePath "$RESULT" >"$LOG" 2>&1
status=$?
```

2. Surface failures quickly.

```bash
rg -n -i "Test Case|failed|error:" "$LOG"
```

3. Parse the xcresult summary.

```bash
scripts/xcresult-summary.sh "$RESULT"
```

## Notes

- Ensure device is trusted and code signing is set up before running tests.
- Keep `xcodebuild` output in a temp file and filter with `rg`.
