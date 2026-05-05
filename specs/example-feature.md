# User Authentication

<!-- Example spec — replace with your first real feature spec.
     Import in CLAUDE.md: @specs/example-feature.md
     Remove this file and its import once you have real specs. -->

## Overview

Users can register with email + password, log in, and log out. Sessions are JWT-based
with a 7-day expiry. This spec covers credential flow only — OAuth and password reset
are out of scope.

## Behavior

- Unauthenticated requests to protected endpoints return 401.
- Registration requires a unique email and a password meeting minimum strength requirements.
- Successful login issues a signed JWT in an HttpOnly cookie.
- Sessions expire after 7 days; logout clears the cookie and invalidates the token server-side.
- Five consecutive failed logins from the same IP trigger a 15-minute lockout.

## Acceptance Criteria

- [ ] `POST /auth/register` creates a user when email is unique and password is valid
- [ ] `POST /auth/register` returns 409 when email is already registered
- [ ] `POST /auth/register` returns 422 when password is shorter than 8 characters
- [ ] `POST /auth/login` returns a JWT cookie on valid credentials
- [ ] `POST /auth/login` returns 401 with `INVALID_CREDENTIALS` on bad credentials
- [ ] `POST /auth/login` returns 429 after 5 failures within 15 minutes from the same IP
- [ ] `POST /auth/logout` clears the session cookie and invalidates the token server-side
- [ ] Expired or invalid tokens return 401 with `TOKEN_EXPIRED` or `TOKEN_INVALID`
- [ ] Passwords are hashed with bcrypt (cost ≥ 12) — plaintext never stored or logged

## API / Interface

```
POST /auth/register
Body:  { email: string, password: string }
200:   { userId: uuid, email: string }
409:   { error: "EMAIL_IN_USE" }
422:   { error: "PASSWORD_TOO_SHORT" }

POST /auth/login
Body:  { email: string, password: string }
200:   { userId: uuid } + Set-Cookie: session=<jwt>; HttpOnly; SameSite=Lax
401:   { error: "INVALID_CREDENTIALS" }
429:   { error: "RATE_LIMITED", retryAfter: seconds }

POST /auth/logout
200:   {} (cookie cleared)
```

## Data Model

```
User {
  id:           uuid        PK
  email:        string      UNIQUE, lowercase-normalised
  passwordHash: string      bcrypt cost >= 12
  createdAt:    timestamp
}

RateLimit {
  ip:          string
  endpoint:    string
  attempts:    int
  windowStart: timestamp
}
```

## Edge Cases

- Email lookup is case-insensitive; store and return the original casing
- `Authorization: Bearer <token>` header accepted as alternative to cookie
- Tokens issued before a password change are immediately invalidated

## Out of Scope

- OAuth / social login (separate spec: `oauth.md`)
- Password reset via email (separate spec: `password-reset.md`)
- Multi-factor authentication
