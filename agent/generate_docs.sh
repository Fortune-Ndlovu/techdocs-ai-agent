#!/bin/bash
# Creates boilerplate docs if missing

set -e

REPO_DIR=$1
REPO_NAME=$2

# Create docs/ folder
mkdir -p "$REPO_DIR/docs"

# Generate clean boilerplate markdowns
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/index.md.tpl > "$REPO_DIR/docs/index.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/getting-started.md.tpl > "$REPO_DIR/docs/getting-started.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/architecture.md.tpl > "$REPO_DIR/docs/architecture.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/deployment-guide.md.tpl > "$REPO_DIR/docs/deployment-guide.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/testing.md.tpl > "$REPO_DIR/docs/testing.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/troubleshooting.md.tpl > "$REPO_DIR/docs/troubleshooting.md"

# Generate mkdocs.yaml
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/mkdocs.yaml.tpl > "$REPO_DIR/mkdocs.yaml"

# Generate catalog-info.yaml
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/catalog-info.yaml.tpl > "$REPO_DIR/catalog-info.yaml"

echo "✅ Generated full boilerplate TechDocs structure for $REPO_NAME."
