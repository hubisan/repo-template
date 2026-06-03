#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# update-ai-config-files.sh
#
# Copies the `agents/` and `tasks/` directories from an external Git repository
# into the current repository's `.project/` directory.
#
# The script:
#   - detects the root of the current Git repository
#   - clones the external repository into a temporary local folder
#   - copies files from:
#       external-repo/agents/ -> .project/agents/
#       external-repo/tasks/  -> .project/tasks/
#   - overwrites existing files with the same names
#   - keeps all other files in `.project/` untouched
#   - removes the temporary clone afterwards
#
# No files are staged or committed automatically.
# Review the changes afterwards with:
#
#   git status
#   git diff
#
# Then stage and commit manually:
#
#   git add .project/agents .project/tasks
#   git commit
# -----------------------------------------------------------------------------

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TMP=".project-update-tmp"
TARGET=".project"
REPO_URL="https://github.com/hubisan/ai-agents-config.git"
BRANCH="main"

rm -rf "$TMP"
mkdir -p "$TARGET/agents" "$TARGET/tasks"

git clone --quiet --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP"

rsync -a "$TMP/agents/" "$TARGET/agents/"
rsync -a "$TMP/tasks/" "$TARGET/tasks/"

rm -rf "$TMP"
