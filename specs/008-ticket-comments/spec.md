# Feature Specification: Ticket Comments

**Feature Branch**: Not created (no branch hook configured)

**Created**: 2026-07-23

**Status**: Draft

**Input**: User Story 4 of the core ticket workflow: authorized reporters, currently assigned
technicians, and administrators can read and add immutable plain-text comments to maintenance tickets
without expanding ticket processing or collaboration scope.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Discuss My Reported Ticket (Priority: P1)

As a reporter, I can read and add comments on a ticket I created so that questions, clarifications,
and work updates remain connected to my maintenance request.

**Why this priority**: The reporter initiated the maintenance record and needs a durable, private way
to exchange context with the people handling it.

**Independent Test**: Create tickets for two reporters, add comments to each, and verify that the
authenticated reporter can list and add comments only on their own ticket. Repeat with an unknown and
another reporter's reference to prove both are concealed identically and no failed request creates a
comment.

**Acceptance Scenarios**:

1. **Given** a reporter viewing their own ticket, **When** they open its comments, **Then** all
   authorized comments appear in chronological order with original content, author identity, and
   creation time.
2. **Given** a reporter viewing their own ticket, **When** they submit a non-empty plain-text comment,
   **Then** exactly one comment is preserved and appears at the correct chronological position.
3. **Given** an unrelated reporter, **When** they attempt to list or add comments on another
   reporter's ticket, **Then** the target is concealed as not found and no ticket or comment contents
   are disclosed.
4. **Given** a reporter whose comment submission has an ambiguous connection failure, **When** the
   same submission is safely retried, **Then** the original accepted attempt is returned or recognized
   without creating a duplicate comment.

---

### User Story 2 - Discuss Currently Assigned Work (Priority: P1)

As the technician currently assigned to a ticket, I can read and add comments so that questions and
work notes are visible to the reporter and authorized oversight staff.

**Why this priority**: Technician participation is the operational half of the discussion and is
equally necessary for comments to reduce coordination gaps.

**Independent Test**: Assign a ticket to one technician, exchange comments with the reporter, and
verify the assigned technician sees the shared chronology and can add one comment. Change the current
assignment through separately approved behavior and prove the former technician immediately loses
both list and add access without comment disclosure.

**Acceptance Scenarios**:

1. **Given** the ticket's current assigned technician, **When** they list comments, **Then** they see
   the same chronological authorized discussion as the reporter.
2. **Given** the ticket's current assigned technician, **When** they submit a non-empty plain-text
   comment, **Then** exactly one immutable comment is added with that technician as author.
3. **Given** a technician who is not or is no longer the current assignee, **When** they attempt to
   list or add comments, **Then** the ticket is concealed as not found and no comment data or existence
   information is exposed.
4. **Given** assignment changes after the technician loads the discussion, **When** the technician
   submits a comment, **Then** current assignment is rechecked, the submission is concealed, and no
   comment is created.

---

### User Story 3 - Oversee Ticket Discussion (Priority: P2)

As an administrator, I can read and add comments on tickets under administrative oversight so that I
can clarify work and maintain operational visibility without taking over reporter or technician
identity.

**Why this priority**: Oversight supports resolution and accountability, but the reporter-technician
discussion provides the primary collaboration value independently.

**Independent Test**: Authenticate as an administrator, open tickets belonging to different
reporters and technicians, list each discussion, and add an administrator-authored comment. Verify an
unknown target is not found, failed submissions create nothing, and administrator access does not
alter assignment or ticket status.

**Acceptance Scenarios**:

1. **Given** an active administrator and an existing ticket within administrative oversight, **When**
   they list comments, **Then** the complete chronological discussion is visible with each original
   author and creation time.
2. **Given** an active administrator and an existing ticket within administrative oversight, **When**
   they add a valid comment, **Then** exactly one immutable administrator-authored comment is appended.
