#!/usr/bin/env bash
# test-install.sh — exercise install.sh end to end in a throwaway directory.
#
# Copies the repo's tracked files (working-tree content) into a temp git repo
# and runs every installer mode against temp targets with HOME redirected, so
# it never touches ~/.claude/skills or the real dist/ folder.

# Test bodies are single-quoted on purpose: check() evals them later.
# shellcheck disable=SC2016

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

SKILLS=(redline-sentry spend-prism bid-compass supplier-truthcheck procure-voice)
PASS=0
FAIL=0

ok()   { echo "  ok   $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }
check() { if eval "$2"; then ok "$1"; else fail "$1"; fi; }
# Run the installer and grep its captured output (avoids SIGPIPE from grep -q
# under pipefail). Usage: run_has "<pattern>" <install.sh args...>
run_has() { local pat="$1" out; shift; out="$("$INSTALL" "$@")" || return 1; grep -q -- "$pat" <<<"$out"; }

# --- Build an isolated copy of the repo -----------------------------------
SRC="$WORK/repo"
mkdir -p "$SRC"
while IFS= read -r -d '' FILE; do
  [[ -f "$REPO/$FILE" ]] || continue
  mkdir -p "$SRC/$(dirname "$FILE")"
  cp -p "$REPO/$FILE" "$SRC/$FILE"
done < <(git -C "$REPO" ls-files -z)
git -C "$SRC" init -q
git -C "$SRC" add -A
git -C "$SRC" -c user.name=ci -c user.email=ci@example.invalid commit -qm snapshot
# An untracked local file in a skill folder must not end up in a package.
echo "local only" > "$SRC/spend-prism/untracked-local-file.md"

export INSTALL="$SRC/install.sh"
export HOME="$WORK/home"
mkdir -p "$HOME"

sources_intact() {
  local s
  for s in "${SKILLS[@]}"; do [[ -f "$SRC/$s/SKILL.md" ]] || return 1; done
}
all_installed() {
  local s
  for s in "${SKILLS[@]}"; do [[ -f "$1/$s/SKILL.md" ]] || return 1; done
}

echo "install.sh tests (workdir $WORK)"

# --- Argument handling ----------------------------------------------------
check "--help exits 0" '"$INSTALL" --help >/dev/null'
check "unknown option exits non-zero" '! "$INSTALL" --bogus >/dev/null 2>&1'
check "--target without a value is rejected" '! "$INSTALL" --target >/dev/null 2>&1'
check "--target with an empty value is rejected" '! "$INSTALL" --target "" >/dev/null 2>&1'

# --- Default target (HOME redirected) -------------------------------------
check "default install goes to \$HOME/.claude/skills" \
  '"$INSTALL" --force >/dev/null && all_installed "$HOME/.claude/skills"'

# --- Install modes --------------------------------------------------------
T="$WORK/target"
check "fresh install installs all skills" \
  'run_has "Installed:    5" --target "$T" && all_installed "$T"'

echo "marker" > "$T/spend-prism/marker"
check "--skip-existing leaves installed skills alone" \
  'run_has "Skipped:      5" --target "$T" --skip-existing && [[ -f "$T/spend-prism/marker" ]]'
check "interactive mode with closed stdin skips instead of aborting" \
  'run_has "Skipped:      5" --target "$T" </dev/null && [[ -f "$T/spend-prism/marker" ]]'
check "interactive mode overwrites on 'y'" \
  'run_has "Overwritten:  5" --target "$T" < <(printf "y\ny\ny\ny\ny\n") && [[ ! -f "$T/spend-prism/marker" ]]'
check "--force overwrites all skills" \
  'run_has "Overwritten:  5" --target "$T" --force && all_installed "$T"'

# --- Self-destruct guard --------------------------------------------------
check "--target <repo> --force is refused" \
  '! (cd "$SRC" && ./install.sh --target . --force >/dev/null 2>&1) && sources_intact'
ln -s "$SRC" "$WORK/repo-link"
check "--target <symlink to repo> --force is refused" \
  '! "$INSTALL" --target "$WORK/repo-link" --force >/dev/null 2>&1 && sources_intact'

# --- Package mode ---------------------------------------------------------
check "--package builds one zip per skill" \
  '"$INSTALL" --package >/dev/null && [[ $(ls "$SRC"/dist/*.zip | wc -l) -eq ${#SKILLS[@]} ]]'
for S in "${SKILLS[@]}"; do
  check "dist/$S.zip extracts to $S/SKILL.md" \
    'unzip -Z1 "$SRC/dist/$S.zip" | grep -x "$S/SKILL.md" >/dev/null'
done
check "untracked files are not packaged" \
  '! unzip -Z1 "$SRC/dist/spend-prism.zip" | grep untracked-local-file >/dev/null'
check "package mode leaves sources intact" 'sources_intact'

echo
echo "$PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
