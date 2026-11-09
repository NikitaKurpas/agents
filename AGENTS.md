# Repository Guidelines

## Project Structure & Module Organization

- `skills/`: locally maintained skills; selected `user/skills/` entries symlink here. Each contains `SKILL.md`, optional `references/`, `scripts/`, and assets.
- `user/`: installed user skills, skill locks, and Codex configuration; home configuration paths symlink here.
- `skills/.experimental/`: in-progress skills not ready for use.
- `scripts/`: repo automation (TypeScript, Deno). Example: `scripts/repo-map.ts`.
- `user/codex/`: local Codex config and rules.
- `justfile`: common entry points for repo checks.

## Build, Test, and Development Commands

- `just setup-hooks`: run once per worktree to enable `.githooks/pre-commit`.
- `just check-plugin-skills` check for drifts between `plugins/standards/skills/ponytail-docs` and `skills/ponytail-docs`. Edit the source skill and copy it into the plugin.

Requires Deno for running TypeScript scripts (see shebang in `scripts/repo-map.ts`).

## Coding Style & Naming Conventions

- Write Markdown without manual line wrapping. Run `dprint fmt <changed-markdown-files>` and let the formatter control layout.
- TypeScript for automation scripts; prefer stdlib modules via `jsr:@std/...`.
- Indentation: 2 spaces in TS (match existing scripts).
- Directory naming: kebab-case for skill names (e.g., `swiftui-view-refactor`).
- Keep files small and focused; split large skills into subfolders when needed.

## Testing Guidelines

- No formal test suite in this repo. Validate changes by running the relevant script or `make` target.
- For skill changes, verify the skill loads in Codex.

## Commit & Pull Request Guidelines

- Commit messages are short, imperative, and sentence case (e.g., `Update AGENTS.md`, `Add check-plugin-skills command`).
- PRs should describe:
  - What changed and why
  - Any new or updated skills
  - How you verified (commands run, manual checks)

## Configuration Tips

- If a skill is experimental, keep it under `skills/.experimental/`.
