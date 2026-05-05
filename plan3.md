# Plan: Adopt Framework Best Practices

## Context

The framework description covers managing developers with Claude Code via structured CLAUDE.md, session persistence, planning-first workflow, worktree isolation, and human-in-the-loop review. Most of it is already implemented here (8 skills, 5 hooks, settings.json permissions, worktree config, mandatory plan step). Three specific gaps exist: session persistence files referenced in CLAUDE.md don't exist, there's no explicit "developer as reviewer" principle, and there's no `/session-start` skill to surface state at the top of a session.

## What NOT changing

- CLAUDE.md workflow rules (already solid)
- All 8 existing skills
- All 5 hooks
- settings.json permissions (allow/deny already correct)
- specs/ directory
- .claudeignore / .worktreeinclude
- README.md (out of scope)

## Changes

### 1. Create `backlog.md` (new file)
Stub with header and one example row. CLAUDE.md already rules "append or edit, never overwrite" — just needs the file to exist.

```
# Backlog

| # | Summary | File(s) | Priority | Status |
|---|---------|---------|----------|--------|
```

### 2. Create `journal.md` (new file)
Session event log stub. CLAUDE.md rules "past events only."

```
# Journal

## YYYY-MM-DD
- Session started
```

### 3. Create `decisions.md` (new file)
Architectural decision record (ADR) stub. CLAUDE.md rules it must not mix with specs or changelog.

```
# Decisions

## ADR-001: [Title] — YYYY-MM-DD
**Status:** Accepted  
**Context:** ...  
**Decision:** ...  
**Consequences:** ...
```

### 4. Add "Developer as Reviewer" section to `CLAUDE.md`
One short block after Scope Discipline:

```markdown
## Developer as Reviewer

Your role is architect and reviewer, not typist. Claude builds; you:
- Approve plans before execution (plan mode)
- Review diffs before commits (/review)
- Own architectural decisions (decisions.md)
- Reject any output that deviates from scope
```

### 5. Create `.claude/skills/session-start/SKILL.md` (new file)
A `/session-start` skill that:
1. Runs `scripts/preflight.sh` (env check)
2. Surfaces open `backlog.md` items (unchecked)
3. Prints last 5 `journal.md` entries
4. Prompts user to log a session goal

This ties together the session persistence concept from the framework with the existing preflight script.

## Files to touch

| File | Action |
|------|--------|
| `backlog.md` | Create |
| `journal.md` | Create |
| `decisions.md` | Create |
| `CLAUDE.md` | Edit — add 1 section (~7 lines) |
| `.claude/skills/session-start/SKILL.md` | Create |

## Verification

1. Open a new Claude Code session and run `/session-start` — should print preflight output, empty backlog, last journal entry
2. Append a row to `backlog.md` manually, re-run `/session-start` — should surface it
3. Check CLAUDE.md renders cleanly: `cat CLAUDE.md | wc -l` should grow by ~8 lines
