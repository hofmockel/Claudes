---
name: fix-bug
description: Pick the next unchecked bug from backlog.md and fix it atomically with a regression test
---

1. Read `backlog.md` — pick the next unchecked item. Read `CLAUDE.md` for project conventions.
2. Write a failing `pytest` that reproduces the bug. Commit: `test: reproduce <slug>`.
3. Implement the minimal fix — do not refactor surrounding code.
4. Run `pytest -x --tb=short`; iterate until green. Report pass count.
5. Run `ruff check` and `mypy` on modified files. Fix any errors before proceeding.
6. Prepend one line to `CHANGELOG.md` (format: `- fix: <summary> (<date>)`).
7. Check off the backlog item using Edit (never overwrite the whole file).
8. Commit atomically: `fix: <one-line summary>`.

Do not ask questions during execution. If blocked by a missing dependency, ambiguous requirement, or failing test that isn't clearly a bug, state the blocker and stop.
