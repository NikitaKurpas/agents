---
name: ui-automation-e2e
description: Automate iOS Simulator UI flows with AXe (describe, interact, screenshot). Use when you need UI discovery or interaction.
---

# UI Automation End-to-End

## Steps

1. Set the simulator UDID for AXe.

```bash
export AXE_UDID="<SIMULATOR_UDID>"
```

2. Describe UI (filter to essential fields).

```bash
axe describe-ui --udid "$AXE_UDID" | jq -c '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") != "" or (.AXValue // "") != "")
| {type, label:.AXLabel, value:.AXValue, id:.AXUniqueId, frame}'
```

3. Interact (prefer id or label).

```bash
axe tap --id "<AXUniqueId>" --udid "$AXE_UDID"
axe tap --label "Continue" --udid "$AXE_UDID"
axe type "Hello" --udid "$AXE_UDID"
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --udid "$AXE_UDID"
```

4. Verify with a screenshot if needed.

```bash
axe screenshot --udid "$AXE_UDID" --output /tmp/axe-sim.png
sips -Z 900 /tmp/axe-sim.png --out /tmp/axe-sim.down.png
```

## Notes

- If AXe is unavailable, fall back to `xcrun simctl io <UDID> screenshot <path>` for visual checks only.
- Use AXe coordinates (points), not downsampled pixel coordinates.
