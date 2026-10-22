---
name: principle-guard-the-context-window
description: "Keeps the main context lean by routing bulk reading to subagents and keeping only their summaries."
disable-model-invocation: true
---

# Guard the Context Window

**Why:** Context overflow degrades reasoning quality, creates compression artifacts, and halts progress.

**Pattern:**

- **Size phases and cap scope.** Limit files per phase, set turn budgets, account for mechanism costs.
- **Search large generated files.** Grep lockfiles and generated definitions for the entries you need instead of loading them whole.
