# Review Guide

Used by `/review` (self-review before submitting) and `@claude review` (automated PR review).

---

## Self-Review Checklist

### Correctness
- [ ] All tests pass locally
- [ ] New code has test coverage
- [ ] Edge cases handled (null, empty, unexpected input)
- [ ] No TODO or FIXME left in new code

### Security
- [ ] No secrets, tokens, or credentials in the diff
- [ ] No `eval()`, dynamic SQL, or shell string interpolation of user input
- [ ] Input validation present for new endpoints or CLI entry points

### Code Quality
- [ ] Names are consistent with conventions in `CLAUDE.md`
- [ ] No dead code (unreachable branches, unused imports, commented-out blocks)
- [ ] Complex logic has a comment explaining *why*, not *what*

### PR Hygiene
- [ ] Title follows conventional commit format (`feat:`, `fix:`, `chore:`, etc.)
- [ ] PR description filled in (Summary, How to Test, Checklist)
- [ ] Spec updated if behavior changed
- [ ] Linked to the relevant issue or ticket

---

## Blockers — must fix before merge

Flag these as must-fix:

- Any secret or credential appearing in the diff
- Tests deleted without a replacement
- Breaking change to a public API without a version bump or migration path
- Direct mutation of shared state in concurrent code without synchronisation

## Suggestions — non-blocking

Flag these as suggestions:

- Naming improvements
- Missing docstrings on public functions
- Opportunities to extract repeated logic into a helper
- Test cases that would increase confidence

## What NOT to flag

- Anything CI already enforces (lint errors, type errors, format issues)
- Style preferences that contradict `CLAUDE.md` conventions — follow CLAUDE.md
- Test-only changes with no production impact
- Generated code in `src/gen/`, `dist/`, or similar output dirs
