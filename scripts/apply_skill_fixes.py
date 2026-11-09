#!/usr/bin/python3
"""Reapply local tweaks to skills installed by `npx skills` (see user/.skill-lock.json).

`npx skills` overwrites SKILL.md and agents/openai.yaml on update. Idempotent.
Pass --stage to `git add` the changed files.
"""

import json
import re
import subprocess
import sys
from functools import reduce
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "user/skills"

# disable_model_invocation: set `disable-model-invocation` in SKILL.md and
#   `allow_implicit_invocation: false` in agents/openai.yaml.
# openai.interface: written as the `interface:` block of agents/openai.yaml when it has none.
FIXES = {
    "bro": {
        "disable_model_invocation": True,
        "openai": {
            "interface": {
                "display_name": "Bro",
                "short_description": "Restate the last message in plain language",
            },
        },
    },
    "cli-creator": {"disable_model_invocation": True},
    "codex-hygiene": {"disable_model_invocation": True},
    "frontend-design": {
        "disable_model_invocation": True,
        "openai": {
            "interface": {
                "display_name": "Frontend Design",
                "short_description": "Distinctive, intentional visual design for new or existing UI",
            },
        },
    },
    "security-threat-model": {"disable_model_invocation": True},
}

IMPLICIT_FLAG = "  allow_implicit_invocation: false"

# System Python has no YAML module; macOS system Ruby ships Psych.
YAML_TO_JSON = ["/usr/bin/ruby", "-ryaml", "-rjson", "-e", "puts JSON.generate(YAML.safe_load(STDIN.read))"]


def parse_yaml(text, label):
    result = subprocess.run(YAML_TO_JSON, input=text, capture_output=True, text=True)
    if result.returncode != 0:
        raise ValueError(f"{label}: invalid YAML: {result.stderr.strip()}")
    return json.loads(result.stdout)


def check_skill_md(text, name, fix):
    match = re.match(r"---\n(.*?)\n---(\n|$)", text, re.DOTALL)
    if not match:
        raise ValueError(f"{name}/SKILL.md: no frontmatter")
    meta = parse_yaml(match.group(1), f"{name}/SKILL.md frontmatter")
    if not isinstance(meta, dict) or meta.get("name") != name:
        raise ValueError(f"{name}/SKILL.md: frontmatter must be a mapping with name: {name}")
    if fix.get("disable_model_invocation") and meta.get("disable-model-invocation") is not True:
        raise ValueError(f"{name}/SKILL.md: disable-model-invocation is not boolean true")


def check_openai_yaml(text, name, fix):
    data = parse_yaml(text, f"{name}/agents/openai.yaml")
    if not isinstance(data, dict):
        raise ValueError(f"{name}/agents/openai.yaml: must be a mapping")
    if fix.get("disable_model_invocation"):
        if data.get("policy", {}).get("allow_implicit_invocation") is not False:
            raise ValueError(f"{name}/agents/openai.yaml: allow_implicit_invocation is not boolean false")
    wanted = fix.get("openai", {}).get("interface")
    if wanted:
        interface = data.get("interface")
        if not isinstance(interface, dict):
            raise ValueError(f"{name}/agents/openai.yaml: missing interface mapping")
        for key in ("display_name", "short_description"):
            if not isinstance(interface.get(key), str) or not interface[key]:
                raise ValueError(f"{name}/agents/openai.yaml: interface.{key} must be a non-empty string")


def set_frontmatter_flag(text, key, value):
    match = re.match(r"---\n(.*?)\n---(\n|$)", text, re.DOTALL)
    if not match:
        raise ValueError("SKILL.md has no frontmatter")
    lines = match.group(1).split("\n")
    line = f"{key}: {value}"
    for i, existing in enumerate(lines):
        if existing.startswith(f"{key}:"):
            lines[i] = line
            break
    else:
        lines.append(line)
    return "---\n" + "\n".join(lines) + "\n---" + match.group(2) + text[match.end():]


def set_implicit_invocation_off(text):
    lines = text.split("\n")
    policy = next((i for i, l in enumerate(lines) if l.startswith("policy:")), None)
    if policy is None:
        return f"policy:\n{IMPLICIT_FLAG}\n{text}"
    for i in range(policy + 1, len(lines)):
        if re.match(r"\s+allow_implicit_invocation:", lines[i]):
            lines[i] = IMPLICIT_FLAG
            break
    else:
        lines.insert(policy + 1, IMPLICIT_FLAG)
    return "\n".join(lines)


def add_interface(text, interface):
    if re.search(r"^interface:", text, re.MULTILINE):
        return text
    block = (
        "interface:\n"
        f'  display_name: "{interface["display_name"]}"\n'
        f'  short_description: "{interface["short_description"]}"\n'
    )
    if text and not text.endswith("\n"):
        text += "\n"
    return text + block


pending = {}


def update(path, transform, check):
    current = pending.get(path)
    if current is None:
        current = path.read_text() if path.exists() else None
    new = transform(current or "")
    check(new)
    if new != current:
        pending[path] = new


def main():
    for name, fix in FIXES.items():
        skill_dir = SKILLS_DIR / name
        if not (skill_dir / "SKILL.md").exists():
            print(f"skip {name}: not installed", file=sys.stderr)
            continue
        if fix.get("disable_model_invocation"):
            update(
                skill_dir / "SKILL.md",
                lambda t: set_frontmatter_flag(t, "disable-model-invocation", "true"),
                lambda t: check_skill_md(t, name, fix),
            )
        steps = []
        if fix.get("disable_model_invocation"):
            steps.append(set_implicit_invocation_off)
        interface = fix.get("openai", {}).get("interface")
        if interface:
            steps.append(lambda t: add_interface(t, interface))
        if steps:
            update(skill_dir / "agents/openai.yaml", lambda t: reduce(lambda acc, step: step(acc), steps, t),
                   lambda t: check_openai_yaml(t, name, fix))


try:
    main()
except ValueError as error:
    sys.exit(f"error: {error}; nothing written")

changed = []
for path, text in pending.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    changed.append(str(path.relative_to(REPO_ROOT)))

for rel in changed:
    print(f"fixed {rel}")

if "--stage" in sys.argv[1:] and changed:
    subprocess.run(["git", "-C", str(REPO_ROOT), "add", "--", *changed], check=True)
