# Feature Specification: Ticket Rating

**Feature Branch**: Not created (no branch hook configured)

**Created**: 2026-07-25

**Status**: Draft

**Input**: User Story 5 - Rate Completed Service: a reporter can rate their own completed ticket exactly once using a whole-number rating from 1 through 5.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rate My Completed Ticket (Priority: P1)

As a reporter, I can submit one whole-number rating for my own completed ticket so that the completed service has a durable quality score.

**Why this priority**: Creating the one permitted rating is the feature's sole value-producing action and is independently useful after ticket completion.

**Independent Test**: Complete a reporter-owned ticket, submit each valid boundary and representative rating, and verify that exactly one rating is preserved and visible on the reporter's authorized ticket details.

**Acceptance Scenarios**:

1. **Given** an authenticated active reporter viewing their own completed unrated ticket, **When** they submit a whole-number rating from 1 through 5, **Then** exactly one rating is accepted and displayed on that ticket's authorized details.
2. **Given** an owned completed ticket rated through an accepted logical submission, **When** the same submission is retried after an ambiguous outcome, **Then** the original authoritative rating is returned without creating another rating or reporting a false failure.
3. **Given** an owned completed ticket with an existing rating, **When** the reporter makes a distinct second rating attempt, **Then** the attempt is rejected and the original rating remains unchanged.

---

### User Story 2 - Prevent Invalid or Premature Ratings (Priority: P1)

As a reporter, I receive clear, safe feedback when a rating is invalid or the ticket is not eligible so that I cannot accidentally create an incorrect service score.

**Why this priority**: Eligibility and value enforcement are inseparable from the integrity of a one-time rating.

**Independent Test**: Attempt to rate owned tickets in every non-completed state and submit missing, fractional, nonnumeric, and out-of-range values; verify every attempt is rejected and stored ticket and rating data remains unchanged.

**Acceptance Scenarios**:

1. **Given** an owned ticket whose status is not `completed`, **When** its reporter attempts to rate it, **Then** the attempt is rejected and the ticket remains unrated.
2. **Given** an owned completed unrated ticket, **When** its reporter submits a missing, fractional, textual, Boolean, or out-of-range rating, **Then** field validation explains the permitted whole-number range and creates no rating.
3. **Given** a rejected or otherwise terminal non-completed ticket, **When** its reporter attempts to rate it, **Then** no rating is accepted and no ticket state changes.

---

### User Story 3 - Protect Rating Ownership (Priority: P1)

As a reporter, I can access rating behavior only for my own tickets so that another user's ticket existence, contents, completion, and rating remain private.

**Why this priority**: Rating eligibility reveals restricted ticket state and therefore requires the same ownership boundary as reporter ticket details.

**Independent Test**: Compare rating attempts against an unknown reference and another reporter's completed ticket, then verify materially equivalent concealed failures, no restricted fields, and no stored changes; also verify technicians and administrators cannot rate.

**Acceptance Scenarios**:

1. **Given** an authenticated reporter, **When** they attempt to rate another reporter's ticket, **Then** the result is indistinguishable from an unknown ticket and exposes no ticket or rating information.
2. **Given** an authenticated technician or administrator, **When** they attempt to use the reporter rating operation, **Then** access is denied before ticket eligibility or rating information is disclosed.
3. **Given** missing, invalid, revoked, or inactive-account authentication, **When** a rating operation is attempted, **Then** no protected ticket or rating data is returned and no rating is created.

### Edge Cases

- A value is numerically equivalent to an integer but supplied as a decimal, string, Boolean, collection, or object; only a whole-number input is accepted.
- Two distinct rating attempts reach an unrated ticket concurrently; at most one becomes the permanent rating and every other attempt is rejected without overwriting it.
- The ticket changes away from an eligible state between display and submission; eligibility is checked authoritatively when the rating is created and no rating is stored if it is not completed.
- A response is lost after an accepted submission; retrying the same logical submission returns the original rating, while a distinct submission is treated as a duplicate attempt.
- Persistence or an unexpected dependency fails during creation; neither a partial rating nor a ticket mutation remains.
- An already-rated ticket is loaded on another reporter device; authorized details show the authoritative rating and do not offer another successful rating path.
- Cached eligibility or rating data becomes stale after authorization or session loss; restricted data is cleared and no client claim can authorize submission.
- A rating exists while the reporter's display name or account state later changes; the rating value, ticket association, and original creation identity remain historically accurate.

## Requirements *(mandatory)*

