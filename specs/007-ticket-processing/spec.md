# Feature Specification: Technician Ticket Processing

**Feature Branch**: `007-ticket-processing` (branch creation not performed; no hook configured)

**Created**: 2026-07-23

**Status**: Draft

**Input**: Enable an assigned technician to view only their assigned tickets and process each ticket
through the status workflow approved by the Version 1 core specification.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Assigned Work (Priority: P1)

As an authenticated technician, I can browse and open only tickets currently assigned to me so that I
can understand the maintenance work for which I am responsible.

**Why this priority**: A technician must be able to find and inspect assigned work before recording
progress or an outcome.

**Independent Test**: Assign tickets to two technicians in several statuses, authenticate as each
technician, and verify that each can traverse and open only their own assigned tickets with complete
work details and chronological status history.

**Acceptance Scenarios**:

1. **Given** tickets assigned to multiple technicians, **When** the current technician lists assigned
   tickets, **Then** only tickets currently assigned to that technician are returned in stable
   newest-first pages.
2. **Given** the current technician has no assigned tickets, **When** the assigned-ticket list loads,
   **Then** a successful empty state is shown without disclosing other technicians' workload.
3. **Given** a ticket assigned to the current technician, **When** the technician opens it, **Then**
   the maintenance details, current status, assignment, photos, timestamps, and complete chronological
   status history needed to perform the work are shown.
4. **Given** a ticket assigned to another technician or an unknown ticket reference, **When** the
   current technician attempts to open it, **Then** both requests receive a materially
   indistinguishable concealed-not-found outcome with no restricted ticket data.
5. **Given** a reporter, administrator, inactive account, or unauthenticated session, **When** the
   technician list or detail operation is requested, **Then** access is denied without assigned-ticket
   data, counts, metadata, or existence clues.

---

### User Story 2 - Start Assigned Work (Priority: P1)

As the technician currently assigned to a ticket, I can mark an `assigned` ticket as `in_progress` so
that its progress is accurately visible in the maintenance record.

**Why this priority**: Starting work is the first permitted technician transition and completes the
minimum useful assignment-to-processing handoff.

**Independent Test**: Seed an `assigned` ticket for one technician, submit the start-work transition,
and verify one atomic status update and one immutable `assigned` to `in_progress` history record;
repeat as another technician and with simultaneous attempts to verify no rejected attempt changes
ticket or history state.

**Acceptance Scenarios**:

1. **Given** an `assigned` ticket currently assigned to the technician, **When** the technician starts
   work, **Then** its status becomes `in_progress` and exactly one immutable history entry records the
   prior status, new status, acting technician, and occurrence time.
2. **Given** a ticket not assigned to the technician, **When** the technician attempts to start it,
   **Then** access is concealed and neither ticket nor history changes.
3. **Given** an `in_progress`, `completed`, or `rejected` ticket, **When** an `in_progress` transition
   is requested, **Then** a conflict explains that the visible state must be refreshed and no new
   history entry is recorded.
4. **Given** two start-work attempts based on the same `assigned` state, **When** they compete, **Then**
   at most one succeeds and exactly one accepted transition appears in history.
5. **Given** persistence fails during the transition, **When** the request ends, **Then** status,
   update time, and history remain unchanged and the technician receives a recoverable server-error
   outcome rather than false success.

---

### User Story 3 - Finish or Reject Assigned Work (Priority: P2)

As the technician currently assigned to a ticket, I can complete work that is in progress or reject
assigned work that cannot be fulfilled, so that the ticket reaches an accurate terminal outcome.

**Why this priority**: Completion or rejection closes the technician processing loop after assigned
work can be found and started.

**Independent Test**: Seed owned tickets in `in_progress` and `assigned`, complete the first and reject
the second with a reason, then verify their terminal states and immutable history independently of the
start-work experience. Exercise missing reasons, invalid transitions, competing requests, and
non-owned tickets to prove atomicity and authorization.

**Acceptance Scenarios**:

1. **Given** an `in_progress` ticket currently assigned to the technician, **When** work is completed,
   **Then** its status becomes `completed` and exactly one immutable history entry records the accepted
   transition, actor, and time.
