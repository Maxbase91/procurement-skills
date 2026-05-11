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
    --target)        TARGET="$2";         shift 2 ;;
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
  for SKILL in "${SKILLS[@]}"; do
    SRC="$SCRIPT_DIR/$SKILL"
    if [[ ! -d "$SRC" ]]; then
      echo "  [SKIP] $SKILL — source folder not found"
      continue
    fi
    # Important: zip the FOLDER so the zip extracts to <skill-name>/SKILL.md
    # not loose files. Claude.ai expects this structure.
    (cd "$SCRIPT_DIR" && zip -rq "$DIST/${SKILL}.zip" "$SKILL" \
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
        read -p "  $SKILL exists. Overwrite? [y/N] " yn
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
