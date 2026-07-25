# Data Model: Ticket Rating

## Overview

Feature 009 adds one immutable optional Rating per Ticket. The Ticket remains the authorization and completion boundary; creating a rating does not modify ticket status, assignment, history, comments, or any other ticket field.

## Entity: Rating

| Field | Conceptual type | Required | Rules |
|---|---|---:|---|
| `id` | stable positive identifier | yes | Server-generated; never accepted from clients |
| `ticket_id` | Ticket relationship | yes | References exactly one ticket; unique for the lifetime of the rating record; restricted from parent deletion by this feature |
| `reporter_id` | User relationship | yes | Authenticated active reporter who owns the ticket; never client-supplied |
| `submission_token` | UUID | yes | Client-generated retry identity; immutable; scoped uniqueness with ticket and reporter |
| `value` | integer | yes | Native whole number from 1 through 5 inclusive |
| `created_at` | unambiguous timestamp | yes | Authoritative acceptance time; immutable |

There is no `updated_at`, review-text field, deletion marker, anonymity field, aggregate, or status field.

### Relationships

- Rating belongs to exactly one Ticket.
- Rating belongs to exactly one reporter User as its author.
- Ticket has zero or one Rating.
- Reporter User may author zero or more Ratings, each for a different owned ticket.

### Invariants

1. `ticket_id` is unique, enforcing at most one Rating per Ticket.
2. `(ticket_id, reporter_id, submission_token)` is unique, enforcing one stored result for a scoped logical submission.
3. `value` is an integer in `[1,5]`, enforced by request validation and a database check constraint where supported by the project database.
4. `reporter_id` equals the ticket's authoritative `reporter_id` at creation.
5. The related ticket has exact status `completed` at commit time.
6. `value`, `ticket_id`, `reporter_id`, `submission_token`, and `created_at` cannot be updated after creation.
7. This feature exposes no delete operation and model-level safeguards reject update/delete attempts.
8. A failed operation leaves the Rating absent or preserves the complete original Rating unchanged.

## Existing Entity: Ticket

Relevant existing fields:

| Field | Role in this feature |
|---|---|
| `id` | Parent relationship and locking target |
| `reference` | Public route identifier resolved inside reporter ownership scope |
| `reporter_id` | Ownership and rating-author boundary |
| `status` | Must equal `completed` at locked commit time |
| existing workflow fields | Read-only and unchanged by rating creation |

New relationship: optional `rating`, deterministically absent or one Rating.

## Existing Entity: User

Relevant existing fields:

| Field | Role in this feature |
|---|---|
| `id` | Authenticated rating author and ownership comparison |
| `role` | Must be reporter through route middleware and server authorization |
| active state | Must remain active through protected request handling |

New relationship: authored ratings. Technicians and administrators have no rating-creation permission even if they can view a ticket through other approved workflows.

## Request Model

Rating creation accepts exactly:

| Field | Rule |
|---|---|
| `rating` | Required native integer, minimum 1, maximum 5 |
| `submission_token` | Required canonical UUID string |

Unsupported fields—including reporter/user identifiers, ticket identifiers, status, author, timestamps, review text, comments, or rating IDs—are rejected.

## Public Representation

```text
RatingRepresentation
  value: integer 1..5
  rated_at: unambiguous timestamp
```

The reporter detail contract exposes `rating` as either this representation or `null`. Submission token, persistence identifiers, reporter profile, and internal foreign keys are not exposed.

## Atomic Creation Algorithm

Within one database transaction:

1. Resolve the ticket by reference through the authenticated reporter's owned-ticket query and lock the ticket row.
2. If no owned ticket is found, return the concealed not-found result before reading rating or status data.
3. Read any rating for the locked ticket.
4. If a rating exists with the same reporter and submission token, return it as an authoritative replay without mutation.
5. If any other rating exists, return the already-rated conflict without mutation.
6. Verify the locked ticket status is exactly `completed`; otherwise return the ineligible-status conflict without mutation.
7. Insert one Rating using the authenticated reporter, validated integer and token, and authoritative creation time.
8. Commit and return the stored representation. Any exception rolls back completely.

The unique ticket constraint is the final concurrency backstop. A constraint race is re-read inside safe error handling and mapped to replay only when the stored token matches; otherwise it is an already-rated conflict.

## State Model

The persisted rating has only two states:

```text
Absent --(authorized completed-ticket creation)--> Present and immutable
```

There is no transition from Present to another value and no deletion transition.

Ticket status transitions are not part of this feature. The rating Action only observes `completed`.

## Failure Matrix

| Condition | Result | Stored effect |
|---|---|---|
| New valid owned completed rating | Created | Exactly one Rating |
| Same accepted token replay | Successful replay | None; original returned |
| Different token after rating | Already-rated conflict | None; original unchanged |
| Owned non-completed ticket | Eligibility conflict | None |
| Invalid value/token/extra field | Validation failure | None |
| Unknown/non-owned target | Concealed not found | None; no rating data disclosed |
| Wrong role | Role denial | None; target not resolved |
| Missing/inactive authentication | Unauthenticated | None |
| Competing valid distinct attempts | One winner; other conflict | One Rating at most |
| Persistence/unexpected failure | Sanitized server failure | Transaction rollback |

## Retention and Privacy

- Rating follows the existing ticket retention policy.
- No rating-specific deletion or anonymization is added.
- Diagnostics omit rating value, submission token, ticket contents, credentials, and unnecessary personal data.
- Rating visibility does not grant or broaden ticket-detail authorization.
