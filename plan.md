# Plan: Build the Claudes Framework from Scratch

A single, end-to-end plan that produces the current repository state if executed from
an empty directory. Ordered so each phase rests on the previous one — no rework, no
backtracking. Sized for a 6-person team (3 devs, 1 analyst, 2 SMEs).

---

## Phase 0 — Repo bootstrap

```bash
mkdir Claudes && cd Claudes
git init
gh repo create hofmockel/Claudes --private --source=. --remote=origin
git checkout -b main
```

Default branch: `main` (set via `gh repo edit --default-branch main` after first push).

Files:
- `.gitignore` — node/python/IDE noise + `.claude/state/` + `.claude/settings.local.json` + `CLAUDE.local.md`
- `LICENSE` — MIT
- `README.md` — placeholder; rewritten in Phase 8

---

## Phase 1 — Project contract (`CLAUDE.md`)

Single source of truth for session behavior. Sections:
1. Response Length — under 400 tokens default
2. Mandatory Plan Step — plan mode required for ≥3-file changes or any "refactor"
3. Scope Discipline — narrower-when-possible
4. Developer as Reviewer — architect/reviewer role
5. Documentation Discipline — append-only `backlog.md`, prepend-only `changelog.md`, separate `decisions.md`
6. Verification Before Shipping — full test suite, regression test for every fix, `/ship` before push
7. Environment & Secrets — `.env` only, no hardcoding
8. Bug Fix Workflow — `/fix-bug`, atomic commits
9. Pushing Code — `/ship` gates `git push`
10. CI Failures — `/ci-fix`
11. Parallel Bug Fixing — `/batch-fix` for ≥5 independent items

Stub the doc files referenced above so the rules don't dangle:
- `backlog.md` — header + empty table
- `decisions.md` — ADR-001 stub
- `REVIEW.md` — review checklist

---

## Phase 2 — Token-saving infrastructure (do this BEFORE skills)

Token discipline must exist before heavy workflows pile on context.

### `.claudeignore`
Exclude `plan*.md`, `.github/`, `.claude/state/`, build artifacts.

### `.claude/settings.json`
- `permissions.allow`: read-only ops (`git status/diff/log`, `ls/find/grep/cat`, `ruff/mypy/pytest`, `gh run/pr view`)
- `permissions.deny`: `git push --force`, `git reset --hard`, `rm -rf *`, `curl|sh`, `Read(.env)`, `Read(*.key)`
- `hooks`: wired to scripts created next. Sensitive write ops (commit, push, pip install) live in `settings.local.json.example` so each dev opts in deliberately.

### `.claude/hooks/` (6 scripts, all bash, executable)
| Hook | Trigger | Purpose |
|---|---|---|
| `pre-bash-safety.sh` | PreToolUse: Bash | Hard-block (`exit 1`) dangerous patterns |
| `post-edit-lint.sh` | PostToolUse: Edit/Write | `ruff` after `.py` edits |
| `post-tool-truncate.sh` | PostToolUse: Bash/Read/WebFetch | Cap output at 4 KB (override via `LESS_TOKENS_MAX_CHARS`) |
| `compact-trigger.sh` | PostToolUse: all | Nudge `/compact` past ~500 KB transcript with hysteresis |
| `caveman-reminder.sh` | PostToolUse: all | Detect filler prose, nudge terseness |
| `stop.sh` | Stop | Write `.claude/state/last-session-handover.md`. Always exit 0 |

---

## Phase 3 — Rules (`.claude/rules/`)

Path-scoped or always-on guidance loaded by Claude.

| File | Scope | Content |
|---|---|---|
| `security.md` | always | Secrets, input validation, PII, dependencies, auth-first timing |
| `api-design.md` | `src/api/**` | REST conventions, error envelope |
| `testing.md` | tests | Naming, mocking, env isolation (`TEST_DATABASE_URL`), test-after order, UI screenshot validation |
| `caveman.md` | always | Prose discipline, no filler, clarifying-questions-as-numbered-menus |

---

## Phase 4 — Specs (`specs/`)

### `specs/README.md`
- "When a spec is required" rule: ≥3 files, user-visible behavior, or SME-driven
- One-page-max rule
- Lifecycle: `draft → senior approves → @import in CLAUDE.md → implement → /check-drift`

### `specs/_template.md` — slim
Three required sections (Behavior, Acceptance Criteria, Out of Scope) + three optional
(API, Data Model, Edge Cases).

### `specs/example-feature.md`
Worked example so the team has a concrete reference.

---

## Phase 5 — Skills (`.claude/skills/`)

Ten skills, each as `<name>/SKILL.md` with frontmatter (`name`, `description`,
`allowed-tools`).

Build order matters — later skills compose earlier ones:

