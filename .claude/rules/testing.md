---
paths:
  - "tests/**"
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
---

# Testing Rules

These rules activate when editing test files.

## Naming

- Test function names describe behavior: `test_returns_404_when_user_not_found`, not `test_get_user`
- Use `describe`/`it` blocks (Jest) or `class Test...` (pytest) to group related cases
- One logical assertion per test — split multiple unrelated assertions into separate tests

## What to test

- Test behavior from the caller's perspective, not implementation details
- Test the happy path, the primary error path, and at least one edge case per function
- Every bug fix requires a regression test that would have caught the original bug

## What to mock

- Mock external services (HTTP APIs, email, SMS, payment processors) — never call them in tests
- Mock the clock for any code that depends on `datetime.now()` or `Date.now()`
- Do **not** mock the database in integration tests — use a real test database or in-memory equivalent
- Do **not** mock the code under test itself

## Structure

- Test files live alongside source files: `src/auth.py` → `tests/test_auth.py` or `src/auth.test.ts`
- Each test is independent — no shared mutable state between tests, no ordering dependencies
- Use fixtures/factories for test data rather than hardcoded literals scattered across tests

## Coverage

- New features require tests before the PR can merge
- Deleted tests must be explicitly justified in the PR description
- Do not write tests that always pass regardless of implementation (vacuous assertions, empty `expect` blocks)

## Test order

Write tests **after** the feature works, not before. TDD slows agentic iteration. Build until the path runs end-to-end, then lock behavior with tests in the same commit.

## Environment isolation

Tests must run against an isolated environment — separate DB, separate env vars. Never against dev or production data. If `TEST_DATABASE_URL` (or equivalent) is missing, fail fast instead of silently falling back.

## UI validation

For UI changes, never report "done" without a browser screenshot via Claude-in-Chrome MCP. Test the golden path and at least one edge case visually before commit.
