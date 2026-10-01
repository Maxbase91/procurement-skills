#!/usr/bin/env python3
"""Static checks for the procurement skills repo.

Checks, per skill folder (any top-level folder containing SKILL.md):
  - SKILL.md has YAML frontmatter that parses, with `name` and `description`
  - `name` matches the folder name
  - SKILL.md is under the 500-line limit for Agent Skills
  - every *.yaml / *.yml file in the skill parses
  - every relative file path referenced in SKILL.md (backticked) exists
  - redline-sentry/templates/default-playbook.yaml holds the same values as
    redline-sentry/config.yaml (it is the fallback / restore-defaults copy)
And for the repo:
  - the SKILLS array in install.sh matches the skill folders
  - `bash -n install.sh` passes; shellcheck runs if it is installed

Exit code 0 = no errors (warnings allowed), 1 = at least one error.
Requires Python 3.11+ and PyYAML (see requirements-dev.txt).
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent.parent
MAX_SKILL_LINES = 500

# Backticked relative paths such as `templates/foo.docx` or `config.yaml`.
REF_RE = re.compile(
    r"`([A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*\.(?:md|ya?ml|docx|xlsx|csv|json|py|txt))`"
)

errors: list[str] = []
warnings: list[str] = []


def error(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def parse_frontmatter(text: str) -> dict | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    data = yaml.safe_load(text[4:end])
    return data if isinstance(data, dict) else None


def check_skill(skill_dir: Path) -> None:
    name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"
    text = skill_md.read_text(encoding="utf-8")

    try:
        fm = parse_frontmatter(text)
    except yaml.YAMLError as exc:
        error(
            f"{name}/SKILL.md: frontmatter is not valid YAML ({exc.__class__.__name__})"
        )
        fm = None
    else:
        if fm is None:
            error(f"{name}/SKILL.md: missing or malformed '---' frontmatter block")

    if fm is not None:
        if fm.get("name") != name:
            error(
                f"{name}/SKILL.md: frontmatter name {fm.get('name')!r} does not match folder {name!r}"
            )
        desc = fm.get("description")
        if not isinstance(desc, str) or not desc.strip():
            error(f"{name}/SKILL.md: frontmatter 'description' is missing or empty")

    line_count = text.count("\n") + 1
    if line_count >= MAX_SKILL_LINES:
        error(f"{name}/SKILL.md: {line_count} lines (limit {MAX_SKILL_LINES})")

    for yml in sorted([*skill_dir.rglob("*.yaml"), *skill_dir.rglob("*.yml")]):
        try:
            yaml.safe_load(yml.read_text(encoding="utf-8"))
        except yaml.YAMLError as exc:
            error(f"{yml.relative_to(REPO)}: invalid YAML ({exc.__class__.__name__})")

    for ref in sorted(set(REF_RE.findall(text))):
        if not (skill_dir / ref).exists():
            error(f"{name}/{ref}: referenced in {name}/SKILL.md but does not exist")


def check_default_playbook() -> None:
    config = REPO / "redline-sentry" / "config.yaml"
    default = REPO / "redline-sentry" / "templates" / "default-playbook.yaml"
    if not (config.exists() and default.exists()):
        return  # missing files are reported by the reference check
    try:
        config_data = yaml.safe_load(config.read_text(encoding="utf-8"))
        default_data = yaml.safe_load(default.read_text(encoding="utf-8"))
    except yaml.YAMLError:
        return  # invalid YAML is reported by check_skill
    if not isinstance(default_data, dict) or not default_data:
        error(f"{default.relative_to(REPO)}: holds no YAML values")
    elif default_data != config_data:
        error(
            f"{default.relative_to(REPO)}: values differ from redline-sentry/config.yaml; keep the shipped defaults in sync"
        )


def check_install_sh(skill_names: list[str]) -> None:
    install = REPO / "install.sh"
    text = install.read_text(encoding="utf-8")
    match = re.search(r"^SKILLS=\(([^)]*)\)", text, re.MULTILINE)
    if not match:
        error("install.sh: could not find the SKILLS=(...) array")
    elif sorted(match.group(1).split()) != sorted(skill_names):
        error(
            f"install.sh: SKILLS array {match.group(1).split()} does not match skill folders {skill_names}"
        )

    result = subprocess.run(
        ["bash", "-n", str(install)], capture_output=True, text=True
    )
    if result.returncode != 0:
        error(f"install.sh: bash -n failed:\n{result.stderr.strip()}")

    if shutil.which("shellcheck"):
        result = subprocess.run(
            ["shellcheck", str(install)], capture_output=True, text=True
        )
        if result.returncode != 0:
            error(f"install.sh: shellcheck reported issues:\n{result.stdout.strip()}")
    else:
        warn("shellcheck not installed; skipped (CI runs it)")


def main() -> int:
    skill_dirs = sorted(p.parent for p in REPO.glob("*/SKILL.md"))
    if not skill_dirs:
        error("no skills found (expected <skill>/SKILL.md)")

    for skill_dir in skill_dirs:
        check_skill(skill_dir)

    check_default_playbook()

    check_install_sh([d.name for d in skill_dirs])

    for msg in warnings:
        print(f"WARN  {msg}")
    for msg in errors:
        print(f"ERROR {msg}")
    print(
        f"\n{len(skill_dirs)} skills checked: {len(errors)} error(s), {len(warnings)} warning(s)"
    )
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
