---
name: device-log-workflow
description: Capture device logs by launching with devicectl console output, then stop and summarize. Use for device runtime debugging.
---

# Device Log Workflow

## Steps

1. Launch with console capture and log to file.

```bash
LOG=/tmp/device-console.log
xcrun devicectl device process launch --device <UDID> --console \
  --terminate-existing --json-output /tmp/launch.json <BUNDLE_ID> >"$LOG" 2>&1 &
LOG_PID=$!
```

2. Reproduce the issue on device.

3. Stop capture and summarize.

```bash
kill "$LOG_PID"
rg -n -i "error|warn|fatal|exception" "$LOG"
```

## Notes

- Device log capture uses console output; OSLog streaming is limited compared to simulators.
- Keep logs in temp files and filter with `rg` to avoid large outputs.
