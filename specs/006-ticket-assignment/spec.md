# Feature Specification: Ticket Assignment

**Feature Branch**: Not created (no branch hook configured)

**Created**: 2026-07-23

**Status**: Draft

**Input**: Administrator oversight of maintenance tickets and initial assignment of new tickets to
eligible technicians, with explicit authorization, validation, atomicity, and status-history behavior.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Assign Tickets for Resolution (Priority: P1)

As an administrator, I can oversee all tickets and assign a ticket to an eligible technician so that
responsibility is explicit and work can begin.

**Why this priority**: Assignment is the bridge between reporter ticket creation and technician work.
Without it, submitted maintenance issues cannot enter the operational workflow with a clearly
accountable technician.

**Independent Test**: Sign in as an administrator, list tickets submitted by multiple reporters,
assign one `new` ticket to an active technician, and verify the ticket summary, current assignment,
status, and single status-history entry. Repeat with ineligible targets and non-administrator actors
to verify that no failed attempt changes or exposes ticket data.

**Acceptance Scenarios**:

1. **Given** tickets from multiple reporters, **When** an administrator lists tickets, **Then** all
   tickets within the administrator's oversight are visible with their status and assignment.
2. **Given** a `new` ticket and an active technician, **When** an administrator assigns the ticket,
   **Then** the technician becomes responsible, the status becomes `assigned`, and the change is
   recorded in history.
3. **Given** an unknown, inactive, or non-technician user, **When** an administrator attempts an
   assignment, **Then** the assignment is rejected with a clear error and the ticket is unchanged.
4. **Given** a user without administrative authority, **When** the user attempts to list all tickets
   or assign one, **Then** access is denied without revealing restricted ticket information.

### Edge Cases

- The selected ticket is unknown, was removed, or is outside the administrator's oversight; the
  assignment is rejected without disclosing restricted ticket details or changing any record.
- The ticket is no longer `new`, already has a technician, or changes after the assignment screen is
  loaded; the stale assignment is rejected and the current ticket remains unchanged.
- The selected technician becomes inactive or loses the technician role after choices load but before
  assignment is committed; eligibility is rechecked and the assignment is rejected atomically.
- Two administrators attempt to assign the same `new` ticket at nearly the same time; exactly one
  assignment succeeds, the other receives a conflict result, and only the accepted change appears in
  history.
- A ticket has no assigned technician; list and detail results represent it explicitly as unassigned
  rather than omitting or inventing an assignment.
- An administrator requests a missing, malformed, zero, negative, excessive, or out-of-range page;
  invalid pagination is rejected and a valid out-of-range page returns an empty result.
- Authentication expires or the administrator account becomes inactive after ticket data loads; the
  next protected action is denied and no additional restricted data is returned.
- Connectivity is lost or an unexpected failure occurs while assigning; the client does not display
  success until the authoritative result is known and offers a safe refresh before retry.
- Unauthorized, offline, conflict, and server failures are never displayed as an empty ticket list or
  a successful assignment.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Only an authenticated, active administrator MUST be able to use the administrator ticket
  list and initial-assignment operations.
- **FR-002**: Administrators MUST be able to list every ticket within their oversight, including
  tickets submitted by different reporters.
- **FR-003**: The administrator ticket list MUST use stable newest-first pagination with a default
  page size of 20 and a maximum page size of 100.
- **FR-004**: Each listed ticket MUST include enough information to identify and triage it, including
  its reference, title, reporter, priority, department, category, creation time, current status, and
  current assigned technician or an explicit unassigned value.
- **FR-005**: Administrators MUST be able to select an active user with the technician role as the
  assignee of a `new`, currently unassigned ticket within their oversight.
- **FR-006**: Technician eligibility MUST be determined from current authoritative user identity,
  active-state, and role information when the assignment is committed, not solely when choices load.
- **FR-007**: A successful initial assignment MUST set exactly one current assigned technician and
  change the ticket status from `new` to `assigned` as one atomic business outcome.
- **FR-008**: A successful assignment MUST append exactly one immutable status-history entry containing
  the ticket, prior status `new`, new status `assigned`, acting administrator, assigned technician,
  and assignment time.
- **FR-009**: Assignment MUST reject an assignee identifier that does not resolve to a known user and
  MUST provide a clear, non-sensitive validation result.
- **FR-010**: Assignment MUST reject a user whose account is inactive at commit time and MUST provide
  a clear, non-sensitive validation result.
- **FR-011**: Assignment MUST reject a user who does not currently hold the technician role and MUST
  provide a clear, non-sensitive validation result.
- **FR-012**: Assignment MUST reject a ticket that is not `new`, already has an assignee, is unknown,
  or is outside the acting administrator's oversight.
- **FR-013**: Every failed or conflicting assignment MUST leave the ticket's assignee, status,
  update time, and status history unchanged.
- **FR-014**: If simultaneous assignment attempts target the same ticket, at most one MUST succeed;
  rejected attempts MUST return a conflict outcome that directs the administrator to refresh.