### Functional Requirements

- **Reporter-only access** is the governing authorization boundary for rating submission.
- **FR-001**: Only an authenticated active user with the reporter role MUST be able to access the rating-submission operation.
- **FR-002**: A reporter MUST be able to submit a rating only for a ticket whose reporter is that authenticated user.
- **FR-003**: Rating authorization MUST be derived from the authenticated actor and current ticket ownership; client-supplied reporter, owner, role, completion, or prior-rating claims MUST NOT grant access.
- **FR-004**: Unknown and non-owned ticket targets MUST produce the same not-found status, public message, error shape, and materially equivalent observable behavior.
- **FR-005**: Concealed failures MUST NOT disclose ticket existence, reporter identity, status, rating existence or value, assignment, history, comments, photos, or other restricted information.
- **FR-006**: A ticket MUST have the authoritative `completed` status when its rating is committed; every other status MUST be ineligible.
- **FR-007**: A rating MUST be supplied as a whole-number value from 1 through 5 inclusive; missing, fractional, textual, Boolean, collection, object, and out-of-range values MUST be rejected.
- **FR-008**: Each ticket MUST have at most one rating for its lifetime.
- **FR-009**: The first valid authorized rating MUST preserve the submitted value, rated ticket, authenticated reporter identity, and authoritative creation time.
- **FR-010**: A distinct attempt to rate an already-rated ticket MUST return a conflict outcome and MUST NOT alter the original rating, its reporter identity, or its creation time.
- **FR-011**: Rating editing and deletion MUST NOT be available through this feature.
- **FR-012**: Rating creation MUST be atomic: validation, authorization, eligibility, concurrency, persistence, or unexpected failure MUST leave no partial rating and MUST leave the ticket and existing related data unchanged.
- **FR-013**: Concurrent distinct submissions for the same unrated ticket MUST result in exactly one accepted rating at most; losing attempts MUST observe a conflict and MUST NOT overwrite the winner.
- **FR-014**: Every rating attempt MUST include a client-generated retry identity scoped to the authenticated reporter and ticket.
- **FR-015**: Replaying the same retry identity after an accepted rating MUST return the original authoritative rating without creating a duplicate; a different retry identity after acceptance MUST be rejected as a distinct duplicate attempt.
- **FR-016**: A successful rating response MUST return the authoritative rating representation so the client can reconcile an ambiguous submission without fabricating success.
- **FR-017**: Authorized reporter ticket details MUST expose the authoritative rating when present and an explicit unrated state when absent; other existing detail authorization rules remain unchanged.
- **FR-018**: Rating visibility MUST NOT broaden ticket-detail access for reporters, technicians, administrators, or unauthenticated actors.
- **FR-019**: Missing, invalid, expired, revoked, or inactive-account authentication MUST produce an unauthenticated outcome without ticket or rating data.
- **FR-020**: Authenticated technician, administrator, or other non-reporter rating attempts MUST be denied before ticket-specific eligibility or rating data is disclosed.
- **FR-021**: The REST behavior MUST distinguish accepted creation, safe retry replay, validation failure, unauthenticated access, wrong-role denial, concealed not-found, already-rated conflict, ineligible-status conflict, and unexpected failure using the project's consistent response structure and stable machine-readable codes where applicable.
- **FR-022**: The protected reporter rating creation operation MUST accept only the rating value and retry identity; unsupported fields MUST be rejected and must not influence ownership, status, authorship, or stored data.
- **FR-023**: A new accepted rating MUST return a creation success; safe replay MUST return a non-creation success; invalid input MUST return validation failure; already-rated and non-completed tickets MUST return conflict outcomes; authentication, authorization, concealment, and unexpected failures MUST follow the established protected-operation behavior.
- **FR-024**: The Flutter rating experience MUST provide unrated entry, submitting, accepted success, already-rated, field-validation, concealed-not-found, unauthorized/session-loss, offline, ambiguous-submission reconciliation, and server-error states.
- **FR-025**: The Flutter client MUST prevent concurrent duplicate submission from one screen, MUST NOT show an optimistic rating as accepted, and MUST retain the same retry identity while reconciling an ambiguous attempt.
- **FR-026**: After authoritative success or already-rated detail refresh, the Flutter experience MUST display the stored rating and MUST NOT present editing, deletion, or another successful rating action.
- **FR-027**: User-visible errors MUST explain correctable value, eligibility, duplicate, or connectivity problems without exposing authorization internals, stack traces, persistence details, credentials, or restricted ticket information.
- **FR-028**: Automated backend verification MUST cover reporter ownership, completed-only eligibility, integer boundaries and invalid types, exactly-once creation, duplicate conflict, safe replay, concurrency, atomic failure, rating detail visibility, concealed access, response consistency, and sanitized material failures.
- **FR-029**: Automated Flutter verification MUST cover contract mapping and entry, submission, success, already-rated, validation, concealed, unauthorized, offline, ambiguous-retry, server-error, duplicate-submit prevention, restricted-data clearing, and authoritative detail states.
- **FR-030**: This feature MUST NOT provide rating editing, rating deletion, review text, rating comments, multiple or anonymous ratings, ratings for non-completed tickets, technician or administrator rating, discussions, status changes, reassignment, or any unsupported workflow.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature implements only User Story 5 of the core workflow by allowing a reporter to record one service-quality rating after their own ticket is completed.
- **Deferred Features Check**: Rating edits, deletion, review text, multiple or anonymous ratings, aggregation and analytics, discussions, assignment changes, status processing, notifications, maps, QR codes, exports, and unsupported workflows are excluded.
- **Increment Boundary**: The smallest independently reviewable increment is authorized completed-ticket rating creation with exactly-once and concealed-ownership behavior; authorized detail visibility and the corresponding mobile states complete the same bounded journey.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **Laravel REST Contract**:
  - Rating creation is a protected reporter ticket-member operation for one ticket reference. It accepts only a whole-number `rating` from 1 through 5 and a client-generated retry identity.
  - A newly accepted rating returns `201` with the authoritative rating. Replay of the same accepted retry identity returns `200` with that original rating. Invalid shape or value returns `422`. A non-completed ticket or a distinct attempt after a rating exists returns `409` without mutation. Missing authentication returns `401`; a wrong role returns a non-disclosing `403`; an unknown or non-owned reporter target returns materially identical `404` behavior; unexpected failure returns a sanitized `500`.
  - Existing protected reporter ticket detail responses expose a nullable authoritative rating representation. The change is additive and MUST preserve all existing ownership and response-envelope behavior.
  - Planning MUST document the exact endpoint path, retry field format, response schema, conflict codes, authorization precedence, compatibility, and authoritative detail shape before client work.
