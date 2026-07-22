# Feature Specification: Version 1 Core Maintenance Ticket Workflow

**Feature Branch**: Not created (no branch hook configured)

**Created**: 2026-07-22

**Status**: Draft

**Input**: Baseline Version 1 workflow for reporters, technicians, and administrators to create,
assign, process, discuss, complete, and rate maintenance tickets.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Report and Track a Maintenance Issue (Priority: P1)

As a reporter, I can create an account, sign in, submit a complete maintenance ticket, and track my
own tickets so that an issue reaches the responsible team without exposing other reporters' work.

**Why this priority**: Ticket submission and personal tracking are the entry point and minimum useful
maintenance workflow.

**Independent Test**: Register a reporter, submit a valid ticket with and without photos, then confirm
that the reporter can list and view that ticket but cannot view another reporter's ticket.

**Acceptance Scenarios**:

1. **Given** valid registration details, **When** a visitor registers, **Then** a reporter account is
   created and can be used to sign in.
2. **Given** valid credentials, **When** a user signs in, **Then** the user can view their profile and
   access actions permitted for their role.
3. **Given** an authenticated reporter and valid ticket details, **When** the reporter submits the
   ticket, **Then** a new ticket is created with a unique reference and initial `new` status.
4. **Given** an authenticated reporter, **When** the reporter lists or opens tickets, **Then** only
   tickets created by that reporter are returned.
5. **Given** missing or invalid ticket fields or photos, **When** the reporter submits the ticket,
   **Then** no ticket is created and clear field-specific errors are shown.
6. **Given** a signed-in user, **When** the user logs out, **Then** the prior session can no longer
   access protected information.

---

### User Story 2 - Assign Tickets for Resolution (Priority: P2)

As an administrator, I can oversee all tickets and assign a ticket to an eligible technician so that
responsibility is explicit and work can begin.

**Why this priority**: Submitted tickets deliver operational value only after they reach a technician.

**Independent Test**: Sign in as an administrator, list all reporters' tickets, assign a new ticket to
a technician, and verify the assignment and status-history entry.

**Acceptance Scenarios**:

1. **Given** tickets from multiple reporters, **When** an administrator lists tickets, **Then** all
   tickets within the administrator's oversight are visible with their status and assignment.
2. **Given** a new ticket and an active technician, **When** an administrator assigns the ticket,
   **Then** the technician becomes responsible, the status becomes `assigned`, and the change is
   recorded in history.
3. **Given** an unknown, inactive, or non-technician user, **When** an administrator attempts an
   assignment, **Then** the assignment is rejected with a clear error and the ticket is unchanged.
4. **Given** a user without administrative authority, **When** the user attempts to list all tickets
   or assign one, **Then** access is denied without revealing restricted ticket information.

---

### User Story 3 - Process an Assigned Ticket (Priority: P2)

As a technician, I can see only my assigned tickets and move them through the permitted workflow so
that reporters and administrators have an accurate record of progress.

**Why this priority**: Assignment and resolution together form the core operational loop.

**Independent Test**: Assign a ticket to one technician, confirm it is absent for another technician,
then move it from assigned to in progress and completed while inspecting the complete history.

**Acceptance Scenarios**:

1. **Given** an authenticated technician, **When** assigned tickets are listed, **Then** only tickets
   currently assigned to that technician are returned.
2. **Given** an `assigned` ticket belonging to the technician, **When** work begins, **Then** the status
   changes to `in_progress` and a history entry records the change.
3. **Given** an `in_progress` ticket belonging to the technician, **When** work finishes, **Then** the
   status changes to `completed` and a history entry records the change.
4. **Given** an assigned or in-progress ticket that cannot be fulfilled, **When** the technician
   rejects it with a reason, **Then** the status changes to `rejected` and the reason is recorded.
5. **Given** an invalid transition or a ticket assigned to someone else, **When** a technician tries
   to change status, **Then** the request is denied and neither status nor history changes.

---

### User Story 4 - Discuss Ticket Work (Priority: P3)

