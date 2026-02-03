---
name: simulator-lab-setup
description: Prepare a deterministic simulator environment (boot/open/reset/erase, location, appearance, status bar). Use before reproducible UI or test runs.
---

# Simulator Lab Setup

## Steps

1. Pick a simulator and boot it.

```bash
xcrun simctl list devices --json
xcrun simctl boot <UDID>
xcrun simctl bootstatus <UDID> -b
open -a Simulator
```

2. Optional: erase to a clean state.

```bash
xcrun simctl shutdown <UDID>
xcrun simctl erase <UDID>
```

3. Set appearance and status bar.

```bash
xcrun simctl ui <UDID> appearance light
xcrun simctl status_bar <UDID> --dataNetwork wifi
xcrun simctl status_bar <UDID> clear
```

4. Set or reset location.

```bash
xcrun simctl location <UDID> set 37.7749,-122.4194
xcrun simctl location <UDID> clear
```

## Notes

- Prefer a stable UDID for repeatability.
- Status bar overrides are visual only; they do not change real network conditions.