3. **Given** an administrator requesting an unknown ticket, **When** they list or add comments,
   **Then** a clear not-found outcome is returned and no comment is created.
4. **Given** a reporter or technician, **When** they attempt to use administrator-specific navigation
   or authorization claims, **Then** no broader comment access is granted.

### Edge Cases

- Comment content is missing, empty, or contains only whitespace; validation identifies the content
  field and creates no comment.
- Comment content contains line breaks, punctuation, or text resembling markup; it remains plain text,
  preserves the submitted meaning, and is never interpreted as executable or formatted content.
- An author's name, role, or active state changes later; existing comments retain their original
  content, author relationship, and creation time and remain visible only through current ticket
  authorization.
- Assignment changes between loading comments and adding one; the add operation rechecks the current
  assignment and creates nothing for the former technician.
- An account becomes inactive or loses its authorized role after comments are loaded; the next
  protected operation is rejected and the active client workflow clears restricted comment data.
- Two comments are accepted at the same recorded time; a stable secondary order ensures every
  authorized client sees a deterministic chronology without omissions or duplicates.
- A valid comment is submitted twice with the same retry identity after an ambiguous outcome; at most
  one comment is created, while two intentional comments with distinct retry identities remain
  separate even when their text is identical.
- A valid comment write fails before completion; no partial comment is visible and a safe retry can
  determine whether the original attempt was accepted.
- A ticket has no comments; authorized users receive an empty successful discussion rather than a
  not-found or error state.
- Connectivity fails while listing or adding comments; entered text is preserved locally when safe,
  restricted cached comments are not exposed after authorization loss, and retry does not falsely
  claim success.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Only authenticated active reporters, technicians, and administrators MUST be able to use
  ticket-comment operations.
- **FR-002**: A reporter MUST be able to list and add comments only for a ticket whose reporter is the
  authenticated reporter.
- **FR-003**: A technician MUST be able to list and add comments only while that technician is the
  ticket's current assigned technician.
- **FR-004**: An administrator MUST be able to list and add comments for existing tickets within the
  administrator's approved oversight scope.
- **FR-005**: Comment authorization MUST be derived from the authenticated actor and current ticket
  ownership, assignment, or oversight state; client-provided author, role, ownership, or assignment
  claims MUST NOT grant access.
- **FR-006**: Current technician assignment MUST be revalidated when a comment is read and when a new
  comment is committed.
- **FR-007**: Unknown and unauthorized ticket targets for reporters and technicians MUST return the
  same not-found status, public message, error shape, and materially equivalent observable behavior.
- **FR-008**: A concealed failure MUST NOT disclose ticket existence, comment existence or count,
  comment content, authors, timestamps, assignment, reporter identity, or other restricted ticket
  information.
- **FR-009**: Authorized users MUST be able to list all comments for one authorized ticket in stable
  oldest-first chronological order, using a deterministic order when creation times are equal.
- **FR-010**: An empty authorized discussion MUST return a successful empty result.
- **FR-011**: Every comment representation MUST contain its stable identifier, original plain-text
  content, author identity sufficient for an authorized participant to understand who wrote it,
  author role, and unambiguous creation time.
- **FR-012**: Adding a comment MUST require non-empty, non-whitespace plain-text content and MUST reject
  malformed, unsupported, or excessive input according to a documented maximum established during
  planning.
- **FR-013**: Comment content MUST be treated and displayed strictly as plain text; markup, scripts,
  links, mentions, or other text-like sequences MUST NOT gain executable or interactive semantics.
- **FR-014**: An accepted add operation MUST preserve the authenticated actor as author, the original
  validated content, and the authoritative creation time in exactly one new comment.
- **FR-015**: Comment author identity, creation time, and original content MUST be immutable after
  creation; this feature MUST expose no edit or delete operation.
- **FR-016**: Comment creation MUST be atomic: validation, authorization, assignment loss,
  persistence, or unexpected failure MUST leave no partial comment record or externally visible
  partial outcome.
