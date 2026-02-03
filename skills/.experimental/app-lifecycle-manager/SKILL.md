---
name: app-lifecycle-manager
description: Derive app paths and bundle IDs, then install/launch/stop across simulator, device, and macOS. Use for cross-platform app control.
---

# App Lifecycle Manager

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcodebuild-app-info.sh`: show build settings and print app path + bundle id.

## Steps

1. Derive app path and bundle id from build settings.

```bash
scripts/xcodebuild-app-info.sh -project <path/to/App.xcodeproj> -scheme <Scheme>
# For simulator/device-specific settings, add:
#   -destination 'platform=iOS Simulator,id=<SIM_UDID>,arch=arm64'
#   -destination 'id=<DEV_UDID>'
```

2. Simulator lifecycle.

```bash
xcrun simctl install <SIM_UDID> <APP_PATH>
xcrun simctl launch --terminate-running-process <SIM_UDID> <BUNDLE_ID>
xcrun simctl terminate <SIM_UDID> <BUNDLE_ID>
```

3. Device lifecycle.

```bash
xcrun devicectl device install app --device <DEV_UDID> <APP_PATH>
xcrun devicectl device process launch --device <DEV_UDID> \
  --terminate-existing --json-output /tmp/launch.json <BUNDLE_ID>
xcrun devicectl device process terminate --device <DEV_UDID> --pid <PID>
```

4. macOS lifecycle.

```bash
open <APP_PATH>
pkill -x <EXECUTABLE_NAME>
```

## Notes

- Keep build settings output in temp files and filter with `rg`.
- Use simulator UDID or device UDID consistently per run.
