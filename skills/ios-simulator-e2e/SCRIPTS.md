# Bundled Scripts (Legacy Usage)

This file keeps the original trimming script examples for reference. Prefer the
`SKILL.md` guidance for writing xcodebuild output to a temp file and inspecting
with `tail`/`rg` before using these.

## Trim build output

- `scripts/xcbuild-trim-log.sh`: keep xcodebuild output signal-only.
  - Example: `xcodebuild ... 2>&1 | scripts/xcbuild-trim-log.sh`

## Trim test output

- `scripts/xcresult-strip-frontend.sh`: remove noisy “Failed frontend command” stanza.
  - Example: `xcodebuild ... 2>&1 | scripts/xcresult-strip-frontend.sh`
- `scripts/xcresult-trim-log.sh`: compress test output to suite/case status lines (passes through other diagnostics).
  - Example: `xcodebuild test ... 2>&1 | scripts/xcresult-trim-log.sh`
