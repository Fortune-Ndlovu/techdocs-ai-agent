#!/bin/bash
# Commits generated docs and opens a PR

set -e

REPO_DIR=$1
REPO_NAME=$2

cd "$REPO_DIR"

# Create new branch
BRANCH_NAME="techdocs-init-$(date +%Y%m%d%H%M)"
git checkout -b "$BRANCH_NAME"

# Stage all new/changed files
git add .

# Commit
git commit -m "🤖 Add initial AI-generated TechDocs for $REPO_NAME"

# Push branch
git push origin "$BRANCH_NAME"

# Open PR using GitHub CLI
gh pr create --title "Add initial TechDocs for $REPO_NAME [auto-generated]" --body "This PR adds AI-generated TechDocs content for $REPO_NAME. 🎉" --base main
