#!/usr/bin/env bash
# collect-signals.sh — read-only signal collector for /frontend-audit.
# Usage: ./collect-signals.sh [URL]
#
# Emits a small JSON document on stdout summarizing what's available in the
# current working directory and (optionally) a live target URL. Designed to
# be called by the frontend-checklist skill in audit mode and parsed with jq.

set -euo pipefail

URL="${1:-}"

emit() { printf '%s\n' "$1"; }

echo "{"

# --- project signals ---
echo '  "project": {'
if [[ -f package.json ]]; then
  echo '    "package_json": true,'
  NAME=$(jq -r '.name // ""' package.json 2>/dev/null || echo "")
  echo "    \"name\": \"${NAME}\","
  DEPS=$(jq -r '[.dependencies // {}, .devDependencies // {}] | add | keys | join(",")' package.json 2>/dev/null || echo "")
  echo "    \"deps\": \"${DEPS}\","
else
  echo '    "package_json": false,'
fi

for cfg in vite.config.ts vite.config.js next.config.js next.config.mjs astro.config.mjs astro.config.ts svelte.config.js nuxt.config.ts nuxt.config.js webpack.config.js rollup.config.js rollup.config.mjs; do
  if [[ -f "$cfg" ]]; then
    echo "    \"$cfg\": true,"
  fi
done

echo "    \"dist_present\": $([[ -d dist ]] && echo true || echo false),"
echo "    \"build_present\": $([[ -d build ]] && echo true || echo false),"
echo "    \"public_present\": $([[ -d public ]] && echo true || echo false),"

LH=$(ls lighthouse*.json 2>/dev/null | head -1 || true)
echo "    \"lighthouse_json\": \"${LH}\","
AXE=$(ls axe-results*.json 2>/dev/null | head -1 || true)
echo "    \"axe_json\": \"${AXE}\""
echo "  }"

# --- live signals ---
if [[ -n "$URL" ]]; then
  echo "  ,"
  echo '  "live": {'
  echo "    \"url\": \"${URL}\","
  HEADERS=$(curl -sI -L --max-time 10 "$URL" 2>/dev/null | tr -d '\r' | sed 's/"/\\"/g' | awk 'NF' | paste -sd '|' -)
  echo "    \"headers_pipe\": \"${HEADERS}\","
  HEAD_HTML=$(curl -s -L --max-time 10 "$URL" 2>/dev/null | tr -d '\n' | grep -oE '<head[^>]*>.*</head>' | head -c 8000 | sed 's/"/\\"/g' || true)
  echo "    \"head_html\": \"${HEAD_HTML}\""
  echo "  }"
fi

echo "}"
