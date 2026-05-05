---
name: ci-fix
description: Fetch the latest CI failure logs from GitHub or GitLab, classify the failure, and fix it locally before pushing.
---

1. Detect which remote is red:
   - `gh run list --limit 5 --json status,conclusion,name,databaseId,headBranch` (GitHub)
   - `glab ci list --status=failed -P 5` (GitLab) — only if the `gitlab` remote is configured
   Pick the most recent failed run on a branch you own. If both are red, fix the GitHub one first; the same diff usually fixes both.
2. Fetch the failure output:
   - GitHub: `gh run view <id> --log-failed`
   - GitLab: `glab ci trace <pipeline-id>` (or `glab ci view <id>`)
3. Classify the failure into exactly one category:
   - `lint` — ruff / flake8 / isort errors
   - `type` — mypy annotation errors
   - `test` — pytest failures
   - `security-scan` — zizmor / bandit findings
   - `coverage` — coverage gate not met
   - `infra` — GitHub Actions YAML / runner issues
4. Apply the matching playbook:
   - **lint**: `ruff check --fix .` → verify clean → commit `ci: fix lint`
   - **type**: fix mypy errors at source → commit `ci: fix type errors`
   - **test**: reproduce locally with `pytest -x`, fix root cause (not the test), add regression test → commit `fix: <cause>`
   - **security-scan**: read the zizmor/bandit output, apply minimal-scope fix → commit `ci: fix security scan`
   - **coverage**: identify uncovered lines, add targeted tests → commit `test: increase coverage`
   - **infra**: report the error verbatim and wait for instruction — do not guess at YAML changes
5. Run `/ship` to validate the full suite locally before pushing.
6. After push: wait 90s, run `gh run list --limit 1 --json conclusion` to confirm green. If still red, repeat from step 2 (max 3 iterations).
