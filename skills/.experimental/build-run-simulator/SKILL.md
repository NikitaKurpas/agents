---
name: build-run-simulator
description: Build, install, and launch an iOS app on a simulator with optional log capture. Use for end-to-end simulator runs.
---

# Build and Run on Simulator

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcodebuild-app-info.sh`: show build settings and print app path + bundle id.

## Steps

1. Pick a simulator UDID and boot it.

```bash
xcrun simctl list devices --json
xcrun simctl boot <UDID>
xcrun simctl bootstatus <UDID> -b
open -a Simulator
```

2. Build with a simulator destination (pipe output).

```bash
LOG=/tmp/xcodebuild-sim-build.log
xcodebuild -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'platform=iOS Simulator,id=<UDID>,arch=arm64' build >"$LOG" 2>&1
tail -n 50 "$LOG"
```

3. Derive the .app path and bundle id.

```bash
scripts/xcodebuild-app-info.sh -project <path/to/App.xcodeproj> -scheme <Scheme> \
  -destination 'platform=iOS Simulator,id=<UDID>,arch=arm64'
```

4. Install and launch.

```bash
xcrun simctl install <UDID> <APP_PATH>
xcrun simctl launch --terminate-running-process <UDID> <BUNDLE_ID>
```

5. Optional: start logs (see `simulator-log-workflow`).

## Notes

- If a build fails, search for errors first: `rg -n -i "error:|fatal error:" "$LOG"`.
- Keep simulator UDID + scheme consistent across all steps.