As a reporter or assigned technician, I can add comments to a ticket I am involved with so that
questions and work notes remain connected to the maintenance record.

**Why this priority**: Comments reduce coordination gaps but are not required to demonstrate the
initial create-assign-resolve path.

**Independent Test**: Add comments as the reporter and assigned technician, then verify that an
unrelated reporter and unassigned technician cannot view or add comments.

**Acceptance Scenarios**:

1. **Given** a reporter viewing their own ticket, **When** they add a non-empty comment, **Then** the
   comment appears with its author and creation time.
2. **Given** the assigned technician, **When** they add a non-empty comment, **Then** the reporter and
   authorized staff can see it on the ticket.
3. **Given** an unrelated or unassigned user, **When** they attempt to view or add comments, **Then**
   access is denied without exposing comment contents.

---

### User Story 5 - Rate Completed Service (Priority: P3)

As a reporter, I can rate my completed ticket once so that service quality can be evaluated.

**Why this priority**: Rating is valuable after resolution but does not block completion of the core
ticket lifecycle.

**Independent Test**: Complete a reporter's ticket, submit one valid rating, and verify that early,
duplicate, out-of-range, and non-owner ratings are rejected.

**Acceptance Scenarios**:

1. **Given** a completed ticket owned by the reporter, **When** the reporter submits a rating from 1
   through 5, **Then** the rating is stored and displayed with the ticket.
2. **Given** a ticket that is not completed, **When** its reporter attempts to rate it, **Then** the
   rating is rejected and the ticket remains unrated.
3. **Given** an already rated ticket or a non-owner, **When** another rating is attempted, **Then** it
   is rejected without changing the original rating.

---

### User Story 6 - Manage Workflow Reference Data (Priority: P3)

As an administrator, I can manage departments, categories, users, roles, and valid assignment choices
so that reporters and technicians operate with current organizational data.

**Why this priority**: Reference data supports ongoing administration, while a seeded minimum set can
support the earlier stories independently.

**Independent Test**: Create and update reference records, deactivate a record already in use, and
confirm historical tickets remain readable while inactive choices cannot be used for new tickets.

**Acceptance Scenarios**:

1. **Given** an administrator, **When** they create or update a valid department, category, or user,
   **Then** the current choice becomes available to the appropriate workflow.
2. **Given** a reference record used by an existing ticket, **When** an administrator deactivates it,
   **Then** historical data remains intact and the inactive record cannot be selected for new work.
3. **Given** a non-administrator, **When** reference-data management is attempted, **Then** access is
   denied and no data changes.

### Edge Cases

- A submitted department or category is inactive, unknown, or the category does not belong to the
  selected department.
- A ticket is reassigned while the previous technician is viewing it; subsequent changes require the
  actor to still be the current assignee.
- Two authorized actors attempt conflicting assignment or status changes at nearly the same time;
  only one valid change succeeds and history reflects the accepted order.
- One or more optional photos are unsupported, oversized, corrupt, or fail to upload; the user sees
  which photo failed and no partial ticket is silently created.
- A ticket or related record was removed, never existed, or is outside the actor's visibility; the
  response does not disclose restricted details.
- An account becomes inactive during an authenticated session; further protected actions are denied.
- Empty or whitespace-only comments, duplicate ratings, and ratings outside the allowed range are
  rejected without changing stored data.
- A completed or rejected ticket receives an attempted status change; terminal status is preserved.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Visitors MUST be able to register a reporter account using a unique email address,
  password, name, and any required contact details.
- **FR-002**: Registered users MUST be able to sign in, view their own profile, and log out securely.
- **FR-003**: Administrators MUST be able to create, view, update, activate, and deactivate users and
  assign reporter, technician, or administrator roles.
- **FR-004**: Administrators MUST be able to create, view, update, activate, and deactivate departments
  and categories while preserving their use on historical tickets.
- **FR-005**: Reporters MUST be able to create tickets with title, description, department, category,
  priority, location text, and zero or more optional photos.
- **FR-006**: Ticket creation MUST reject blank required fields, invalid references, categories outside
  the chosen department, unsupported priorities, and photos that violate documented limits.
