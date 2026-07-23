# Data Model: Reporter Ticket Creation and Tracking

## Ticket

| Field | Type / constraint | Notes |
|---|---|---|
| id | unsigned bigint, primary | Stable pagination tie-breaker |
| reference | varchar(16), unique, immutable | `TKT-` + 12 uppercase alphanumeric chars |
| reporter_id | FK users, indexed | Derived only from authenticated reporter |
| department_id | FK departments | Must be active at commit |
| category_id | FK categories | Must be active and belong to department |
| submission_token | UUID string | Unique with reporter_id; immutable |
| title | varchar(160) | Required, trimmed, non-whitespace |
| description | text, max 5000 chars | Required, trimmed, non-whitespace |
| priority | enum-like varchar | low, medium, high, urgent |
| location | varchar(255) | Required, trimmed, non-whitespace |
| status | varchar, default `new` | Server-owned; no transition in this feature |
| created_at / updated_at | timestamps | Server-owned UTC serialization |

Relationships: belongs to Reporter, Department, and Category; has zero to five Ticket Photos.

## Ticket Photo

| Field | Type / constraint | Notes |
|---|---|---|
| id | unsigned bigint, primary | Internal identity |
| ticket_id | FK tickets, cascade delete | Exactly one ticket |
| disk | varchar | Private configured disk |
| path | varchar, unique | Generated non-user path |
| original_name | varchar(255) | Sanitized display name only |
| mime_type | varchar | image/jpeg, image/png, image/webp |
| size | unsigned bigint, max 10,485,760 | Verified server upload size |
| position | unsigned tinyint, 0..4 | Stable submitted order; unique per ticket |
| created_at / updated_at | timestamps | Server timestamps |

Ticket and all photo rows/files are one logical creation unit. No post-creation mutation is exposed.

## Existing entities

- **Reporter/User**: must be active and have role `reporter`; owns many tickets.
- **Department**: existing active classification; owns categories and tickets.
- **Category**: existing department child; must be active and match the submitted department.
- **Submission Token**: represented on Ticket rather than a separate entity because it has exactly one
  reporter and at most one creation result.

## State and invariants

- New ticket status is always `new`; clients cannot provide reporter, reference, status, or timestamps.
- Text is boundary-trimmed before validation/persistence.
- Classification is checked again within the creation transaction.
- A reporter/token pair maps to no ticket or exactly one ticket.
- A ticket has 0..5 photos; each supported MIME and size limit is authoritative at submission.
- This feature defines no ticket state transitions, update, or deletion behavior.
