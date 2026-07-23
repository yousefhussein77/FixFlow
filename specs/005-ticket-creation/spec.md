# Feature Specification: Reporter Ticket Creation and Tracking

**Feature Branch**: `005-ticket-creation` (branch creation not performed; no hook configured)

**Created**: 2026-07-23

**Status**: Draft

**Input**: Create a focused reporter-only maintenance ticket creation and personal tracking feature,
including validated classification and photos, private newest-first ticket lists, ticket details,
REST operations, Flutter experiences, and complete failure-state handling.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a Maintenance Ticket (Priority: P1)

As an authenticated reporter, I can describe a maintenance issue, classify it using active options,
optionally attach up to five photos, and submit it so that the issue has a durable reference I can
use to track it.

**Why this priority**: Ticket creation is the feature's essential value and the entry point to the
maintenance workflow.

**Independent Test**: Authenticate as a reporter, load active departments and categories, submit
valid tickets with zero and five photos, and confirm each ticket is owned by the reporter, starts as
`new`, and has a unique human-readable reference and creation time.

**Acceptance Scenarios**:

1. **Given** an authenticated active reporter and valid required values, **When** the reporter
   submits a ticket without photos, **Then** exactly one ticket is created with a unique reference,
   reporter ownership, creation timestamp, and initial `new` status.
2. **Given** an authenticated active reporter and five valid photos, **When** the reporter submits a
   valid ticket, **Then** the ticket and all five photos are created together and the success view
   identifies the new ticket.
3. **Given** active and inactive reference data, **When** the reporter loads creation options,
   **Then** only active departments and active categories belonging to the selected active department
   can be selected.
4. **Given** an invalid, inactive, or mismatched department/category selection, **When** creation is
   submitted, **Then** field-specific validation is returned and no ticket or photo record is created.
5. **Given** more than five photos, an unsupported photo type, or a photo larger than 10 MB, **When**
   the reporter selects or submits the photos, **Then** the problem is identified clearly and no
   invalid ticket submission is accepted.
6. **Given** a photo cannot be stored or another creation step fails, **When** submission is
   processed, **Then** no partial ticket or photo record remains and the reporter receives a
   recoverable error without a false success.

---

### User Story 2 - List My Tickets (Priority: P2)

As an authenticated reporter, I can browse only the tickets I created in newest-first pages so that
I can find and track my reported issues.

**Why this priority**: Personal tracking makes submitted tickets useful after creation while remaining
independently testable using existing ticket records.

**Independent Test**: Create tickets for two reporters at distinct times, list each reporter's pages,
and verify stable newest-first ordering, pagination metadata, empty behavior, and complete ownership
isolation.

**Acceptance Scenarios**:

1. **Given** a reporter owns multiple tickets, **When** the reporter opens My Tickets, **Then** only
   that reporter's tickets are shown in stable newest-first order.
2. **Given** more owned tickets than fit on one page, **When** the reporter requests successive pages,
   **Then** pagination metadata and non-overlapping results allow the full owned set to be traversed.
3. **Given** a reporter owns no tickets, **When** My Tickets loads, **Then** a successful empty state
   invites the reporter to create a ticket.
4. **Given** another reporter has newer tickets, **When** the current reporter lists tickets, **Then**
   those tickets and their existence are not disclosed or counted in pagination.
5. **Given** the device is offline or the service fails, **When** the list is requested, **Then** the
   reporter sees the appropriate recoverable state and can retry without duplicated or stale rows.

---

### User Story 3 - View My Ticket Details (Priority: P3)

As an authenticated reporter, I can open one of my tickets and see its full submitted details and
current status so that I understand what was recorded and can track its current state.

**Why this priority**: Detail visibility completes personal tracking but is useful only after tickets
can be created and found.

**Independent Test**: Open an owned ticket and verify all specified fields, photos, and timestamps;
then attempt the same operation as another reporter and as other roles and compare concealed denial
behavior against an unknown reference.

**Acceptance Scenarios**:

1. **Given** an owned ticket, **When** its reporter opens it, **Then** the reference, title,
   description, current status, department, category, priority, location, photos, and timestamps are
   displayed.
