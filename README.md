# Claudes

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-7c3aed)](https://claude.ai/code)
[![Status](https://img.shields.io/badge/status-active-brightgreen)](#)
[![Changelog](https://img.shields.io/badge/changelog-keepachangelog-orange)](changelog.md)

> A right-sized Claude Code workflow framework for small product teams.
> Spec-driven, token-aware, with quality gates that fit on one screen.

---

## 📖 Description

**Claudes** is a drop-in `.claude/` configuration plus a thin set of conventions
that turn Claude Code into a reliable teammate for a 6-person team
(3 developers, 1 analyst, 2 domain experts).

It bundles ten skills, six hooks, four rules, one sub-agent, and a slim
spec template — all tuned to maximise leverage per file added. No YAML state
machines. No ceremony. Token-saving guards run on every tool call.

**Why it exists.** Off-the-shelf Claude setups either over-engineer (heavy
session state, multi-tier health systems) or under-engineer (no review gate,
no spec discipline). This repo is the middle path.

---

## 🚀 Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- `git`, `gh` CLI, `bash` 4+
- Python 3.10+ (for `ruff`, `mypy`, `pytest` hooks) — optional if you swap the lint stack

### Setup

```bash
# 1. Clone
git clone git@github.com:hofmockel/Claudes.git
cd Claudes

# 2. Personal settings (gitignored)
cp .claude/settings.local.json.example .claude/settings.local.json

# 3. Verify environment
bash scripts/preflight.sh
```

Expected output:

```
✅ git found
✅ gh authenticated
✅ Claude Code permissions readable
```

---

## 💡 Usage

### Daily on-ramp

```bash
claude              # opens Claude Code, loads CLAUDE.md + specs
/session-start      # preflight + backlog + last journal + goal prompt
```

### Build a feature

```bash
# 1. SME or dev drafts a spec
cp specs/_template.md specs/my-feature.md

# 2. Implement against Acceptance Criteria
/fix-bug            # or a fresh implementation session

# 3. Verify and ship
/check-drift        # spec ↔ code alignment
/review             # invokes code-reviewer sub-agent
/ship               # ruff + mypy + pytest + actionlint
/create-pr          # push + open PR
```

### End of day

```bash
/handover           # writes .claude/state/handover-YYYYMMDD-HHMM.md
exit                # Stop hook also writes last-session-handover.md
```

---

## ✨ Features

- **10 team skills** — `/session-start`, `/handover`, `/commit`, `/create-pr`, `/review`, `/ship`, `/check-drift`, `/fix-bug`, `/ci-fix`, `/batch-fix`
- **`code-reviewer` sub-agent** — deep correctness + edge-case + type-safety review
- **Token-saving by default** — output truncation at 4 KB, transcript-size compact trigger, `.claudeignore` for noisy paths
- **Spec-driven, lightweight** — slim 3-required-section template, one-page rule, drift detection
- **Safety hooks** — hard-block dangerous bash, lint after edits, terseness reminders
- **Role playbook** — explicit workflows for junior dev, senior dev, analyst, SME
- **CI integration** — GitHub Actions workflow plus local-CI parity script
- **Worktree-friendly** — `.worktreeinclude` for parallel `/batch-fix` runs

### Roles at a glance

| Role | Daily move |
|---|---|
| Junior dev | Pair with Claude → `/review` → `/ship` |
| Senior dev | Spec approval, `code-reviewer`, final PR review |
| Analyst | Describe data + desired output → Claude writes SQL/Python/viz |
| SME | Fill `specs/_template.md` in plain English |

---

## 🛠 Tech Stack / Built With

- **Claude Code** — the CLI/IDE harness
- **Bash** — all hooks (zero runtime dependencies)
- **Python tooling** — `ruff`, `mypy`, `pytest`, `actionlint`
- **GitHub** — Actions, PR templates, `gh` CLI
- **Markdown** — specs, rules, skills, ADRs

### Repository structure

```
CLAUDE.md                Project-wide instructions loaded every session
changelog.md             Keep a Changelog 1.1.0 format
backlog.md               Open work items (append-only)
journal.md               Session events log (past tense only)
decisions.md             Architectural decision records

specs/
  README.md              Spec rules (when required, one-page max)
  _template.md           Slim 3-required + 3-optional sections
  example-feature.md

.claude/
  settings.json          Permissions + 6 hooks (committed)
  settings.local.json.example
  rules/                 security · api-design · testing · caveman
  hooks/                 pre-bash-safety · post-edit-lint · post-tool-truncate
                         · compact-trigger · caveman-reminder · stop
  skills/                10 slash commands
  agents/code-reviewer.md
  state/                 Session handovers (gitignored)

scripts/
  preflight.sh           Env + toolchain check
  local-ci.sh            CI parity runner

.github/
  PULL_REQUEST_TEMPLATE.md
  workflows/claude-code.yml
```

---

## 🤝 Contributing

1. Open a spec for any change touching ≥3 files or adding user-visible behavior.
2. Branch from `main`. Run `/ship` locally before pushing.
3. Use `/create-pr`. Fill the PR template. PRs need senior-dev review.
4. Update `changelog.md` under `[Unreleased]` in the same commit.

See [CLAUDE.md](CLAUDE.md) for the full workflow contract.

---

## 📄 License

Released under the [MIT License](LICENSE).

---

## 🙏 Credits

Synthesised from ideas across:

- [hofmockel/less_tokens](https://github.com/hofmockel/less_tokens) — token-saving hook patterns
- [lvalics/claude_code_stuffs](https://github.com/lvalics/claude_code_stuffs) — session continuity, handover concepts
- [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) — changelog format
- [Shaun Fulton — README rules](https://medium.com/@fulton_shaun/readme-rules-structure-style-and-pro-tips-faea5eb5d252) — README structure
- The Anthropic Claude Code team for the underlying tool
