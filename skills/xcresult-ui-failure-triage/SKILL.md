---
name: xcresult-ui-failure-triage
description: Extract failing UI-test artifacts from a raw `.xcresult` bundle, especially the plain-text accessibility hierarchy that Xcode captures during failure triage. Use when Codex needs to inspect a failed `xcodebuild test` run, identify the failed UI test, export its attachments, and read the `App UI hierarchy` text.
---

# XCResult UI Failure Triage

Use the bundled scripts first. Fall back to raw `xcresulttool` only if the scripts fail or the bundle shape is unusual.

## Default Path

1. Run `scripts/export-failed-ui-test-artifacts.sh`.
2. If needed, run `scripts/print-a11y-tree.sh` on the exported directory.
3. Report concrete paths and attachment names.
4. Only if the scripts fail, read `references/manual-workflow.md` and use raw `xcresulttool`.

## Rules

- Do not rely on `--only-failures` for hierarchy export. Xcode often marks the failure-triage hierarchy attachment as not failure-associated.
- Treat the plain-text `App UI hierarchy` attachment as the stable artifact.
- Expect `UI Snapshot ...` to export as a binary `NSKeyedArchive`, not a PNG.
- If the user asks for the screenshot bitmap, state that `xcresulttool export attachments` exports the visual snapshot as a keyed archive rather than a standalone image.

## Helper Scripts

- `scripts/export-failed-ui-test-artifacts.sh`
  - Find the first failed test from summary.
  - Export that test's attachments.
  - Print the export directory, chosen test id, hierarchy file path if present, and all attachment names.
- `scripts/print-a11y-tree.sh`
  - Read `manifest.json` from an exported attachment directory.
  - Print the `App UI hierarchy` text attachment.

Use these scripts by default. Fall back to raw `xcresulttool` commands only if they fail.

## Commands

Export first failed test:

```bash
./scripts/export-failed-ui-test-artifacts.sh /path/to/result.xcresult
```

If `--output-dir` is omitted, the script creates a fresh temp directory under `/tmp`.

Export specific test:

```bash
./scripts/export-failed-ui-test-artifacts.sh /path/to/result.xcresult --test-id 'BundleName/testCase()'
```

Export to a custom directory:

```bash
./scripts/export-failed-ui-test-artifacts.sh /path/to/result.xcresult --output-dir /tmp/xcresult-ui-failure
```

Print hierarchy from exported directory:

```bash
./scripts/print-a11y-tree.sh /tmp/xcresult-ui-failure
```

## Fallback

If the scripts do not work, read:
- `references/manual-workflow.md`

## Output Expectations

Report:
- failing test id
- export directory
- hierarchy text file path
- whether the hierarchy attachment was found
- whether a `UI Snapshot` archive was present
- if asked about screenshots, note that no standalone PNG/JPEG is exported by default