2. **Given** a ticket belongs to another reporter, **When** the current reporter requests it, **Then**
   access is denied using behavior indistinguishable from a ticket that does not exist.
3. **Given** an unauthenticated session, **When** ticket details are requested, **Then** authentication
   is required and no ticket data is returned.
4. **Given** an offline device or service failure, **When** details are requested, **Then** the screen
   distinguishes the failure, retains no newly trusted restricted data, and offers a safe retry.

### Edge Cases

- Required text containing only whitespace is rejected; accepted text is trimmed at its boundaries.
- A category is changed, moved, or deactivated after options load but before submission; creation
  revalidates current department/category state and rejects the stale selection atomically.
- A department becomes inactive while one of its categories remains active; neither is selectable
  for a new ticket.
- The same submission is sent twice because of a retry or rapid tap; the client prevents concurrent
  submission, and the service detects a repeated submission token so no duplicate ticket is created.
- Two tickets are created at the same instant; their human-readable references remain unique and list
  ordering uses a stable tie-breaker.
- A photo has an allowed filename extension but invalid, corrupt, or mismatched content; it is
  rejected based on verified content.
- The combined upload is interrupted after some bytes or photos arrive; temporary data is cleaned up
  and no durable partial ticket or photo record remains.
- Pagination requests use missing, malformed, negative, zero, excessive, or out-of-range values;
  invalid values receive validation errors and an out-of-range valid page returns an empty page.
- A ticket is created between page requests; each returned page remains internally stable and free
  of duplicates, while a refresh starts again from the newest current result set.
- A reporter account becomes inactive or its session is revoked after a screen loads; the next
  protected operation is rejected without exposing additional data.
- A photo representation is unavailable after ticket creation; details remain usable, identify the
  unavailable photo safely, and allow retry without treating the ticket as missing.
- Conflict, unauthorized, offline, and server failures never appear as an empty list or successful
  creation.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Only an authenticated user with an active reporter role MUST be able to use ticket
  creation, My Tickets, and reporter ticket-detail operations.
- **FR-002**: Ticket creation MUST accept title, description, department, category, priority,
  location text, and zero to five optional photos.
- **FR-003**: Title, description, department, category, priority, and location text MUST be required;
  required text containing only whitespace MUST be rejected.
- **FR-004**: Priority MUST accept exactly `low`, `medium`, `high`, or `urgent`.
- **FR-005**: The selected department and category MUST exist and be active at the time creation is
  committed, and the category MUST belong to the selected department.
- **FR-006**: Creation MUST reject more than five photos, any photo larger than 10 MB, and any photo
  whose verified content is not JPEG, PNG, or WebP.
- **FR-007**: Every successfully created ticket MUST receive a unique, immutable, human-readable
  reference suitable for display and support communication.
- **FR-008**: Every successfully created ticket MUST record the authenticated reporter as owner, the
  creation timestamp, and initial status `new`; clients MUST NOT be able to override these values.
- **FR-009**: Ticket creation and durable photo association MUST be atomic: any validation, storage,
  conflict, authorization, or unexpected failure MUST leave no new ticket or photo records.
- **FR-010**: A repeated submission carrying the same reporter-scoped submission token MUST return
  the original successful result or a conflict-safe outcome and MUST NOT create a duplicate ticket.
- **FR-011**: Authenticated reporters MUST be able to load active department options and active
  category options scoped to one selected active department.
- **FR-012**: Changing the selected department MUST clear any category selection that does not belong
  to the new department before submission is allowed.
- **FR-013**: Reporters MUST be able to list only tickets they own; ownership filtering MUST occur
  before counts, pagination, or ticket data are produced.
- **FR-014**: My Tickets MUST support pagination with a default page size of 20 and maximum page size
  of 100, and MUST return stable newest-first ordering using creation time and a unique tie-breaker.
- **FR-015**: Each My Tickets item MUST provide enough summary information to identify and open the
  ticket, including reference, title, current status, priority, department, category, and creation
  timestamp.
