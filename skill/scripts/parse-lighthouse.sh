#!/usr/bin/env bash
# parse-lighthouse.sh — extract key metrics from a Lighthouse JSON report.
# Usage: ./parse-lighthouse.sh path/to/lighthouse.json
#
# Emits a small JSON document on stdout: { lcp, inp, cls, fcp, ttfb, score }.
# All values in seconds (or unitless ratio for cls / 0..1 for score).
# Returns "null" for any metric not present in the report.

set -euo pipefail

FILE="${1:-lighthouse.json}"

if [[ ! -f "$FILE" ]]; then
  echo "{\"error\":\"file not found: ${FILE}\"}"
  exit 1
fi

jq '{
  lcp:   (.audits["largest-contentful-paint"].numericValue // null) | (if . then . / 1000 else null end),
  inp:   (.audits["interaction-to-next-paint"].numericValue // .audits["experimental-interaction-to-next-paint"].numericValue // null) | (if . then . / 1000 else null end),
  cls:   (.audits["cumulative-layout-shift"].numericValue // null),
  fcp:   (.audits["first-contentful-paint"].numericValue // null) | (if . then . / 1000 else null end),
  ttfb:  (.audits["server-response-time"].numericValue // null) | (if . then . / 1000 else null end),
  tbt:   (.audits["total-blocking-time"].numericValue // null),
  score: (.categories.performance.score // null)
}' "$FILE"