2. **Given** an `assigned` or `in_progress` ticket currently assigned to the technician, **When** the
   technician rejects it with a non-blank reason, **Then** its status becomes `rejected` and exactly one
   immutable history entry preserves that reason with the accepted transition, actor, and time.
3. **Given** a rejection with a missing or whitespace-only reason, **When** it is submitted, **Then** a
   field-specific validation outcome is returned and ticket status, update time, and history remain
   unchanged.
4. **Given** an `assigned` ticket, **When** completion is requested without first reaching
   `in_progress`, **Then** the invalid transition receives a conflict outcome and makes no change.
5. **Given** a `completed` or `rejected` ticket, **When** any further technician status transition is
   requested, **Then** the terminal state and history are preserved.
6. **Given** another technician's ticket, **When** completion or rejection is attempted, **Then** the
   target is concealed as not found and no state or history change occurs.

### Edge Cases

- A ticket is assigned to the technician when the list loads but assignment changes before detail or
  transition; the next operation rechecks the current assignee and discloses no newly restricted data.
- A technician account becomes inactive or loses the technician role after a screen loads; the next
  protected operation is rejected and cached restricted data is cleared from the active workflow.
- Two valid but different transitions target the same current status nearly simultaneously; only the
  transition that first satisfies the authoritative state is accepted and history reflects that one
  accepted order.
- A stale client submits a transition after another actor has changed the status; a conflict triggers
  authoritative refresh and does not overwrite the newer state.
- Pagination inputs are missing, malformed, negative, zero, excessive, or out of range; invalid values
  receive validation errors and a valid out-of-range page returns an empty page.
- A status-history record exists with an actor who later becomes inactive; the historical actor and
  chronology remain readable to an authorized current assignee.
- A ticket photo is temporarily unavailable; ticket details and history remain usable, the unavailable
  photo is identified safely, and retry does not treat the ticket as absent.
- Connectivity fails after a transition request may have reached the service; the client does not
  claim success or retry blindly and refreshes authoritative ticket/history state first.
- Validation, concealed denial, conflict, offline, and server failures never appear as an empty list,
  a successful transition, or a missing history entry for an accepted change.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Only an authenticated user with an active technician role MUST be able to use the
  technician assigned-ticket list, detail, and status-transition operations.
- **FR-002**: Technicians MUST be able to list only tickets whose current assigned technician is the
  authenticated technician; assignment filtering MUST occur before counts, pagination, metadata, or
  ticket data are produced.
- **FR-003**: The assigned-ticket list MUST use stable newest-first pagination with a default page size
  of 20 and a maximum page size of 100.
- **FR-004**: Each list item MUST include enough information to identify and open assigned work,
  including reference, title, current status, priority, department, category, and creation time.
- **FR-005**: A technician MUST be able to open a ticket only while that technician remains its current
  assignee.
- **FR-006**: Assigned-ticket details MUST include reference, title, description, current status,
  department, category, priority, location text, photos, assignment, creation and update times, and
  complete chronological status history.
- **FR-007**: Status history shown to the technician MUST preserve each accepted entry's prior status,
  new status, actor, occurrence time, and reason when one was recorded.
- **FR-008**: The only technician status transitions permitted by this feature MUST be `assigned` to
  `in_progress`, `assigned` to `rejected`, `in_progress` to `completed`, and `in_progress` to
  `rejected`.
- **FR-009**: `completed` and `rejected` MUST be terminal; this feature MUST NOT reopen or otherwise
  transition a terminal ticket.
- **FR-010**: Only the ticket's current assigned technician at commit time MUST be able to perform a
  technician transition; cached assignment state or client-provided ownership MUST NOT grant access.
- **FR-011**: Rejection MUST require a non-empty, non-whitespace reason; completion and start-work
  requests MUST NOT require a rejection reason.
- **FR-012**: Every accepted technician transition MUST update the ticket status and append exactly one
  immutable history entry containing the ticket, prior status, new status, acting technician,
  occurrence time, and rejection reason when applicable.
