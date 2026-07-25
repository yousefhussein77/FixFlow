# Research: Ticket Rating

## Decision 1: Persist a separate immutable one-to-one rating record

**Decision**: Store rating data in a dedicated record related one-to-one with a ticket and belonging to the authenticated reporter.

**Rationale**: A separate record expresses optional absence cleanly, permits database-enforced one-per-ticket uniqueness, preserves author and creation time, and avoids mixing immutable feedback with mutable ticket workflow fields.

**Alternatives considered**:

- Nullable rating columns on `tickets`: rejected because retry identity, authorship, creation time, and immutability become implicit and ticket updates could accidentally alter feedback.
- Generic feedback/review entity: rejected because review text, multiple feedback types, and anonymous behavior are outside scope.

## Decision 2: Use one singular reporter member endpoint

**Decision**: Create ratings with `POST /api/reporter/tickets/{reference}/rating`; expose the nullable rating through the existing reporter ticket detail response rather than adding a standalone read endpoint.

**Rationale**: Rating is a singular subordinate resource, and authorized detail visibility is already required. One creation route plus additive detail data is the smallest contract and does not create new access paths.

**Alternatives considered**:

- `/ratings` collection path: rejected because multiple ratings are prohibited.
- Separate `GET /rating`: rejected because it duplicates authorized reporter detail and expands routes without user value.
- `PATCH /tickets/{reference}`: rejected because it implies ticket editing and obscures rating immutability.

## Decision 3: Authenticate and authorize before eligibility disclosure

**Decision**: Apply `auth:sanctum`, active-account, and reporter-role middleware first; then resolve the ticket through the authenticated reporter's owned-ticket relationship. Only an owned ticket is checked for completion and prior rating.

**Rationale**: This preserves existing reporter concealment. A non-owner cannot distinguish unknown, incomplete, completed, rated, or unrated tickets.

**Alternatives considered**:

- Load by reference and authorize afterward: rejected because timing, messages, or error codes could disclose existence or rating eligibility.
- General rating policy exposed to every role: rejected because only reporters may rate and the existing role route group is clearer.

## Decision 4: Distinguish safe replay from a distinct duplicate

**Decision**: Require a UUID `submission_token`. The accepted rating stores it. Repeating the same token for the same authenticated reporter and ticket returns the original rating with `200`; any different token after a rating exists returns `409 RATING_ALREADY_EXISTS` without change.

**Rationale**: A lost success response must be safely recoverable, but the product rule still requires a distinct second attempt to be rejected. Comparing rating values cannot distinguish retry from a new attempt.

**Alternatives considered**:

- Reject every repeat: rejected because an ambiguous accepted response could not be reconciled safely.
- Treat matching values as replay: rejected because distinct intentional duplicates could be misclassified and tokens are the established project pattern.
- Permit replacement with a new token: rejected because editing is explicitly excluded.

## Decision 5: Lock the owned ticket and enforce uniqueness in the database

**Decision**: In one transaction, resolve and lock the reporter-owned ticket, verify `completed`, check any existing rating, replay only an identical scoped token, and otherwise insert exactly once. Enforce unique `ticket_id` and scoped token uniqueness in the schema.

**Rationale**: The ticket lock serializes status eligibility and competing rating attempts. Database uniqueness remains the final invariant if application-level concurrency assumptions fail. Transaction rollback leaves no partial rating.

**Alternatives considered**:

- Application-only pre-check: rejected because concurrent requests could both observe no rating.
- Unique constraint without lock: rejected because it produces less controlled conflict/replay behavior and does not coordinate eligibility with authoritative ticket state.
- Distributed lock or queue: rejected as unnecessary complexity for one database-owned record.

## Decision 6: Treat completed status as commit-time eligibility

**Decision**: Only the exact authoritative `completed` status is eligible, checked while the ticket row is locked. The rating Action never changes ticket status or history.

**Rationale**: The core specification names completed as the only eligible state. Commit-time checking prevents stale Flutter detail data from authorizing a rating.

**Alternatives considered**:

- Client-side status check only: rejected because client state is untrusted and may be stale.
- Include rejected tickets: rejected as unsupported scope.
- Complete and rate in one request: rejected because status processing is a separate approved feature and rating is reporter-only.

## Decision 7: Validate a native integer from 1 through 5 and reject extra fields

**Decision**: Accept exactly `rating` as an integer between 1 and 5 and `submission_token` as a UUID. Reject fractions, numeric strings, Booleans, arrays, objects, missing fields, and unsupported fields.

**Rationale**: Strict shape prevents coercion surprises and client attempts to supply author, owner, status, timestamps, or alternate review content.

**Alternatives considered**:

- Coerce numeric strings or decimal equivalents: rejected because the specification requires a whole-number value and strict contracts improve cross-client consistency.
- Star labels as transport values: rejected because presentation must not redefine the integer API contract.

## Decision 8: Add one nullable immutable rating object to reporter detail

**Decision**: Reporter ticket detail includes `rating: null` or `{value, rated_at}`. Creation responses additionally include the same public rating shape. Internal reporter identity and submission token are not returned because ownership is already established by the protected reporter context.

**Rationale**: The reporter needs authoritative value and time. Omitting internal identifiers and retry tokens minimizes exposed data while preserving additive compatibility.

**Alternatives considered**:

- Return the submission token: rejected because it is request/reconciliation metadata, not ticket detail.
- Return full reporter profile: rejected as unnecessary personal data.
- Add rating to every ticket summary or technician/admin detail: rejected because only authorized reporter detail visibility is required.

## Decision 9: Reconcile ambiguous Flutter submissions using retained token and detail refresh

**Decision**: The controller generates one token per draft/attempt, disables concurrent submission, retains that token after offline or server ambiguity, and retries with it. It accepts only the authoritative create/replay response, then refreshes reporter detail. Validation leaves the unrated entry state; concealed or unauthorized failure clears restricted data; already-rated conflict triggers authoritative detail refresh before further action.

**Rationale**: This prevents optimistic success and accidental second attempts while providing the requested offline and server recovery states.

**Alternatives considered**:

- Generate a token on every tap: rejected because a lost accepted response would become a prohibited distinct duplicate.
- Optimistically display the chosen score: rejected because persistence may have failed or a concurrent rating may have won.
- Offline queued rating: rejected because background synchronization is outside scope.

## Decision 10: Reuse existing dependencies and diagnostics

**Decision**: Use existing Laravel transactions/locking, factories, canonical `ApiResponse`, `TicketEvent`, Flutter secure token access, HTTP service, repository mapping, `ChangeNotifier` state, and widget tests. Add no package. Record event type/outcome/correlation/actor and safe reference only; omit score, token, ticket text, credentials, and personal data.

**Rationale**: Existing facilities satisfy all requirements and preserve project consistency and security.

**Alternatives considered**:

- Add an idempotency middleware/package or state-management library: rejected because it would broaden architecture for one bounded operation.
- Log full request payloads: rejected because rating value and retry identity are unnecessary operational data.

## Resolved Questions

All planning questions are resolved and no ambiguity remains for implementation planning.
