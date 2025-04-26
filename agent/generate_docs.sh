#!/bin/bash
# Creates docs if missing

set -e

REPO_DIR=$1
REPO_NAME=$2

# Create docs/ folder if missing
mkdir -p "$REPO_DIR/docs"

# Generate index.md
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/index.md.tpl > "$REPO_DIR/docs/index.md"

# Generate mkdocs.yaml
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/mkdocs.yaml.tpl > "$REPO_DIR/mkdocs.yaml"

# Generate catalog-info.yaml
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/catalog-info.yaml.tpl > "$REPO_DIR/catalog-info.yaml"

echo "✅ Generated full TechDocs structure for $REPO_NAME."
