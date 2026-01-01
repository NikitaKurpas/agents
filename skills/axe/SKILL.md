---
name: axe
description: Use AXe CLI to inspect and control iOS Simulator UIs with token-efficient filtering of accessibility JSON. Trigger when a task needs simulator UI discovery or interaction.
---

# AXe

## Quick start

Set the simulator UDID once per session:

```bash
export AXE_UDID="8657E64C-781C-46A7-901E-2F5E84ECA2CF"
```

Scripts live under this skill folder’s `scripts/` directory. Always execute the bundled scripts from this skill’s `scripts/` folder (the one next to this `SKILL.md`), not any `scripts/` folder in the project repo. Use `scripts/<script-name>` from the skill folder.

Prefer the helper script (token-efficient and recommended). With no extra args it returns every node that has an `AXLabel` or `AXValue` (including `StaticText`), so you usually do not need raw `axe describe-ui` + `jq`. It prints help if no `AXE_UDID` or `--udid` is provided:

```bash
scripts/axe_interactables.sh --udid "$AXE_UDID"
scripts/axe_interactables.sh --udid "$AXE_UDID" --label 'Send|OK'
scripts/axe_interactables.sh --udid "$AXE_UDID" --type Button
scripts/axe_interactables.sh --udid "$AXE_UDID" --bounds 0 400 390 800 --label 'Send'
scripts/axe_interactables.sh --udid "$AXE_UDID" --value-regex 'error|failed'
```

Describe UI with token-efficient output:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") != "" or (.AXValue // "") != "")
| {
  type,
  role:.role_description,
  label:.AXLabel,
  value:.AXValue,
  id:.AXUniqueId,
  x:.frame.x,
  y:.frame.y,
  w:.frame.width,
  h:.frame.height,
  cx:(.frame.x + (.frame.width/2)),
  cy:(.frame.y + (.frame.height/2))
}'
```

Tap by label or id (preferred over coordinates when available):

```bash
axe tap --label "Send" --udid "$AXE_UDID"
axe tap --id "<AXUniqueId>" --udid "$AXE_UDID"
```

## Describe UI (token-efficient patterns)

Use focused filters and avoid dumping full JSON to the model.

Find elements by label regex:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c --arg re 'Send|OK' '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") | test($re; "i"))
| {type, label:.AXLabel, id:.AXUniqueId, frame}'
```

Find elements by value regex:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c --arg re 'error|failed' '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXValue // "") | test($re; "i"))
| {type, label:.AXLabel, value:.AXValue, id:.AXUniqueId, frame}'
```

List only likely interactables (label or value present):

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") != "" or (.AXValue // "") != "")
| {type, role:.role_description, label:.AXLabel, value:.AXValue, id:.AXUniqueId, frame}'
```

When AXUniqueId is null, fall back to AXLabel or coordinates.

### Presets

Buttons only:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select(.type == "Button")
| {type, label:.AXLabel, id:.AXUniqueId, frame}'
```

Text fields only:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select(.type == "TextField")
| {type, label:.AXLabel, value:.AXValue, id:.AXUniqueId, frame}'
```

### Dedupe and scope by bounds

If labels are duplicated, scope by frame bounds (x/y/width/height) and keep only hits in a region:

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c --arg re "Send" '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") | test($re; "i"))
| select(.frame.x >= 0 and .frame.y >= 400 and .frame.y <= 800)
| {type, label:.AXLabel, id:.AXUniqueId, frame}'
```

## Interaction commands

Type text (US keyboard only):

```bash
axe type "Hello" --udid "$AXE_UDID"
```

Non-US text input is not supported by `axe type` (US HID keyboard only). Workaround: use the simulator pasteboard and paste.

```bash
# 1) Focus the target field with axe tap.
# 2) Copy non-US text to the simulator pasteboard:
printf '%s' "$TEXT" | xcrun simctl pbcopy "$AXE_UDID"
# 3) Long-press the field to show the edit menu, then tap "Paste".
```

Fully automated long-press + paste (requires field coordinates):

```bash
# Long-press at the field center (x,y) to open the edit menu.
axe touch -x 200 -y 500 --down --up --delay 1.0 --udid "$AXE_UDID"
# Tap the "Paste" menu item.
axe tap --label "Paste" --udid "$AXE_UDID"
```

Note: The “Paste” label may be localized on non-English simulators.

Swipe between coordinates:

```bash
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --udid "$AXE_UDID"
```

Press simulator buttons:

```bash
axe button home --udid "$AXE_UDID"
axe button lock --duration 1.5 --udid "$AXE_UDID"
```

## Screenshots (token-efficient)

If you need a screenshot, downsample it (2x–3x) before reading it to reduce tokens.

```bash
axe screenshot --udid "$AXE_UDID" --output /tmp/axe-sim.png
# Downsample ~3x by capping the longest edge.
sips -Z 900 /tmp/axe-sim.png --out /tmp/axe-sim.down.png
# Then read/attach the downsampled image.
```

Coordinate mapping note: AXe coordinates are in simulator points, but screenshots are pixels. If you’re interpreting a downsampled image, scale points to the downsampled pixel size:

```bash
# Generic mapping:
x_ds = floor(x_points * img_w / pts_w)
y_ds = floor(y_points * img_h / pts_h)
```

You can derive `img_w`/`img_h` from the screenshot and `pts_w`/`pts_h` from AXe output:

```bash
sips -g pixelWidth -g pixelHeight /tmp/axe-sim.down.png
```

For AXe actions (`tap`, `touch`), always use the original point coordinates from AXe, not the downsampled image.

## Notes and heuristics

Prefer `--id` over `--label` when available to disambiguate duplicates.
Floor coordinates when pulling them to avoid fractional pixels (the helper script already floors x/y/w/h/cx/cy).
Filter by label first, then refine by `type`, `role_description`, or `frame`.
If output is still large, narrow the regex or filter on `type` (e.g., `Button`, `TextField`).
Keep describe-ui output compact with `jq -c` and only the fields needed for the next action.
