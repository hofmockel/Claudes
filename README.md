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

Existing skills: `/fix-bug`, `/ship` (local CI gate), `/ci-fix`, `/batch-fix` — see `.claude/skills/`.

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

Personal approvals (your own `git commit`, `git push`, `pip install`, etc.) go in `.claude/settings.local.json` (gitignored).

Two hooks run automatically:
- **`pre-bash-safety.sh`** — blocks dangerous patterns before execution
- **`post-edit-lint.sh`** — runs `ruff` after every `.py` edit (lint stubs for other languages available, commented out)

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
CLAUDE.md                  Session instructions — read at every session start
REVIEW.md                  Review checklist — used by /review and @claude review
.worktreeinclude           Files copied into new worktrees

specs/                     Feature specifications (source of truth for behavior)
  README.md                How to write and use specs
  _template.md             Blank spec template
  example-feature.md       Worked example (replace with real specs)

.claude/
  settings.json            Team permissions + hooks (committed, shared)
  settings.local.json.example  Personal approvals template (copy → gitignored)
  rules/
    security.md            Always-active security rules
    api-design.md          API conventions (activates for src/api/**)
    testing.md             Test conventions (activates for tests/**)
  hooks/
    pre-bash-safety.sh     PreToolUse: blocks dangerous bash patterns
    post-edit-lint.sh      PostToolUse: lints after file edits
  skills/
    commit/                /commit — conventional commit
    create-pr/             /create-pr — push + open PR
    review/                /review — self-review checklist
    check-drift/           /check-drift — spec vs implementation
    fix-bug/               /fix-bug — atomic bug fix with regression test
    ship/                  /ship — pre-push CI gate
    ci-fix/                /ci-fix — fetch + fix failed CI run
    batch-fix/             /batch-fix — parallel 5-bug burn-down

scripts/
  preflight.sh             Session start env + toolchain check
  local-ci.sh              Local CI equivalent

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
