#!/usr/bin/env bash
# test-validate.sh — check that scripts/validate.py passes on the repo and
# fails on known-bad inputs. Each case runs on a fresh copy of the repo's
# tracked files in a temp directory, so the real working tree is never changed.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
PYTHON="${PYTHON:-python3}"
PASS=0
FAIL=0

ok()   { echo "  ok   $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

# Fresh copy of the tracked files (working-tree content) in $WORK/<name>.
fresh_copy() {
  local dest="$WORK/$1" file
  mkdir -p "$dest"
  while IFS= read -r -d '' file; do
    [[ -f "$REPO/$file" ]] || continue
    mkdir -p "$dest/$(dirname "$file")"
    cp -p "$REPO/$file" "$dest/$file"
  done < <(git -C "$REPO" ls-files -z)
  echo "$dest"
}

# expect_pass <label> <copy>
expect_pass() {
  local out
  if out="$("$PYTHON" "$2/scripts/validate.py" 2>&1)"; then ok "$1"; else fail "$1"; echo "$out"; fi
}

# expect_error <label> <copy> <pattern expected in the ERROR output>
expect_error() {
  local out
  if out="$("$PYTHON" "$2/scripts/validate.py" 2>&1)"; then
    fail "$1 (exit 0)"
  elif grep -q -- "$3" <<<"$out"; then
    ok "$1"
  else
    fail "$1 (missing '$3')"; echo "$out"
  fi
}

echo "validate.py tests (workdir $WORK)"

C="$(fresh_copy clean)"
expect_pass "clean repo passes" "$C"

C="$(fresh_copy missing-ref)"
echo 'See `templates/does-not-exist.docx`.' >> "$C/bid-compass/SKILL.md"
expect_error "missing referenced file is an error" "$C" "bid-compass/templates/does-not-exist.docx: referenced"

C="$(fresh_copy dropped-template)"
echo 'Use `templates/redline-output.docx`.' >> "$C/redline-sentry/SKILL.md"
expect_error "previously allow-listed template is now an error" "$C" "redline-sentry/templates/redline-output.docx: referenced"

C="$(fresh_copy playbook-drift)"
sed -i.bak 's/minimum_cap_multiple: 12/minimum_cap_multiple: 6/' "$C/redline-sentry/templates/default-playbook.yaml"
expect_error "default playbook drifting from config.yaml is an error" "$C" "values differ from redline-sentry/config.yaml"

C="$(fresh_copy playbook-empty)"
printf '# comments only\n' > "$C/redline-sentry/templates/default-playbook.yaml"
expect_error "comments-only default playbook is an error" "$C" "holds no YAML values"

C="$(fresh_copy bad-name)"
sed -i.bak 's/^name: spend-prism$/name: spend-prisms/' "$C/spend-prism/SKILL.md"
expect_error "frontmatter name mismatch is an error" "$C" "does not match folder"

echo
echo "$PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
