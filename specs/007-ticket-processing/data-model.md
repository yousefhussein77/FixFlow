# Data Model: Technician Ticket Processing

## Existing Ticket (extended behavior, no new ticket column)

Relevant fields:

| Field | Constraint | Processing use |
|---|---|---|
| reference | unique immutable display reference | Technician member lookup after assignment scoping |
| assigned_technician_id | nullable FK users, indexed | Current-assignment authorization boundary |
| status | Version 1 status string | Authoritative transition source and destination |
| created_at / updated_at | timestamps | Stable list ordering and accepted-change timestamp |

Relevant relationships: belongs to assigned technician, reporter, department, and category; has photos
and chronological status history.

Processing adds status constants `in_progress`, `completed`, and `rejected` alongside existing `new`
and `assigned`. This feature never changes `assigned_technician_id` or submitted ticket content.

## Existing Ticket Status History (additive reason field)

| Field | Constraint | Notes |
|---|---|---|
| id | unsigned bigint, primary | Stable tie-breaker for chronological order |
| ticket_id | FK tickets, restrict delete | History belongs to exactly one ticket |
| from_status | string(30) | Authoritative status before accepted change |
| to_status | string(30) | Authoritative status after accepted change |
| actor_id | FK users, restrict delete | Authenticated actor who performed the change |
| assigned_technician_id | FK users, restrict delete | Technician responsibility at occurrence time |
| reason | nullable string/text, max 1000 characters | Required and trimmed only when `to_status = rejected` |
| occurred_at | timestamp | Business occurrence time |
| created_at | timestamp | Persistence audit timestamp |

The existing `(ticket_id, occurred_at, id)` index supplies complete deterministic history ordering.
History is append-only: application update/delete attempts remain rejected. Existing feature-006
assignment rows migrate with `reason = null`.

## Existing Technician/User

An authorized processing actor must have current role `technician`, an active account, valid Sanctum
authentication, and be the Ticket's current `assigned_technician_id`. Role/active state is rechecked on
each request; assignment is rechecked under the transition lock.

## Transition Matrix

| Current status | Requested status | Reason | Result |
|---|---|---|---|
| assigned | in_progress | not required/stored null | Accept |
| assigned | rejected | required, trimmed, non-blank, ≤1000 | Accept |
| in_progress | completed | not required/stored null | Accept |
| in_progress | rejected | required, trimmed, non-blank, ≤1000 | Accept |
| new | any technician status | any | Conflict; technicians cannot process unassigned intake |
| assigned | completed | any | Conflict; work must start first |
| in_progress | in_progress | any | Conflict; no duplicate transition |
| completed | any | any | Conflict; terminal |
| rejected | any | any | Conflict; terminal |
| any | unsupported value | any | Validation error before mutation |

Every accepted row satisfies:

1. authenticated active actor is the current assigned technician;
2. current/requested pair is listed as Accept above;
3. ticket status update and one history insert commit in one transaction;
4. `from_status` is the locked prior value and `to_status` is the accepted requested value;
5. history actor and assigned technician both identify the authenticated technician;
6. rejection stores the reason; other processing transitions store null.

## Query and privacy invariants

- Assigned list starts with `assigned_technician_id = authenticated technician` before pagination or
  counts and orders by `created_at DESC, id DESC`.
- Detail and transition locate the reference through that same current-assignment scope.
- Unknown and non-assigned references produce the same public 404 representation.
- Assignment changes between page/detail/submit invalidate stale access at the next server operation.
- List/detail/history resources omit internal persistence fields and unsupported controls.

## Atomic failure invariant

The transaction locks the assigned ticket, validates assignment and state, updates the ticket, and
inserts history. Validation, concealment, conflict, concurrent loss, or injected persistence failure
leaves ticket status, `updated_at`, assignment, and history exactly as before the attempt.
