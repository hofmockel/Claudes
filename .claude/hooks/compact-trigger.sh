#!/usr/bin/env bash
# compact-trigger.sh — PostToolUse hook (all tools)
#
# Monitors transcript size. When it exceeds MAX_SESSION_CHARS, exits 2
# with a nudge to run /compact. Implements hysteresis so it doesn't fire
# on every subsequent tool use after the threshold is crossed.
#
# State file: .claude/state/compact-trigger-last (stores size at last trigger)
#
# Exit 0 = under threshold or within hysteresis window.
# Exit 2 = over threshold (soft signal — Claude sees the message, not blocked).

set -euo pipefail

MAX_SESSION_CHARS="${LESS_TOKENS_MAX_SESSION_CHARS:-500000}"
HYSTERESIS=$(( MAX_SESSION_CHARS / 4 ))  # must grow 25% past last trigger to fire again

STATE_DIR=".claude/state"
STATE_FILE="$STATE_DIR/compact-trigger-last"

PAYLOAD=$(cat)

TRANSCRIPT_PATH=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('transcript_path', ''))
except Exception:
    print('')
" 2>/dev/null || true)

[[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]] && exit 0

TRANSCRIPT_SIZE=$(wc -c < "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)

[[ $TRANSCRIPT_SIZE -le $MAX_SESSION_CHARS ]] && exit 0

LAST_TRIGGER=0
if [[ -f "$STATE_FILE" ]]; then
    LAST_TRIGGER=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

# Only fire if we've grown HYSTERESIS chars past the last trigger
if [[ $TRANSCRIPT_SIZE -le $(( LAST_TRIGGER + HYSTERESIS )) ]]; then
    exit 0
fi

mkdir -p "$STATE_DIR"
echo "$TRANSCRIPT_SIZE" > "$STATE_FILE"

APPROX_KB=$(( TRANSCRIPT_SIZE / 1024 ))
echo "Transcript ~${APPROX_KB}KB. Run /compact to reduce context before continuing." >&2

exit 2
