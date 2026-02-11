#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

[[ -f convo.json ]] || { echo "Run filter.sh first to create convo.json"; exit 1; }
mkdir -p ./files

jq -r '.. | objects | select(has("attachments")) | .attachments[] | "\(.id)\t\(.name)"' convo.json |
while IFS=$'\t' read -r id name; do
  src="$EXPORT_PATH/${id}-${name}"
  if [[ -f "$src" ]]; then
    cp "$src" ./files/
    echo "✅ $name"
  else
    echo "❌ $name"
  fi
done