# Manual Workflow

Use this only if the bundled scripts fail or the `.xcresult` bundle shape is unusual.

## Inspect Summary

Confirm the failing test and whether it is a UI test.

```bash
xcrun xcresulttool get test-results summary --path /path/to/result.xcresult
```

If the failing test identifier is not obvious, list tests.

```bash
xcrun xcresulttool get test-results tests --path /path/to/result.xcresult
```

## Inspect Activities

Inspect activity trees for the failing test. Look for:
- `Collecting debug information to assist test failure triage`
- `Requesting snapshot of accessibility hierarchy`
- attachment names beginning with `App UI hierarchy`

```bash
xcrun xcresulttool get test-results activities \
  --path /path/to/result.xcresult \
  --test-id 'BundleName/testCase()'
```

## Export Attachments

Export attachments for that test.

```bash
xcrun xcresulttool export attachments \
  --path /path/to/result.xcresult \
  --output-path /tmp/xcresult-ui-failure \
  --test-id 'BundleName/testCase()'
```

Read `manifest.json`. Find the attachment whose `suggestedHumanReadableName` starts with `App UI hierarchy`.

Open the exported `.txt` file referenced by `exportedFileName`. That text file is the accessibility tree.

## Known Limits

- Do not rely on `--only-failures` for hierarchy export. Xcode often marks the failure-triage hierarchy attachment as not failure-associated.
- `UI Snapshot ...` usually exports as a binary `NSKeyedArchive`, not a PNG.
- If asked about screenshots, state that `xcresulttool export attachments` does not usually emit a standalone PNG or JPEG by default.
