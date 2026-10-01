#!/usr/bin/env bash
# install.sh — copy procurement skills into your Claude skills directory.
#
# Usage:
#   ./install.sh                          # interactive: prompts on collisions
#   ./install.sh --force                  # overwrite existing skills without asking
#   ./install.sh --skip-existing          # skip any skill already installed
#   ./install.sh --target /custom/path    # install to a custom directory
#   ./install.sh --package                # generate zips for Claude.ai upload

set -e

# ----------------------------------------------------------------------
# Config
# ----------------------------------------------------------------------
SKILLS=(redline-sentry spend-prism bid-compass supplier-truthcheck procure-voice)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ----------------------------------------------------------------------
# Parse args
# ----------------------------------------------------------------------
MODE="interactive"
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)         MODE="force";        shift ;;
    --skip-existing) MODE="skip";         shift ;;
    --target)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Error: --target requires a directory path." >&2
        exit 1
      fi
      TARGET="$2"; shift 2 ;;
    --package)       MODE="package";      shift ;;
    -h|--help)
      cat <<EOF
install.sh — install procurement skills into Claude's skills directory.

Options:
  --force            Overwrite existing skills without prompting.
  --skip-existing    Skip skills that already exist (no overwrite).
  --target PATH      Install into a custom directory (otherwise auto-detected).
  --package          Generate upload-ready zips in dist/ for Claude.ai web
                     and Claude Desktop (no filesystem install).
  -h, --help         Show this help.