- **FR-015**: Users without administrative authority MUST NOT receive the administrator-wide ticket
  list, its counts or metadata, or assignment choices.
- **FR-016**: Users without administrative authority MUST NOT assign tickets, and denied assignment
  attempts MUST make no ticket or history change.
- **FR-017**: Unauthenticated requests MUST return an unauthenticated outcome without ticket,
  assignment, reporter, or technician data.
- **FR-018**: Authenticated but unauthorized requests MUST be denied before restricted ticket data is
  returned and MUST NOT confirm whether a targeted restricted ticket exists.
- **FR-019**: Unknown and out-of-oversight ticket targets MUST have materially indistinguishable
  public outcomes wherever revealing the distinction would disclose restricted information.
- **FR-020**: Administrator ticket listing and assignment MUST distinguish success, empty success,
  validation error, unauthenticated, unauthorized or concealed-not-found, conflict, and unexpected
  failure through the project's consistent response structure and stable machine-readable errors.
- **FR-021**: The administrator ticket-list experience MUST support loading, populated success, empty
  success, pagination loading, unauthorized, offline, and server-error states with safe retry.
- **FR-022**: The assignment experience MUST support ready, submitting, success, validation-error,
  unauthorized, concealed-not-found, conflict, offline, and server-error states and MUST prevent
  concurrent duplicate submission from the same screen.
- **FR-023**: Assignment success MUST refresh or update the visible ticket so the administrator sees
  the authoritative `assigned` status and technician without requiring an application restart.
- **FR-024**: User-visible errors MUST explain correctable eligibility or conflict issues while
  excluding credentials, authorization details, internal identifiers not already visible, stack
  traces, and restricted ticket contents.
- **FR-025**: This feature MUST NOT provide technician ticket processing, ticket discussions,
  ratings, reassignment, unassignment, ticket deletion, or any status transition other than the
  successful initial transition from `new` to `assigned`.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature delivers the initial operational handoff after ticket
  creation: administrators can oversee incoming tickets and make responsibility explicit by assigning
  an eligible technician.
- **Deferred Features Check**: Technician work queues and processing, `in_progress`, `completed`, or
  `rejected` transitions, comments, ratings, reassignment, unassignment, deletion, maps, QR codes,
  push notifications, export, and analytics are excluded.
- **Increment Boundary**: The smallest reviewable increment is an authorized, paginated administrator
  ticket list that shows current status and assignment. Atomic initial assignment, history recording,
  and the corresponding Flutter interaction follow as independently verifiable increments.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - Administrator ticket list: a Sanctum-authenticated administrator collection read with page and
    page-size inputs. Success returns `200` with ticket summaries and pagination metadata, including
    an empty collection; invalid pagination returns `422`; missing authentication returns `401`; and
    insufficient authority returns non-disclosing `403`.
  - Initial assignment: a Sanctum-authenticated administrator member operation accepting the intended
    technician identifier. Success returns `200` with the authoritative ticket assignment and status;
    invalid, inactive, or non-technician assignees return `422`; missing authentication returns `401`;
    insufficient authority returns non-disclosing `403`; an unknown or concealed ticket returns `404`;
    and stale status, existing assignment, or competing assignment returns `409`.
  - Success representations use the project's data and metadata envelope; errors use its error and
    code envelope. The contract MUST document request fields, ticket and assignment representations,
    pagination, validation rules, history effects, authentication, authorization, status codes, and
    compatibility expectations before client integration.
- **Authorization Rules**: Laravel Sanctum authentication, active-account enforcement, administrator
  role authorization, and ticket-oversight checks apply server-side. Authorization is evaluated before
  resolving a restricted ticket in any manner that could disclose its existence. Assignee eligibility
  is derived from authoritative user data and never trusted from client labels or cached state.
- **Flutter States**:
  - Administrator ticket list: loading, populated success, empty success, loading next page,
    unauthorized, offline, and server error. Validation applies to rejected pagination inputs;
    conflict is not a valid list result and is treated as a contract or server error.
  - Initial assignment: ready, submitting, success, technician-validation error, unauthorized,
    concealed-not-found, conflict requiring refresh, offline, and server error. Empty applies only
    when no eligible technician choices exist and disables submission with guidance.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Authentication state, pagination values, ticket identifiers, technician
  identifiers, cached ticket status, cached assignment state, and client-provided role or active-state
  labels are untrusted. Ticket contents, reporter identity, technician identity, and assignment history
  are restricted data governed by role and oversight checks.
- **Failure and Recovery**: Eligibility, ticket status, existing assignment, and administrator
  authority are revalidated when assignment commits. Ticket, assignment, status, and history change
  atomically. After an ambiguous connectivity failure, the client refreshes authoritative ticket state
  before offering retry so it does not misreport or duplicate an accepted assignment.
- **Operational Evidence**: Successful assignments, eligibility rejection categories, authorization
  denials, concealed target denials, assignment conflicts, and unexpected failures MUST produce
  structured diagnostics containing event type, outcome, timestamp, correlation identifier, acting
  user identifier when available, and ticket reference only when safe. Diagnostics MUST exclude
  authentication secrets, ticket descriptions, reporter contact data, and unnecessary personal data.