1. `commit` — conventional commit format, Co-Authored-By trailer
2. `create-pr` — push + `gh pr create` with required template sections
3. `review` — runs `REVIEW.md` checklist; invokes `code-reviewer` sub-agent (Phase 6)
4. `ship` — `ruff` + `mypy` + `pytest` + `actionlint`; gates `git push`
5. `check-drift` — verify each spec's Acceptance Criteria against code; emoji status per AC
6. `fix-bug` — pick next unchecked `backlog.md` row, fix atomically, regression test
7. `ci-fix` — `gh run view --log-failed`, classify, fix locally, re-verify
8. `batch-fix` — spawn 5 parallel sub-agents in worktrees (`.worktreeinclude` defines copy-set)
9. `session-start` — preflight + backlog + last handover + goal prompt
10. `handover` — write `.claude/state/handover-YYYYMMDD-HHMM.md` with git-derived state

---

## Phase 6 — Sub-agents (`.claude/agents/`)

### `code-reviewer.md`
Deep review focused on correctness, edge cases, type safety, test coverage.
Output format: `BLOCKERS / SUGGESTIONS / LOOKS GOOD` with `file:line` citations.
Invoked by `/review` or directly.

(Skip a `python-best-practices` agent — `.claude/rules/` + `ruff`/`mypy` already enforce.)

---

## Phase 7 — Scripts + CI

### `scripts/`
- `preflight.sh` — verify `git`, `gh`, `glab`, env vars, Python tooling. Exit non-zero on missing requirements.
- `local-ci.sh` — same checks `/ship` runs, callable standalone.
- `push-all.sh` — push current branch to **every** configured remote (GitHub + GitLab). Used by `/ship` and `/create-pr`.

### `.github/`
- `PULL_REQUEST_TEMPLATE.md` — Summary · Test plan · Spec link · Checklist
- `workflows/claude-code.yml` — `test` job on push/PR; `claude-code` job on manual dispatch with `ANTHROPIC_API_KEY` secret

### `.gitlab/` and `.gitlab-ci.yml`
- `.gitlab-ci.yml` — mirrors the GitHub workflow: `test` stage on push/MR; manual `claude-code` stage using `claude` CLI. Requires `ANTHROPIC_API_KEY` CI/CD variable.
- `.gitlab/merge_request_templates/Default.md` — mirrors the PR template; adds "Both remotes pushed" checkbox.

### Dual remotes
Repo lives on both GitHub (`github` remote) and GitLab (`gitlab` remote). Both must stay in sync — `/ship` enforces this via `scripts/push-all.sh`. Both pipelines run on every push/MR.

### `.worktreeinclude`
Whitelist of files copied into worktrees so `/batch-fix` sub-agents have full config.

---

## Phase 8 — README, changelog, plan-of-record

### `README.md`
Follow the [Keep a Changelog README structure](https://medium.com/@fulton_shaun/readme-rules-structure-style-and-pro-tips-faea5eb5d252):
Title · Description · Installation · Usage · Features · Tech Stack · Contributing · License · Credits.
Add Shields.io badges. Sparing emojis. Code blocks for commands.

### `changelog.md`
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) format. Newest at top.
Sections: Added · Changed · Deprecated · Removed · Fixed · Security.

### `plan_rightsize.md`
Captures the synthesis decisions (what was kept, added, rejected) for future reference.

---

## Phase 9 — First commit + push

```bash
git add .
git commit -m "init: Claude Code workflow framework for 6-person team"
git push -u origin main
gh repo edit --default-branch main
```

---

## Verification (run end-to-end after Phase 9)

1. Fresh shell → `bash scripts/preflight.sh` → all green
2. `claude` → reads `CLAUDE.md` + specs automatically
3. `/session-start` → preflight + backlog + last handover print
4. Edit a `.py` file → `post-edit-lint.sh` fires `ruff`
5. Run a 5 KB-output bash command → `post-tool-truncate.sh` caps it
6. Make a deliberate spec/code mismatch → `/check-drift` reports `❌ drifted`
7. Stage a logic gap → `/review` invokes `code-reviewer` → catches it
8. `/ship` → `ruff` + `mypy` + `pytest` + `actionlint` all pass
9. `/create-pr` → PR opens with template populated
10. Type `exit` → `stop.sh` writes `.claude/state/last-session-handover.md`

---

## What this plan deliberately does NOT include

- No YAML session-state machine — handover markdown files are enough for 6 people
- No `/health` skill — `compact-trigger.sh` already nudges at the threshold
- No `/document` skill — `/check-drift` covers spec/code drift
- No language-specific sub-agents beyond `code-reviewer` — rules + linters carry that load
- No TTS / sound / JIRA hooks — novelty, not team-relevant
- No separate SME brief template — SMEs draft the spec directly in `specs/_template.md`

---

## Total artifact count

- 1 `CLAUDE.md`, 1 `README.md`, 1 `changelog.md`, 1 `LICENSE`
- 3 stub docs (`backlog`, `decisions`, `REVIEW`)
- 3 specs files + 1 `_template.md`
- 1 `settings.json` + 1 `.example`
- 4 rules
- 6 hooks
- 10 skills
- 1 sub-agent
- 3 scripts (`preflight`, `local-ci`, `push-all`)
- 1 PR template + 1 GitHub workflow
- 1 MR template + 1 GitLab pipeline (`.gitlab-ci.yml`)
- 3 dotfiles (`.gitignore`, `.claudeignore`, `.worktreeinclude`)

**~40 files total.** Every file earns its place; nothing is decorative.
