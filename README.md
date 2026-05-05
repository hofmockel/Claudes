# [Project Name]

> One-line description of what this project does.

---

## Getting Started with Claude Code

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- Your language runtime and package manager (see **Development Commands** below)

### Setup

```bash
# 1. Clone
git clone <repo-url> && cd <repo>

# 2. Personal Claude settings (gitignored — yours only)
cp CLAUDE.local.md.example CLAUDE.local.md
cp .claude/settings.local.json.example .claude/settings.local.json

# 3. Install dependencies
[your install command here]
```

### First session

```bash
claude          # opens Claude Code — reads CLAUDE.md + specs automatically
/check-drift    # verify implementation matches specs
```

---

## Team Skills

| Skill | What it does |
|---|---|
| `/commit` | Stage + commit with conventional commit format and Co-Authored-By trailer |
| `/create-pr` | Push branch and open a PR with required sections |
| `/review` | Self-review diff against `REVIEW.md` — BLOCKERS / SUGGESTIONS / LOOKS GOOD |
| `/ship` | Full pipeline: test → lint → review → commit → push → PR |
| `/check-drift` | Check each spec's Acceptance Criteria against the implementation |
| `/fix-bug` | Atomic bug fix with regression test from `backlog.md` |
| `/ci-fix` | Fetch failed CI run, classify failure, fix and re-verify |
| `/batch-fix` | Parallel 5-bug burn-down via git worktrees |

---

## Spec-Driven Workflow

Specs in `/specs/` describe **what** the system should do. Code implements them.

```
Write spec  →  @-import in CLAUDE.md  →  implement  →  /check-drift  →  ✅
                                                               ↓
                                              update spec if requirements change
```

1. Create `specs/<feature>.md` using `specs/_template.md`
2. Add `@specs/<feature>.md` to `CLAUDE.md` so every session loads it
3. Implement against the Acceptance Criteria
4. Run `/check-drift` to confirm all criteria are met
5. If requirements change: update the spec **before** changing the code

---

## Safety & Permissions

`.claude/settings.json` pre-approves read-only operations (no prompt) and hard-blocks destructive ones:

| Always allowed (no prompt) | Always blocked |
|---|---|
| `git status/diff/log/branch` | `git push --force` |
| `ls/find/grep/cat` | `git reset --hard` |
| `ruff/mypy/pytest` | `rm -rf *` |
| `gh run/pr view/issue` | `curl \| sh`, `dd`, `mkfs` |
| | `Read(.env)`, `Read(*.key)` |

Personal approvals (`git commit`, `git push`, `pip install`, etc.) go in `.claude/settings.local.json` (gitignored). Use `settings.local.json.example` as a starting point.

### Hooks (run automatically on every tool use)

| Hook | Trigger | What it does |
|---|---|---|
| `pre-bash-safety.sh` | PreToolUse: Bash | Hard-blocks dangerous patterns (`rm -rf *`, `dd`, `curl\|sh`, etc.) |
| `post-edit-lint.sh` | PostToolUse: Edit/Write | Runs `ruff` after `.py` edits; stubs for JS/TS, Go, Ruby, shell |
| `post-tool-truncate.sh` | PostToolUse: Bash/Read/WebFetch | Caps output at 4,000 chars to protect context window |
| `compact-trigger.sh` | PostToolUse: all | Nudges `/compact` when transcript exceeds ~500KB |
| `caveman-reminder.sh` | PostToolUse: all | Detects verbose filler prose, nudges terseness |

Exit codes: `0` = allow, `1` = hard block, `2` = soft signal (Claude sees message and continues).

Override the truncation limit: `export LESS_TOKENS_MAX_CHARS=8000` in your shell.

---

## CI / CD

### GitHub Actions

Add `ANTHROPIC_API_KEY` as a repository secret (`Settings → Secrets → Actions`).

- **`test` job** — runs on every push and PR (replace the placeholder command)
- **`claude-code` job** — manual dispatch only; runs Claude with a custom prompt

Trigger manually: `Actions → CI → Run workflow`.

---

## What's in this repo

```
CLAUDE.md                    Session instructions — read at every session start
CLAUDE.local.md.example      Personal notes template (copy → CLAUDE.local.md, gitignored)
REVIEW.md                    Review checklist — used by /review and @claude review
.claudeignore                Files excluded from Claude's read scope
.worktreeinclude             Files copied into new worktrees

specs/
  README.md                  How to write and use specs
  _template.md               Blank spec template
  example-feature.md         Worked example (replace with real specs)

.claude/
  settings.json              Team permissions + hooks (committed, shared)
  settings.local.json.example  Personal approvals template (copy → gitignored)
  rules/
    security.md              Always active — secrets, input validation, PII
    api-design.md            Activates for src/api/** — REST conventions, error envelope
    testing.md               Activates for tests/** — naming, mocking, coverage
    caveman.md               Always active — prose discipline, no filler
  hooks/
    pre-bash-safety.sh       PreToolUse: hard-blocks dangerous bash patterns
    post-edit-lint.sh        PostToolUse: lint after file edits
    post-tool-truncate.sh    PostToolUse: cap large tool outputs at 4K chars
    compact-trigger.sh       PostToolUse: nudge /compact at ~500KB transcript
    caveman-reminder.sh      PostToolUse: nudge terse prose when filler detected
  skills/
    commit/                  /commit — conventional commit with approval gate
    create-pr/               /create-pr — push + open PR
    review/                  /review — self-review checklist
    check-drift/             /check-drift — spec vs implementation
    fix-bug/                 /fix-bug — atomic bug fix with regression test
    ship/                    /ship — pre-push CI gate (ruff + mypy + pytest)
    ci-fix/                  /ci-fix — fetch + fix failed CI run
    batch-fix/               /batch-fix — parallel 5-bug burn-down

scripts/
  preflight.sh               Session start env + toolchain check
  local-ci.sh                Local CI equivalent

.github/
  PULL_REQUEST_TEMPLATE.md
  workflows/claude-code.yml
```

---

## Project Structure

```
[fill in your source layout here]
```

## Development Commands

| | Command |
|---|---|
| **Install** | `[install command]` |
| **Run** | `[run command]` |
| **Test** | `[test command]` |
| **Lint** | `[lint command]` |
| **Build** | `[build command]` |
