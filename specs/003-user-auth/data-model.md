# Data Model: User Authentication and Session Management

## User Account

Represents one person who can authenticate.

| Field | Type | Rules |
|-------|------|-------|
| `id` | unsigned integer | Primary stable identifier |
| `name` | string, max 255 | Required; surrounding whitespace normalized; non-empty |
| `email` | string, max 255 | Required; normalized by trimming and lowercasing; unique |
| `password` | protected string | Required at creation; one-way hashed; hidden from serialization and logs |
| `role` | string enum | `reporter`, `technician`, or `administrator`; public creation always `reporter` |
| `is_active` | boolean | Defaults true; false prevents login and every protected operation |
| `created_at` | timestamp | Returned in profile |
| `updated_at` | timestamp | Internal lifecycle metadata |

### Validation

- Registration name: required string, 1–255 characters after surrounding whitespace normalization.
- Registration email: required syntactically valid address, max 255, unique after normalization.
- Password: 12–128 characters, contains at least one letter and number, confirmation matches, never trimmed.
- Role and active state are server-assigned and not mass-assignable from public input.

### State transitions

```text
not present --valid registration--> active reporter
active account --external future provisioning/deactivation--> inactive account
inactive account --external future reactivation--> active account
```

Role changes and active-state administration are outside this feature. Tests/factories may create inactive or privileged accounts to verify authentication boundaries.

## Authentication Token

Laravel Sanctum-owned record representing one session.

| Field | Rules |
|-------|-------|
| token owner | Exactly one User Account |
| name | Fixed client-identifying value, without device secrets |
| token digest | One-way digest persisted by Sanctum; raw token returned once at issuance |
| abilities | Minimal/default authenticated ability; authorization still checks account and ownership |
| last used / timestamps | Framework lifecycle metadata; never used to expose token data |

### State transitions

```text
absent --successful registration/login--> valid
valid --current-session sign-out--> revoked/deleted
valid --account becomes inactive--> unusable for protected operations
valid --invalid/malformed client credential--> not matched
```

An account may own multiple valid tokens. Sign-out affects only the presented current token.

## Client Session State

An in-memory mobile state with protected token persistence.

| State | Meaning | Allowed transition examples |
|-------|---------|-----------------------------|
| restoring | Reading token and verifying profile | authenticated, signedOut, offline, serverError |
| signedOut | No confirmed active token | submittingRegistration, submittingLogin |
| submittingRegistration | Registration in progress | authenticated, validationError, authError, offline, serverError |
| submittingLogin | Login in progress | authenticated, validationError, authError, offline, serverError |
| authenticated | Active profile confirmed | refreshingProfile, signingOut, signedOut on 401 |
| refreshingProfile | Protected profile request in progress | authenticated, signedOut, offline, serverError |
| signingOut | Revocation attempt in progress | signedOut in every terminal outcome |
| validationError | Field errors available | submittingRegistration or submittingLogin |
| authError | Generic credential/unauthenticated failure | signedOut or retry submission |
| offline | Transport unavailable; safe retry offered | prior operation retry or signedOut |
| serverError | Service/contract failure; safe retry offered | prior operation retry or signedOut |

Late asynchronous results carry an operation generation and cannot restore a session after local sign-out.

## API Error

| Field | Rules |
|-------|-------|
| `success` | Always false |
| `message` | Safe user-facing summary |
| `data` | Always null |
| `errors` | Field map for validation, otherwise null |
| `code` | Stable machine-readable identifier |

No raw exception, credential, authorization header, password representation, or full token is included.

## Relationships

- User Account 1 — 0..many Authentication Tokens.
- Client Session State 0..1 — 1 User Account profile, only while authenticated.
- Client Session State 0..1 — 1 raw token, persisted solely through the secure token store.
