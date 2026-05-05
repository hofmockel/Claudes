---
name: check-drift
description: Detect divergence between /specs/ and the current implementation. Run before major changes or periodically to catch regressions.
allowed-tools: "Bash(find *) Bash(grep *) Read"
---

## Specs available
!`find ./specs -name "*.md" ! -name "README.md" ! -name "_template.md" | sort`

---

For each spec file listed above — or only the spec matching `$ARGUMENTS` if provided:

1. Read the spec file.
2. Use `grep` and `find` to locate the relevant implementation files.
3. Check each item in the **Acceptance Criteria** section against the actual code.
4. Classify each criterion:
   - ✅ **IMPLEMENTED** — criterion is met
   - ❌ **DRIFT** — spec says X, code does Y (cite file:line)
   - ⚠️ **MISSING** — no implementation found for this criterion
   - 📝 **SPEC GAP** — code has behavior not covered by the spec

5. End with a drift score: `N of M criteria implemented. X drifted, Y missing.`
6. Ask: "Should I fix any drift now?"
