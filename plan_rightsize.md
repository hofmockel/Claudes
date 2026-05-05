# Right-sized Claude Code Framework — Team of 6

Team: 3 devs (1 sr, 2 jr) · 1 analyst · 2 domain experts (SMEs).

## Context

Five overlapping plans (`plan.md`–`plan6.md`) accreted from different articles and reference repos. Plan1 ≈ plan2 (session continuity). Plan3 is mostly already implemented. Plans 4–6 add team-specific guidance. Framework weight must stay low for 6 people: keep what gives leverage per added file, drop ceremony.

## Synthesis principle

Add a file only if it does work the team can't get from existing skills/rules. They need: a clean on-ramp, a durable handover, a SME→code bridge, and one reviewer agent that multiplies senior bandwidth. Everything else is decoration at this team size.

## Already in place — do not touch

- `CLAUDE.md` (workflow rules + Developer-as-Reviewer)
- 8 skills: `batch-fix, check-drift, ci-fix, commit, create-pr, fix-bug, review, ship` (`security-review` also available)
- 5 hooks: `caveman-reminder, compact-trigger, post-edit-lint, post-tool-truncate, pre-bash-safety`
- 4 rules: `api-design, caveman, security, testing`
- `specs/` (README, `_template.md`, `example-feature.md`)
- `REVIEW.md`, `.worktreeinclude`, `.claudeignore`, `.gitignore`
- `backlog.md`, `journal.md`, `decisions.md` stubs
- `.github/workflows/claude-code.yml`, PR template
- `scripts/preflight.sh`, `scripts/local-ci.sh`

## What to ADD

### Tier 1 — Team workflow (3 things)

1. **`/session-start` skill** — `.claude/skills/session-start/SKILL.md`
   - Runs `scripts/preflight.sh`
   - Prints unchecked `backlog.md` rows + last 5 `journal.md` entries
   - Prompts user to log a session goal
   - Replaces plan1/2's `/health` (redundant with `compact-trigger.sh`)

2. **`/handover` skill + Stop hook**
   - `.claude/skills/handover/SKILL.md` writes `.claude/state/handover-YYYYMMDD-HHMM.md` (Summary · Current state · In-progress · Next steps · Key context)
   - `.claude/hooks/stop.sh` auto-fires on session end → `.claude/state/last-session-handover.md`. Always exits 0.
   - `.claude/settings.json` gets a `"Stop"` hook entry.
   - Skip `current-session.yaml` — YAML state machine is ceremony for 6 people.

3. **Lightweight spec-driven workflow** — slim `specs/_template.md` + tightened rules

   **When a spec is required:** change touches ≥3 files, adds user-visible behavior, or is SME-driven. Not for typos, refactors, single-file fixes.

   **One page max.** If it doesn't fit on a screen, split it.

   **Acceptance Criteria is the contract** — what `/check-drift` verifies. Every other section is optional.

   **SME brief = spec draft.** No separate brief file. SMEs fill the slim template in plain English; senior + Claude tighten Behavior + Acceptance Criteria. One artifact, one review.

   **Slim `specs/_template.md`** (replaces current 7-section template):

   ```markdown
   # [Feature]

   <!-- One sentence: what + for whom. -->

   ## Behavior
   <!-- What the system does from the caller's perspective. Present tense. -->

   ## Acceptance Criteria
   - [ ] [Verifiable, testable criterion]

   ## Out of Scope
   - [What this spec does NOT cover]

   <!-- Optional — include only if needed -->
   ## API
   ## Data Model
   ## Edge Cases
   ```

   **Lifecycle:** `draft spec → senior approves → @import in CLAUDE.md → implement → /check-drift`

### Tier 2 — Reviewer leverage (1 thing)

4. **`code-reviewer` agent** — `.claude/agents/code-reviewer.md`
   - Sub-agent invoked by `/review`. Focuses on correctness, edge cases, type safety, test coverage.
   - Highest-leverage single addition for this team — multiplies sr dev review bandwidth.
   - Skip `python-best-practices` agent — `.claude/rules/` + ruff/mypy already cover that.

### Tier 3 — Cheap rule appends (3 edits)

5. **`.claude/rules/testing.md`** — append:
   - **Test order:** write tests after the feature works; lock behavior once green.
   - **Environment isolation:** block tests if `TEST_DATABASE_URL` (or equivalent) is missing.
   - **UI validation:** for UI changes, screenshot via Claude-in-Chrome MCP before "done."

