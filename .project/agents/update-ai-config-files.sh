#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# update-ai-config-files.sh
#
# Copies the contents of `.project/` from an external Git repository into the
# current repository's `.project/` directory.
#
# The script:
#   - detects the root of the current Git repository
#   - clones the external repository into a temporary local folder
#   - copies everything from:
#       external-repo/.project/ -> current-repo/.project/
#   - overwrites existing files with the same names
#   - keeps other existing files in `.project/` untouched
#   - removes the temporary clone afterwards
#
# No files are staged or committed automatically.
# -----------------------------------------------------------------------------

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TMP=".project-update-tmp"
TARGET=".project"
REPO_URL="https://github.com/hubisan/ai-agents-config.git"
BRANCH="main"

rm -rf "$TMP"
mkdir -p "$TARGET"

git clone -q --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP"

rsync -a "$TMP/.project/" "$TARGET/"

rm -rf "$TMP"
