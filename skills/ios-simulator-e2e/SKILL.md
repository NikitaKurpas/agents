---
name: ios-simulator-e2e
description: End-to-end iOS app development workflow on the iOS Simulator using CLI tools (xcodebuild, xcrun simctl, log stream, xctrace). Use to build, install, run, log, inspect UI, interact, capture screenshots/recordings, or iterate on iOS apps in the Simulator. Prefer the axe skill for UI inspection/interaction when present.
---

# iOS Simulator End-to-End Workflow

## Preferred UI tooling

- Prefer using the `axe` skill for UI inspection and interaction when it is available.
- Fall back to XCUITest-driven UI dumps/interactions or `simctl` only if `axe` is unavailable.

## Quick start (CLI)

- In sandboxed environments, run Xcode/Simulator commands with escalated permissions to avoid CoreSimulatorService and device discovery failures.
- List Simulators: `xcrun simctl list devices`
- Boot a device: `xcrun simctl boot <device-udid>` or `xcrun simctl boot "iPhone 15"`
- Wait for boot: `xcrun simctl bootstatus <device-udid> -b`
- Prefer a picked destination string when device discovery is flaky: `./scripts/simctl-destination.sh`
- Build: prefer UDID + arch to avoid ambiguous name matching:
  - `xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,id=<UDID>,arch=arm64' -quiet -hideShellScriptEnvironment build`
- Install: `xcrun simctl install <device-udid> <path-to-app>`
- Launch: `xcrun simctl launch <device-udid> <bundle-id>`

## Bundled helper scripts

- Scripts live under this skill folder’s `scripts/` directory. Always execute the **bundled** scripts from this skill’s `scripts/` folder (the one next to this `SKILL.md`), not any `scripts/` folder in the project repo.
- Use `scripts/<script-name>` from the skill folder:
- `scripts/xcodebuild-app-info.sh`: print app path, bundle id, and executable name.
  - Example: `scripts/xcodebuild-app-info.sh -scheme <Scheme> -sdk iphonesimulator -configuration Debug`
- `scripts/simctl-destination.sh`: pick a simulator destination and print `DESTINATION` (with `arch=arm64`), `UDID`, `NAME`, `STATE`.
  - Example: `scripts/simctl-destination.sh | while IFS= read -r line; do export "$line"; done` then use `$DESTINATION` or `$UDID`.
- `scripts/simlog-stream.sh`: duration-capped log stream with optional predicate.
  - Example: `scripts/simlog-stream.sh "$UDID" aiTomo 5`
  - Example with predicate: `scripts/simlog-stream.sh --udid "$UDID" --process aiTomo --duration 5 --predicate 'subsystem == "com.apple.network"'`
- `scripts/xcresult-failures.sh`: summarize xcresult test failures (Xcode 16+ summary format).
  - Example: `scripts/xcresult-failures.sh ./.tmp/LatestTests.xcresult`

## Bootstrap snippet

- One-paste setup for simulator target + build outputs:
  - `scripts/simctl-destination.sh | while IFS= read -r line; do export "$line"; done`
  - `scripts/xcodebuild-app-info.sh -scheme <Scheme> -sdk iphonesimulator -configuration Debug | while IFS= read -r line; do export "$line"; done`
  - Optional: `xcrun simctl install "$UDID" "$APP_PATH"` and `xcrun simctl launch "$UDID" "$BUNDLE_ID"`

## Xcode output handling

Use `-quiet -hideShellScriptEnvironment` flags to omit diagnostic output.

## Find the built .app and identifiers

- Use build settings to locate the .app and identifiers:
  - `xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Device>' -showBuildSettings | rg 'TARGET_BUILD_DIR|FULL_PRODUCT_NAME|PRODUCT_BUNDLE_IDENTIFIER|EXECUTABLE_NAME'`
  - `.app` path: `<TARGET_BUILD_DIR>/<FULL_PRODUCT_NAME>`
  - Bundle id: `<PRODUCT_BUNDLE_IDENTIFIER>`
  - Process name: `<EXECUTABLE_NAME>`
  - One-liner for `.app` path:
    - `xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Device>' -showBuildSettings | rg 'TARGET_BUILD_DIR|FULL_PRODUCT_NAME' | awk -F' = ' 'NR==1{dir=$2} NR==2{print dir "/" $2}'`

## Logs

- Stream logs (Simulator): `xcrun simctl spawn <device-udid> log stream --style compact --predicate 'process == "<AppProcessName>"'`
- Find bundle/process name from the app’s Info.plist or build settings.
- Prefer a duration-capped wrapper and filter noisy lines (e.g., `getpwuid_r`) to keep output token-efficient.

## UI inspection and interaction

- Use `axe` skill for accessibility tree queries, element discovery, taps, typing, and scrolling.
- If `axe` is unavailable, drive UI via XCUITest and log `app.debugDescription` for a UI tree snapshot.
- Other CLI paths are limited: `simctl io` only supports screenshots/recordings and pasteboard, not element-level interaction.

## Screenshots and recordings

- Screenshot: `xcrun simctl io <device-udid> screenshot <path>`
- Record video: `xcrun simctl io <device-udid> recordVideo <path>` and stop with SIGINT.
- If you need a screenshot for analysis, downsample it (2x–3x) before reading it to reduce tokens:
  - `xcrun simctl io <device-udid> screenshot <temp file path>`
  - `sips -Z 900 <src file path> --out <temp out file path>`
  - Use the downsampled image for inspection/attachment.

## Iterate

- Rebuild → reinstall → relaunch; terminate first if needed: `xcrun simctl terminate <device-udid> <bundle-id>`
- Uninstall when necessary: `xcrun simctl uninstall <device-udid> <bundle-id>`

## Profiling (optional)

- Use Instruments CLI: `xcrun xctrace record --template <Template> --launch <bundle-id> --device <device-udid>`
