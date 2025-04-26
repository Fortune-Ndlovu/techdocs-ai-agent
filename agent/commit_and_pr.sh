#!/bin/bash
# Git + GitHub CLI commit/PR

#!/bin/bash

set -e

REPO_DIR=$1
BRANCH_NAME="techdocs-init-$(date +%Y%m%d%H%M)"

cd "$REPO_DIR"
git checkout -b "$BRANCH_NAME"
git add docs/ mkdocs.yaml
git commit -m "chore(docs): add initial TechDocs structure"
git push origin "$BRANCH_NAME"

gh pr create --title "Add initial TechDocs structure" --body "This PR adds a starter TechDocs structure for RHDH integration." --base main
