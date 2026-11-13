---
name: continuity
description: Maintain a task-specific Continuity Ledger to preserve goals, constraints, decisions, progress, open questions, and the working set across context compaction, keeping ongoing work coherent when conversational context is incomplete.
---

# Continuity Ledger

Maintain a concise, task-specific session briefing outside shared project checkouts.

## Resolve the ledger

1. Check whether `CODEX_THREAD_ID` is available.
2. If it is available, use `${CODEX_HOME:-$HOME/.codex}/continuity/${CODEX_THREAD_ID}.md`.
3. Create the parent directory and ledger file when needed.
4. Treat this Codex-managed ledger as the canonical session briefing across context compaction. Do not rely on earlier chat text unless the ledger reflects it.

If `CODEX_THREAD_ID` is unavailable, do not read, create, or update a Continuity Ledger. Never fall back to a repo-root `CONTINUITY.md` or another shared file.

## Maintain the ledger

At the start of every assistant turn, read the task-specific ledger if it exists, then create or update it to reflect the latest goal, constraints, decisions, and state before proceeding.

Update it again whenever any of these change:

- Goal
- Constraints or assumptions
- Key decisions
- Progress state: Done, Now, or Next
- Important tool outcomes

Keep it short and stable. Record facts, not transcripts. Prefer bullets. Mark uncertainty as `UNCONFIRMED`; never guess.

If recall is missing or context appears compacted, refresh or rebuild the ledger from visible context, mark gaps `UNCONFIRMED`, ask up to three targeted questions, and continue where possible.

## Coordinate with execution plans

Use `functions.update_plan` for a small, short-term execution plan of roughly three to seven steps. Use the Continuity Ledger for the long-running what, why, and current state.

Keep both consistent. When the plan or state changes, update the ledger at the intent and progress level rather than recording every micro-step.

## Report in replies

Begin replies with a brief `Ledger Snapshot` containing Goal, Now/Next, and Open Questions. Print the full ledger only when it materially changes or the user asks for it.

## Use this format

```markdown
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