- **FR-016**: Reporters MUST be able to view details only for tickets they own.
- **FR-017**: Ticket details MUST include reference, title, description, current status, department,
  category, priority, location text, photos, creation timestamp, and last-updated timestamp.
- **FR-018**: A reporter request targeting another reporter's ticket MUST use the same not-found
  status, public message, error shape, and materially equivalent observable behavior as a request for
  an unknown ticket.
- **FR-019**: Technicians and administrators MUST be denied reporter creation, My Tickets, and
  reporter-detail operations unless a future approved specification explicitly grants that role the
  operation; denial MUST not disclose ticket existence.
- **FR-020**: Missing, invalid, expired, revoked, or inactive-account authentication MUST return an
  unauthenticated result without ticket or option data.
- **FR-021**: All operations MUST distinguish success, validation error, unauthenticated,
  unauthorized or concealed-not-found, conflict, and server-error outcomes using the project's
  consistent response structure and stable machine-readable error codes.
- **FR-022**: The create-ticket experience MUST support idle, option-loading, ready, photo-validation,
  submitting, success, field-validation, unauthorized, offline, conflict, and server-error states and
  MUST prevent duplicate submission while submitting.
- **FR-023**: My Tickets MUST support loading, populated success, empty success, unauthorized,
  offline, and server-error states, plus safe pagination loading and retry without duplicate items.
- **FR-024**: Ticket Details MUST support loading, populated success, concealed-not-found or
  unauthorized, offline, photo-unavailable, and server-error states.
- **FR-025**: Department/category option loading MUST support loading, populated success, empty
  success, validation, unauthorized, offline, and server-error states; stale responses MUST not
  restore a category for a previously selected department.
- **FR-026**: Flutter photo selection MUST enforce count, verified supported type, and per-photo size
  before submission when the device can determine them, while server validation remains authoritative.
- **FR-027**: User-visible error messages MUST identify correctable fields or photos, preserve safe
  form input for retry where possible, and MUST NOT expose storage paths, stack traces, credentials,
  other users' identifiers, or ticket-existence clues.
- **FR-028**: Laravel MUST expose documented REST operations for creation, owned paginated listing,
  owned detail, active department options, and department-scoped active category options.
- **FR-029**: Laravel Feature Tests MUST cover every primary success path, validation boundary,
  unauthenticated case, role denial, ownership rule, concealed existence behavior, atomic rollback,
  duplicate-submission behavior, pagination rule, and material failure described by this specification.
- **FR-030**: Flutter tests MUST cover state transitions, contract mapping, photo validation, stale
  option responses, duplicate-submit prevention, pagination, authorization loss, offline recovery,
  conflict handling, and server errors for the three screens.
- **FR-031**: This feature MUST NOT provide assignment, technician status changes, comments, ratings,
  ticket editing or deletion, post-creation photo addition, maps/GPS, notifications, or export.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature delivers the reporter intake and personal tracking
  slice of the core maintenance workflow: valid issue submission followed by private list and detail
  access.
- **Deferred Features Check**: Assignment, technician status updates, comments, ratings, editing,
  deletion, post-creation photos, maps, GPS, notifications, PDF/spreadsheet export, QR codes, and
  analytics are excluded.
- **Increment Boundary**: The smallest reviewable increment is valid reporter ticket creation without
  photos, including authorization, classification validation, atomic persistence, REST behavior,
  Flutter form states, and tests. Optional photos, My Tickets, and Ticket Details follow as separate
  independently verifiable increments.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - Create ticket: authenticated reporter collection operation accepting the specified fields,
    optional photos, and a reporter-scoped submission token. Success returns `201`; validation `422`;
    unauthenticated `401`; wrong role `403`; repeated/conflicting submission `409` when the original
    result cannot be safely replayed; unexpected failure `500`.
  - My Tickets: authenticated reporter collection read with page and page-size inputs. Success returns
    `200` with owned summaries and pagination metadata, including an empty page; invalid pagination
    returns `422`; unauthenticated `401`; wrong role `403`.
  - Ticket Details: authenticated reporter member read. Owned success returns `200`; unknown and
    non-owned targets both return the same concealed `404`; unauthenticated returns `401`; wrong role
    receives a non-disclosing `403`.
  - Active departments and department-scoped categories: authenticated reporter option reads return
    `200`, including empty collections; an invalid or inactive department scope returns `422`;
    authentication/role failures return `401`/`403`.
  - Success representations use the existing data/metadata envelope; errors use the existing
    error/code envelope. Contracts document fields, file rules, timestamps, reference format,
    pagination, authentication, authorization, status codes, and compatibility expectations before
    client integration.
