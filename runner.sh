#!/bin/bash
# Main orchestrator

#!/bin/bash
# Main orchestrator

set -e

if [ -z "$1" ]; then
  echo "❌ Error: No GitHub repo URL provided!"
  echo "Usage: bash runner.sh <repo-url>"
  exit 1
fi

REPO_URL=$1
CLONE_DIR=temp-repo
REPO_SUMMARY=repo-summary.json

echo "🔽 Cloning $REPO_URL..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"

if [ $? -ne 0 ]; then
  echo "❌ Failed to clone repo $REPO_URL"
  exit 1
fi

echo "🔎 Scanning repo..."
python3 agent/repo-scanner/scanner.py "$CLONE_DIR" > "$REPO_SUMMARY"

# Here we could inspect the scan result if needed
# but let's assume we always generate fresh docs now (better)

echo "🛠️ Generating full TechDocs using LLM..."
python3 agent/llm-client/generate_full_docs.py "$REPO_SUMMARY" "$CLONE_DIR"

echo "✅ Full documentation generated."

# Commit and open PR
REPO_NAME=$(basename -s .git "$REPO_URL")

bash agent/commit_and_pr.sh "$CLONE_DIR" "$REPO_NAME"

echo "🎉 PR creation flow completed!"
# 