#!/usr/bin/env bash
# caveman-reminder.sh — PostToolUse hook (all tools)
#
# Scans tool output for verbose filler patterns. When detected, exits 2
# with a terse nudge. Behavioral shaping — not a hard block.
#
# Pattern list adapted from less_tokens/hooks/caveman-reminder.py.
#
# Exit 0 = no filler detected.
# Exit 2 = filler detected (soft signal — Claude sees the nudge).

set -euo pipefail

PAYLOAD=$(cat)

OUTPUT=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_response', {}).get('output', '') or str(d.get('tool_response', '')) or '')
except Exception:
    print('')
" 2>/dev/null || true)

[[ -z "$OUTPUT" ]] && exit 0

FILLER_PATTERNS=(
    'I apologize'
    "I'd be happy to"
    'Certainly!'
    'Certainly,'
    'Great question'
    'Of course'
    'Absolutely'
    'I understand that'
    'Please note that'
    'It is worth noting'
    'It seems that'
    'I was unable to'
    'As an AI'
)

for pattern in "${FILLER_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qi "$pattern" 2>/dev/null; then
        echo "Caveman mode. Short sentence. No filler." >&2
        exit 2
    fi
done

exit 0
