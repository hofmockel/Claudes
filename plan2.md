# Team Collaboration Layer — Implementation Plan (Phase 2)

Branch: `main`
References: [less_tokens](https://github.com/hofmockel/less_tokens) · [claude_code_stuffs](https://github.com/lvalics/claude_code_stuffs)

---

## What this plan adds

From lvalics/claude_code_stuffs, four things are genuinely worth adding. Everything else
(TTS, sound effects, JIRA, CLI scaffolding, ElevenLabs, non-Python agents) is skipped.

```
.claude/
  hooks/
    stop.sh                              new — session-end handover doc
  skills/
    health/SKILL.md                      new — session health check 🟢🟡🔴
    handover/SKILL.md                    new — structured handover when context fills
    document/SKILL.md                    new — refresh CLAUDE.md + README.md
  agents/
    python-best-practices.md             new — Python-specific subagent
    code-reviewer.md                     new — dedicated code review subagent
  state/
    current-session.yaml.example        new — session state template
```

---

## File specs

### `stop.sh` — Stop hook

Fires when a Claude session ends. Creates `.claude/state/last-session-handover.md`
with a brief summary so the next session can resume without replaying context.

Sections written: Completed · In progress · Next steps · Blockers · Key files touched.

Pure bash. Reads transcript path from stdin JSON. Fails silently if unavailable.
Always exits 0 — never blocks session end.

Wired in `settings.json` as a `"Stop"` hook entry.

---

### `/health` skill

Checks two signals:
1. Transcript size — reads `.claude/state/compact-trigger-last` (written by compact-trigger.sh)
2. Session state — reads `.claude/state/current-session.yaml` if it exists

Reports:
```
🟢 Healthy     — transcript < 250KB
🟡 Approaching — transcript 250KB–500KB (compact soon)
🔴 Handover    — transcript > 500KB (run /handover now)
```

```yaml
---
name: health
description: Check session health — transcript size and context status. Run when sessions feel slow or after many tool uses.
allowed-tools: "Bash(wc *) Read(.claude/state/*)"
---
```

---

### `/handover` skill

Generates a structured handover doc at `.claude/state/handover-$(date +%Y%m%d-%H%M).md`
and displays it inline. Run before `/compact` or ending a long session.

Sections: Session summary · Current state (branch, last commit, test status) ·
In-progress work · Next steps (prioritized) · Key context (decisions, patterns, gotchas).

```yaml
---
name: handover
description: Generate a structured handover document before context runs out or ending a long session. Run before /compact.
allowed-tools: "Bash(git log *) Bash(git status) Bash(git diff*) Bash(date) Read(.claude/state/*)"
---
```

---

### `/document` skill

Scans the project and refreshes `CLAUDE.md` and `README.md` to match the current
state of the codebase. Shows a diff for approval before writing.

Steps:
1. Scan `src/`, `tests/`, `scripts/` — inventory what exists
2. `git log --oneline -20` — identify recent changes
3. Compare against current CLAUDE.md architecture table and README repo tree
4. Propose updates: add new files/dirs, remove deleted ones, correct stale commands
5. Show diff, ask for approval, then write

Constraint: never removes workflow rules, conventions, or prohibitions — only updates
factual structural descriptions.

```yaml
---
name: document
description: Refresh CLAUDE.md architecture table and README repo tree to match current codebase. Run after significant structural changes.
allowed-tools: "Bash(find . *) Bash(git log *) Bash(ls*) Read(CLAUDE.md) Read(README.md)"
---
```

---

### `python-best-practices.md` agent

Subagent with Python-specific best practices scoped to this stack (ruff, mypy, pytest,
type hints). Stored at `.claude/agents/python-best-practices.md`.

Content (condensed from the 16KB source): type annotation requirements, ruff rule set,
mypy strict mode guidance, pytest fixture patterns, pathlib over os.path, f-strings,
context managers, dataclasses vs NamedTuple, async/await patterns.

---

### `code-reviewer.md` agent

Subagent for deep code review — correctness, logic errors, edge cases, type safety,
test coverage gaps. Separate from `/review` (which uses REVIEW.md checklist).

Stored at `.claude/agents/code-reviewer.md`. Invoked by `/review` as a sub-step
or directly for deeper analysis.

---

### `current-session.yaml.example`

Session state template at `.claude/state/current-session.yaml.example`.
Teams copy to `current-session.yaml` (gitignored via `.claude/state/`).

```yaml
session:
  id: ""
  health: healthy          # healthy | approaching | handover
  started_at: ""

mode: BUILD                # BUILD | REVIEW | DEBUG | LEARN
scope: MEDIUM              # MICRO | SMALL | MEDIUM | LARGE | EPIC

task:
  title: ""
  branch: ""
  phase: ""                # planning | implementing | testing | reviewing

context:
  last_file: ""
  last_command: ""

notes: []
```

Updated manually or by `/health`. Gives `/handover` structured context to work from.

---

## `settings.json` change

Add Stop hook alongside existing PreToolUse/PostToolUse:

```json
"Stop": [
  {
    "hooks": [{"type": "command", "command": "bash .claude/hooks/stop.sh"}]
  }
]
```

---

## Implementation order

```
1.  .claude/hooks/stop.sh                       (chmod +x)
2.  .claude/skills/health/SKILL.md
3.  .claude/skills/handover/SKILL.md
4.  .claude/skills/document/SKILL.md
5.  .claude/agents/python-best-practices.md
6.  .claude/agents/code-reviewer.md
7.  .claude/state/current-session.yaml.example
8.  .claude/settings.json                       (add Stop hook)
9.  README.md                                   (add new skills + agents to tree)
```

---

## Skipped from claude_code_stuffs

| Item | Reason |
|---|---|
| TTS hooks (ElevenLabs, OpenAI, pyttsx3) | Personal/novelty, API keys required |
| Sound effects | Novelty |
| JIRA integration | Environment-specific |
| CLI scaffolding | Different scope |
| Multi-LLM completion messages | Personal feature |
| 16 non-Python agent files | Irrelevant to this stack |
| Team config YAML system | Complexity without benefit over CLAUDE.md |
| `notification.py`, `subagent_stop.py` | TTS dependency |
| `add-mcp.sh`, `setup-dev-env.sh` | Infrastructure, out of scope |
| execute_parallel_agents | Redundant with batch-fix |

---

## Verification

- `/health` → outputs 🟢/🟡/🔴 with transcript size
- `/handover` → writes `.claude/state/handover-*.md`, displays inline
- End a session → `stop.sh` fires, writes `last-session-handover.md`
- `/document` → shows proposed CLAUDE.md/README.md diff for approval before writing
- Edit `.py` file → python-best-practices agent context available
