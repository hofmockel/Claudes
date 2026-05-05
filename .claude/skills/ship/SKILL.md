---
name: ship
description: Pre-push quality gate — runs the full local CI equivalent before pushing to all remotes (GitHub + GitLab).
---

Run each check in sequence. Stop and report the exact failure on first error. Do NOT push if anything fails.

1. `ruff check .` — report file:line for any lint errors
2. `mypy . --ignore-missing-imports` — report type errors
3. `pytest --tb=short -q` — report pass/fail/error counts
4. If `.github/workflows/` exists: `actionlint` — report YAML issues
5. If `.gitlab-ci.yml` exists: validate via `glab ci lint` (or skip with a note if `glab` unavailable)

If all checks pass:
- `bash scripts/push-all.sh` — pushes the current branch to **every** configured remote (GitHub + GitLab)
- Report: branch name, commit SHA, per-remote push result, and a one-line summary of what shipped

If any check fails:
- List each failure with file and line
- Do NOT push
- Wait for instruction — do not attempt auto-fixes unless explicitly asked

## Dual-remote contract

Both `github` and `gitlab` remotes must succeed. If one fails:
- Do not declare ship complete
- Report which remote failed and why
- Suggest `git push <remote> <branch>` to retry the failed one only
