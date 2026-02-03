---
name: simulator-log-workflow
description: Capture simulator logs with console and OSLog streams, then stop and summarize. Use when debugging simulator runtime behavior.
---

# Simulator Log Workflow

## Steps

1. Start console log capture (relaunches the app).

```bash
LOG=/tmp/sim-console.log
xcrun simctl launch --console-pty --terminate-running-process <UDID> <BUNDLE_ID> >"$LOG" 2>&1 &
CONSOLE_PID=$!
```

2. Start structured OSLog capture (does not relaunch).

```bash
xcrun simctl spawn <UDID> log stream --level=debug \
  --predicate 'subsystem == "<BUNDLE_ID>"' >>"$LOG" 2>&1 &
OSLOG_PID=$!
```

3. Reproduce the issue in the simulator.

4. Stop capture and summarize.

```bash
kill "$CONSOLE_PID" "$OSLOG_PID"
rg -n -i "error|warn|fatal|exception" "$LOG"
```

## Notes

- Console capture restarts the app; skip it if you need a warm state.
- Keep logs in a temp file and filter with `rg` to avoid large outputs.
