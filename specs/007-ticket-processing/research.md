# Research: Technician Ticket Processing

## Technician routing and concealed lookup

**Decision**: Add technician operations below `/api/technician` behind the existing Sanctum and active
middleware plus a technician-role middleware. Use technician-specific queries/controllers/resources.
List and detail queries constrain `assigned_technician_id` to the authenticated technician before
counts or resolution; unknown and non-assigned references share `TICKET_NOT_FOUND`.

**Rationale**: A separate surface preserves reporter/admin contracts and makes current assignment the
first data boundary. It provides the required indistinguishable outcome without resolving restricted
tickets globally.

**Alternatives considered**: Reusing reporter endpoints was rejected because ownership differs.
Broad route-model binding followed by authorization was rejected because resolution can create
observable differences. Client-side filtering was rejected because it is not authorization.

## Transition endpoint and validation taxonomy

**Decision**: Use `PATCH /api/technician/tickets/{reference}/status` with `status` and conditional
`reason`. Form Request validation accepts only `in_progress`, `completed`, or `rejected`, trims reason,
and requires a non-blank reason for `rejected` (maximum 1000 characters). The Action enforces the
state-dependent transition matrix. Shape/reason errors are `422 VALIDATION_ERROR`; invalid, stale,
terminal, or competing transitions are `409 STATUS_TRANSITION_CONFLICT`.

**Rationale**: One endpoint represents one bounded state-change concept while the Action remains the
authoritative state machine. A bounded reason protects storage and diagnostics without restricting
ordinary maintenance explanations.

**Alternatives considered**: Separate start/complete/reject endpoints duplicate authorization and
recovery behavior. Accepting arbitrary status strings risks unsupported workflow. Treating state
conflicts as validation hides the need to refresh authoritative state. Unlimited reason text creates
unnecessary abuse/storage risk; 255 characters was considered too restrictive.

## Atomicity and concurrency

**Decision**: `TransitionTicketStatus` starts one database transaction, queries the ticket through the
authenticated technician's current assignments, locks that ticket row, rechecks assignment/status,
updates status, and inserts exactly one history row before commit. A competing request observes the
new state after the lock and returns conflict. Any exception rolls back status, timestamp, and history.

**Rationale**: A MariaDB row lock serializes transitions on one ticket; the transaction makes current
status and immutable history one outcome. No distributed lock, queue, or client version field is
needed for the documented invariant.

**Alternatives considered**: Client-side disabling cannot coordinate devices. Optimistic-only updates
need an additional version contract without improving this single-row invariant. Queues/distributed
locks add unsupported operational complexity.

## History reason persistence and immutability

**Decision**: Add nullable `reason` (up to 1000 characters) to the existing
`ticket_status_histories` table. Assignment/start/completion history uses null; rejection history stores
the trimmed reason. Preserve model-level update/delete rejection and chronological `(occurred_at, id)`
ordering. Do not add reason to the Ticket row.

**Rationale**: The reason describes a specific immutable transition, not current ticket state. An
additive nullable field preserves feature-006 history and existing assignment rows.

**Alternatives considered**: A separate rejection table is needless one-to-one complexity. Ticket
columns lose transition context. Comments are explicitly excluded and have different authorization.

## Detail and history representations

**Decision**: Return technician summaries without reporter contact data. Detail reuses approved ticket
fields/photos, includes the current assignee summary, and embeds chronological history with status,
actor summary, occurrence time, and nullable reason. History does not expose internal database IDs.

**Rationale**: Technicians receive the work content and audit trail required to perform assigned work
without widening personal data or leaking internal persistence identities.

**Alternatives considered**: Returning reporter contact details was rejected as unsupported. A
separate history endpoint adds another operation with no independent requirement. Reusing admin
summaries would expose reporter data and wrong capabilities.

## Flutter composition and recovery

**Decision**: Add technician-specific contract models, service/repository methods, ChangeNotifier
controllers, assigned-list/detail screens, and a transition widget. Never update status optimistically.
After `409`, ambiguous offline, or server failure, block another transition until authoritative detail
and history refresh. Clear restricted state on `401`, `403`, or concealed `404`.

**Rationale**: This follows established project layers and prevents false success or stale transition
chains while supporting every specified state.

**Alternatives considered**: Reusing admin assignment state was rejected because transition semantics
and authorization differ. Queued offline mutation is unsafe and excluded. A new state package is
unnecessary.

## Test and live-verification strategy

**Decision**: Laravel Feature Tests use factories/isolated databases for list/detail privacy,
transition matrix, reason validation, immutable history, injected rollback, and competing requests.
Flutter service/repository/controller/widget tests cover mapping and states with fakes. Full existing
suites protect earlier features. Live Android/API verification is a separate final task and is
explicitly deferred—not passed—when no device/emulator or required network artifacts are available.

**Rationale**: Automated tests cover deterministic security and atomicity risks. A live smoke test can
validate platform integration but must not be conflated with or block truthful automated evidence when
the environment cannot provide a device.

**Alternatives considered**: Manual-only verification violates the constitution. Declaring emulator
success without a device is invalid. Making a device test part of unit/widget suites is impractical.