- **Authorization Rules**: Authentication and active-account checks precede reporter-role and ownership checks. Ownership and completed status are revalidated against authoritative ticket state at creation. The authenticated reporter is always the rating author; client identity and eligibility claims are ignored.
- **Flutter States**: Authorized completed unrated details expose a 1-through-5 whole-number entry action with submitting and validation feedback. Accepted or already-rated details show the authoritative value without edit/delete controls. Concealed-not-found and unauthorized states clear restricted ticket/rating data. Offline and server failures preserve safe intent, prevent false success, and reconcile ambiguous submissions with the original retry identity before allowing a distinct attempt.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Authentication state, account activity, role, ticket reference, ownership, ticket status, prior-rating state, rating input, retry identity, cached eligibility, and client-supplied identity claims are untrusted. Ticket existence, contents, ownership, completion, and rating existence/value are restricted data.
- **Failure and Recovery**: Authorization, completed status, and absence of an existing rating are evaluated atomically when creating a rating. Validation, concealment, conflict, concurrent loss, persistence failure, and unexpected failure create no partial record or ticket change. Safe replay distinguishes an ambiguous accepted attempt from a prohibited distinct second rating.
- **Operational Evidence**: Accepted creation, retry replay, validation category, ineligible status, duplicate conflict, concealed access, role denial, concurrent loss, and unexpected failure MUST produce structured diagnostics with event type, outcome, timestamp, correlation identifier, and acting user identifier when available. Diagnostics MUST exclude credentials, retry identities, ticket descriptions, locations, photos, comments, rating values, and unnecessary personal data; a ticket reference is included only when safe.
- **Quality Constraints**: Under normal connectivity, visible submission progress appears within 1 second and 95% of rating or conflict outcomes complete within 2 seconds. Rating controls and states use accessible labels, logical focus order, scalable text, non-color-only feedback, and localization-ready surrounding text. Formal availability guarantees, offline queued submission, rating analytics, and new retention policies are outside scope.

### Verification Requirements

