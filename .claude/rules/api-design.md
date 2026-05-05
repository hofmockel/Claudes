---
paths:
  - "src/api/**"
  - "lib/api/**"
  - "routes/**"
  - "app/api/**"
---

# API Design Rules

These rules activate when editing files in API/route directories.

## Resource naming

- Use plural nouns for collections: `/users`, `/orders`, not `/user`, `/order`
- Use kebab-case for multi-word segments: `/payment-methods`, not `/paymentMethods`
- Nest resources only one level deep: `/users/{id}/orders` — avoid `/users/{id}/orders/{id}/items`

## HTTP semantics

- `GET` — read only, no side effects, safe to retry
- `POST` — create a new resource or trigger an action
- `PUT` — replace a resource entirely (all fields required)
- `PATCH` — partial update (only changed fields required)
- `DELETE` — remove a resource; return 204 with no body on success

## Error envelope

All error responses use this structure:

```json
{
  "error": "SCREAMING_SNAKE_CASE_CODE",
  "message": "Human-readable description for developers",
  "details": {}
}
```

- `error` is a stable machine-readable code — never change it once published
- `message` is informational — clients must not parse it
- HTTP status maps to error class: 4xx = client error, 5xx = server error

## Validation

- Validate all inputs at the handler boundary before touching business logic
- Return 422 with field-level errors for invalid request bodies
- Return 400 for malformed requests (wrong content-type, unparseable JSON)

## Documentation

- Every new endpoint requires a docstring or inline comment describing: purpose, auth requirements, request shape, and possible error codes
- If the project uses OpenAPI, update the spec before or alongside the implementation
