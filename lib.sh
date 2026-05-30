#!/usr/bin/env bash

[[ -f "${SCRIPT_DIR:-.}/.env" ]] && . "${SCRIPT_DIR:-.}/.env" 2>/dev/null || true

: "${EXPORT_PATH:?Export path not set}"

SPLITS=("$EXPORT_PATH"/conversations-*.json)

find_src() {
  [[ -f "$EXPORT_PATH/conversations.json" ]] && { echo "$EXPORT_PATH/conversations.json"; return; }
  [[ -f "${SPLITS[0]}" ]] && { merge_splits; return; }

  echo "no conversation files in $EXPORT_PATH" >&2; exit 1
}

# ChatGPT exports changed format around early 2026:
# old: single conversations.json (one JSON array)
# new: split into conversations-000.json .. conversations-NNN.json (each a separate array)
# merge them into one cached file so downstream scripts don't care which format
merge_splits() {
  local merged="$EXPORT_PATH/.conversations-merged.json"
  local newest=""

  for f in "${SPLITS[@]}"; do
    [[ -z "$newest" || "$f" -nt "$newest" ]] && newest="$f"
  done

  [[ -f "$merged" && "$merged" -nt "$newest" ]] || {
    jq -s 'add' "${SPLITS[@]}" > "$merged"
    echo "merged ${#SPLITS[@]} files → $merged" >&2
  }

  echo "$merged"
}

SRC=$(find_src)

require_src() { [ -f "$SRC" ] || { echo "File not found: $SRC" >&2; exit 1; }; }