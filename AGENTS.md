# Repository Guidelines

## Project Structure & Module Organization
- `skills/`: locally maintained skill directories (one per skill). Each contains `SKILL.md`, optional `references/`, `scripts/`, and assets.
- `skills/.vendor/`: source-managed vendored skills and `sources.toml`.
- `skills/.experimental/`: in-progress skills not ready for sync.
- `scripts/`: repo automation (TypeScript, Deno). Example: `scripts/update_skills.ts` syncs skill sources.
- `codex/`: local Codex config, rules, and enabled skill list (e.g., `codex/enabled-skills`).
- `justfile`: common entry points for updating and syncing skills.

## Build, Test, and Development Commands
- `just update-skills`: pull skills listed in `skills/.vendor/sources.toml` into `skills/.vendor/` (uses `scripts/update_skills.ts`).
- `just sync-skills`: copy skills listed in `codex/enabled-skills` into `~/.codex/skills` for local use.
- `./scripts/update_skills.ts --help`: show flags (`--file`, `--dest`, `--overwrite`, `--dry-run`).

Requires Deno for running TypeScript scripts (see shebang in `scripts/update_skills.ts`).

## Coding Style & Naming Conventions
- TypeScript for automation scripts; prefer stdlib modules via `jsr:@std/...`.
- Indentation: 2 spaces in TS (match existing scripts).
- Directory naming: kebab-case for skill names (e.g., `swiftui-view-refactor`).
- Keep files small and focused; split large skills into subfolders when needed.

## Testing Guidelines
- No formal test suite in this repo. Validate changes by running the relevant script or `make` target.
- For skill changes, sanity-check with `just sync-skills` and verify the skill loads in Codex.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and sentence case (e.g., `Update AGENTS.md`, `Add sync-skills command`).
- PRs should describe:
  - What changed and why
  - Any new or updated skills
  - How you verified (commands run, manual checks)

## Configuration Tips
- `codex/enabled-skills` is the source of truth for what gets synced to `~/.codex/skills`.
- Vendored skills belong in `skills/.vendor/`; update them through `just update-skills`.
- If a skill is experimental, keep it under `skills/.experimental/` and avoid syncing it.
