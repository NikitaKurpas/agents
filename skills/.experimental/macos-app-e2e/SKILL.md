---
name: macos-app-e2e
description: Build, launch, stop, and optionally test a macOS app from an Xcode project/workspace. Use for macOS app dev cycles.
---

# macOS App End-to-End

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcodebuild-app-info.sh`: show build settings and print app path + bundle id.
- `scripts/xcresult-summary.sh`: emit an xcresult summary JSON.

## Steps

1. Build (pipe output).

```bash
LOG=/tmp/xcodebuild-macos-build.log
xcodebuild -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'platform=macOS' build >"$LOG" 2>&1
tail -n 50 "$LOG"
```

2. Derive .app path.

```bash
scripts/xcodebuild-app-info.sh -project <path/to/App.xcodeproj> -scheme <Scheme> \
  -destination 'platform=macOS'
```

3. Launch and stop.

```bash
open <APP_PATH> --args <optional-args>
pkill -x <EXECUTABLE_NAME>
```

4. Optional: run tests and parse results.

```bash
LOG=/tmp/xcodebuild-macos-test.log
RESULT=/tmp/MacTests.xcresult
xcodebuild test -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'platform=macOS' -resultBundlePath "$RESULT" >"$LOG" 2>&1
scripts/xcresult-summary.sh "$RESULT"
```

## Notes

- Always pipe `xcodebuild` output to a temp file, then `rg`/`tail`.
