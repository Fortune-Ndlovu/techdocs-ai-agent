#!/bin/bash
# Creates docs if missing

set -e

REPO_DIR=$1
REPO_NAME=$2

mkdir -p "$REPO_DIR/docs"

# Replace {{ repo_name }} in templates
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/index.md.tpl > "$REPO_DIR/docs/index.md"
sed "s/{{ repo_name }}/$REPO_NAME/g" agent/templates/mkdocs.yaml.tpl > "$REPO_DIR/mkdocs.yaml"

echo "✅ Generated starter docs for $REPO_NAME."
