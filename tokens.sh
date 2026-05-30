#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"
require_src

# detect best available tokenizer
# shellcheck disable=SC2016  # $id is a jq variable
detect_tokenizer() {
  command -v ttok &>/dev/null && { echo ttok; return; }
  python3 -c "import tiktoken" 2>/dev/null && { echo tiktoken; return; }
  echo chars
}

TOKENIZER=$(detect_tokenizer)

count_tiktoken() {
  python3 -c "
import tiktoken, sys
enc = tiktoken.encoding_for_model('gpt-4o')
print(len(enc.encode(sys.stdin.read())))" < "$1"
}

count_tokens() {
  case "$TOKENIZER" in
    ttok)     ttok < "$1" ;;

    tiktoken) count_tiktoken "$1" ;;

    chars)
              local bytes; bytes=$(wc -c < "$1")
              echo $(( bytes / 4 )) ;;

    *)        echo "unknown tokenizer: $TOKENIZER" >&2; exit 1 ;;
  esac
}

extract_text() {
  jq -r --arg id "$1" '
    .[] | select(.id == $id)
    | .mapping | to_entries[]
    | .value.message // empty
    | select(.author.role != "system")
    | select(.content.parts != null)
    | .content.parts[] | strings
  ' "$SRC"
}

usage() {
  echo "Usage: $0 <id> [id...]"
  echo "       ./search.sh CommP | $0"
  echo "Tokenizer: $TOKENIZER"
  exit 1
}

[[ $# -eq 0 ]] && [[ -t 0 ]] && usage

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

tokenize_convo() {
  extract_text "$1" > "$tmp"
  local tokens; tokens=$(count_tokens "$tmp")
  local title; title=$(jq -r --arg id "$1" '.[] | select(.id == $id) | .title // "untitled"' "$SRC")
  printf '%s\t%s\t%s\n' "$1" "$tokens" "$title"
}

# two input modes:
#   args:  ./tokens.sh 69a4b982-... 67d7dfae-...
#   pipe:  ./search.sh CommP | ./tokens.sh
collect_ids() {
  # mode 1: IDs as arguments
  if [[ $# -gt 0 ]]; then
    printf '%s\n' "$@"

  # mode 2: piped from stdin
  else
    while read -r id rest; do
      [[ "$id" == "ID" || -z "$id" ]] && continue # skip blank
      echo "$id"
    done
  fi
}

{
  printf '%s\t%s\t%s\n' ID TOKENS TITLE
  for id in $(collect_ids "$@"); do
    tokenize_convo "$id"
  done
} | column -t -s$'\t'

echo "(tokenizer: $TOKENIZER)" >&2