---
name: gh-issue-fix
description: GitHub issue implementation workflow using gh CLI. Use when asked to implement an issue, open or update a PR, or follow the specific gh commands and constraints for viewing issues, branching, PR creation, commenting, updating, checkout, and merge.
---

# Gh Issue Fix

## Workflow

1. Read issue details: `gh issue view <n>`. For comments only: `gh issue view <n> --comments`.
1. Check auth and repo context: `gh auth status`, `git remote -v`.
1. Create/checkout branch: `gh issue develop <n> --checkout`.
1. Implement changes and run required checks/tests.
1. Create PR: `gh pr create -a "@me" --title <string> --body-file <file>`. Use `-` to read body from stdin.
1. Link issue in PR body with `Fixes #<n>` or `Closes #<n>` to auto-close on merge.
1. View PR info or comments: `gh pr view <n> [--comments]`.
1. Update PR branch with base: `gh pr update-branch`.
1. Leave PR comment after updates: `gh pr comment <n> --body-file <file>` (use `-` for stdin).
1. Checkout existing PR when needed: `gh pr checkout <n>`.
1. Merge only when explicitly instructed: `gh pr merge <n> --delete-branch --merge --squash`.
