#!/bin/bash
# Wait for PR to merge and register catalog-info.yaml into Developer Hub

set -e

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
  echo "❌ Error: No GitHub repo URL provided!"
  exit 1
fi

REPO_OWNER=$(basename $(dirname "$REPO_URL"))
REPO_NAME=$(basename -s .git "$REPO_URL")
BRANCH="main" # Assuming PR is merged into main

# GitHub Token (optional if repo is public; safer to use token if private)
GITHUB_TOKEN="your-github-token-here"

# RHDH details
DEVHUB_URL="https://your-devhub.example.com"    # <-- 🔥 your cluster Developer Hub URL
RHDH_TOKEN="your-devhub-access-token-here"      # <-- 🔥 your OpenShift RHDH service token

# Get the latest merged commit
echo "🔎 Checking for latest merged commit..."
MERGED=false
while [ "$MERGED" = false ]; do
  sleep 10
  PR_STATUS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls?state=closed" | jq '.[] | select(.merged_at != null) | .merged_at' | head -n1)

  if [ ! -z "$PR_STATUS" ]; then
    echo "✅ PR merged at $PR_STATUS"
    MERGED=true
  else
    echo "⏳ Waiting for PR to merge..."
  fi
done

# Compose the catalog-info.yaml URL (raw)
CATALOG_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/catalog-info.yaml"

# Register it into Developer Hub
echo "🚀 Registering component into Developer Hub..."

curl -X POST "$DEVHUB_URL/api/catalog/register" \
  -H "Authorization: Bearer $RHDH_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"location\": {\"type\": \"url\", \"target\": \"$CATALOG_URL\"}}"

echo "🎉 Component registered successfully: $CATALOG_URL"