Default Claude skills directory locations:
  Linux/macOS:  \$HOME/.claude/skills
  (Claude Code respects this path; Claude.ai / Cowork may use a different
   location — see Anthropic's skills documentation for your platform.)
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ----------------------------------------------------------------------
# Package mode: generate zips for Claude.ai upload
# ----------------------------------------------------------------------
if [[ "$MODE" == "package" ]]; then
  DIST="$SCRIPT_DIR/dist"
  mkdir -p "$DIST"
  rm -f "$DIST"/*.zip
  echo "Packaging skills as zips for Claude.ai / Claude Desktop upload"
  echo "Output directory: $DIST"
  echo
  STAGE=""
  if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    STAGE="$(mktemp -d)"
    trap 'rm -rf "$STAGE"' EXIT
  fi
  for SKILL in "${SKILLS[@]}"; do
    SRC="$SCRIPT_DIR/$SKILL"
    if [[ ! -d "$SRC" ]]; then
      echo "  [SKIP] $SKILL — source folder not found"
      continue
    fi
    # In a git checkout, package only tracked files so local, unreviewed
    # files dropped into a skill folder (e.g. sample inputs) never ship.
    # Outside git (e.g. a downloaded source archive) fall back to the folder.
    ZIP_ROOT="$SCRIPT_DIR"
    if [[ -n "$STAGE" ]]; then
      ZIP_ROOT="$STAGE"
      while IFS= read -r -d '' FILE; do
        [[ -f "$SCRIPT_DIR/$FILE" ]] || continue
        mkdir -p "$STAGE/$(dirname "$FILE")"
        cp "$SCRIPT_DIR/$FILE" "$STAGE/$FILE"
      done < <(git -C "$SCRIPT_DIR" ls-files -z --cached -- "$SKILL")
      UNTRACKED=$(git -C "$SCRIPT_DIR" ls-files --others -- "$SKILL" | grep -vc '\.DS_Store$' || true)
      if [[ "$UNTRACKED" -gt 0 ]]; then
        echo "  [NOTE] $SKILL — $UNTRACKED untracked file(s) not packaged"
      fi
    fi
    # Important: zip the FOLDER so the zip extracts to <skill-name>/SKILL.md
    # not loose files. Claude.ai expects this structure.
    (cd "$ZIP_ROOT" && zip -rq "$DIST/${SKILL}.zip" "$SKILL" \
      -x "*.DS_Store" "*/.*")
    SIZE=$(du -h "$DIST/${SKILL}.zip" | cut -f1)
    echo "  [PACKAGED] $SKILL → dist/${SKILL}.zip ($SIZE)"
  done
  echo
  echo "============================================================"
  echo "Done. ${#SKILLS[@]} zips ready in: $DIST"
  echo "============================================================"
  echo
  echo "Next steps:"
  echo "  1. Open Claude.ai in your browser"
  echo "  2. Go to: Settings > Capabilities > Skills (or Settings > Features)"
  echo "  3. Click 'Upload skill' and select each zip from dist/"
  echo "  4. Once uploaded, skills appear in the / menu across Claude.ai"
  echo "     web, Claude Desktop, Claude mobile, and Cowork"
  echo
  echo "See INSTALL.md for screenshots and full step-by-step."
  echo
  exit 0
fi

# ----------------------------------------------------------------------
# Resolve target directory
# ----------------------------------------------------------------------
if [[ -z "$TARGET" ]]; then
  TARGET="$HOME/.claude/skills"
fi

mkdir -p "$TARGET"

# Refuse to install into the repo itself: --force would rm -rf the source
# skill folders before copying them.
if [[ "$(cd "$TARGET" && pwd -P)" == "$(cd "$SCRIPT_DIR" && pwd -P)" ]]; then
  echo "Error: --target must not be the repository directory ($SCRIPT_DIR)." >&2
  exit 1
fi

echo "Installing procurement skills into: $TARGET"
echo

# ----------------------------------------------------------------------
# Install each skill
# ----------------------------------------------------------------------
INSTALLED=()
SKIPPED=()
OVERWRITTEN=()

for SKILL in "${SKILLS[@]}"; do
  SRC="$SCRIPT_DIR/$SKILL"
  DST="$TARGET/$SKILL"

  if [[ ! -d "$SRC" ]]; then
    echo "  [SKIP] $SKILL — source folder not found at $SRC"
    continue
  fi

  if [[ -d "$DST" ]]; then
    case "$MODE" in
      force)
        rm -rf "$DST"
        cp -r "$SRC" "$DST"
        echo "  [OVERWRITE] $SKILL"
        OVERWRITTEN+=("$SKILL")
        ;;
      skip)
        echo "  [SKIP] $SKILL — already installed"
        SKIPPED+=("$SKILL")
        ;;
      interactive)
        # No answer (e.g. stdin closed when piped or in CI) means the
        # default "N", instead of aborting the whole run under set -e.
        read -r -p "  $SKILL exists. Overwrite? [y/N] " yn || yn=""
        case "$yn" in
          [Yy]*)
            rm -rf "$DST"
            cp -r "$SRC" "$DST"
            echo "         → overwritten"
            OVERWRITTEN+=("$SKILL")
            ;;
          *)
            echo "         → skipped"
            SKIPPED+=("$SKILL")
            ;;
        esac
        ;;
    esac
  else
    cp -r "$SRC" "$DST"
    echo "  [INSTALL] $SKILL"
    INSTALLED+=("$SKILL")
  fi
done

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
echo
echo "============================================================"
echo "Done."
echo "  Installed:    ${#INSTALLED[@]}   ${INSTALLED[*]:-(none)}"
echo "  Overwritten:  ${#OVERWRITTEN[@]}   ${OVERWRITTEN[*]:-(none)}"
echo "  Skipped:      ${#SKIPPED[@]}   ${SKIPPED[*]:-(none)}"
echo "============================================================"
echo
echo "Next steps:"
echo "  1. Edit the config.yaml file in each skill folder to match your"
echo "     organisation's playbook, taxonomy, and scoring weights:"
for SKILL in "${SKILLS[@]}"; do
  if [[ -f "$TARGET/$SKILL/config.yaml" ]]; then
    echo "       $TARGET/$SKILL/config.yaml"
  fi
done
echo
echo "  2. Start a new Claude session — the skills are auto-discovered."
echo
echo "  3. Try one out:  \"Review this NDA\" / \"Analyse this spend\" / etc."
echo
