# Claude Code Workflow Rules

This repo is the source of truth for Claude Code configuration across all projects. Rules here apply to every session.

## Response Length

Keep responses under 400 tokens unless explicitly asked for long-form output. Prefer file paths and one-line summaries over inline code dumps. Never dump entire file contents unless asked.

## Mandatory Plan Step

Before editing ANY change that touches 3+ files, or any request containing the word "refactor": enter plan mode, list every file you will touch, explicitly state what you will NOT change, wait for approval. No exceptions.

## Scope Discipline

When a change can be narrower, make it narrower. A single-file bug fix does not need surrounding cleanup. A one-shot helper does not need a generalized abstraction. If you catch yourself generalizing beyond the stated request, stop.

## Developer as Reviewer

Your role is architect and reviewer, not typist. Claude builds; you:
- Approve plans before execution (plan mode)
- Review diffs before commits (`/review`)
- Own architectural decisions (`decisions.md`)
- Reject any output that deviates from scope

## Documentation Discipline

- `backlog.md`: append or edit in place only — never overwrite. Use Edit, not Write.
- `plan.md` = future actions only.
- `changelog.md`: [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/). Prepend new entries to `[Unreleased]`; never append.
- `decisions.md`: architectural decisions. Do not mix into `specification.md` or changelog.
- Past-session context lives in `.claude/state/` (handover files written by `/handover` and the Stop hook). No standalone journal.

## Verification Before Shipping

After every multi-file change: run the full test suite and report pass count before declaring done. For bug fixes: add a regression test in the same commit. Run `/ship` before any `git push`.

Never propose deleting a confirmation or safety alert without explicit user approval.

## Environment & Secrets

All secrets load from `.env` — never hardcode. Required env vars:
- `GITHUB_TOKEN` with `repo` + `workflow` scopes — gh CLI / PR creation
- `GITLAB_TOKEN` — glab CLI / MR creation

Run `scripts/preflight.sh` at session start. If env vars are missing, surface them immediately rather than failing mid-session.

## Bug Fix Workflow

Use `/fix-bug` for all backlog items. Commit format: `fix: <one-line summary>`. Each fix is one atomic commit — no bundling.

## Pushing Code

Use `/ship` before any `git push`. It runs ruff + mypy + pytest + actionlint, validates `.gitlab-ci.yml` if present, then calls `scripts/push-all.sh` to push to **every** configured remote (GitHub + GitLab).

A "ship" is not complete until both remotes accept the push. If one fails, retry only that remote (`git push <remote> <branch>`) — do not skip it.

## CI Failures

Use `/ci-fix` when CI is red on either remote. It checks GitHub via `gh` and GitLab via `glab`, classifies the failure, fixes locally, and re-verifies. Never push a "maybe this fixes it" commit without running the full local equivalent first.

## Parallel Bug Fixing

Use `/batch-fix` for 5+ independent backlog items. It spawns sub-agents with git worktrees so agents do not collide on shared files.
