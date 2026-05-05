# Using Claude Code as a Team Force Multiplier

## Context

Team: 2 junior devs, 1 senior dev, 1 analyst/data viz, 2+ SMEs.
Skill gaps exist. Headcount is thin. Claude Code fills the gaps in expertise and absorbs
labor the team can't cover alone.

---

## 1. Role Map — What Claude Covers

| Team Member | What's Missing | Claude Fills It With |
|-------------|---------------|----------------------|
| Junior dev (×2) | Code review, patterns, security instincts | Pair session + `/review` on every PR |
| Senior dev | Bandwidth for deep review + mentorship | `/batch-fix`, `/review`, `/ship` enforcement |
| Analyst | Python/SQL automation, viz code | Inline sessions for data scripts + chart code |
| SME (×2+) | Can't translate domain knowledge into code | Spec-first pipeline (see §3) |
| Everyone | No QA, no security specialist, stale docs | `/security-review`, test-alongside-feature, `/check-drift` |

---

## 2. Skill Gap Coverage Matrix

| Gap | Claude Workflow | Who Triggers It |
|-----|----------------|----------------|
| Insufficient code review | `/review` before every human review request | Juniors — mandatory |
| No security specialist | `/security-review` on PRs touching auth, data, or APIs | Senior assigns |
| Slow bug throughput | `/batch-fix` for 5+ independent backlog items | Any dev |
| SME domain knowledge stuck in heads | Spec-first pipeline (§3) | SME + Senior |
| Analyst needs automation | Claude session: describe the data problem, get working code | Analyst |
| No dedicated QA | Claude writes tests alongside every feature in the same commit | All devs |
| Docs drift from implementation | `/check-drift` weekly + doc refresh pass | Rotation (assign in sprint) |
| No DevOps specialist | Claude reads CI logs, classifies failures, fixes locally via `/ci-fix` | Any dev when CI is red |

---

## 3. SME-to-Code Pipeline

SMEs have the domain knowledge. Claude converts it to working code. Steps:

1. **SME writes a plain-English brief** using `specs/_sme-brief-template.md` (to be created).
   - What problem does this solve?
   - Who uses it and how?
   - What are the edge cases / constraints?
   - What does "done" look like?

2. **Senior dev reviews the brief** — 15 min sanity check, not a full spec.

3. **Claude converts brief → spec** using `specs/_template.md` format.
   - Senior approves the spec before implementation begins.

4. **Claude implements** from the spec with `/fix-bug` or a feature session.

5. **Human review** of the PR — not skipped, even with `/review` passing.

---

## 4. Junior Dev Pairing Protocol

Claude acts as a second brain, not an autopilot. Junior devs should:

- Open a Claude Code session before starting any non-trivial task.
- Describe the problem and ask Claude to outline an approach before writing code.
- Run `/review` on their own branch before requesting human review — fixes obvious issues before they waste senior's time.
- Use Claude to explain unfamiliar patterns: "What does this code do and why is it structured this way?"
- Never merge a PR that hasn't passed `/ship`.

---

## 5. Analyst Workflow

The analyst doesn't need to be a developer to get code that works:

- Describe the data source, the transformation needed, and the desired output format.
- Ask Claude to write the SQL query or Python script.
- Run it, paste errors back, iterate.
- For recurring tasks: ask Claude to wrap the script in a function with a CLI entry point.
- For visualizations: describe what the chart should show; Claude generates the Matplotlib/Plotly/Vega code.

---

## 6. Quality Gates (Non-Negotiable)

These apply regardless of who wrote the code — human or Claude-assisted:

- `/ship` runs before every `git push` (ruff + mypy + pytest + actionlint).
- All Claude-generated PRs get human review, not just automated `/review`.
- Security-sensitive changes (auth, data access, secrets handling) get `/security-review`.
- Specs are the source of truth — `/check-drift` catches when code diverges.

---

## 7. Configuration Work Needed

These additions make the above practical:

| Item | File | Owner |
|------|------|-------|
| SME brief template | `specs/_sme-brief-template.md` | Senior dev |
| Analyst workflow guide | `specs/analyst-workflows.md` | Analyst + Claude |
| `/security-review` skill | `.claude/skills/security-review/SKILL.md` | Senior dev |
| Role quick-start sections in README | `README.md` | Any dev |
| Skills inventory (what Claude covers) | `skills-inventory.md` | Senior dev |

---

## 8. What Claude Does NOT Replace

- Architecture decisions — Claude drafts options, senior decides.
- SME domain judgment — Claude implements what SMEs define, doesn't invent domain logic.
- Human PR review — automated `/review` is a floor, not a ceiling.
- Stakeholder communication — Claude can draft, humans send.
