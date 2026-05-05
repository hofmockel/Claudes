# Plan: Integrate Best Practices from Spec-Driven Development Article

## Context

The article (heeki.medium.com) advocates spec-driven development with Claude Code. The repo already has a strong spec workflow (`specs/`, `/check-drift`, skill system). This plan takes only what's genuinely missing — three small, targeted additions. Nothing structural changes.

## What NOT to adopt (already covered or low value)

- Spec-first lifecycle → already in `specs/README.md`
- CLAUDE.md steering docs → already the pattern here
- Custom skills → already in `.claude/skills/`
- Context window monitoring → already handled by `compact-trigger.sh` hook
- tmux parallel sessions → operational preference, not a rule
- Session resume flag → CLI detail, not worth documenting

## What to add (genuinely missing)

### 1. Clarifying questions as menus — `.claude/rules/caveman.md`

```
## Clarifying Questions
When you need a decision from the user, offer numbered options — not open-ended prompts.
Bad: "How would you like to handle auth?"
Good: "Auth approach: 1) JWT  2) OAuth2  3) Session cookie — pick one."
```

### 2. Auth-first timing — `.claude/rules/security.md`

```
## Architecture timing
Design authentication and authorization in phase 1 of any multi-phase plan.
Late-stage auth integration forces destructive resource replacements.
```

### 3. Continuous spec updates — `specs/README.md`

Add as step 2 in the lifecycle list:

```
Update the spec at each significant design decision — don't wait for /check-drift to reveal gaps.
```

## Files to modify

| File | Change |
|---|---|
| `.claude/rules/caveman.md` | Add "Clarifying Questions" section |
| `.claude/rules/security.md` | Add "Architecture timing" section |
| `specs/README.md` | Add continuous update note to lifecycle |

## Files NOT touched

Everything else — `CLAUDE.md`, `settings.json`, hooks, skills, `README.md`, `REVIEW.md`.