- **FR-017**: Every add attempt MUST carry a client-generated retry identity scoped to the
  authenticated actor and ticket; replaying the same identity MUST return the original accepted
  comment without creating a duplicate, while a different identity represents a distinct intentional
  comment even if the content matches.
- **FR-018**: Concurrent submissions using the same retry identity MUST create at most one comment and
  return the same authoritative accepted result to successful callers.
- **FR-019**: A successful add response MUST return the authoritative created comment so the visible
  chronology can update without an application restart or an optimistic fabricated comment.
- **FR-020**: Missing, invalid, expired, revoked, or inactive-account authentication MUST return an
  unauthenticated outcome without ticket or comment data.
- **FR-021**: Comment operations MUST distinguish success, empty success, validation failure,
  unauthenticated, wrong-role or concealed-not-found, retry replay, and unexpected failure through the
  project's consistent response structure and stable machine-readable codes where applicable.
- **FR-022**: The reporter comment experience MUST support loading, populated success, empty success,
  submitting, validation, concealed-not-found, unauthorized, offline, and server-error states while
  preserving safe unsent text and clearing restricted data after access loss.
- **FR-023**: The technician comment experience MUST support the same applicable states and MUST
  refresh or leave the discussion when current assignment is lost.
- **FR-024**: The administrator comment experience MUST support loading, populated success, empty
  success, submitting, validation, not-found, unauthorized, offline, and server-error states across
  tickets within oversight.
- **FR-025**: Comment clients MUST prevent concurrent duplicate submission from one screen, MUST NOT
  display an optimistic comment as accepted, and MUST reconcile an ambiguous add outcome using its
  retry identity before offering an unsafe retry.
- **FR-026**: User-visible errors MUST explain correctable content or connection problems without
  credentials, authorization internals, stack traces, persistence details, restricted ticket data, or
  comment content belonging to an inaccessible ticket.
- **FR-027**: Automated backend verification MUST cover authorized reporter, current-technician, and
  administrator list/add behavior; empty and chronological lists; content validation; immutable
  fields; concealment; assignment loss; atomic failure; retry replay; concurrent duplicate attempts;
  canonical responses; and sanitized material failures.
- **FR-028**: Automated Flutter verification MUST cover strict comment-contract mapping and reporter,
  technician, and administrator loading, populated, empty, submission, validation, access-loss,
  concealed/not-found, offline, server, retry, restricted-data clearing, and duplicate-submit states.
- **FR-029**: This feature MUST NOT provide real-time chat, comment editing, comment deletion, comment
  attachments, mentions, reactions, typing indicators, push notifications, ticket assignment or
  reassignment, ticket status processing, ratings, or any unsupported workflow.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature implements only User Story 4 of the core workflow by
  attaching durable plain-text discussion to a maintenance ticket for its reporter, current assigned
  technician, and administrator oversight.
- **Deferred Features Check**: Real-time delivery, editing, deletion, attachments, mentions,
  reactions, presence and typing signals, notifications, maps/GPS, QR codes, exports, analytics,
  assignment changes, status processing, ratings, and unsupported collaboration features are excluded.
- **Increment Boundary**: The smallest independently reviewable increment is authorized chronological
  comment viewing. Reporter comment creation, technician comment creation with current-assignment
  checks, and administrator oversight creation can then be verified independently against the same
  immutable comment contract.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - Comment list: a protected ticket-member collection read for an authorized reporter, current
    assigned technician, or administrator. Authorized success returns `200` with an oldest-first
    collection, including an empty collection. Missing authentication returns `401`; an authenticated
    actor with no applicable comment role receives a non-disclosing `403`; unknown and concealed
    reporter/technician targets return materially identical `404` outcomes; unexpected failure returns
    a sanitized `500`.
  - Comment add: a protected ticket-member creation accepting plain-text content and a retry identity.
    A new accepted comment returns `201`; replay of the same accepted retry identity returns `200` with
    the original authoritative comment; invalid content or request shape returns `422`; authentication,
    authorization, concealment, and unexpected failures follow the list rules and create no comment.
  - Success uses the existing data envelope; errors use the existing error and stable-code envelope.
    Planning MUST document exact paths, request fields and limits, response schemas, authorization
    precedence, retry semantics, status codes, and additive compatibility before client work.
