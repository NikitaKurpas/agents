---
name: doctor-env-audit
description: Audit local Apple dev tooling (Xcode, simctl, devicectl, xcresulttool, AXe) and report readiness. Use for setup or environment troubleshooting.
---

# Doctor Environment Audit

## Steps

1. Record OS and Xcode basics.

```bash
sw_vers
xcodebuild -version
xcode-select -p
```

2. Verify tool availability.

```bash
xcrun --find simctl
xcrun --find devicectl
xcrun --find xcresulttool
```

3. Check simulator and device visibility.

```bash
xcrun simctl list devices --json
xcrun devicectl list devices --json-output /tmp/devices.json
```

4. Optional: check AXe if UI automation is needed.

```bash
axe --version
```

## Notes

- Treat large outputs as logs; save to temp files if needed and filter with `rg`.
- If any tool is missing, reinstall Xcode or run `xcode-select --install`.
