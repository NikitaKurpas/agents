# Bundled Scripts (Legacy Usage)

## Trim test output

- `scripts/xcresult-strip-frontend.sh`: remove noisy “Failed frontend command” stanza.
  - Example: `xcodebuild ... 2>&1 | scripts/xcresult-strip-frontend.sh`
