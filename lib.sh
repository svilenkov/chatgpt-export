#!/usr/bin/env bash

[[ -f "${SCRIPT_DIR:-.}/.env" ]] && . "${SCRIPT_DIR:-.}/.env" 2>/dev/null || true

: "${EXPORT_PATH:?Export path not set}"
SRC="$EXPORT_PATH/conversations.json"

require_src() {
    [ -f "$SRC" ] || { echo "File not found: $SRC" >&2; exit 1; }
}