- **FR-013**: Ticket update and history insertion MUST be atomic: any validation, authorization,
  conflict, persistence, or unexpected failure MUST leave ticket status, update time, and history
  unchanged.
- **FR-014**: The current assignment and status MUST be revalidated when the transition is committed.
- **FR-015**: Invalid or stale transitions, terminal tickets, and competing requests MUST return a
  conflict outcome that identifies safe refresh as the recovery action without overwriting newer
  state.
- **FR-016**: When simultaneous technician transitions target the same ticket state, at most one MUST
  succeed for that state and history MUST contain no duplicate accepted transition.
- **FR-017**: A request targeting another technician's ticket MUST use the same not-found status,
  public message, error shape, and materially equivalent observable behavior as a request for an
  unknown ticket.
- **FR-018**: Reporters and administrators MUST be denied the technician-specific operations unless a
  future approved specification explicitly grants that role the operation; denial MUST disclose no
  assigned-ticket data or target existence.
- **FR-019**: Missing, invalid, expired, revoked, or inactive-account authentication MUST return an
  unauthenticated outcome without assigned-ticket data.
- **FR-020**: Technician operations MUST distinguish success, empty success, validation error,
  unauthenticated, unauthorized or concealed-not-found, conflict, and unexpected failure through the
  project's consistent response structure and stable machine-readable error codes.
- **FR-021**: The assigned-ticket list experience MUST support loading, populated success, empty
  success, loading next page, unauthorized, offline, and server-error states with safe refresh and
  retry that do not duplicate rows.
- **FR-022**: The assigned-ticket detail experience MUST support loading, populated success,
  concealed-not-found or unauthorized, offline, photo-unavailable, and server-error states.
- **FR-023**: The technician transition experience MUST support ready, submitting, success,
  field-validation, unauthorized, concealed-not-found, conflict, offline, and server-error states;
  it MUST prevent concurrent duplicate submission from the same screen.
- **FR-024**: The client MUST NOT display an optimistic status change as accepted before receiving an
  authoritative success result; ambiguous offline or server outcomes and conflicts MUST refresh ticket
  and history state before another transition is offered.
- **FR-025**: A successful transition MUST refresh or update the visible detail and assigned-ticket row
  with the authoritative status and history without requiring an application restart.
- **FR-026**: User-visible errors MUST explain correctable reason or transition problems while
  excluding credentials, authorization details, stack traces, internal persistence information,
  other users' identifiers, and restricted ticket contents.
- **FR-027**: Laravel Feature Tests MUST cover technician list/detail success and emptiness, pagination,
  authentication, role denial, assignment isolation, concealed existence, every permitted transition,
  rejection-reason validation, invalid and terminal transitions, atomic rollback, competing requests,
  history immutability, and sanitized material failure behavior.
- **FR-028**: Flutter tests MUST cover contract mapping, list/detail states, stable pagination,
  assignment loss, stale results, every permitted transition, rejection validation, duplicate-submit
  prevention, authoritative refresh, concealed denial, conflict, offline, and server recovery.
- **FR-029**: This feature MUST NOT provide ticket discussions, ratings, assignment, reassignment,
  unassignment, ticket deletion, reference-data management, administrator oversight, reporter
  operations, or any status transition not listed in FR-008.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature implements only User Story 3 of the core workflow: the
  current technician privately finds assigned work and records permitted progress or terminal status
  changes with an immutable audit trail.
- **Deferred Features Check**: Ticket discussions, ratings, assignment changes, deletion,
  reference-data management, maps/GPS, QR codes, notifications, exports, analytics, offline
  synchronization, and every unsupported workflow are excluded.
