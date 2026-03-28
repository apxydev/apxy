#!/usr/bin/env bash
set -euo pipefail

# seed-traffic.sh — Send curl requests through the APXY proxy to populate traffic logs.
# Usage: seed-traffic.sh <scenario.json> <proxy_port>

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not found in PATH" >&2
  exit 1
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <scenario.json> <proxy_port>" >&2
  exit 1
fi

SCENARIO_FILE="$1"
PROXY_PORT="$2"

if [[ ! -f "$SCENARIO_FILE" ]]; then
  echo "Error: scenario file not found: $SCENARIO_FILE" >&2
  exit 1
fi

ENTRY_COUNT=$(jq '.setup.seed_traffic | length' "$SCENARIO_FILE")

if [[ "$ENTRY_COUNT" -eq 0 ]]; then
  echo "Seeded traffic: 0 endpoint(s)"
  exit 0
fi

for i in $(seq 0 $((ENTRY_COUNT - 1))); do
  METHOD=$(jq -r ".setup.seed_traffic[$i].method" "$SCENARIO_FILE")
  URL=$(jq -r ".setup.seed_traffic[$i].url" "$SCENARIO_FILE")
  REPEAT=$(jq -r ".setup.seed_traffic[$i].repeat // 1" "$SCENARIO_FILE")
  BODY=$(jq -r ".setup.seed_traffic[$i].body // empty" "$SCENARIO_FILE")
  HAS_HEADERS=$(jq ".setup.seed_traffic[$i] | has(\"headers\")" "$SCENARIO_FILE")

  CURL_ARGS=(-s -o /dev/null -X "$METHOD" -x "http://127.0.0.1:${PROXY_PORT}" "$URL")

  if [[ -n "$BODY" ]]; then
    CURL_ARGS+=(-d "$BODY" -H "Content-Type: application/json")
  fi

  if [[ "$HAS_HEADERS" == "true" ]]; then
    while IFS= read -r header_line; do
      CURL_ARGS+=(-H "$header_line")
    done < <(jq -r ".setup.seed_traffic[$i].headers | to_entries[] | \"\(.key): \(.value)\"" "$SCENARIO_FILE")
  fi

  for _r in $(seq 1 "$REPEAT"); do
    curl "${CURL_ARGS[@]}" || true
  done
done

echo "Seeded traffic: ${ENTRY_COUNT} endpoint(s)"