6. **`.claude/rules/security.md`** — append:
   - **Architecture timing:** design auth/authz in phase 1 of any multi-phase plan; late integration forces destructive replacement.

7. **`.claude/rules/caveman.md`** — append:
   - **Clarifying questions as menus:** numbered options, not open prompts. Example: `Auth: 1) JWT  2) OAuth2  3) Session cookie`.

### Tier 4 — README role section (1 edit)

8. **`README.md`** — add a `## Roles` section (~30 lines):
   - **Junior dev** — `/review` before requesting human review; `/ship` before push; pair with Claude on non-trivial tasks.
   - **Senior dev** — owns architecture + spec approval; uses `code-reviewer` agent + `/batch-fix`; final reviewer on every PR.
   - **Analyst** — describe data + desired output → Claude generates SQL/Python/viz; wrap recurring scripts with CLI entry points.
   - **SME** — fill `specs/_template.md` in plain English; senior + Claude tighten it; implementation follows.

## What to REJECT from the source plans

| Source | Rejected | Reason |
|---|---|---|
| plan1, plan2 | `/health` skill | Redundant with `compact-trigger.sh` hook |
| plan1, plan2 | `/document` skill | Overlaps `/check-drift` |
| plan1, plan2 | `python-best-practices` agent | Rules + ruff/mypy already enforce |
| plan1, plan2 | `current-session.yaml.example` | YAML state file = ceremony for 6 people |
| plan3 | Create `backlog.md`, `journal.md`, `decisions.md` | Already exist |
| plan3 | "Developer as Reviewer" section | Already in `CLAUDE.md` |
| plan4 | Standalone `ui-validation.md` rule file | One bullet in `testing.md` is enough |
| plan5 | Continuous-spec-update note | `/check-drift` already enforces this |
| plan6 | Standalone `analyst-workflows.md` | Folded into README Roles section |
| plan6 | Standalone `skills-inventory.md` | README repo tree already serves this |
| plan6 | New `/security-review` skill creation | Skill already available |

## Files touched

| Path | Action |
|---|---|
| `.claude/skills/session-start/SKILL.md` | Create |
| `.claude/skills/handover/SKILL.md` | Create |
| `.claude/hooks/stop.sh` | Create (chmod +x) |
| `.claude/settings.json` | Edit — add `Stop` hook entry |
| `.claude/agents/code-reviewer.md` | Create |
| `.claude/rules/testing.md` | Append 3 short sections |
| `.claude/rules/security.md` | Append 1 short section |
| `.claude/rules/caveman.md` | Append 1 short section |
| `specs/_template.md` | Replace with slim version (3 required + 3 optional sections) |
| `specs/README.md` | Append "spec required when" rule + one-page-max note |
| `README.md` | Add `## Roles` section |

## Implementation order

```
1.  .claude/hooks/stop.sh                    (chmod +x)
2.  .claude/settings.json                    (add Stop hook)
3.  .claude/skills/session-start/SKILL.md
4.  .claude/skills/handover/SKILL.md
5.  .claude/agents/code-reviewer.md
6.  specs/_template.md                       (slim replacement)
6b. specs/README.md                           (append rules)
7.  .claude/rules/testing.md                 (append)
8.  .claude/rules/security.md                (append)
9.  .claude/rules/caveman.md                 (append)
10. README.md                                (Roles section)
```

## How this satisfies the four tensions

- **Robust + flexible:** core gates (`/ship`, `/review`, `/check-drift`, hooks) stay non-negotiable; new additions are opt-in skills the team invokes when useful.
- **Stable + extensible:** no churn to existing skills/rules/specs; new files live in their own paths and can be deleted without breakage.
- **Fast + simple:** 8 net additions, most under 30 lines. No new hard dependencies. No YAML state machine. One agent, not five.

## Verification

1. `/session-start` in fresh session → preflight + backlog rows + last journal entries print.
2. `/handover` → `.claude/state/handover-*.md` appears with all sections populated from git state.
3. End a session → `last-session-handover.md` written; session ends normally.
4. SME drafts a spec from slim `_template.md` → senior tightens Behavior + Acceptance Criteria → `@import` in `CLAUDE.md` → implement → `/check-drift` returns ✅.
5. PR with a deliberate logic gap → `/review` invokes `code-reviewer` agent → catches at least one issue the REVIEW.md checklist alone misses.
6. Trigger each appended rule path (test command missing `TEST_DATABASE_URL`; multi-phase plan request; ambiguous design question) → expected guidance fires.