- **Increment Boundary**: The smallest reviewable increment is the technician-only assigned list and
  detail with assignment isolation. Starting work follows as one independently testable transition;
  completion and rejection follow as terminal transition increments.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - Assigned-ticket list: a Laravel REST collection read protected for active technicians, accepting
    page and page-size inputs. Success returns `200` with only current assignments and pagination
    metadata, including an empty page; invalid pagination returns `422`; missing authentication returns
    `401`; and the wrong role receives a non-disclosing `403`.
  - Assigned-ticket detail: a protected technician member read. An assigned target returns `200` with
    work details and chronological history; unknown and non-assigned targets return the same concealed
    `404`; missing authentication returns `401`; and the wrong role receives a non-disclosing `403`.
  - Status transition: a protected technician member operation accepting the requested status and a
    required reason only for rejection. An accepted transition returns `200` with authoritative ticket
    status and appended history; invalid input returns `422`; missing authentication returns `401`;
    the wrong role returns a non-disclosing `403`; unknown and non-assigned targets return the same
    concealed `404`; stale, invalid, terminal, or competing transitions return `409`; and unexpected
    failure returns `500` with no partial change.
  - Success representations use the existing data and metadata envelope; errors use the existing
    error and stable-code envelope. The documented contract MUST define paths, fields, history shape,
    pagination, validation, authentication, authorization, status codes, and additive compatibility
    before Flutter integration.
- **Authorization Rules**: Laravel Sanctum authentication, active-account enforcement, technician-role
  authorization, current-assignment filtering, and commit-time current-assignee checks all apply
  server-side. Restricted targets are resolved through current assignment before any outcome can
  reveal their existence. The authenticated actor and assignment are never accepted from client data.
- **Flutter States**:
  - Assigned Tickets: loading, populated success, empty success, loading next page, unauthorized,
    offline, and server error. Pagination validation appears only when an input is rejected; conflict
    is not valid for this read and is treated as a contract/server error.
  - Assigned Ticket Details: loading, populated success, concealed-not-found or unauthorized, offline,
    photo-unavailable, and server error. Empty and conflict are not valid detail outcomes.
  - Status Transition: ready, submitting, success, field-validation, unauthorized,
    concealed-not-found, conflict requiring authoritative refresh, offline requiring authoritative
    refresh, and server error requiring authoritative refresh. Submission is disabled while a request
    is pending, and no optimistic status is trusted.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Authentication state, role, account state, pagination values, ticket
  references, requested status, rejection reason, cached assignment/status/history, and all
  client-derived ownership claims are untrusted. Ticket contents, photos, assignment, actor identity,
  and history are restricted data.
- **Failure and Recovery**: Authorization and transition validation occur against current authoritative
  state. Ticket status and immutable history commit as one outcome. Concealed, validation, conflict,
  persistence, and unexpected failures make no partial business change. After an ambiguous connection
  or server failure, the client refreshes authoritative detail/history before offering another
  transition.
- **Operational Evidence**: List/detail access denials, concealed ownership denials, accepted status
  changes, invalid transitions, conflicts, rejection validation, and unexpected failures MUST produce
  structured diagnostics with event type, outcome, timestamp, correlation identifier, acting user
  identifier when available, and ticket reference only when safe. Diagnostics MUST exclude tokens,
  descriptions, locations, photo content, rejection-reason text, credentials, and unnecessary personal
  data.
- **Quality Constraints**: Under normal connectivity, visible progress appears within 1 second and 95%
  of list, detail, and transition outcomes complete within 3 seconds. Screens use accessible labels,
  logical focus order, scalable text, and non-color-only status indicators; user-visible strings are
  localization-ready. Offline persistence, queued transitions, retention policy, and formal
  availability guarantees are outside this feature.

### Verification Requirements

- **VR-001**: Automated backend tests MUST prove ownership-first assigned-ticket listing and counts,
  stable newest-first pagination, empty results, complete owned details/history, and indistinguishable
  unknown/non-assigned detail outcomes.
- **VR-002**: Automated backend tests MUST verify only active authenticated technicians can use these
  operations and that reporters, administrators, inactive accounts, and unauthenticated requests
  receive non-disclosing outcomes.
- **VR-003**: Automated backend tests MUST verify every permitted transition and every invalid,
  terminal, stale, or non-owned transition, including rejection with missing, blank, and valid reasons.
- **VR-004**: Automated backend tests MUST prove each accepted transition updates one ticket and
  appends exactly one immutable history entry atomically, while injected failures leave status, update
  time, and history unchanged.
