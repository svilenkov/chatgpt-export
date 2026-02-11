#!/usr/bin/env bash

jq -r '.[].mapping[]?.message.content.parts[]?' convo.json > convo_lines.txt

title=$(jq -r '.[0].title // "untitled"' convo.json)
lines=$(wc -l < convo_lines.txt | tr -d ' ') || :
words=$(wc -w < convo_lines.txt | tr -d ' ') || :

echo "extracted '$title' to convo_lines.txt ($lines lines, $words words)"