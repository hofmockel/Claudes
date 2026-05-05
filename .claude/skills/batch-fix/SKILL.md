---
name: batch-fix
description: Parallel sub-agent burn-down of independent backlog bugs using git worktrees
---

1. Read `backlog.md`. Select **2 to 5** unchecked bugs that have NO shared files between them (verify by reading each bug description and the relevant source files). If any two candidates share a file, drop one or sequence them — never let two worktrees touch the same file. If selected bugs share an interface or contract, land that contract in a single seed commit on `main` first, then fan out.

2. For each of the 5 bugs, spawn a parallel Task sub-agent with these exact instructions:
   ```
   You are fixing bug: <description>
   
   Steps:
   1. git worktree add ../fix-<slug> -b fix/<slug>
   2. cd ../fix-<slug>
   3. Write a failing pytest reproducing the bug. Commit: test: reproduce <slug>
   4. Implement the minimal fix. No refactoring.
   5. Run pytest -x --tb=short until green. Report pass count.
   6. Run ruff check and mypy on changed files.
   7. Prepend one line to CHANGELOG.md.
   8. git commit -m "fix: <one-line summary>"
   9. gh pr create --title "fix: <slug>" --body "Closes backlog item: <full description>"
   10. Report back: PR URL, or the exact error if blocked.
   ```

3. Wait for all agents to return. Print a results table:
   | Bug | Status | PR URL |
   |-----|--------|--------|

4. Update `backlog.md`: check off each successfully completed item using Edit (one edit per item, preserve all others).

5. Clean up worktrees for completed branches:
   `git worktree remove ../fix-<slug>` for each successful fix.

6. For any failed agents: report the exact blocker. Do not retry automatically.
