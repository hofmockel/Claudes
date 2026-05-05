---
name: ship
description: Pre-push quality gate — runs the full local CI equivalent before git push
---

Run each check in sequence. Stop and report the exact failure on first error. Do NOT push if anything fails.

1. `ruff check .` — report file:line for any lint errors
2. `mypy . --ignore-missing-imports` — report type errors
3. `pytest --tb=short -q` — report pass/fail/error counts
4. If `.github/workflows/` exists: `actionlint` — report YAML issues

If all four pass:
- `git push` (current branch)
- Report: branch name, commit SHA, and a one-line summary of what shipped

If any check fails:
- List each failure with file and line
- Do NOT push
- Wait for instruction — do not attempt auto-fixes unless explicitly asked
