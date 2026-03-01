---
name: continuity
description: Maintain a compaction-safe workspace continuity ledger in CONTINUITY.md as canonical cross-turn briefing. Use when work spans multiple turns, context may compact/summarize, state tracking is critical, or the user asks to preserve ongoing goal/constraints/decisions/progress across turns.
---

# Continuity Ledger (compaction-safe)

Maintain a single Continuity Ledger for this workspace in `CONTINUITY.md`. Treat the ledger as canonical session briefing designed to survive context compaction. Do not rely on earlier chat text unless reflected in the ledger.

## How it works

- At start of every assistant turn: read `CONTINUITY.md`, update it for latest goal/constraints/decisions/state, then proceed with work.
- Update `CONTINUITY.md` again whenever any of these change: goal, constraints/assumptions, key decisions, progress state (`Done/Now/Next`), important tool outcomes.
- Keep ledger short/stable: facts only, no transcripts. Prefer bullets. Mark uncertainty as `UNCONFIRMED` (never guess).
- If missing recall or compaction/summary event detected: refresh/rebuild ledger from visible context, mark gaps `UNCONFIRMED`, ask up to 1-3 targeted questions, continue.

## `functions.update_plan` vs the Ledger

- `functions.update_plan`: short-term execution scaffolding while working (small 3-7 step plan with `pending/in_progress/completed`).
- `CONTINUITY.md`: long-running continuity across compaction (the what/why/current state), not step-by-step task list.
- Keep consistent: when plan or state changes, update ledger at intent/progress level (not every micro-step).

## In replies

- Begin with brief `Ledger Snapshot`:
  - Goal
  - Now/Next
  - Open Questions
- Print full ledger only when it materially changes or user asks.

## `CONTINUITY.md` format (keep headings)

```md
- Goal (incl. success criteria):
- Constraints/Assumptions:
- Key decisions:
- State:
  - Done:
  - Now:
  - Next:
- Open questions (UNCONFIRMED if needed):
- Working set (files/ids/commands):
```
