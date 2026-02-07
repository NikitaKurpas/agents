set shell := ["bash", "-euo", "pipefail", "-c"]

update-skills:
  ./scripts/update_skills.ts --file skills/sources.toml --dest skills --overwrite

sync-skills:
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p "$HOME/.codex/skills"

  # Temp indexes: all repo skill names + enabled skill names.
  repo_skills_tmp="$(mktemp)"
  enabled_tmp="$(mktemp)"
  trap 'rm -f "$repo_skills_tmp" "$enabled_tmp"' EXIT

  # Snapshot skill dirs from this repo only (one name per line).
  find "{{justfile_directory()}}/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -u > "$repo_skills_tmp"

  # Normalize enabled list: drop blanks/comments, dedupe/sort.
  while IFS= read -r skill || [ -n "$skill" ]; do
    [ -z "$skill" ] && continue
    case "$skill" in \#*) continue ;; esac
    printf '%s\n' "$skill"
  done < "{{justfile_directory()}}/codex/enabled-skills" | sort -u > "$enabled_tmp"

  # Sync enabled skills by replacing destination directories.
  while IFS= read -r skill || [ -n "$skill" ]; do
    src="{{justfile_directory()}}/skills/$skill"
    dest="$HOME/.codex/skills/$skill"
    if [ ! -d "$src" ]; then
      echo "Missing skill directory: $src" >&2
      exit 1
    fi
    rm -rf "$dest"
    cp -R "$src" "$dest"
    echo "Synced: $skill"
  done < "$enabled_tmp"

  # Prune only repo-owned skills that are no longer enabled.
  # Keep non-repo/custom skills in ~/.codex/skills untouched.
  find "$HOME/.codex/skills" -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r dest; do
    skill="$(basename "$dest")"
    if grep -Fxq "$skill" "$repo_skills_tmp" && ! grep -Fxq "$skill" "$enabled_tmp"; then
      rm -rf "$dest"
      echo "Removed: $skill"
    fi
  done
