#!/bin/bash
# Main orchestrator

set +e  # Allow non-zero exits (don't kill immediately)

if [ -z "$1" ]; then
  echo "❌ Error: No GitHub repo URL provided!"
  echo "Usage: bash runner.sh <repo-url>"
  exit 1
fi

REPO_URL=$1
CLONE_DIR=temp-repo

echo "🔽 Cloning $REPO_URL..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"

if [ $? -ne 0 ]; then
  echo "❌ Failed to clone repo $REPO_URL"
  exit 1
fi

echo "🔎 Scanning repo in $CLONE_DIR..."

bash agent/scan_repo.sh "$CLONE_DIR"
SCAN_RESULT=$?

echo "🔍 Scan result code: $SCAN_RESULT"

if [ "$SCAN_RESULT" -eq 0 ]; then
  echo "✅ Repo already has full TechDocs structure. Nothing to do."
  exit 0
elif [ "$SCAN_RESULT" -eq 1 ]; then
  echo "🛠️ Missing TechDocs detected. Generating files..."
  REPO_NAME=$(basename -s .git "$REPO_URL")

  bash agent/generate_docs.sh "$CLONE_DIR" "$REPO_NAME"
  bash agent/commit_and_pr.sh "$CLONE_DIR" "$REPO_NAME"

  echo "✅ PR creation flow completed!"
  exit 0
else
  echo "❌ Unknown scan result: $SCAN_RESULT"
  exit 99
fi
