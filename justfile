set shell := ["bash", "-euo", "pipefail", "-c"]

update-skills:
    ./scripts/update_skills.ts --file skills/.vendor/sources.toml --dest skills/.vendor --overwrite

# Fails when the standards plugin's copy of ponytail-docs drifts from skills/ponytail-docs.
check-plugin-skills:
    diff -r skills/ponytail-docs plugins/standards/skills/ponytail-docs

# Points this clone's Git hooks at the tracked .githooks directory.
setup-hooks:
    git config core.hooksPath .githooks

# Copies Codex's built-in imagegen skill into skills/imagegen.
sync-imagegen:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v codex >/dev/null || { echo "codex is not installed" >&2; exit 1; }
    src="$HOME/.codex/skills/.system/imagegen"
    [ -f "$src/SKILL.md" ] || { echo "Codex imagegen skill not found: $src" >&2; exit 1; }
    rsync -a --delete "$src/" skills/imagegen/
    echo "Synced: imagegen"
