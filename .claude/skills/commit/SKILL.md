---
name: commit
description: Stage and commit changes with conventional commit format. Use after changes are ready to commit.
allowed-tools: "Bash(git add *) Bash(git diff*) Bash(git status) Bash(git commit *)"
---

1. Run `git status` and `git diff --cached` to see what's staged.
2. If nothing is staged, run `git add -u` to stage all modified tracked files. Show what was staged.
3. Draft a conventional commit message:
   ```
   <type>(<optional scope>): <imperative summary, max 72 chars>

   <optional body: why this change was made, not what>

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   ```
   Valid types: `feat` `fix` `docs` `style` `refactor` `test` `chore` `perf` `ci` `build` `revert`
   Rules: imperative mood ("add" not "added"), no period at end, summary under 72 chars.
4. Show the proposed message and ask for approval before running anything.
5. On approval: `git commit -m "<message>"`. Report the resulting commit SHA.
