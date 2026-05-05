# Plan: Incorporate article insights into workflow rules

Source: https://thebootstrappedfounder.com/how-to-actually-use-claude-code-to-build-serious-software/

## What's already covered (skip)

- CLAUDE.md system prompt discipline ✅
- settings.json allowlist/denylist ✅
- `/loop` skill (Ralph Wiggum loop) ✅
- review/ship/commit skills ✅

## What's new and worth adding

### 1. Feature-first testing (`.claude/rules/testing.md`)

Append two rules:

**Test Order** — Write tests after the feature works, not before. TDD slows agentic iteration. Build until it runs, then lock behavior with tests.

**Environment Isolation** — Tests must run against an isolated environment (separate DB, separate env vars). Never run tests against dev or production data. Block test commands if `TEST_DATABASE_URL` (or equivalent) is absent.

### 2. UI validation pattern (`.claude/rules/ui-validation.md`) — new file

When building UI features, use Claude in Chrome MCP to visually validate before declaring done:
1. Start dev server
2. Navigate to feature in browser
3. Screenshot + inspect DOM for layout issues
4. Test golden path + at least one edge case
5. Commit only after visual confirmation

Rule: never report a UI task complete without a browser screenshot.

### 3. `CLAUDE.md` — one line in "Verification Before Shipping"

Add: `For UI changes: use Claude in Chrome MCP to screenshot and validate before declaring done (see .claude/rules/ui-validation.md).`

## Files touched

- `.claude/rules/testing.md` (append)
- `.claude/rules/ui-validation.md` (new)
- `CLAUDE.md` (1-line edit)

## Files NOT touched

- `settings.json`, all skills, `README.md`