- **FR-007**: Every created ticket MUST receive a unique human-readable reference, creation time,
  reporter identity, and initial `new` status.
- **FR-008**: Reporters MUST be able to list and view only tickets they created, including assignment,
  status history, authorized comments, and rating when present.
- **FR-009**: Administrators MUST be able to list and view all tickets and filter them by status,
  department, category, priority, reporter, technician, and creation period.
- **FR-010**: Administrators MUST be able to assign or reassign a nonterminal ticket to an active
  technician; an initial assignment MUST move a `new` ticket to `assigned`.
- **FR-011**: Technicians MUST be able to list and view only tickets currently assigned to them.
- **FR-012**: The allowed forward status transitions MUST be `new` to `assigned` or `rejected`,
  `assigned` to `in_progress` or `rejected`, and `in_progress` to `completed` or `rejected`.
  `completed` and `rejected` MUST be terminal.
- **FR-013**: Only an administrator MAY assign or reassign tickets; only the current assigned
  technician MAY move an assigned ticket to `in_progress`, `completed`, or `rejected`.
- **FR-014**: Every accepted assignment, reassignment, and status change MUST append an immutable
  history record containing the ticket, prior status, new status, actor, time, and reason when given.
- **FR-015**: Invalid or conflicting status transitions MUST leave the ticket and history unchanged
  and return a clear explanation of the currently allowed actions.
- **FR-016**: A ticket's reporter and current assigned technician MUST be able to add non-empty
  comments; administrators MAY view and comment for oversight.
- **FR-017**: Comments MUST preserve author, creation time, and original content and MUST be visible
  only to actors authorized to view the ticket.
- **FR-018**: A reporter MUST be able to rate their own completed ticket exactly once using a whole
  number from 1 through 5; ratings on other or non-completed tickets MUST be rejected.
- **FR-019**: Every protected action MUST verify the actor's authentication, role, permission,
  assignment, and ticket ownership as applicable.
- **FR-020**: Requests without valid authentication MUST be rejected without performing the action or
  returning protected data.
- **FR-021**: Requests from authenticated but unauthorized users MUST be rejected without confirming
  or exposing restricted ticket, comment, history, photo, or rating details.
- **FR-022**: Requests for absent visible records MUST return a clear not-found result and perform no
  state change.
- **FR-023**: Success and error results MUST use a consistent structure and provide clear validation,
  unauthenticated, unauthorized, not-found, conflict, and server-error outcomes.
- **FR-024**: Ticket lists MUST support pagination and stable newest-first ordering by default.
- **FR-025**: User-visible dates and times MUST be presented consistently while preserving an
  unambiguous chronological audit trail.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This baseline covers identity, ticket submission, personal and
  operational queues, assignment, status progression, history, comments, rating, authorization, and
  the minimum reference-data administration needed to complete maintenance work.
- **Deferred Features Check**: Maps, GPS, QR codes, push notifications, PDF or spreadsheet export,
  advanced analytics, real-time chat, and offline synchronization are explicitly excluded.
- **Increment Boundary**: Delivery is split into independently reviewable identity, reporter intake,
  administration and assignment, technician processing, comments, rating, and reference-data slices.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **Interaction Contract**: Protected operations require an authenticated session. Each operation
  defines accepted fields, validation rules, authorization rules, success data, pagination where
  relevant, and consistent validation, unauthenticated, unauthorized, not-found, conflict, and
  unexpected-failure results. Contract changes MUST preserve existing Version 1 consumers or be
  explicitly versioned before use.
- **Authorization Rules**: Reporter access is ownership-based; technician access is current-assignment
  based; administrator access is role- and permission-based. All applicable checks are cumulative.
- **Client States**: Every data-driven view MUST present loading, success, empty, validation-error,
  unauthorized, offline, and server-error states, with a retry path where retry is safe.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Registration, sign-in, all user-supplied text, identifiers, filters, photos,
  comments, ratings, roles, assignments, and status changes are untrusted until validated and
  authorized. Credentials, sessions, personal data, ticket contents, and photos are sensitive.
