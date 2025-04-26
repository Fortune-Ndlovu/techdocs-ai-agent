#!/bin/bash
# Main orchestrator

set -e

REPO_URL=$1
CLONE_DIR=temp-repo

echo "🔽 Cloning $REPO_URL..."
rm -rf $CLONE_DIR
git clone "$REPO_URL" $CLONE_DIR

bash agent/scan_repo.sh $CLONE_DIR
SCAN_RESULT=$?

if [ $SCAN_RESULT -eq 0 ]; then
  echo "✅ Repo already has TechDocs structure. Nothing to do."
  exit 0
elif [ $SCAN_RESULT -eq 1 ] || [ $SCAN_RESULT -eq 2 ]; then
  echo "🛠️ Generating missing docs..."
  REPO_NAME=$(basename -s .git "$REPO_URL")
  bash agent/generate_docs.sh $CLONE_DIR $REPO_NAME
  bash agent/commit_and_pr.sh $CLONE_DIR
else
  echo "❌ Unknown scan error."
  exit 99
fi
