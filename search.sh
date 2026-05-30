#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"
require_src

content=false
[[ "${1:-}" == "-c" ]] && { content=true; shift; }

[[ $# -lt 1 ]] && { echo "Usage: $0 [-c] <search-term>"; echo "  -c  search message content (slower)"; exit 1; }

# shared output: ID FROM TO MSGS TITLE
fmt_row='[.id,
  ((.create_time // 0) | strftime("%Y-%m-%d")),
  ((.update_time // 0) | strftime("%Y-%m-%d")),
  ([.mapping | to_entries[] | select(.value.message != null and .value.message.author.role != "system")] | length),
  (.title // "untitled")]
| @tsv'

search_by_title() {
  jq -r --arg q "$1" \
    ".[] | select((.title // \"\") | test(\$q; \"i\")) | $fmt_row" "$SRC"
}

search_by_content() {
  jq -r --arg q "$1" "
    .[]
    | select(any(.mapping[].message? // empty |
        .content.parts[]? // empty | strings;
        test(\$q; \"i\")))
    | $fmt_row" "$SRC"
}

{
  printf '%s\t%s\t%s\t%s\t%s\n' ID FROM TO MSGS TITLE
  if $content; then
    search_by_content "$*"
  else
    search_by_title "$*"
  fi
} | column -t -s$'\t'