# Changelog

All notable changes to this repository are documented here.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `/session-start` skill — daily on-ramp: preflight, unchecked backlog rows, last 5 journal entries, session-goal prompt.
- `/handover` skill — writes a structured snapshot to `.claude/state/handover-YYYYMMDD-HHMM.md` for mid-session or pre-`/compact` use.
- `Stop` hook (`.claude/hooks/stop.sh`) — auto-writes `.claude/state/last-session-handover.md` at session end. Always exits 0; never blocks.
- `code-reviewer` sub-agent (`.claude/agents/code-reviewer.md`) — deep review for correctness, edge cases, type safety, and test coverage. Invoked by `/review` or directly.
- `specs/README.md`: "When a spec is required" rule (≥3 files, user-visible behavior, or SME-driven) and one-page-max guidance.
- `.claude/rules/testing.md`: test-after-implementation order, `TEST_DATABASE_URL` isolation requirement, UI screenshot validation via Claude-in-Chrome.
- `.claude/rules/security.md`: auth/authz must be designed in phase 1 of multi-phase plans.
- `.claude/rules/caveman.md`: clarifying questions must be presented as numbered menus, not open prompts.
- `README.md`: Roles section (junior dev, senior dev, analyst, SMEs) and sub-agents reference.
- `plan_rightsize.md` — synthesized framework spec consolidating `plan.md`–`plan6.md`.

### Changed
- `specs/_template.md` — slimmed from 7 sections to 3 required (Behavior, Acceptance Criteria, Out of Scope) + 3 optional (API, Data Model, Edge Cases).
- `.claude/settings.json` — added `Stop` hook entry. Existing token-saving hooks (`post-tool-truncate`, `compact-trigger`, `caveman-reminder`) unchanged.
- GitHub default branch set to `main` (was `seed/team-collab-template`).

### Removed
- N/A

## [0.1.0] - 2026-05-05

### Added
- `plan2.md`–`plan6.md` exploring team workflows, spec-driven dev, framework integration.

### Notes
- Commit `983a031` ("plans, plans, more plans") aggregates the planning round.

## [0.0.2] - 2026-05-04

### Added
- Team collaboration scaffolding: 8 skills (`commit`, `create-pr`, `review`, `ship`, `check-drift`, `fix-bug`, `ci-fix`, `batch-fix`), 5 hooks (`pre-bash-safety`, `post-edit-lint`, `post-tool-truncate`, `compact-trigger`, `caveman-reminder`), 4 rules (`api-design`, `caveman`, `security`, `testing`).
- `specs/` directory with `README.md`, `_template.md`, `example-feature.md`.
- `REVIEW.md`, `.worktreeinclude`, GitHub workflow + PR template.
- Token-saving infrastructure: `.claudeignore`, transcript-size compaction trigger, post-tool truncation cap.
- `.gitignore` (commit `30cb7cd`).

### Notes
- Commit `9c9a3c2` ("team and tokens") and prior chore commits.

## [0.0.1] - 2026-05-04

### Added
- Initial repository: `CLAUDE.md` workflow rules, scope discipline, env/secrets policy.
- Sourced from usage-report analysis (commit `f18537a`).

[Unreleased]: https://github.com/hofmockel/Claudes/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hofmockel/Claudes/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/hofmockel/Claudes/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/hofmockel/Claudes/releases/tag/v0.0.1
