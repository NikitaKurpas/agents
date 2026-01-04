---
name: local-skill-installer
description: Install Codex skills from a local directory or SKILL.md file into $CODEX_HOME/skills (or a specified destination).
---

# Local Skill Installer

## Quick start

1. Install from a local skill directory:

```bash
./scripts/install-skill-from-local.py /path/to/skill-dir
```

2. Install from a local SKILL.md file:

```bash
./scripts/install-skill-from-local.py /path/to/skill-dir/SKILL.md
```

3. Install to a custom destination (defaults to `~/.codex/skills`):

```bash
./scripts/install-skill-from-local.py /path/to/skill-dir --dest /custom/skills/dir
```

4. Install to the current folder scope (`$CWD/.codex/skills`):

```bash
./scripts/install-skill-from-local.py /path/to/skill-dir --scope cwd
```

5. Install to the current repo scope (`$REPO_ROOT/.codex/skills`):

```bash
./scripts/install-skill-from-local.py /path/to/skill-dir --scope repo
```

## Options

- `--name <skill-name>`: override the destination skill directory name.
- `--dest <skills-dir>`: install into a custom skills directory (defaults to `~/.codex/skills`).
- `--force`: overwrite destination if it already exists.
- `--scope <user|cwd|repo>`: install into `~/.codex/skills`, `$CWD/.codex/skills`, or `$REPO_ROOT/.codex/skills` when `--dest` is not provided.

## Notes

- The installer aborts if the destination skill directory already exists.
- `--scope repo` requires running inside a git repository.
- Restart Codex to pick up newly installed skills.
