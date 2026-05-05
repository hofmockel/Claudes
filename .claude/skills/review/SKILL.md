---
name: review
description: Self-review staged or committed changes against the REVIEW.md checklist. Run before submitting any PR.
allowed-tools: "Bash(git diff*) Bash(git log *) Read(REVIEW.md)"
---

1. Get the diff:
   - If changes are staged: `git diff --cached`
   - If already committed: `git diff origin/main...HEAD`
2. Read `REVIEW.md` for the full checklist.
3. Work through each section of the checklist against the diff.
4. Report findings in exactly three buckets with file:line citations:

   **BLOCKERS** — must fix before merge (bugs, missing tests, secrets, broken contracts)
   **SUGGESTIONS** — non-blocking improvements (naming, docs, refactoring opportunities)
   **LOOKS GOOD** — what's done well (acknowledge correct patterns)

5. End with: "Should I fix any of the blockers now?"