- **Authorization Rules**: Laravel Sanctum authentication and active-account checks apply to every
  operation. Server-side role and ownership policies are authoritative. Reporter ownership is derived
  from the authenticated principal, never client input. Authorization occurs before resolving a
  restricted ticket in a way that could reveal its existence.
- **Flutter States**:
  - Create Ticket: idle, loading options, ready, submitting, success, validation error, unauthorized,
    offline, conflict, and server error. Empty applies to option collections and blocks submission
    with guidance; it is not a creation result.
  - My Tickets: loading, populated success, empty success, loading next page, unauthorized, offline,
    and server error. Validation is applicable only to rejected pagination inputs; conflict does not
    apply to this read and any such response is treated as a contract/server error.
  - Ticket Details: loading, populated success, concealed-not-found/unauthorized, offline,
    photo-unavailable, and server error. Empty and conflict are not valid detail-read outcomes and are
    treated as contract/server errors.
  - Active options: loading, populated success, empty success, validation for department scope,
    unauthorized, offline, and server error. Conflict does not apply to these reads.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Untrusted inputs include all text, identifiers, priority, pagination values,
  submission tokens, photo names/metadata/content, authentication credentials, and client-derived
  ownership data. Photos cross a file-content boundary and require content verification. Ticket and
  reporter identifiers are private data subject to ownership checks.
- **Failure and Recovery**: Validation occurs before durable creation where possible, and ticket/photo
  persistence completes as one atomic outcome. Temporary uploads are removed after failed or abandoned
  creation. Safe retry uses the same submission token to prevent duplication. Read retries replace or
  extend results only when they match the current screen, filter, page, and authentication context.
  Conflict recovery explains whether the reporter should refresh or retry without silently changing
  submitted fields.
- **Operational Evidence**: Creation success/failure, validation denial, authentication/authorization
  denial, concealed ownership denial, duplicate submission, photo-storage failure, and unexpected
  errors produce structured diagnostics with event type, outcome, timestamp, correlation identifier,
  authenticated actor identifier when available, and ticket reference only when safe. Diagnostics
  exclude tokens, raw photo content, full descriptions, location text, authorization headers, and
  unnecessary personal data.
- **Quality Constraints**: Under normal connectivity, visible progress appears within 1 second and
  95% of option, list, detail, and creation outcomes complete within 3 seconds after uploads finish.
  Screens support accessible labels, logical focus order, text scaling, and non-color-only state
  indicators. User-visible strings are localization-ready. Ticket/photo retention, offline creation
  or caching, and formal availability guarantees are outside this feature and require a future data
  governance or offline specification; transient form values are retained only long enough for safe
  retry during the active session.

### Verification Requirements

- **VR-001**: Automated backend tests MUST verify valid creation with zero through five photos and
  every field, relationship, role, photo type, photo size, and photo count validation boundary.
- **VR-002**: Automated backend tests MUST prove all failed creation paths leave ticket and photo
  counts and durable files unchanged, including simulated failure after partial photo processing.
- **VR-003**: Automated backend tests MUST prove references are unique and human-readable and that
  reporter ownership, server timestamps, and `new` status cannot be supplied or overridden by clients.
- **VR-004**: Automated backend tests MUST verify reporter-only list/detail access, ownership-filtered
  counts, stable newest-first pagination, and indistinguishable unknown/non-owned detail responses.
- **VR-005**: Automated backend tests MUST verify active-option filtering and submission-time
  revalidation when reference data changes after option loading.
