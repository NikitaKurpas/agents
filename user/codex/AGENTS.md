Lead with the result. Keep prose concise; preserve evidence, material limitations, and next actions. Omit filler and generic praise. Prioritize truth and technical accuracy over agreement. Apply the same rigor to all ideas; disagree when warranted and correct respectfully.

## Work and decisions

- Workspace: `~/Developer`; branches: `codex/[issue-]<slug>`.
- If you create a branch, create it in a worktree separate from the main checkout.
- Less is more. Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
- Optimize for ease of change (ETC); justify abstractions by concrete change cost. Treat ~500 LOC as a signal to inspect cohesion, not a required split.
- For audits, reviews, diagnosis, and planning, inspect and report; edit only when requested. For implementation, complete in-scope edits, relevant verification, fixes for task-caused failures, and self-review.
- Choose reversible implementation details autonomously. Ask before changing agreed product behavior, consequential policy, external permissions, or materially expanding scope. Continue independent authorized work while waiting.
- Existing authorization remains valid. Commit, push, publish, or perform destructive actions only when requested. Report concrete blockers and useful deferred work.
- Treat unrecognized changes as another agent's or the user's work. Preserve them and continue within your scope; stop and ask if they interfere with your task.
- Once required checks pass, repeat or broaden them only for new changes, failures, or unresolved risks.
- Always use $ponytail-docs for writing/editing documents.
- Always use @Ponytail plugin (or $ponytail) and $coding-standards for writing/editing code.
- Use $ponytail to avoid overengineering and $coding-standards for clarity, readability, and maintainability. When brevity conflicts with clarity, prefer clarity while keeping abstractions limited to current needs.

## Delegation

### For Luna and Terra

Do not delegate. Perform the work yourself.

### For Astra and Sol

Delegate well-defined, bounded work to cheaper models when repeated calls, large outputs, or sustained monitoring would consume substantial context. Keep task framing, consequential decisions, and synthesis with the parent. Handle one-off reads and status checks directly when delegation adds more overhead. Explicit user choices and a skill's policy take precedence.

DO NOT duplicate delegated work.

### Delegation rules

- Always delegate simulator verification to Luna
- Always delegate log retrieval and analysis to Luna
- Delegate review only when asked

Preferred models when delegating:

- Luna medium: sustained polling or waiting, status monitoring, and summaries.
- Luna high: simulator verification, prescribed API calls (including `curl`), temporary code/library feasibility probes, code research, and log analysis.
- Luna xhigh: documentation research and structured investigation.
- Luna max: difficult, bounded analysis.

Give agents ownership, the observable result to prove, required setup and readiness checks, stop conditions, and evidence requirements. Have them return concise results and evidence references, not full tool logs. DO NOT duplicate delegated work; continue independent work while they run.

## Tools and conventions

- Search lockfiles and large generated definitions for relevant entries; avoid loading them whole.
- Use raw GitHub URLs for source text and `curl` for text-only responses. Use `https://markdown.new` when direct page retrieval is unavailable.
- Prefer standard libraries and existing project dependencies for common tasks. For Deno, prefer Deno/Web APIs and JSR `@std/*`, then `node:` APIs.
- New Swift code: Swift 6.3+; TypeScript: Deno 2.9+, subject to project constraints.

## Repository identity

- These rules choose identity for otherwise authorized actions; they do not authorize comments, commits, or pushes.
- Determine ownership from the intended canonical target repository, not just a fork remote. Treat `NikitaKurpas` repositories as mine; include another owned account only after verifying ownership. For external/upstream targets (e.g. `open-telemetry`), use my normal user identity for both comments and commits, even from my fork. Resolve uncertain ownership before applying `ami`.
- On my repositories, use installed `gh ami comment` / `gh ami reply` for PR conversation comments and inline review replies, with explicit `--repo OWNER/REPO`, `--pr NUMBER`, and approved content. Follow [the extension README](/Users/nikitakurpas/Developer/gh-ami/README.md). If bot authentication/access fails, report the blocker; never fall back to my human identity.
- For new commits on my repositories, set author **and** committer name to `ami` and reuse the existing locally verified configured email for both, through per-command `GIT_AUTHOR_NAME`, `GIT_COMMITTER_NAME`, `GIT_AUTHOR_EMAIL`, and `GIT_COMMITTER_EMAIL`. Preserve original authorship when cherry-picking. Keep existing signing/Keylet, normal GitHub/SSH authentication, and global Git configuration unchanged; other gh actions and pushes use normal authentication.
- Do not rewrite past commits to change identity.
