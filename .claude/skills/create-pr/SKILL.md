---
name: create-pr
description: Push the current branch to all remotes and open a PR on GitHub and an MR on GitLab. Run after /commit.
allowed-tools: "Bash(git status) Bash(git log *) Bash(git diff*) Bash(git remote*) Bash(bash scripts/push-all.sh) Bash(gh pr *) Bash(glab mr *)"
---

1. Run `git status` — if uncommitted changes, stop and say so.
2. Run `git log origin/main..HEAD --oneline` (or first remote's `main`) to list commits.
3. Run `git diff main...HEAD --stat` for a file summary.
4. **Push to all remotes:** `bash scripts/push-all.sh`. If any remote fails, stop.
5. Build the title (conventional-commit format) and body using this template:
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
   - [ ] Both remotes pushed

   🤖 Generated with [Claude Code](https://claude.ai/code)
   ```
6. Show proposed title + body. Ask for approval.
7. On approval, open on **every** configured remote:
   - GitHub: `gh pr create --title "<title>" --body "<body>"`
   - GitLab: `glab mr create --title "<title>" --description "<body>" --source-branch "$(git rev-parse --abbrev-ref HEAD)" --target-branch main --yes`
8. Report each URL. If only one tool is installed, run that one and note the missing tool.

## Dual-remote contract

Both PR and MR must exist for cross-team visibility. If `glab` or `gh` is unavailable on this machine:
- Open the one that works
- Print the exact command needed to open the other manually