- **Authorization Rules**: Authentication and active-account checks precede role and ticket-level
  authorization. Reporter ownership, current technician assignment, or administrator oversight is
  evaluated server-side for every operation. Author identity is always the authenticated actor.
  Reporter and technician restricted targets are concealed before comment data, counts, or authors
  can influence a response.
- **Flutter States**:
  - Reporter Comments: loading, populated success, empty success, submitting, field validation,
    concealed-not-found, unauthorized/session loss, offline, ambiguous-submit reconciliation, and
    server error.
  - Technician Comments: all reporter states plus assignment-loss handling that clears restricted
    comments and returns to an authorized workflow.
  - Administrator Comments: loading, populated success, empty success, submitting, field validation,
    explicit unknown-ticket not-found, unauthorized/session loss, offline, ambiguous-submit
    reconciliation, and server error.
  - All roles preserve safe entered text after correctable failure, disable duplicate submission,
    render content as plain text, and add only authoritative accepted comments to the visible list.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Authentication state, account activity, role, ticket reference, reporter
  ownership, current assignment, oversight scope, comment content, retry identity, cached comments,
  and client-derived author or authorization claims are untrusted. Ticket and comment existence,
  content, authors, timestamps, reporter identity, and assignment are restricted data.
- **Failure and Recovery**: Authorization is evaluated against current ticket state for every read and
  at comment commit time. Validation, concealment, authorization loss, persistence failure, and
  unexpected failure create no partial comment. A retry identity distinguishes safe replay from a new
  intentional comment and lets ambiguous outcomes reconcile without duplication.
- **Operational Evidence**: Comment-list and add decisions, concealed targets, validation categories,
  retry replays, assignment loss, accepted creation, and unexpected failures MUST produce structured
  diagnostics with event type, outcome, timestamp, correlation identifier, acting user identifier
  when available, and ticket reference only when safe. Diagnostics MUST exclude tokens, credentials,
  ticket descriptions, locations, photos, comment content, and unnecessary personal data.
- **Quality Constraints**: Under normal connectivity, visible progress appears within 1 second and 95%
  of comment list/add outcomes complete within 2 seconds. Comment screens use accessible labels,
  logical focus order, scalable text, non-color-only states, and localization-ready surrounding UI;
  user-authored content is preserved rather than translated. Formal availability guarantees,
  background synchronization, offline queued creation, and a new retention policy are outside scope.

### Verification Requirements

- **VR-001**: Automated backend tests MUST prove reporters list and add comments only on their own
  tickets and that unknown and other-owned targets have indistinguishable concealed outcomes.
- **VR-002**: Automated backend tests MUST prove technicians list and add comments only while currently
  assigned, including assignment loss between read and commit, with no restricted disclosure or write.
- **VR-003**: Automated backend tests MUST prove administrators can list and add comments across their
  oversight scope without changing ticket ownership, assignment, or status.
- **VR-004**: Automated backend tests MUST verify empty and stable chronological lists, exact comment
  fields, plain-text preservation, required-content validation, immutable original content, and the
  absence of edit, delete, attachment, and real-time operations.
- **VR-005**: Automated backend tests MUST prove atomic creation, same-identity replay, concurrent
  duplicate suppression, distinct-identity identical comments, and safe reconciliation after an
  injected ambiguous or persistence failure.
- **VR-006**: Automated backend tests MUST verify stable envelopes and sanitized diagnostics for
  success, validation, authentication, role denial, concealed targets, retry replay, assignment loss,
  and unexpected failure.
