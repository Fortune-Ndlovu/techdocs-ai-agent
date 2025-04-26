#!/bin/bash
# Git + GitHub CLI commit/PR

set -e

REPO_DIR=$1
REPO_NAME=$2
BRANCH_NAME="techdocs-init-$(date +%Y%m%d%H%M)"

cd "$REPO_DIR"
git checkout -b "$BRANCH_NAME"

# Add all relevant files
git add docs/ mkdocs.yaml catalog-info.yaml

git commit -m "chore(docs): add initial TechDocs structure for $REPO_NAME"
git push origin "$BRANCH_NAME"

# Create PR with dynamic title
PR_TITLE="Add initial TechDocs for ${REPO_NAME} project [auto-generated]"

gh pr create --title "$PR_TITLE" \
  --body "This PR adds a starter TechDocs structure for the **${REPO_NAME}** project to enable RHDH documentation integration." \
  --base main
