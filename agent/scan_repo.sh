#!/bin/bash
# Checks repo structure

set -e

REPO_DIR=$1

echo "🔎 Scanning repo in $REPO_DIR..."

if [ ! -d "$REPO_DIR/docs" ]; then
  echo "⚠️ Docs folder missing."
  exit 1
fi

if [ ! -f "$REPO_DIR/mkdocs.yaml" ]; then
  echo "⚠️ mkdocs.yaml missing."
  exit 2
fi

echo "✅ Repo has TechDocs structure."
exit 0
