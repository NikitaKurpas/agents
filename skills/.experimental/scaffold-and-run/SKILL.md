---
name: scaffold-and-run
description: Scaffold an iOS/macOS app from a template, configure identifiers, then build and run. Use when starting a new app quickly.
---

# Scaffold and Run

## Steps

1. Obtain a template (clone or copy a local template repo).

```bash
git clone <template-repo> <new-project-dir>
```

2. Update identifiers and targets (bundle id, deployment target, device family).

```bash
rg -n "com\.example|Bundle Identifier|PRODUCT_BUNDLE_IDENTIFIER" <new-project-dir>
```

3. Open the workspace/project and perform the first build.

```bash
open <new-project-dir>/<App>.xcworkspace
```

4. Run using `build-run-simulator` or `macos-app-e2e`.

## Notes

- Prefer local templates to avoid binary downloads.
- Use `rg` to locate bundle identifiers and update via `apply_patch`.
