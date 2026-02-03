---
name: spm-dev-cycle
description: Build, test, run, and manage Swift Package executables. Use for SwiftPM projects and CLI tools.
---

# SwiftPM Dev Cycle

## Steps

1. Build and test.

```bash
swift build --package-path <path/to/package>
swift test --package-path <path/to/package>
```

2. Run an executable.

```bash
swift run --package-path <path/to/package> <Executable> -- <args>
```

3. Run in background and stop later.

```bash
swift run --package-path <path/to/package> <Executable> -- <args> &
PID=$!
kill "$PID"
```

## Notes

- Use `-c release` for release builds when benchmarking.
- Track PIDs in a file if multiple background runs are active.