- **VR-005**: Automated backend tests MUST prove competing transitions accept at most one transition
  for the same starting state and never duplicate history.
- **VR-006**: Automated backend tests MUST verify stable envelopes/error codes and sanitized
  diagnostics for success, validation, authentication, authorization, concealed targets, conflicts,
  and unexpected failures.
- **VR-007**: Flutter tests MUST verify strict contract mapping, all applicable screen states,
  pagination de-duplication, stale-result suppression, assignment loss, every transition, reason
  validation, duplicate-submit prevention, authoritative refresh, concealed denial, and offline/server
  recovery without optimistic status.

### Key Entities *(include if feature involves data)*

- **Technician**: An authenticated active user with the technician role who may see and process only
  tickets for which that user is the current assignee.
- **Ticket**: An assigned maintenance issue with immutable reference and submitted details, current
  assigned technician, current status, timestamps, photos, and chronological status history.
- **Assignment**: The current responsibility relationship used as the authorization boundary for
  technician list, detail, and transition operations; this feature does not change it.
- **Status History**: An append-only chronological record of every accepted assignment and status
  transition, including prior status, new status, actor, time, and reason when recorded.
- **Rejection Reason**: Required non-blank text preserved on the immutable history entry for an
  accepted transition to `rejected`; it does not create a discussion or editable note.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of representative technicians can locate and open a recently assigned
  ticket in 30 seconds or less without assistance.
- **SC-002**: In 100% of authorization and privacy tests, technicians receive only their current
  assignments, other roles cannot use technician operations, and non-assigned targets cannot be
  distinguished from unknown targets.
- **SC-003**: In 100% of accepted transition tests, exactly one ticket reaches the requested permitted
  status and exactly one immutable history entry records the correct prior status, new status, actor,
  time, and rejection reason when applicable.
- **SC-004**: In 100% of invalid, stale, terminal, competing, unauthorized, concealed, and failure
  tests, ticket status, update time, assignment, and history remain free of partial or duplicate
  changes.
- **SC-005**: At least 95% of representative technicians can start, complete, or reject eligible work
  in one minute or less, including supplying a rejection reason when required.
- **SC-006**: Technicians can traverse all currently assigned tickets in stable newest-first pages with
  zero missing, duplicated, or cross-technician results in acceptance tests.
- **SC-007**: Under normal connectivity, 95% of users see progress within 1 second and receive a list,
  detail, validation, conflict, or transition outcome within 3 seconds.
- **SC-008**: All applicable loading, populated, empty, validation, unauthorized,
  concealed-not-found, conflict, offline, photo-unavailable, and server-error journeys pass acceptance
  testing without false success, restricted-data leakage, or unsafe retry.
- **SC-009**: Zero discussion, rating, assignment/reassignment/unassignment, deletion,
  reference-management, unsupported-status, map, notification, or export controls or operations are
  exposed by this feature.

## Assumptions

- Existing Sanctum authentication, active-account enforcement, reporter/technician/administrator
  roles, canonical response envelopes, reporter ticket creation, and initial one-time administrator
  assignment are available and authoritative from earlier features.
- Initial assignment has already moved a ticket from `new` to `assigned`, set exactly one current
  technician, and recorded the assignment in immutable history before this feature begins.
- Current assignment remains attached when a ticket becomes `in_progress`, `completed`, or `rejected`,
  so the current assigned technician retains access to that work record; changing or removing the
  assignment is explicitly outside this feature.
- Rejection is available from `assigned` or `in_progress` and requires a reason, as defined by the core
  specification. Completion is available only from `in_progress`. Terminal tickets cannot be reopened.
- Ticket details reuse already approved submitted fields and authorized photo representations; this
  feature does not add, edit, delete, or reclassify ticket content or photos.
- A default page size of 20 and maximum of 100 follow existing ticket-list conventions; search,
  filtering, sorting choices, and offline caching are not included.
- Timestamps preserve the project's unambiguous chronological representation and are localized only
  for display.