- **Quality Constraints**: Under normal connectivity, list and assignment actions show visible progress
  within 1 second and 95% complete within 3 seconds. Screens use accessible labels, logical focus order,
  text scaling, and non-color-only status indicators. User-visible text is localization-ready. Formal
  availability guarantees, offline caching, and feature-specific retention changes are out of scope.

### Verification Requirements

- **VR-001**: Automated backend tests MUST verify administrator listing across multiple reporters,
  oversight filtering, fields, explicit unassigned representation, stable ordering, pagination, and
  empty results.
- **VR-002**: Automated backend tests MUST verify successful initial assignment changes exactly one
  ticket from `new` to `assigned`, records exactly one active technician, and appends exactly one
  complete history entry.
- **VR-003**: Automated backend tests MUST verify unknown, inactive, and non-technician assignees are
  rejected and leave all ticket and history values unchanged.
- **VR-004**: Automated backend tests MUST verify non-`new`, already assigned, unknown, and
  out-of-oversight tickets are rejected with the defined non-disclosing or conflict outcomes and no
  state change.
- **VR-005**: Automated backend tests MUST verify unauthenticated, inactive-account, reporter, and
  technician actors cannot list administrator tickets or assign them and receive no restricted data.
- **VR-006**: Automated backend tests MUST verify competing assignments permit exactly one accepted
  outcome and one history entry.
- **VR-007**: Flutter tests MUST verify all applicable list and assignment states, response mapping,
  duplicate-submit prevention, pagination behavior, authorization loss, conflict refresh, technician
  validation, and offline/server recovery.

### Key Entities *(include if feature involves data)*

- **Ticket**: A reporter-owned maintenance issue with a human-readable reference, triage information,
  current status, optional current assignment, creation and update times, and status history. Only a
  `new`, unassigned ticket is eligible for assignment in this feature.
- **Administrator**: An authenticated active user authorized to oversee tickets and perform initial
  assignment within the applicable oversight boundary.
- **Technician**: An authenticated user identity that is eligible for assignment only while active and
  holding the technician role.
- **Assignment**: The ticket's current responsibility relationship to exactly one eligible technician,
  created together with the initial status transition.
- **Status History**: An immutable chronological record of the accepted assignment transition,
  including prior and new status, acting administrator, assigned technician, and time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Administrators can locate and assign a `new` ticket to an eligible technician in two
  minutes or less in at least 95% of representative acceptance-test attempts.
- **SC-002**: In 100% of successful assignment tests, exactly one technician becomes responsible, the
  status is `assigned`, and exactly one complete history entry records the accepted change.
- **SC-003**: In 100% of eligibility tests, unknown, inactive, and non-technician users are rejected
  with actionable feedback and no ticket or history change.
- **SC-004**: In 100% of authorization and privacy tests, non-administrators cannot obtain the
  administrator ticket list or assign a ticket and learn no restricted ticket information.
- **SC-005**: In 100% of conflict and failure tests, no partial or duplicate assignment or history
  record remains, and competing attempts yield at most one successful assignment.
- **SC-006**: Administrators can traverse all tickets within their oversight with zero missing or
  duplicate tickets in stable-pagination acceptance tests, and every item displays status and either
  its assigned technician or an explicit unassigned value.
- **SC-007**: Under normal connectivity, 95% of users see progress within 1 second and receive a list
  or assignment outcome within 3 seconds.
- **SC-008**: All applicable loading, populated, empty, validation, unauthorized, concealed-not-found,
  conflict, offline, and server-error journeys pass acceptance testing without false success,
  restricted-data leakage, or an unintended ticket change.
- **SC-009**: Zero technician-processing, discussion, rating, reassignment, unassignment, deletion, or
  out-of-scope status-transition controls are exposed by this feature.

## Assumptions

- Existing Sanctum authentication, active-account enforcement, reporter/technician/administrator
  roles, response envelopes, ticket creation behavior, and active user records from earlier features
  are available and authoritative.
- In Version 1, every active administrator oversees all maintenance tickets. More granular department,
  site, or organization oversight is outside this feature and requires a future specification.
- Only `new`, unassigned tickets may receive an initial assignment. Reassignment and unassignment are
  explicitly deferred, and this feature does not alter tickets already in another state.
- Eligible technician choices may be obtained through existing authorized user/reference-data
  capabilities; creating, editing, activating, deactivating, or changing user roles is outside this
  feature.
- The existing human-readable ticket reference and canonical timestamp representation remain
  unchanged. Times are localized for display by the client without weakening chronological history.
- A default page size of 20 and maximum of 100 are suitable for Version 1. Search, advanced filtering,
  bulk assignment, and analytics are outside this feature.
- Assignment history is retained according to the project's wider ticket retention policy; this
  feature introduces no deletion or retention-policy controls.
- Offline means the remote operation cannot currently complete. Offline list caching, queued
  assignment, and background synchronization are not included.
