#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"
require_src

mode=title
[[ "${1:-}" == "-c" ]]    && { mode=content; shift; }
[[ "${1:-}" == "--id" ]]  && { mode=id; shift; }

[[ $# -lt 1 ]] && { echo "Usage: $0 [-c|--id] <search-term|conversation-id>"; exit 1; }

# shellcheck disable=SC2016  # $q is a jq variable, not bash
find_ids() {
  local filter
  if [[ "$mode" == "content" ]]; then
    filter='select(any(.mapping[].message? // empty |
      .content.parts[]? // empty | strings;
      test($q; "i")))'
  else
    filter='select((.title // "") | test($q; "i"))'
  fi
  jq -r --arg q "$1" ".[] | $filter | .id" "$SRC"
}

extract_transcript() {
  jq -r --arg id "$1" '
    .[] | select(.id == $id)
    | "\(.title // "untitled")\n============================================================",
    (.mapping | to_entries[]
      | .value.message // empty
      | select(.author.role != "system")
      | select(.content.parts != null)
      | "\(.author.role): \(.content.parts | map(strings) | join(" "))\n")
  ' "$SRC"
}

if [[ "$mode" == "id" ]]; then
  ids="$1"
else
  ids=$(find_ids "$*")
fi
[[ -z "$ids" ]] && { echo "no matches for: $*" >&2; exit 1; }

count=$(echo "$ids" | wc -l | tr -d ' ')
[[ "$count" -gt 1 ]] && echo "$count conversations matched, showing all" >&2

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for id in $ids; do
  extract_transcript "$id"
done > "$tmp"

less "$tmp"