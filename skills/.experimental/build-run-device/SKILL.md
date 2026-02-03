---
name: build-run-device
description: Build, install, and launch an app on a physical Apple device using devicectl. Use when deploying to hardware after signing is configured.
---

# Build and Run on Device

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcodebuild-app-info.sh`: show build settings and print app path + bundle id.

## Steps

1. List connected devices and pick a UDID.

```bash
xcrun devicectl list devices --json-output /tmp/devices.json
```

2. Build for the device (pipe output).

```bash
LOG=/tmp/xcodebuild-device-build.log
xcodebuild -scheme <Scheme> -project <path/to/App.xcodeproj> \
  -destination 'id=<UDID>' build >"$LOG" 2>&1
tail -n 50 "$LOG"
```

3. Derive the .app path and bundle id.

```bash
scripts/xcodebuild-app-info.sh -project <path/to/App.xcodeproj> -scheme <Scheme> \
  -destination 'id=<UDID>'
```

4. Install and launch.

```bash
xcrun devicectl device install app --device <UDID> <APP_PATH>
xcrun devicectl device process launch --device <UDID> \
  --terminate-existing --json-output /tmp/launch.json <BUNDLE_ID>
```

## Notes

- Code signing must be configured in Xcode before device builds will succeed.
- If `devicectl` is unavailable, fall back to `xcrun xctrace list devices` for discovery.
- Keep `xcodebuild` output in temp logs and filter with `rg`.