- **Failure and Recovery**: A failed validation, upload, authorization, assignment, comment, rating,
  or status transition MUST make no partial business change. Retriable connectivity or server failures
  MUST preserve entered user data where safe and offer retry without creating duplicates.
- **Operational Evidence**: Authentication failures, denied privileged actions, assignments, status
  changes, and unexpected failures MUST be diagnosable by authorized operators without recording
  passwords, session secrets, photo contents, or unnecessary personal and ticket text.
- **Quality Constraints**: Lists are paginated; common user actions provide visible feedback within
  two seconds under normal supported conditions; all controls and status information have accessible
  text labels; sensitive values are never exposed in errors or diagnostic output.

### Key Entities

- **User**: A person with identity, profile, account state, and one or more authorized roles.
- **Department**: An organizational destination for tickets, with an active state and categories.
- **Category**: A selectable classification belonging to a department, with an active state.
- **Ticket**: A reported maintenance issue with reference, content, priority, location, ownership,
  department, category, current status, assignment, timestamps, and related records.
- **Ticket Photo**: An optional image attached during ticket creation with file metadata and ownership.
- **Assignment**: The current technician responsibility and its assignment or reassignment details.
- **Status History**: An immutable chronological record of assignment and status changes.
- **Comment**: A timestamped message authored by an authorized ticket participant or administrator.
- **Rating**: A reporter's single 1-to-5 evaluation of their completed ticket.
- **Role and Permission**: The authority assigned to a user and used with ownership and assignment
  checks to decide permitted actions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of first-time reporters can register, sign in, and submit a valid ticket
  without assistance in five minutes or less during usability validation.
- **SC-002**: 100% of submitted valid tickets receive a visible unique reference and appear in the
  reporter's ticket list immediately after confirmation.
- **SC-003**: Administrators can locate and assign a new ticket to an eligible technician in two
  minutes or less in at least 95% of acceptance-test attempts.
- **SC-004**: Technicians can identify their assigned work and record a valid progress change in one
  minute or less in at least 95% of acceptance-test attempts.
- **SC-005**: 100% of tested ownership, role, permission, and assignment violations prevent access or
  modification and reveal no restricted ticket details.
- **SC-006**: 100% of accepted assignment and status changes appear once, in correct chronological
  order, with actor, time, prior status, and new status.
- **SC-007**: 100% of tested invalid inputs, unauthenticated requests, unauthorized actions,
  not-found records, and invalid transitions produce the defined clear outcome with no partial change.
- **SC-008**: At least 95% of common list, detail, submission, assignment, comment, status, and rating
  actions provide visible success or failure feedback within two seconds under normal conditions.
- **SC-009**: Every data-driven user journey demonstrates all applicable loading, success, empty,
  validation, unauthorized, offline, and server-error states during acceptance testing.
- **SC-010**: All Version 1 acceptance scenarios pass without implementing any explicitly excluded
  advanced feature.

## Assumptions

- Public registration creates reporter accounts only; administrators provision or promote technicians
  and other administrators.
- Email addresses uniquely identify accounts, and password reset and email verification are outside
  this baseline unless later specified as separate Version 1 increments.
- Priorities are `low`, `medium`, `high`, and `urgent` and are managed as a fixed Version 1 set.
- A reporter may attach up to five JPEG, PNG, or WebP photos of no more than 10 MB each at creation;
  later photo editing is outside this baseline.
- Administrators may reject a `new` ticket during triage. Technicians may reject only tickets assigned
  to them and must supply a reason. Completed and rejected tickets cannot be reopened in Version 1.
- Reassignment preserves prior history and gives further technician access only to the current assignee.
- Comments are plain text, cannot be edited or deleted in Version 1, and are not real-time chat.
- Rating is optional, may be submitted once, and cannot be edited in Version 1.
- Deactivation is preferred to deletion for referenced users, departments, and categories so historical
  ticket records remain meaningful.
- Data retention duration and formal regulatory obligations will be established before production
  deployment; Version 1 must preserve records unless an authorized retention policy says otherwise.

