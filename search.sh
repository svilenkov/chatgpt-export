#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"
require_src

[[ $# -lt 1 ]] && { echo "Usage: $0 <search-term>"; exit 1; }

{
  printf '%s\t%s\t%s\t%s\t%s\n' ID FROM TO MSGS TITLE
  jq -r --arg q "$*" '
    .[]
    | select((.title // "") | test($q; "i"))
    | [.id, ((.create_time // 0) | strftime("%Y-%m-%d")), ((.update_time // 0) | strftime("%Y-%m-%d")), (.mapping | to_entries | map(select(.value.message != null and .value.message.author.role != "system")) | length), (.title // "untitled")]
    | @tsv
  ' "$SRC"
} | column -t -s$'\t'