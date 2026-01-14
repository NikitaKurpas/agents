---
name: ios-simulator-e2e
description: End-to-end iOS app development workflow on the iOS Simulator using CLI tools. Use to build, install, run, log, inspect UI, interact, capture screenshots/recordings, or iterate on iOS apps in the Simulator. Prefer the axe skill for UI inspection/interaction when present.
---

# iOS Simulator End-to-End Workflow

## Preferred UI tooling

- Prefer using the `axe` skill for UI inspection and interaction when it is available.
- Fall back to XCUITest-driven UI dumps/interactions or `simctl` only if `axe` is unavailable.

## Quick start (CLI)

Always prefer to use the project's tasks/recipes if they exist.

- In sandboxed environments, run Xcode/Simulator commands with escalated permissions to avoid CoreSimulatorService and device discovery failures.
- List Simulators: `xcrun simctl list devices`
- Boot a device: `xcrun simctl boot <device-udid>` or `xcrun simctl boot "iPhone 15"`
- Wait for boot: `xcrun simctl bootstatus <device-udid> -b`
- Prefer a picked destination string when device discovery is flaky: `./scripts/simctl-destination.sh`
- Build: prefer UDID + arch to avoid ambiguous name matching:
  - `xcodebuild build -scheme <Scheme> -destination 'platform=iOS Simulator,id=<UDID>,arch=arm64' -quiet -hideShellScriptEnvironment`
- Install: `xcrun simctl install <device-udid> <path-to-app>`
- Launch: `xcrun simctl launch <device-udid> <bundle-id>`

## Bundled helper scripts

- Always use `scripts/<script-name>` from the skill folder (the one next to this `SKILL.md`):
- `scripts/xcodebuild-app-info.sh`: print .app path, bundle id, and executable name.
  - Example: `scripts/xcodebuild-app-info.sh -scheme <Scheme> -sdk iphonesimulator -configuration Debug`
- `scripts/simctl-destination.sh`: pick the first available iPhone simulator destination and print `DESTINATION`, `UDID`, `NAME`, `STATE`.
- `scripts/xcresult-failures.sh`: summarize xcresult test failures (Xcode 16+ summary format).
  - Example: `scripts/xcresult-failures.sh /tmp/LatestTests.xcresult`

## Xcode output handling

Use `-quiet -hideShellScriptEnvironment` flags to omit diagnostic output.

## Find the built .app and identifiers

- Use build settings to locate the .app and identifiers:
  - `xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Device>' -showBuildSettings | rg 'TARGET_BUILD_DIR|FULL_PRODUCT_NAME|PRODUCT_BUNDLE_IDENTIFIER|EXECUTABLE_NAME'`
  - `.app` path: `<TARGET_BUILD_DIR>/<FULL_PRODUCT_NAME>`
  - Bundle id: `<PRODUCT_BUNDLE_IDENTIFIER>`
  - Process name: `<EXECUTABLE_NAME>`
  - One-liner for `.app` path: `xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Device>' -showBuildSettings | rg 'TARGET_BUILD_DIR|FULL_PRODUCT_NAME' | awk -F' = ' 'NR==1{dir=$2} NR==2{print dir "/" $2}'`

## Logs

If you know in advance you will need logs to debug/verify, stream logs in background terminal: `xcrun simctl spawn booted/<device-udid> log stream --style compact --predicate '...'`
  - To reduce output size, use `--style ndjson` and pipe to sed and jq: `sed -n '/^{/p' | jq -r --unbuffered '[.messageType,.subsystem,.category,.eventMessage] | @tsv'`
Otherwise, show past logs: `xcrun simctl spawn booted/<device-udid> log show --style compact --last <timeframe or use 2m> --predicate '...'`
  - To reduce output size, use `--style json` and pipe to jq: `jq -r '.[] | [.messageType,.subsystem,.category,.eventMessage] | @tsv'`

- Strongly prefer to narrow logs down using subsystem and category, if known: `--predicate 'subsystem == "..." [AND category == "..."]'`.
- Otherwise, use app process name to filter logs: `--predicate 'process == "<AppProcessName>"'`; this will output a lot of noise, so try filtering.
- Find bundle/process name using `scripts/xcodebuild-app-info.sh`.

## UI inspection and interaction

- Use `axe` skill for element discovery, taps, typing, and scrolling.
- If skill use unavailable, use the `axe` command and filter output with `jq`.
- Other CLI paths are limited: `simctl io` only supports screenshots/recordings and pasteboard.

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
