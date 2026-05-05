---
name: create-pr
description: Push the current branch and open a pull request on GitHub. Run after /commit.
allowed-tools: "Bash(git status) Bash(git log *) Bash(git diff*) Bash(git push *) Bash(gh pr *)"
---

1. Run `git status` — if there are uncommitted changes, stop and say so.
2. Run `git log origin/main..HEAD --oneline` to list commits going into this PR.
3. Run `git diff origin/main...HEAD --stat` for a file summary.
4. Push: `git push -u origin HEAD`.
5. Build the PR body using this template:
   ```
   ## Summary
   - [what changed]
   - [why it changed]

   ## How to Test
   1. [step]
   2. [step]

   ## Checklist
   - [ ] Tests pass
   - [ ] No secrets in diff
   - [ ] Spec updated if behavior changed

   🤖 Generated with [Claude Code](https://claude.ai/code)
   ```
6. Show the proposed title (conventional commit format) and body. Ask for approval.
7. On approval: `gh pr create --title "<title>" --body "<body>"`. Report the PR URL.
