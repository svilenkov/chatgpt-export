#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/lib.sh"
require_src

{
  printf '%s\t%s\t%s\n' TITLE UPDATED MSGS
  jq -r '.[] | [
    (.title // "untitled")[:50],
    ((.update_time // 0) | strftime("%Y-%m-%d %H:%M")),
    (.mapping | to_entries | map(select(.value.message != null and .value.message.author.role != "system")) | length)
  ] | @tsv' "$SRC"
} | column -t -s$'\t'

total=$(jq length "$SRC")
echo "Total: $total"