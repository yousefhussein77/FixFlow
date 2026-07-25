# Research: Ticket Assignment

## Administrator routing and restricted lookup

**Decision**: Add all three operations below `/api/admin` inside the existing `auth:sanctum`, `active`,
and `administrator` middleware chain. Use an administrator-specific ticket query/controller rather
than broadening reporter endpoints. Resolve ticket references only after those checks; unknown and
out-of-oversight targets return the same sanitized `TICKET_NOT_FOUND` envelope.

**Rationale**: Existing routes and middleware already establish the project authorization boundary
and safe `401`/`403` envelopes. A separate surface prevents administrator-only reporter and assignment
data from leaking into the reporter contract and leaves room for future oversight scoping.

**Alternatives considered**: Reusing `/reporter/tickets` was rejected because its ownership semantics
and response are intentionally reporter-private. Implicit route-model binding was rejected because it
can resolve a restricted target before the oversight boundary and may not use the canonical envelope.

## Active-technician eligibility lookup

**Decision**: Provide `GET /api/admin/options/technicians`, returning only `id` and `name` for active
users whose current role is `technician`, ordered by normalized name then id. Treat the list as a UI
convenience only; the assignment transaction rechecks the identified user, active flag, and role.

**Rationale**: A minimal authorized lookup satisfies selection UX without exposing email, contact,
inactive users, or role-management capabilities. Commit-time validation closes the race between
loading options and submitting assignment.

**Alternatives considered**: Returning all users and filtering on the device was rejected for privacy
and trust-boundary reasons. Reusing department/category option endpoints was rejected because user
eligibility has different authorization and lifecycle semantics. Caching eligibility as authoritative
was rejected because account state and role can change.

## Assignment persistence model

**Decision**: Add nullable `assigned_technician_id` to `tickets`, referencing `users` with restricted
deletion, plus a dedicated append-only `ticket_status_histories` table. An accepted row records ticket,
`new`, `assigned`, acting administrator, assigned technician, and occurrence time. Add ticket/technician
indexes and chronological history indexing.

**Rationale**: The ticket needs a fast authoritative current responsibility while immutable history
needs a separate chronological audit record. Restricted deletion preserves the meaning of current and
historical assignments. The schema supports only what this feature requires without modeling comments,
ratings, or future workflow transitions.

**Alternatives considered**: Deriving the current technician from history was rejected because it
complicates every list and invariant check. Storing only the current technician was rejected because
FR-008 requires immutable history. A general event store was rejected as premature complexity.

## Atomicity and competing assignment

**Decision**: `AssignTicket` runs inside one database transaction, locks the ticket row, verifies it
is still `new` and unassigned, obtains and revalidates the technician, updates the ticket, and inserts
one history row before commit. A stale/already-assigned/non-`new` ticket returns `409
ASSIGNMENT_CONFLICT`; transaction failure rolls back both records.

**Rationale**: The lock serializes competing attempts and the transaction makes technician, status,
and history one outcome. Exactly one contender can satisfy the invariant, while retry after an
ambiguous network result can safely refresh authoritative state.

**Alternatives considered**: Client-side disabling alone was rejected because it cannot coordinate
multiple devices or administrators. Optimistic status changes were rejected because they can show
false success. A distributed lock or queue was rejected because one MariaDB row transaction is the
simplest adequate boundary.

## Validation and error taxonomy

**Decision**: A Form Request validates the technician identifier shape. The Action returns field-level
`422 VALIDATION_ERROR` outcomes for unknown, inactive, and non-technician assignees after authoritative
transaction-time checks. Ticket absence/concealment is `404 TICKET_NOT_FOUND`; stale ticket state is
`409 ASSIGNMENT_CONFLICT`; auth uses existing `401`/`403`; unexpected failures use sanitized `500`.
Every rejected path leaves ticket timestamps, assignment, status, and history unchanged.

**Rationale**: This matches the approved spec and existing `ApiResponse` envelope while keeping
correctable technician errors distinct from ticket concurrency. Stable codes let Flutter map states
without parsing messages.

**Alternatives considered**: Treating all invalid technicians as `404` was rejected because the
administrator is authorized to use the eligibility workflow and needs actionable correction.
Returning internal exception text was rejected for security and contract stability.

## Administrator ticket list and pagination

**Decision**: Query all Version 1 oversight tickets, eager-load reporter, department, category, and
assigned technician, then paginate with `(created_at DESC, id DESC)`, default 20 and maximum 100.
Return an admin-only summary containing the spec fields and an explicit nullable assignee.

**Rationale**: This mirrors the established reporter pagination behavior, avoids N+1 reads, provides
stable pages, and meets the current assumption that all tickets are in each administrator's oversight.

**Alternatives considered**: Search/filter infrastructure was rejected as out of scope. Adding admin
fields to `TicketSummaryResource` was rejected because it would risk widening reporter responses.

## Flutter composition and recovery

**Decision**: Preserve manual dependency injection, `http`, secure token storage, layered ticket
models/service/repository/controllers/screens, and ChangeNotifier state. Add admin-specific models and
repository methods. Never optimistically assign; update a row only from the successful authoritative
response. After `409`, `404`, offline, or ambiguous server failure, require refresh before retry.

**Rationale**: This follows current mobile architecture and provides explicit list, option, validation,
authorization, conflict, offline, and server states. Separate admin models keep reporter contract
mapping stable.

**Alternatives considered**: A new state-management or code-generation package was rejected because
existing patterns are sufficient. Reusing reporter summary models was rejected because admin rows
require reporter and nullable technician data. Queued offline assignment was rejected as unsafe and
outside scope.

## Test strategy

**Decision**: Use Laravel Feature Tests with factories and isolated databases for contract, database,
authorization, rollback, and concurrency behavior. Use Flutter fake repositories for controller/widget
states plus service/repository contract-mapping tests. Run full existing suites to protect earlier
features and optionally smoke-test on an Android device.

**Rationale**: These are the established project test layers and cover both high-risk server invariants
and user-visible state transitions without coupling tests to live services.

**Alternatives considered**: Manual-only verification was rejected by the constitution. Testing only
controllers was rejected because transaction and database constraints are the critical risk. A live
backend dependency in Flutter unit tests was rejected for speed and determinism.