- **VR-006**: Automated backend tests MUST verify repeat submission safety, unauthenticated and
  inactive-account behavior, technician/administrator denial, consistent envelopes, and sanitized
  material error behavior.
- **VR-007**: Flutter tests MUST verify all applicable screen and option states, photo-validation
  feedback, form preservation, duplicate-submit prevention, stable pagination, stale-result rejection,
  safe ownership-denial display, and offline/server recovery.

### Key Entities *(include if feature involves data)*

- **Ticket**: A reporter-owned maintenance issue with immutable human-readable reference, title,
  description, selected department and category, priority, location text, current status, creation
  timestamp, update timestamp, and zero to five photos. It begins in `new` status.
- **Ticket Photo**: An immutable creation-time attachment belonging to exactly one ticket, with safe
  display identity, verified JPEG/PNG/WebP type, size no greater than 10 MB, ordering, and timestamps.
- **Reporter**: An authenticated active user role that owns created tickets and is the only role
  permitted by this feature to create, list, and view through reporter operations.
- **Department**: An organizational classification option. It must be active to be selected and owns
  zero or more categories.
- **Category**: A classification belonging to exactly one department. It is selectable only when it
  and its department are active.
- **Submission Token**: A reporter-scoped, single-creation identifier used to recognize safe retries
  and prevent accidental duplicate tickets.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of representative reporters can create a valid ticket without assistance
  on their first attempt in under 3 minutes, excluding photo transfer time.
- **SC-002**: In 100% of validation tests, inactive or mismatched classifications and invalid photo
  count, type, or size are rejected with actionable feedback and no partial records.
- **SC-003**: In 100% of authorization and privacy tests, reporters receive only their own ticket data,
  other roles cannot use reporter operations, and a non-owned ticket cannot be distinguished from an
  unknown ticket.
- **SC-004**: In 100% of successful creation tests, exactly one ticket receives a unique readable
  reference, correct reporter ownership, a creation time, and initial `new` status.
- **SC-005**: In 100% of failure and retry tests, no orphan ticket/photo records or duplicate tickets
  remain after interrupted, failed, or repeated creation attempts.
- **SC-006**: Reporters can find any owned ticket by traversing pages ordered newest first, with zero
  missing or duplicate tickets in stable-result pagination tests.
- **SC-007**: At least 95% of representative reporters can locate and open a recently created ticket
  from My Tickets in under 30 seconds.
- **SC-008**: Under normal connectivity, 95% of users see loading feedback within 1 second and option,
  list, detail, or non-upload processing results within 3 seconds.
- **SC-009**: All applicable loading, success, empty, validation-error, unauthorized, offline,
  conflict, photo-unavailable, and server-error journeys pass acceptance testing without false success,
  restricted-data leakage, or loss of safely retryable form input.
- **SC-010**: Zero assignment, technician status-update, comment, rating, edit, delete, post-creation
  photo, map/GPS, notification, or export controls are exposed by this feature.

## Assumptions

- Existing Sanctum authentication, active-account enforcement, reporter/technician/administrator
  roles, response envelopes, and active department/category option data from earlier features are
  available and authoritative.
- The user-provided name `005-ticket-creation` identifies the intended feature directory and future
  branch name; this command does not create or switch branches because no branch hook is configured.
- Title, description, and location length limits and the precise human-readable reference pattern
  will be documented in the REST contract during planning, using existing project conventions;
  limits will preserve ordinary maintenance descriptions and be enforced consistently.
- Photos are immutable attachments supplied only during initial creation. Their original binaries are
  not embedded in list results; details provide authorized display access.
- Timestamps use the project's canonical unambiguous time representation and are localized for display
  by the client.
- A default page size of 20 and maximum of 100 are suitable for Version 1; search and filtering beyond
  newest-first pagination are out of scope.
- Offline means the application detects that the requested remote operation cannot currently complete;
  offline ticket drafting, queued submission, and durable offline caching are not included.
- Ticket and photo retention/deletion policy is governed outside this feature because editing and
  deleting tickets are explicitly excluded.
