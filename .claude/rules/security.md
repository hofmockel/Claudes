# Security Rules

These rules are always active regardless of which files are being edited.

## Secrets and credentials

- Never hardcode secrets, API keys, tokens, or passwords — always load from environment variables
- Never log secrets, even in debug statements
- `.env` is gitignored and blocked from `Read` in `settings.json` — do not attempt to read it
- If a required env var is missing, surface it immediately rather than failing mid-operation

## Input handling

- Validate and sanitize all user-supplied input at system boundaries (HTTP handlers, CLI args, file uploads)
- Never interpolate user input directly into SQL queries — use parameterized queries or an ORM
- Never interpolate user input into shell commands — use subprocess with argument lists, not string formatting
- Never use `eval()` or `exec()` on user-supplied strings

## PII and data

- Never log PII: email addresses, names, phone numbers, SSNs, payment data, IP addresses
- Treat any field whose name contains `password`, `token`, `secret`, `key`, or `credential` as sensitive
- Scope database queries to the authenticated user's tenant/account — never return all rows without a filter

## Dependencies

- Do not add a new dependency without checking for known CVEs (run `pip audit` or `npm audit`)
- Pin versions in requirements files — avoid open ranges like `>=1.0` with no upper bound
