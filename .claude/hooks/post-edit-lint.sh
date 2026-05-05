#!/usr/bin/env bash
# post-edit-lint.sh — PostToolUse hook for Edit and Write tools
#
# Runs the appropriate linter after every file edit.
# Exit 0 = clean (or no linter configured). Exit 2 = lint errors (soft block —
# Claude sees the output and can fix the issues in the same session).
#
# SETUP: uncomment the block for your stack. Multiple blocks can be active.
# Each block guards with `command -v` so a missing linter exits 0 gracefully.

set -euo pipefail

PAYLOAD=$(cat)

FILE=$(printf '%s' "$PAYLOAD" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || true)

[[ -z "$FILE" || ! -f "$FILE" ]] && exit 0

EXT="${FILE##*.}"
OUTPUT=""
RC=0

# ── Python — ruff (active) ────────────────────────────────────────────────────
if [[ "$EXT" == "py" ]] && command -v ruff &>/dev/null; then
    OUTPUT=$(ruff check --quiet "$FILE" 2>&1) || RC=$?
fi

# ── JavaScript / TypeScript ───────────────────────────────────────────────────
# if [[ "$EXT" == "js" || "$EXT" == "ts" || "$EXT" == "jsx" || "$EXT" == "tsx" ]]; then
#     if command -v eslint &>/dev/null; then
#         OUTPUT=$(eslint --quiet "$FILE" 2>&1) || RC=$?
#     fi
# fi

# ── Go ────────────────────────────────────────────────────────────────────────
# if [[ "$EXT" == "go" ]] && command -v golint &>/dev/null; then
#     OUTPUT=$(golint "$FILE" 2>&1) || RC=$?
# fi

# ── Ruby ──────────────────────────────────────────────────────────────────────
# if [[ "$EXT" == "rb" ]] && command -v rubocop &>/dev/null; then
#     OUTPUT=$(rubocop --format quiet "$FILE" 2>&1) || RC=$?
# fi

# ── Shell ─────────────────────────────────────────────────────────────────────
# if [[ "$EXT" == "sh" ]] && command -v shellcheck &>/dev/null; then
#     OUTPUT=$(shellcheck "$FILE" 2>&1) || RC=$?
# fi

if [[ $RC -ne 0 && -n "$OUTPUT" ]]; then
    echo "Lint errors in $FILE:" >&2
    echo "$OUTPUT" >&2
    exit 2
fi

exit 0
