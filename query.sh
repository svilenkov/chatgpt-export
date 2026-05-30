#!/usr/bin/env bash
set -euo pipefail

[[ -f convo.json ]] || { echo "Run filter.sh first to create convo.json" >&2; exit 1; }
[[ $# -lt 1 ]] && { echo "Usage: $0 '<question about this conversation>'" >&2; exit 1; }

prompt="$*"

transcript=$(jq -r '
  .[].mapping | to_entries[]
  | .value.message // empty
  | select(.author.role != "system")
  | select(.content.parts != null)
  | "\(.author.role): \(.content.parts | map(strings) | join(" "))"
' convo.json)

[[ -z "$transcript" ]] && { echo "No messages found in convo.json" >&2; exit 1; }

printf 'Here is a conversation transcript:\n\n%s\n\nQuestion: %s\n' "$transcript" "$prompt" | claude -p
