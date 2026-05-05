#!/usr/bin/env bash
# post-tool-truncate.sh — PostToolUse hook for Bash, Read, WebFetch
#
# Caps tool output at MAX_CHARS to avoid flooding context with large outputs.
# Strategy (from less_tokens):
#   Bash       — preserve first HEAD_LINES + last TAIL_LINES, elide middle
#   Read/WebFetch — keep first 60% + last 40%
#
# Exit 0 = output within limit, no action.
# Exit 2 = output truncated (soft signal — Claude sees the note and continues).
#
# Override the limit: export LESS_TOKENS_MAX_CHARS=8000 in your shell or .env.

set -euo pipefail

MAX_CHARS="${LESS_TOKENS_MAX_CHARS:-4000}"
HEAD_LINES=50
TAIL_LINES=20

PAYLOAD=$(cat)

TOOL=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('tool_name', ''))
except Exception:
    print('')
" 2>/dev/null || true)

OUTPUT=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_response', {}).get('output', '') or d.get('tool_response', '') or '')
except Exception:
    print('')
" 2>/dev/null || true)

OUTPUT_LEN=${#OUTPUT}

[[ $OUTPUT_LEN -le $MAX_CHARS ]] && exit 0

case "$TOOL" in
  Bash)
    TRUNCATED=$(printf '%s' "$OUTPUT" | head -n "$HEAD_LINES")
    TAIL=$(printf '%s' "$OUTPUT" | tail -n "$TAIL_LINES")
    OMITTED=$(( OUTPUT_LEN - ${#TRUNCATED} - ${#TAIL} ))
    printf '%s\n... %d chars omitted ...\n%s\n' "$TRUNCATED" "$OMITTED" "$TAIL" >&2
    echo "Output truncated to first ${HEAD_LINES} + last ${TAIL_LINES} lines (${OMITTED} chars omitted). Use a narrower command to see more." >&2
    ;;
  Read|WebFetch)
    SPLIT=$(( MAX_CHARS * 6 / 10 ))
    HEAD_PART="${OUTPUT:0:$SPLIT}"
    TAIL_PART="${OUTPUT: -$(( MAX_CHARS * 4 / 10 ))}"
    OMITTED=$(( OUTPUT_LEN - ${#HEAD_PART} - ${#TAIL_PART} ))
    printf '%s\n... %d chars omitted ...\n%s\n' "$HEAD_PART" "$OMITTED" "$TAIL_PART" >&2
    echo "Output truncated (${OMITTED} chars omitted). Request a specific section to read more." >&2
    ;;
  *)
    exit 0
    ;;
esac

exit 2
