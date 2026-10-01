#!/usr/bin/env python3
"""Static checks for the procurement skills repo.

Checks, per skill folder (any top-level folder containing SKILL.md):
  - SKILL.md has YAML frontmatter that parses, with `name` and `description`
  - `name` matches the folder name
  - SKILL.md is under the 500-line limit for Agent Skills
  - every *.yaml / *.yml file in the skill parses
  - every relative file path referenced in SKILL.md (backticked) exists
And for the repo:
  - the SKILLS array in install.sh matches the skill folders
  - `bash -n install.sh` passes; shellcheck runs if it is installed

References listed in scripts/known-missing.txt are reported as warnings
instead of errors: they are files the skills mention but the repo does not
ship yet, pending an owner decision (adding them changes skill output).

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
KNOWN_MISSING_FILE = REPO / "scripts" / "known-missing.txt"
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


def load_known_missing() -> set[str]:
    if not KNOWN_MISSING_FILE.exists():
        return set()
    entries: set[str] = set()
    for line in KNOWN_MISSING_FILE.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            entries.add(line)
    return entries


def parse_frontmatter(text: str) -> dict | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    data = yaml.safe_load(text[4:end])
    return data if isinstance(data, dict) else None


def check_skill(skill_dir: Path, known_missing: set[str]) -> None:
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
        rel = f"{name}/{ref}"
        if (skill_dir / ref).exists():
            continue
        if rel in known_missing:
            warn(
                f"{rel}: referenced in SKILL.md but not shipped (listed in known-missing.txt)"
            )
        else:
            error(f"{rel}: referenced in {name}/SKILL.md but does not exist")


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
    known_missing = load_known_missing()
    skill_dirs = sorted(p.parent for p in REPO.glob("*/SKILL.md"))
    if not skill_dirs:
        error("no skills found (expected <skill>/SKILL.md)")

    for skill_dir in skill_dirs:
        check_skill(skill_dir, known_missing)

    # Stale allowlist entries hide nothing, but should be cleaned up.
    for rel in sorted(known_missing):
        if (REPO / rel).exists():
            error(f"known-missing.txt lists {rel}, which now exists; remove the entry")

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
