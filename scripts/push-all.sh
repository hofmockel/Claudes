#!/usr/bin/env bash
# Push the current branch to every configured remote.
# Used by /ship and /create-pr to keep GitHub + GitLab in sync.
set -euo pipefail

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
REMOTES="$(git remote)"

if [ -z "$REMOTES" ]; then
  echo "No remotes configured." >&2
  exit 1
fi

FAIL=0
for remote in $REMOTES; do
  echo "→ pushing to $remote/$BRANCH"
  if git push -u "$remote" "$BRANCH"; then
    echo "  ✅ $remote"
  else
    echo "  ❌ $remote — push failed" >&2
    FAIL=1
  fi
done

exit "$FAIL"
