#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/lib.sh"
require_src

title="${1:-Series Structure and Routing}"

[[ "${1:-}" == "--id" ]] && {
  jq --arg id "$2" '[ .[] | select(.id == $id) ]' "$SRC" > convo.json
  exit 0
}

jq --arg t "$title" ' [ .[] | select(.title == $t) ]' "$SRC" > convo.json
