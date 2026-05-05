# Claude Code Workflow Rules

This repo is the source of truth for Claude Code configuration across all projects. Rules here apply to every session.

## Response Length

Keep responses under 400 tokens unless explicitly asked for long-form output. Prefer file paths and one-line summaries over inline code dumps. Never dump entire file contents unless asked.

## Mandatory Plan Step

Before editing ANY change that touches 3+ files, or any request containing the word "refactor": enter plan mode, list every file you will touch, explicitly state what you will NOT change, wait for approval. No exceptions.

## Scope Discipline

When a change can be narrower, make it narrower. A cash pass-through does not need multi-account support. A single-file bug fix does not need surrounding cleanup. If you catch yourself generalizing beyond the stated request, stop.

## Documentation Discipline

- `journal.md` / `journal.csv` = past events log only. Never write forward-looking items there.
- `backlog.md`: append or edit in place only — never overwrite. Use Edit, not Write.
- `plan.md` = future actions only.
- `CHANGELOG.md`: one entry per commit, prepend (newest at top), not append.
- `decisions.md`: architectural decisions. Do not mix into `specification.md` or changelog.

## Verification Before Shipping

After every multi-file change: run the full test suite and report pass count before declaring done. For bug fixes: add a regression test in the same commit. Run `/ship` before any `git push`.

Never propose deleting a confirmation or safety alert without explicit user approval.

## Environment & Secrets

All secrets load from `.env` — never hardcode. Required env vars:
- `RH_ROTH_ACCOUNT_NUMBER` — Robinhood sync
- `GITHUB_TOKEN` with `repo` + `workflow` scopes — gh CLI / PR creation

For any portfolio or CI work, run `scripts/preflight.sh` at session start. If env vars are missing, surface them immediately rather than failing mid-session.

## Bug Fix Workflow

Use `/fix-bug` for all backlog items. Commit format: `fix: <one-line summary>`. Each fix is one atomic commit — no bundling.

## Pushing Code

Use `/ship` before any `git push`. It runs ruff + mypy + pytest + actionlint and gates the push on all passing.

## CI Failures

Use `/ci-fix` when CI is red. Never push a "maybe this fixes it" commit without running the full local equivalent first.

## Parallel Bug Fixing

Use `/batch-fix` for 5+ independent backlog items. It spawns sub-agents with git worktrees so agents do not collide on shared files.
