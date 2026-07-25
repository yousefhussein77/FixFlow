# Data Model: Ticket Comments

## Existing Ticket (authorization parent; unchanged schema)

Relevant fields and relationships:

| Field | Constraint | Comment use |
|---|---|---|
| id | Primary key | Parent reference for comments |
| reference | Unique immutable public reference | Role-scoped member lookup |
| reporter_id | FK users | Reporter ownership boundary |
| assigned_technician_id | Nullable FK users, indexed | Current technician boundary |
| status | Version 1 workflow state | Display context only; comments never change it |

Add a `comments` relationship ordered by `created_at`, then `id`, ascending. Comment reads do not lock
the ticket. Comment creation locks the parent ticket inside its transaction so current authorization
cannot change between its final check and insert.

## New Ticket Comment

| Field | Constraint | Notes |
|---|---|---|
| id | Unsigned bigint, primary | Stable identifier and equal-time ordering tie-breaker |
| ticket_id | FK tickets, indexed, restrict delete | Exactly one parent ticket |
| author_id | FK users, indexed, restrict delete | Authenticated author; never client supplied |
| author_role | String(30), required | Snapshot of authorized role at creation |
| submission_token | UUID/string(36), required | Retry identity; never returned |
| content | Text, required, 1–2,000 characters after boundary trim | Original validated plain text |
| created_at | Timestamp, required | Authoritative immutable creation time |

`updated_at` is absent. A unique constraint on `(ticket_id, author_id, submission_token)` provides the
database-level duplicate guard. An index on `(ticket_id, created_at, id)` supports chronological reads.
The model rejects update and delete operations. Foreign-key deletion is restricted so referenced
comments cannot disappear through parent or author deletion.

## Relationships

- Ticket has many Ticket Comments.
- Ticket Comment belongs to exactly one Ticket.
- Ticket Comment belongs to exactly one User as author.
- Reporter ownership and current technician assignment remain Ticket relationships and are not copied
  into comments.
- Administrator oversight is an authorization rule, not a persisted Comment relationship.

## Validation Rules

### List

- `reference`: required route value, resolved only through the authenticated role's authorized ticket query.
- No filters, sorting, pagination, search, or comment-content query parameters are accepted.

### Create

- `content`: required string; boundary-trimmed; nonblank; 1–2,000 characters; internal whitespace and
  line breaks preserved; plain text only.
- `submission_token`: required valid UUID string.
- Additional request fields are rejected, including author, role, ticket, timestamp, attachment, and
  notification controls.
- Authenticated actor supplies `author_id`; current authorized role supplies `author_role`.

## Authorization Matrix

| Actor | Existing authorized target | Unknown target | Existing unauthorized target |
|---|---|---|---|
| Active reporter | Own ticket: list/add | Concealed 404 | Concealed 404 |
| Active technician | Currently assigned ticket: list/add | Concealed 404 | Concealed 404 |
| Active administrator | Oversight ticket: list/add | Explicit 404 | 404 if outside oversight |
| Wrong authenticated role for route | 403 before target resolution | 403 | 403 |
| Missing/revoked/inactive authentication | 401 before role/target resolution | 401 | 401 |

List and create use the same authorized target predicate. Creation repeats it while holding the ticket
row lock. No client-supplied actor or assignment value participates in authorization.

## Creation Transaction and Replay

1. Begin one database transaction.
2. Resolve the ticket through the actor's authorized role predicate and lock the ticket row.
3. If no authorized row exists, return the role-appropriate concealed/explicit not-found outcome.
4. Query `(ticket_id, authenticated author_id, submission_token)`.
5. If found, return that original comment as a replay without mutation.
6. Otherwise insert one comment with authenticated author, role snapshot, validated content, and
   authoritative creation time.
7. Commit and return the authoritative comment.

Any exception rolls back the insertion. The parent row lock serializes same-ticket commit-time
authorization and submissions; the unique constraint remains the final concurrency invariant. An
ambiguous client retry reuses the same token. A newly intended comment uses a new token.

## Lifecycle and Immutability

Ticket Comments have one transition only:

```text
absent --authorized atomic create--> immutable
```

No edit, delete, restore, attachment, reaction, mention, delivery, read-receipt, or notification state
exists. Ticket assignment and status changes are external established workflows. A future assignment
change affects technician authorization but does not alter historical comments.

## API Representation

```text
TicketComment
|-- id
|-- content
|-- author
|   |-- id
|   |-- name
|   `-- role
`-- created_at
```

The representation excludes `ticket_id`, `submission_token`, internal timestamps other than creation,
ownership/assignment fields, credentials, and persistence metadata.
