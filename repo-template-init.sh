#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# repo-template-init
#
# Initializes a target project from this local repo-template repository.
#
# Usage:
#   repo-template-init markdown /path/to/target-project
#   repo-template-init org-mode /path/to/target-project
#
# The script:
#   - must be run from inside the local repo-template repository
#   - updates this template repository with git pull
#   - copies the selected variant into the target path with rsync
#   - overwrites existing files with the same names
#   - keeps other existing target files untouched
#   - runs the target project's .project/agents/update-ai-config-files.sh
#   - prints the target project's Git status if it is a Git repository
#
# No files are staged or committed automatically.
# -----------------------------------------------------------------------------

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  repo-template-init markdown TARGET_PATH
  repo-template-init org-mode TARGET_PATH

Variants:
  markdown  Initialize target project from the Markdown template
  org-mode  Initialize target project from the Org-mode template
EOF
}

VARIANT="${1:-}"
TARGET_PATH="${2:-}"

case "$VARIANT" in
  markdown|org-mode)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  "")
    echo "Error: Missing variant."
    echo
    usage
    exit 1
    ;;
  *)
    echo "Error: Unknown variant: $VARIANT"
    echo
    usage
    exit 1
    ;;
esac

if [ -z "$TARGET_PATH" ]; then
  echo "Error: Missing target path."
  echo
  usage
  exit 1
fi

TEMPLATE_ROOT="$(git rev-parse --show-toplevel)"
cd "$TEMPLATE_ROOT"

SOURCE="$VARIANT"
TARGET="$(mkdir -p "$TARGET_PATH" && cd "$TARGET_PATH" && pwd)"

if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory not found: $SOURCE"
  exit 1
fi

echo "Initializing repository from template"
echo "Template: $TEMPLATE_ROOT"
echo "Variant:  $VARIANT"
echo "Source:   $SOURCE/"
echo "Target:   $TARGET"
echo

echo "Updating local template repository..."
git pull --ff-only

echo
echo "Copying template files..."
RSYNC_OUTPUT="$(
  rsync -a --itemize-changes "$SOURCE/" "$TARGET/" \
    | awk '
      /^[^.]/{ print "  " $2 }
    '
)"

if [ -n "$RSYNC_OUTPUT" ]; then
  echo
  echo "Updated files:"
  echo "$RSYNC_OUTPUT"
else
  echo
  echo "No template file changes detected."
fi

UPDATE_SCRIPT="$TARGET/.project/agents/update-ai-config-files.sh"

if [ ! -f "$UPDATE_SCRIPT" ]; then
  echo
  echo "Error: Update script not found: $UPDATE_SCRIPT"
  exit 1
fi

if [ ! -x "$UPDATE_SCRIPT" ]; then
  chmod +x "$UPDATE_SCRIPT"
fi

echo
echo "Running target update script..."
(
  cd "$TARGET"
  ./.project/agents/update-ai-config-files.sh
)

echo
echo "Done. No files were staged or committed."

if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo
  echo "Target Git status:"
  echo
  git -C "$TARGET" status --short
fi
