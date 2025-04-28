#!/bin/bash
# Register a GitHub repo into RHDH via OpenShift OAuth Token

set -euo pipefail

# ===========
# INPUT
# ===========
REPO_URL="${1:-}"
if [[ -z "$REPO_URL" ]]; then
  echo "❌ Error: No GitHub repo URL provided!"
  echo "Usage: bash register_component.sh <github-repo-url>"
  exit 1
fi

# ===========
# CONFIGURATION
# ===========
DEVHUB_URL="https://redhat-developer-hub-rhdh-helm.apps.rosa.yt5yv-s5w6d-qyv.zn48.p3.openshiftapps.com"
BRANCH="main"

# OpenShift token for authentication (export this before running the script)
: "${OCP_TOKEN:=}"

if [[ -z "$OCP_TOKEN" ]]; then
  echo "❌ Error: OCP_TOKEN environment variable not set."
  echo "Set it with: export OCP_TOKEN=sha256~your-real-token"
  exit 1
fi

# ===========
# FUNCTIONS
# ===========

retry_curl() {
  local retries=5
  local wait=5
  local i=0

  until "$@"; do
    if (( i >= retries )); then
      echo "❌ Command failed after $retries attempts."
      return 1
    fi
    echo "⚡ Retry $((i+1))/$retries in ${wait}s..."
    sleep "$wait"
    ((i++))
  done
}

# ===========
# MAIN
# ===========

# Detect catalog-info.yaml location
if [[ "$REPO_URL" == *"/blob/"* ]]; then
  RAW_URL="${REPO_URL/github.com/raw.githubusercontent.com}"
  RAW_URL="${RAW_URL/\/blob\//\/}"
else
  REPO_OWNER="$(basename "$(dirname "$REPO_URL")")"
  REPO_NAME="$(basename -s .git "$REPO_URL")"
  RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/catalog-info.yaml"
fi

echo "📄 Using catalog-info.yaml from: $RAW_URL"

# Validate catalog-info.yaml exists
if ! curl --head --silent --fail "$RAW_URL" > /dev/null; then
  echo "❌ catalog-info.yaml not found at $RAW_URL"
  exit 1
fi
echo "✅ catalog-info.yaml found!"

# Register component
echo "🚀 Registering component into Developer Hub..."

response=$(retry_curl curl -s -w "\n%{http_code}" -X POST "$DEVHUB_URL/api/catalog/register" \
  -H "Authorization: Bearer $OCP_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"location\": {\"type\": \"url\", \"target\": \"$RAW_URL\"}}")

# Split body and HTTP status
body=$(echo "$response" | sed '$d')
status=$(echo "$response" | tail -n1)

if [[ "$status" == "200" ]]; then
  echo "🎉 Successfully registered: $RAW_URL"
else
  echo "❌ Failed to register component! HTTP $status"
  echo "Response:"
  echo "$body"
  exit 1
fi