- **VR-001**: Automated backend tests MUST prove an active reporter can rate only their own completed unrated ticket and that the stored whole-number value, authenticated author, and creation time are authoritative and immutable.
- **VR-002**: Automated backend tests MUST reject every non-completed status, missing and invalid value type, fractional value, and values outside 1 through 5 without creating or changing rating or ticket data.
- **VR-003**: Automated backend tests MUST prove unknown and non-owned targets are materially indistinguishable, wrong roles are rejected before target disclosure, and authentication failures expose no protected data.
- **VR-004**: Automated backend tests MUST prove one accepted rating per ticket, unchanged original data after distinct duplicate attempts, same-identity replay, concurrent one-winner behavior, and complete rollback after injected persistence failure.
- **VR-005**: Automated backend tests MUST verify the exact REST envelopes and statuses for creation, replay, validation, authentication, role denial, concealed target, ineligible status, duplicate conflict, and unexpected failure, plus nullable authorized-detail visibility.
- **VR-006**: Automated Flutter tests MUST verify strict rating-contract parsing and entry, submission, authoritative success, already-rated, validation, concealed, unauthorized, offline, ambiguous-retry, server-error, restricted-data clearing, and duplicate-submit states.
- **VR-007**: Route, model, response, and client-control audits MUST find no edit, delete, review-text, multiple-rating, anonymous-rating, non-completed-rating, technician/admin-rating, discussion, status, assignment, or unsupported operation introduced by this feature.

### Key Entities *(include if feature involves data)*

- **Rating**: The single immutable service score associated with one completed ticket, preserving a whole-number value from 1 through 5, the authenticated reporter identity, authoritative creation time, and retry identity used for safe replay.
- **Ticket**: The maintenance record whose reporter ownership, authoritative `completed` status, and absence or presence of a rating determine eligibility; rating creation does not change ticket workflow state.
- **Rating Reporter**: The authenticated reporter who owns the ticket and submits its one permitted rating; identity cannot be selected or overridden by the client.
- **Retry Identity**: A client-generated identifier scoped to one reporter and ticket that permits safe replay of the same logical rating attempt without allowing a distinct second rating.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of representative reporters can rate an eligible completed ticket and see the authoritative score in 30 seconds or less without assistance.
- **SC-002**: In 100% of accepted-rating tests, exactly one immutable whole-number score from 1 through 5 preserves the authenticated reporter and authoritative creation time.
- **SC-003**: In 100% of non-completed, invalid, unauthorized, duplicate, concurrent-loss, persistence-failure, and unexpected-failure tests, no partial rating is created and existing rating and ticket data remain unchanged.
- **SC-004**: In 100% of ownership tests, reporters can rate only their own tickets, while unknown and non-owned targets reveal no distinguishable ticket or rating information.
- **SC-005**: In 100% of retry tests, replaying one accepted logical submission produces no duplicate and returns the original rating; a distinct later attempt never changes that rating.
- **SC-006**: Authorized ticket details display the authoritative rating when present and an explicit unrated state when absent in 100% of acceptance tests, without broadening detail access.
- **SC-007**: Under normal connectivity, 95% of users see submission progress within 1 second and receive an accepted, replay, validation, eligibility, duplicate, or failure outcome within 2 seconds.
- **SC-008**: All entry, submitting, success, already-rated, validation, concealed, unauthorized, offline, ambiguous-retry, and server-error journeys pass acceptance testing without false success or restricted-data leakage.
- **SC-009**: Zero rating edit/delete, review-text, multiple or anonymous rating, non-completed rating, technician/administrator rating, discussion, status-processing, reassignment, or unsupported operations or controls are exposed by this feature.

## Assumptions

- Existing authentication, active-account enforcement, reporter-role middleware, reporter ticket ownership, protected ticket-detail behavior, response envelopes, and role-gated Flutter navigation remain authoritative.
- Rating is optional: a completed ticket may remain unrated indefinitely, but once accepted its rating cannot be replaced or removed in Version 1.
- `completed` is the only eligible status. Rejected, new, assigned, and in-progress tickets are ineligible, and this feature cannot change status or reopen a ticket.
- Retry safety uses a client-generated identity because identical rating values cannot distinguish a network retry from an intentional second submission. Replay returns the original result but does not create an additional rating.
- The reporter who owns the ticket at creation remains its authoritative owner; this feature introduces no ownership transfer.
- Rating visibility is added only to ticket-detail views already authorized by existing feature rules; it creates no new listing, oversight, technician, or administrator rating permission.
- Ratings follow the ticket's established retention policy. This feature introduces no rating deletion, archival, aggregation, or analytics behavior.
