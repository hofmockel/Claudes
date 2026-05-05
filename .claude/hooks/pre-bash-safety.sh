#!/usr/bin/env bash
# pre-bash-safety.sh — PreToolUse hook for the Bash tool
#
# Blocks unconditionally dangerous command patterns before execution.
# Exit 0 = allow. Exit 1 = hard block (Claude sees error, cannot proceed).
#
# To add a pattern: extend BLOCKED_PATTERNS below.
# To disable a check: comment out the line.

set -euo pipefail

PAYLOAD=$(cat)

COMMAND=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null || true)

[[ -z "$COMMAND" ]] && exit 0

BLOCKED_PATTERNS=(
    'rm[[:space:]]+-rf[[:space:]]+/'        # rm -rf / (root)
    'rm[[:space:]]+-rf[[:space:]]+\*'       # rm -rf * (wildcard)
    'rm[[:space:]]+-rf[[:space:]]+~'        # rm -rf ~ (home)
    'dd[[:space:]]+if=.*of=/dev/'           # dd to block device
    'mkfs\.'                                # filesystem format
    '>[[:space:]]*/dev/sd'                  # redirect to disk
    'chmod[[:space:]]+-R[[:space:]]+777'    # recursive world-write
    'curl.*\|.*sh'                          # curl pipe to shell
    'wget.*\|.*sh'                          # wget pipe to shell
    ':\(\)\{[[:space:]]*:\|:&[[:space:]]*\};:' # fork bomb
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern" 2>/dev/null; then
        echo "BLOCKED: command matches dangerous pattern '$pattern'" >&2
        echo "Command: $COMMAND" >&2
        exit 1
    fi
done

exit 0
