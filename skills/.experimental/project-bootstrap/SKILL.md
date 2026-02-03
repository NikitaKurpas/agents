---
name: project-bootstrap
description: Discover Xcode projects/workspaces, list schemes, and inspect build settings to choose targets. Use when starting work in an unknown Xcode repo.
---

# Project Bootstrap

## Bundled scripts

Scripts live under this skill folder’s `scripts/` directory.

- `scripts/xcodebuild-app-info.sh`: show build settings and print app path + bundle id.

## Steps

1. Discover Xcode projects/workspaces.

```bash
rg --files -g '*.xcodeproj' -g '*.xcworkspace'
```

2. List schemes for the chosen project/workspace.

```bash
xcodebuild -list -project <path/to/App.xcodeproj>
# or
xcodebuild -list -workspace <path/to/App.xcworkspace>
```

3. Inspect build settings and extract key values.

```bash
scripts/xcodebuild-app-info.sh -project <path/to/App.xcodeproj> -scheme <Scheme>
# or
scripts/xcodebuild-app-info.sh -workspace <path/to/App.xcworkspace> -scheme <Scheme>
```

4. Record:
   - scheme
   - bundle identifier
   - app path (`TARGET_BUILD_DIR` + `FULL_PRODUCT_NAME`)

## Notes

- Prefer workspace over project when both exist.
- Treat `xcodebuild` output as large: always pipe to a temp file, then search with `rg` or `tail`.
