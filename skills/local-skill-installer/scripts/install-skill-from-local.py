#!/usr/bin/env python3
"""Install a local skill directory into $CODEX_HOME/skills."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys


class InstallError(Exception):
    pass


class Args(argparse.Namespace):
    source: str
    dest: str | None
    name: str | None
    force: bool
    scope: str


def _codex_home() -> str:
    return os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex"))


def _default_dest() -> str:
    return os.path.join(_codex_home(), "skills")


def _git_root(cwd: str) -> str:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        raise InstallError("Not inside a git repository.")
    return result.stdout.strip()


def _resolve_dest(args: Args) -> str:
    if args.dest:
        return args.dest
    if args.scope == "cwd":
        return os.path.join(os.getcwd(), ".codex", "skills")
    if args.scope == "repo":
        repo_root = _git_root(os.getcwd())
        return os.path.join(repo_root, ".codex", "skills")
    return _default_dest()


def _validate_skill_name(name: str) -> None:
    altsep = os.path.altsep
    if not name or os.path.sep in name or (altsep and altsep in name):
        raise InstallError("Skill name must be a single path segment.")
    if name in (".", ".."):
        raise InstallError("Invalid skill name.")


def _resolve_source_dir(source: str) -> str:
    if os.path.isdir(source):
        return source
    if os.path.isfile(source):
        if os.path.basename(source) != "SKILL.md":
            raise InstallError("Source file must be SKILL.md.")
        return os.path.dirname(source)
    raise InstallError("Source path not found.")


def _validate_skill(path: str) -> None:
    skill_md = os.path.join(path, "SKILL.md")
    if not os.path.isfile(skill_md):
        raise InstallError("SKILL.md not found in selected skill directory.")


def _copy_skill(src: str, dest_dir: str, *, force: bool) -> None:
    os.makedirs(os.path.dirname(dest_dir), exist_ok=True)
    if os.path.exists(dest_dir):
        if not force:
            raise InstallError(f"Destination already exists: {dest_dir}")
        shutil.rmtree(dest_dir)
    shutil.copytree(src, dest_dir)


def _parse_args(argv: list[str]) -> Args:
    parser = argparse.ArgumentParser(description="Install a local Codex skill.")
    parser.add_argument("source", help="Path to skill directory or SKILL.md")
    parser.add_argument("--dest", help="Destination skills directory")
    parser.add_argument("--name", help="Destination skill name override")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite destination if it already exists",
    )
    parser.add_argument(
        "--scope",
        choices=["user", "cwd", "repo"],
        default="user",
        help="Destination scope when --dest is not set",
    )
    return parser.parse_args(argv, namespace=Args())


def main(argv: list[str]) -> int:
    args = _parse_args(argv)
    try:
        source_dir = _resolve_source_dir(args.source)
        _validate_skill(source_dir)
        skill_name = args.name or os.path.basename(source_dir.rstrip(os.sep))
        _validate_skill_name(skill_name)
        dest_root = _resolve_dest(args)
        dest_dir = os.path.join(dest_root, skill_name)
        _copy_skill(source_dir, dest_dir, force=args.force)
        print(f"Installed {skill_name} to {dest_dir}")
        return 0
    except InstallError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
