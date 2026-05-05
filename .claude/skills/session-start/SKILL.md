---
name: session-start
description: Daily on-ramp. Run preflight, surface unchecked backlog rows, print last journal entries, prompt for session goal.
allowed-tools: "Bash(scripts/preflight.sh) Bash(grep*) Bash(tail*) Bash(head*) Bash(cat*) Read(backlog.md) Read(journal.md) Read(.claude/state/*)"
---

# /session-start

Run at the top of every session. Cheap, idempotent.

## Steps

1. **Preflight** — run `scripts/preflight.sh`. Surface missing env vars or toolchain gaps before anything else.
2. **Last handover** — if `.claude/state/last-session-handover.md` exists, print it.
3. **Backlog** — print unchecked rows from `backlog.md` (lines containing `[ ]` or rows with `Status: open`).
4. **Journal** — print the last 5 entries from `journal.md`.
5. **Goal prompt** — ask the user: "What is the one outcome for this session?" Append the answer to `journal.md` under today's date.

## Output format

```
🟢 Preflight OK
📋 Backlog (3 open):
  - #4 Fix flaky auth test (auth.py)
  - #5 Add rate limiter (api/middleware.py)
  ...
📓 Last journal entries:
  ...
🎯 Goal: <user response>
```

Keep output under 30 lines. If preflight fails, stop and surface the error.
