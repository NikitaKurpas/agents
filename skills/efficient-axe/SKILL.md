---
name: efficient-axe
description: Token-efficient overlay for AXe CLI on iOS Simulator tasks. Use for compact discovery and filtered output; if the `axe` skill is available, refer to it for full AXe CLI guidance.
---

# Efficient AXe

Thin wrapper; not full AXe reference.

If the `axe` skill is available, use it for:
- full command guidance
- interaction patterns
- screenshots, typing, swipes, buttons
- broader troubleshooting / workflows

This skill only adds token-efficiency rules on top of AXe CLI usage.

## Rules

- Default: compact output; no raw full-tree dumps.
- Prefer filtered `jq -c` projections over verbatim `axe describe-ui`.
- Keep only fields needed for next action, e.g. `type`, `AXLabel`, `AXValue`, `AXUniqueId`, `frame`.
- Prefer helper script in this skill for interactable discovery.
- Narrow early: label regex, type, bounds, value regex.
- Prefer `AXUniqueId` over label when disambiguation needed.

## Helper script

Run bundled helper from this skill’s `scripts/` dir:

```bash
scripts/axe_interactables.sh --udid <udid>
scripts/axe_interactables.sh --udid <udid> --label 'Send|OK'
scripts/axe_interactables.sh --udid <udid> --type Button
scripts/axe_interactables.sh --udid <udid> --bounds 0 400 390 800 --label 'Send'
scripts/axe_interactables.sh --udid <udid> --value-regex 'error|failed'
```

Use helper first. Falls back to filtered `axe describe-ui` only when needed.

## Compact `describe-ui`

Base pattern:

```bash
axe describe-ui --udid <udid> | jq -c '
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

Common filter swaps:

- `(.AXLabel // "") | test($re; "i")` with `--arg re 'Send|OK'`
- `(.AXValue // "") | test($re; "i")`
- `.type == "Button"` / `.type == "TextField"`

Bounds narrowing:

```bash
axe describe-ui --udid <udid> | jq -c --arg re "Send" '
def nodes: .. | objects | select(has("type") and has("frame"));
nodes
| select((.AXLabel // "") | test($re; "i"))
| select(.frame.x >= 0 and .frame.y >= 400 and .frame.y <= 800)
| {type, label:.AXLabel, id:.AXUniqueId, frame}'
```

## Output discipline

- Quote only exact hits / minimal rows.
- If output still large, tighten regex or add `type` / bounds filters.
- Use screenshots sparingly; prefer AX data first.
- For full interaction guidance, refer to the `axe` skill when available.
