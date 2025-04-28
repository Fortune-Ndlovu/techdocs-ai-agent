#!/bin/bash
# Main orchestrator

set -e

if [ -z "$1" ]; then
  echo "❌ Error: No GitHub repo URL provided!"
  echo "Usage: bash runner.sh <repo-url>"
  exit 1
fi

REPO_URL="$1"
REPO_NAME=$(basename -s .git "$REPO_URL")   # example: ML
CLONE_DIR="$REPO_NAME"
REPO_SUMMARY="repo-summary.json"

echo "🔽 Cloning $REPO_URL into $CLONE_DIR..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"

if [ $? -ne 0 ]; then
  echo "❌ Failed to clone repo $REPO_URL"
  exit 1
fi

echo "🔎 Scanning repo..."
python3 agent/repo-scanner/scanner.py "$CLONE_DIR" > "$REPO_SUMMARY"

# 🛠️ Inject repo_url and repo_name into repo-summary.json
echo "🧹 Patching repo-summary.json with repo_url and repo_name..."
python3 -c "
import json
data = json.load(open('$REPO_SUMMARY'))
data['repo_name'] = '$REPO_NAME'
data['repo_url'] = '$REPO_URL'
with open('$REPO_SUMMARY', 'w') as f:
    json.dump(data, f, indent=2)
"

echo "🛠️ Generating full TechDocs using LLM..."
python3 agent/llm-client/generate_full_docs.py "$REPO_SUMMARY" "$CLONE_DIR"

echo "✅ Full documentation generated."

# Commit and open PR
bash agent/commit_and_pr.sh "$CLONE_DIR" "$REPO_NAME"

echo "🎉 PR creation flow completed!"
