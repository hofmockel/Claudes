# Specs

Source of truth for what the system should do. Code implements specs; specs don't document code.

## What belongs here

- Feature behavior described from the user or API caller's perspective
- Acceptance Criteria that define "done" in a verifiable way
- API contracts and data shapes
- Edge cases and explicit out-of-scope decisions

Not: internal architecture, implementation patterns, or code conventions (those live in `.claude/rules/` and `CLAUDE.md`).

## File conventions

- One file per feature or domain: `auth.md`, `payments.md`, `notifications.md`
- Lowercase with hyphens: `user-profile.md`, `email-verification.md`
- Use `_template.md` as a starting point

## Loading specs into Claude sessions

Add an `@` import line to `CLAUDE.md` for each spec Claude should have in context every session:

```
@specs/auth.md
@specs/payments.md
```

Remove the line when a feature is retired.

## Spec lifecycle

```
Write spec → @-import in CLAUDE.md → implement → /check-drift → ✅
                                                        ↓
                                         update spec if requirements change
```

1. Write the spec **before** implementing — specs describe intent, code describes execution.
2. Run `/check-drift` to check implementation status against Acceptance Criteria.
3. If requirements change, update the spec **first**, then update the code.
4. Never update a spec to match drifted code without team review — that erases the record of the drift.

## Drift detection

```
/check-drift              # check all specs
/check-drift auth         # check only specs matching "auth"
```

Reports each Acceptance Criterion as: ✅ implemented · ❌ drifted · ⚠️ missing · 📝 spec gap.