- **VR-007**: Flutter tests MUST verify strict contract parsing and all applicable reporter,
  technician, and administrator list/add states, safe text preservation, duplicate-submit prevention,
  retry reconciliation, assignment/session loss, restricted-data clearing, and offline/server recovery
  without optimistic success.

### Key Entities *(include if feature involves data)*

- **Comment**: An immutable plain-text message attached to exactly one ticket, preserving a stable
  identifier, original content, author, author role at presentation, creation time, and retry identity.
- **Ticket**: The maintenance record that defines comment membership and the reporter, current
  technician assignment, and administrator oversight authorization boundaries; this feature does not
  change ticket data or workflow state.
- **Comment Author**: The authenticated reporter, current assigned technician, or administrator whose
  identity is preserved on an accepted comment; author identity cannot be supplied by the client.
- **Retry Identity**: A client-generated value scoped to one authenticated author and ticket that
  makes replay of one logical comment creation distinguishable from a new intentional comment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of representative reporters, assigned technicians, and administrators can
  open an authorized ticket discussion and identify the newest comment in 30 seconds or less.
- **SC-002**: At least 95% of representative authorized users can add a valid plain-text comment and
  see its authoritative author and creation time within one minute without assistance.
- **SC-003**: In 100% of authorization tests, reporters see comments only on their own tickets,
  technicians see comments only while currently assigned, administrators retain approved oversight,
  and concealed targets reveal no comment contents, authors, counts, or existence clues.
- **SC-004**: In 100% of accepted-comment tests, exactly one immutable comment preserves the
  authenticated author, original validated content, and authoritative creation time.
- **SC-005**: In 100% of invalid, unauthorized, assignment-loss, persistence-failure, and unexpected
  failure tests, no partial comment is created and existing ticket/comment data remains unchanged.
- **SC-006**: In 100% of retry and competing-duplicate tests, one logical add attempt creates at most
  one comment, while distinct intentional submissions remain distinct.
- **SC-007**: Every authorized discussion is returned in deterministic oldest-first order with zero
  missing, duplicated, or cross-ticket comments in acceptance tests.
- **SC-008**: Under normal connectivity, 95% of users see progress within 1 second and receive a list,
  validation, replay, or add outcome within 2 seconds.
- **SC-009**: All applicable loading, populated, empty, submitting, validation, concealed/not-found,
  unauthorized, assignment-loss, offline, ambiguous-retry, and server-error journeys pass acceptance
  testing without false success or restricted-data leakage.
- **SC-010**: Zero real-time chat, editing, deletion, attachment, mention, reaction, typing, push
  notification, assignment, status-processing, rating, or unsupported-workflow operations or controls
  are exposed by this feature.

## Assumptions

- Existing authentication, active-account enforcement, reporter ownership, technician current
  assignment, administrator oversight, canonical response envelopes, and role-gated Flutter
  navigation from earlier features remain authoritative.
- A reporter retains comment access to their own ticket throughout its lifecycle. A technician retains
  access only while recorded as the current assignee, including on a terminal ticket if that current
  assignment remains attached; reassignment or unassignment immediately changes technician access.
- Administrators may view and add comments for oversight, as explicitly permitted by core FR-016, but
  this feature grants no ticket mutation capability beyond adding a comment.
- Comments may be added regardless of the ticket's current status because the core workflow does not
  limit discussion by status; comments do not reopen or otherwise alter terminal tickets.
- Comment content has a finite maximum length to protect usability and reliability; the exact limit is
  a planning decision that must be documented consistently in validation and contracts without
  changing plain-text semantics.
- Two intentional comments may contain identical text. Retry safety therefore relies on a distinct
  per-attempt identity rather than content comparison.
- Existing comments follow the lifecycle of the ticket and its established data-retention policy;
  this feature introduces no comment-specific archival or purge behavior.
- Comment chronology uses authoritative creation time plus a stable secondary order. Display may
  localize timestamps, but transmitted and stored chronology remains unambiguous.
