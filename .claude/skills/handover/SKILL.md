---
name: handover
description: Generate a structured handover document mid-session or before /compact. Writes to .claude/state/handover-YYYYMMDD-HHMM.md.
allowed-tools: "Bash(git log*) Bash(git status*) Bash(git diff*) Bash(date*) Bash(mkdir*) Read(.claude/state/*) Write(.claude/state/*)"
---

# /handover

Capture session state so the next session resumes without replay. Run before `/compact` or when context is filling up.

## Steps

1. Create `.claude/state/` if missing.
2. Compose a handover doc with these sections:
   - **Summary** — what was accomplished this session (one paragraph)
   - **Current state** — branch, last commit, test status, dirty files
   - **In-progress work** — incomplete changes, where to resume
   - **Next steps** — prioritized list (top 3)
   - **Key context** — decisions made, gotchas, patterns to follow
3. Write to `.claude/state/handover-$(date +%Y%m%d-%H%M).md`.
4. Display the file inline so the user can copy/paste into a fresh session.

## Constraints

- Pull facts from git (`git log -10 --oneline`, `git status`, `git diff --stat`) — do not invent.
- Keep the doc under one page. Brevity > completeness.
- Never log secrets, env values, or PII.
