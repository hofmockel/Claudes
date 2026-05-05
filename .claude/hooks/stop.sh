#!/usr/bin/env bash
# Stop hook — fires when a Claude session ends.
# Writes .claude/state/last-session-handover.md so the next session resumes fast.
# Always exits 0 — never blocks session end.

set -u

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_DIR="$REPO_ROOT/.claude/state"
OUT="$STATE_DIR/last-session-handover.md"

mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
LAST_COMMIT="$(git -C "$REPO_ROOT" log -1 --oneline 2>/dev/null || echo none)"
DIRTY_FILES="$(git -C "$REPO_ROOT" status --short 2>/dev/null | head -20)"
RECENT_COMMITS="$(git -C "$REPO_ROOT" log --oneline -5 2>/dev/null)"

{
  echo "# Last Session Handover"
  echo
  echo "_Generated $(date '+%Y-%m-%d %H:%M:%S') by stop.sh_"
  echo
  echo "## Current state"
  echo "- Branch: \`$BRANCH\`"
  echo "- Last commit: $LAST_COMMIT"
  echo
  echo "## In progress (uncommitted)"
  if [ -n "$DIRTY_FILES" ]; then
    echo '```'
    echo "$DIRTY_FILES"
    echo '```'
  else
    echo "_clean working tree_"
  fi
  echo
  echo "## Recent commits"
  echo '```'
  echo "$RECENT_COMMITS"
  echo '```'
  echo
  echo "## Next steps"
  echo "- Run \`/session-start\` to surface backlog + journal."
  echo "- Run \`/handover\` mid-session for a richer snapshot."
} > "$OUT" 2>/dev/null

exit 0
