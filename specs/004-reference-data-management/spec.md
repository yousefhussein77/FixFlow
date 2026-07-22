# Feature Specification: Department and Category Reference Data

**Feature Branch**: `main`

**Created**: 2026-07-22

**Status**: Draft

**Input**: User description: "Create focused reference-data management for departments and categories, with administrator management, active-only options for reporters and technicians, historical visibility, strict authorization, REST APIs, Flutter management screens, complete client states, validation, and failure handling."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manage Departments (Priority: P1)

As an administrator, I want to create, list, view, rename, activate, and deactivate departments so that FixFlow has a controlled top-level structure for maintenance work.

**Why this priority**: Every category requires a department, so department management is the smallest independently useful foundation for all reference data.

**Independent Test**: Authenticate as an administrator, create a department, inspect it in the complete administrative list, rename it, deactivate it, and reactivate it while verifying validation, authorization, and lifecycle states at each step.

**Acceptance Scenarios**:

1. **Given** an administrator supplies a valid unused department name, **When** creation is submitted, **Then** one active department is created and returned using the consistent response structure.
2. **Given** department names differing only by letter case or surrounding whitespace, **When** an administrator attempts to create or rename a department to the equivalent name, **Then** validation rejects the duplicate and no state changes.
3. **Given** active and inactive departments exist, **When** an administrator opens the department list, **Then** both states are visible and clearly distinguishable, including an empty state when none exist.
4. **Given** an existing department, **When** an administrator views it, **Then** its identity, normalized name, active state, and timestamps are visible.
5. **Given** an active department, **When** an administrator deactivates it, **Then** it remains available in administrative and historical contexts but is excluded from all new-work option lists.
6. **Given** an inactive department, **When** an administrator reactivates it, **Then** it becomes selectable again and only its individually active categories become selectable.
7. **Given** a reporter, technician, visitor, or missing/invalid session, **When** a department modification operation is attempted, **Then** no reference data changes and the caller receives only the appropriate safe authentication or authorization response.
8. **Given** the same department is changed concurrently, **When** an update targets a stale version, **Then** the operation returns a conflict, preserves the newer data, and offers the administrator a refresh/retry path.

---

### User Story 2 - Manage Categories Within Departments (Priority: P1)

As an administrator, I want to create and manage categories under departments so that future maintenance work can be classified consistently.

**Why this priority**: Categories are the selectable classification needed by the later ticket workflow and cannot exist without the department foundation.

**Independent Test**: Create two departments, create categories with scoped uniqueness, view and update a category's name and department, change its active state, and verify that invalid relationships and concurrent conflicts make no partial change.

**Acceptance Scenarios**:

1. **Given** an active department and an unused category name within it, **When** an administrator creates a category, **Then** one active category linked to exactly that department is created.
2. **Given** the same normalized category name exists in two different departments, **When** both are created, **Then** both succeed because uniqueness is scoped to department.
3. **Given** an equivalent category name already exists in the selected department, **When** an administrator creates or updates a category to that name, **Then** validation rejects it and neither category is changed.
4. **Given** a category, **When** an administrator views it, **Then** its department, name, active state, and timestamps are shown.
5. **Given** an existing category and a valid target department, **When** an administrator updates its name or department, **Then** the resulting department/name pair remains unique and the update is atomic.
6. **Given** an inactive department, **When** an administrator attempts to create a category in it or move a category into it, **Then** validation rejects the relationship and no category is created or moved.
7. **Given** an active category, **When** an administrator deactivates it, **Then** it remains visible administratively and historically but cannot be selected for new work.
8. **Given** an active category whose department is inactive, **When** active options are requested, **Then** the category is excluded even though its own active flag remains unchanged.
9. **Given** a reporter or technician, **When** a category modification operation is attempted, **Then** the operation is denied without revealing restricted administration details and no data changes.

---

### User Story 3 - Load Active Reference Options (Priority: P2)

As an authenticated reporter or technician, I want to load active departments and their active categories so that future work forms can offer only valid choices.

**Why this priority**: Read-only active options advance the future maintenance workflow while depending on the P1 reference data being available.

**Independent Test**: Authenticate as a reporter and technician against a mixture of active and inactive records and verify that only selectable department/category combinations are returned, with no administration metadata or controls.

**Acceptance Scenarios**:

1. **Given** active and inactive departments exist, **When** a reporter or technician lists department options, **Then** only active departments are returned in deterministic name order.
2. **Given** active and inactive categories across active and inactive departments, **When** a reporter or technician requests categories for an active department, **Then** only active categories belonging to that department are returned in deterministic name order.
3. **Given** a category or department was previously selected on a historical record and later deactivated, **When** that historical record is viewed by a future workflow, **Then** the referenced name and inactive state remain resolvable even though the item is absent from new-work options.
4. **Given** no selectable options exist, **When** active reference data is requested, **Then** a successful empty result is returned and the Flutter consumer presents a clear empty state.
5. **Given** an authenticated administrator, **When** active options are requested for a normal work-form context, **Then** the same active-only option rules apply; administrative all-record lists remain separate.
6. **Given** a visitor or invalid session, **When** any active-option operation is requested, **Then** the request is rejected as unauthenticated.
7. **Given** the device is offline or the service fails, **When** options are loaded, **Then** the Flutter consumer preserves no newly confirmed selection, shows the correct recoverable state, and offers a safe retry.

### Edge Cases

- Concurrent attempts to create equivalent department names result in at most one department; the losing operation returns a validation or conflict response with no duplicate.
- Concurrent attempts to create equivalent category names within one department result in at most one category; the same name in different departments remains valid.
- Names containing only whitespace are invalid; accepted names are trimmed for storage and comparison without otherwise changing the administrator's text.
- Names use case-insensitive uniqueness, including accented or non-ASCII letters according to the system's documented normalization behavior.
- A category cannot be created without a department, linked to a missing department, or linked to an inactive department.
- Deactivating a department does not rewrite each category's active flag; it makes every child category effectively unavailable while the department is inactive.
- Reactivating a department does not reactivate categories that administrators individually deactivated.
- Deactivating an already inactive record and activating an already active record are safe idempotent outcomes and do not create duplicate audit events or unintended changes.
- A category update that changes departments must satisfy uniqueness in the target department and must target an active department.
- A late Flutter response from a stale list or update request cannot overwrite a newer successful refresh or display a false success.
- Records are never permanently deleted through this feature, including records that are not yet referenced.
- Administrative list loading distinguishes a true empty collection from an authorization, offline, or server failure.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support department creation, complete administrative listing, individual viewing, name updates, activation, and deactivation.
- **FR-002**: The system MUST support category creation, complete administrative listing, individual viewing, name/department updates, activation, and deactivation.
- **FR-003**: Every category MUST belong to exactly one existing department at all times.
- **FR-004**: Department names MUST be required, between 1 and 120 characters after trimming, stored without surrounding whitespace, and unique using case-insensitive comparison.
- **FR-005**: Category names MUST be required, between 1 and 120 characters after trimming, stored without surrounding whitespace, and unique within their department using case-insensitive comparison.
- **FR-006**: New departments and categories MUST be active by default.
- **FR-007**: Creating or moving a category into an inactive department MUST be rejected with field-level validation and no partial state change.
- **FR-008**: Only authenticated administrators MUST be able to create, view administrative detail, list all records, update, activate, or deactivate reference data.
- **FR-009**: Authenticated reporters and technicians MUST be denied every administrative reference-data operation with a safe forbidden response that does not disclose whether a targeted restricted record exists.
- **FR-010**: Visitors and missing, invalid, revoked, or inactive-account sessions MUST be rejected as unauthenticated for every operation in this feature.
- **FR-011**: Authenticated active reporters, technicians, and administrators MUST be able to list active department options for later work forms.
- **FR-012**: Authenticated active reporters, technicians, and administrators MUST be able to list active category options belonging to a specified active department.
- **FR-013**: Active-option results MUST exclude inactive departments, inactive categories, and categories whose department is inactive.
- **FR-014**: Active-option results MUST be ordered by normalized display name, with stable identifiers included for future selections.
- **FR-015**: Administrative lists MUST include active and inactive records and clearly expose each record's active state.
- **FR-016**: Deactivation MUST preserve the record, its stable identifier, its relationships, and its ability to resolve historical references.
- **FR-017**: Permanent deletion of departments or categories MUST NOT be available through any endpoint or Flutter screen in this feature.
- **FR-018**: Reactivating a department MUST restore selectability only for categories whose own active state is true.
- **FR-019**: Updating a category's department MUST atomically validate the target department and scoped name uniqueness before changing either value.
- **FR-020**: Every create, update, activation, and deactivation MUST be atomic; validation, authorization, conflict, and server failures MUST leave the prior state unchanged.
- **FR-021**: Updates MUST detect conflicting concurrent changes using a record version supplied from the most recently read representation; stale updates MUST return conflict without overwriting newer data.
- **FR-022**: Repeating activation on an active record or deactivation on an inactive record MUST succeed without changing unrelated data.
- **FR-023**: Success, validation, unauthenticated, forbidden, conflict, and server responses MUST use the project's consistent response envelope and stable machine-readable error codes.
- **FR-024**: Administrative forbidden responses MUST use the same safe message and response shape whether or not the targeted department or category exists.
- **FR-025**: Flutter MUST provide administrator department and category list, detail, create, edit, activate, and deactivate experiences without exposing controls to non-administrators.
- **FR-026**: Flutter administrative list experiences MUST represent loading, populated success, empty success, unauthorized, offline, and server-error states.
- **FR-027**: Flutter create/edit experiences MUST represent idle, loading, success, field validation, unauthorized, offline, conflict, and server-error states and MUST prevent duplicate submission while loading.
- **FR-028**: Flutter activation/deactivation experiences MUST require clear confirmation, represent loading, success, unauthorized, offline, conflict, and server-error states, and refresh the affected record after success.
- **FR-029**: Flutter active-option loading MUST represent loading, populated success, empty success, unauthenticated, offline, and server-error states; validation applies when a category request lacks or supplies an invalid department identifier.
- **FR-030**: Flutter MUST discard or ignore stale asynchronous results that arrive after a newer refresh, update, navigation change, or authentication loss.
- **FR-031**: This feature MUST NOT add ticket behavior, assignment, comments, ratings, user/role administration, advanced search, analytics, or permanent deletion.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: Departments and categories provide the minimum controlled classification options required before reporters can create maintenance tickets and technicians can work with them.
- **Deferred Features Check**: Tickets, assignment, comments, ratings, user/role administration, permanent deletion, advanced search, analytics, maps, QR codes, push notifications, and document export are excluded.
- **Increment Boundary**: The smallest reviewable increment is administrator department management with authorization, lifecycle states, validation, API behavior, and Flutter list/form states. Category management and read-only active options follow as independently verifiable increments.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - Administrator department collection: list all and create departments. List success returns `200`; creation returns `201`; validation returns `422`; unauthenticated returns `401`; non-administrator returns `403`.
  - Administrator department member: view and update a department. Success returns `200`; validation returns `422`; stale version returns `409`; unauthenticated returns `401`; non-administrator and concealed restricted targets return the same safe `403`.
  - Administrator department lifecycle: activate or deactivate a department. Success returns `200`; stale version returns `409`; authentication/authorization failures return `401`/safe `403`.
  - Administrator category collection and member operations follow the same list/create/view/update/lifecycle status behavior and include department identity in requests and representations.
  - Active department options: authenticated read-only collection returning only selectable departments with `200`, including an empty collection when appropriate.
  - Active category options: authenticated read-only collection scoped by department identifier, returning selectable categories with `200`; invalid or inactive department input returns `422`; unauthenticated returns `401`.
  - All representations include stable identifier, display name, active state, timestamps, and a version value; category representations also include their department identity and name. No permanent-delete operation exists.
  - All responses use the existing success/data/errors/code envelope. Incompatible paths, fields, status semantics, or option-filtering behavior require an explicit future compatibility decision.
- **Authorization Rules**: Sanctum authentication and active-account enforcement apply throughout. Administrator role is required before resolving or disclosing administrative targets. Reporters and technicians receive active option data only. Administrator management checks are server-enforced independently of Flutter visibility.
- **Flutter States**:
  - Administrative lists: loading, populated success, empty success, unauthorized, offline, and server error. Validation and conflict are impossible for an unfiltered collection read and unexpected occurrences become server/contract errors.
  - Detail: loading, populated success, unauthorized, offline, conflict after a stale action, and server error. Empty success is invalid for a requested member and becomes a server/contract error.
  - Create/edit: idle, loading, success, field validation, unauthorized, offline, conflict, and server error. Empty success is invalid.
  - Activation/deactivation: confirmation, loading, success, unauthorized, offline, conflict, and server error; validation is shown if relationship rules prevent the action.
  - Active options: loading, populated success, empty success, unauthenticated, offline, validation for invalid department scope, and server error. Conflict does not apply to a read-only option request.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Untrusted inputs include names, department identifiers, record identifiers, version values, status transitions, tokens, and all client response data. Server authorization must distinguish administrator management from authenticated active-option reads before exposing restricted records.
- **Failure and Recovery**: Validation, authorization, inactive-account, uniqueness, relationship, conflict, and service failures make no partial change. Safe retries are offered for reads and for mutations only after the client reconciles whether a prior request succeeded. Conflict recovery refreshes the latest record before resubmission. Deactivation is reversible; permanent deletion is unavailable.
- **Operational Evidence**: Create, update, activation, deactivation, validation denial, authorization denial, conflict, and unexpected failure outcomes produce structured diagnostics containing event type, outcome, actor identifier when authenticated, reference type/identifier when safely known, timestamp, and correlation identifier. Diagnostics exclude tokens, authorization headers, raw request payloads, and unnecessary names.
- **Quality Constraints**: Under normal connectivity, users see loading feedback within 1 second and 95% of list/detail/mutation outcomes within 3 seconds. Administrative and option screens support text scaling, accessible control labels, and non-color-only status indicators. User-facing strings are localization-ready. Reference records are retained indefinitely within this feature because historical resolution and deletion policy belong to future ticket/data-governance work.

### Verification Requirements

- **VR-001**: Automated backend tests MUST cover department and category creation, listing, viewing, updates, activation, deactivation, uniqueness, relationship validation, idempotence, and stale conflicts.
- **VR-002**: Automated backend tests MUST cover unauthenticated, inactive-account, reporter, technician, and administrator behavior for every endpoint class.
- **VR-003**: Automated backend tests MUST prove non-administrator administrative responses do not reveal target existence and denied/failed mutations preserve record counts and values.
- **VR-004**: Automated backend tests MUST prove active options exclude every inactive combination while administrative lists retain those records.
- **VR-005**: Automated backend tests MUST prove deactivation never deletes records or breaks category relationships and reactivation respects category-level state.
- **VR-006**: Flutter tests MUST cover list, detail, form, lifecycle, and active-option state transitions, contract mapping, stale-result handling, authorization loss, offline recovery, conflict recovery, and server errors.

### Key Entities *(include if feature involves data)*

- **Department**: A top-level maintenance reference value with stable identifier, normalized unique display name, active state, timestamps, and concurrency version. It owns zero or more categories and remains retained when inactive.
- **Category**: A maintenance classification with stable identifier, normalized display name, exactly one department, active state, timestamps, and concurrency version. Its name is unique within its department and it remains retained when inactive.
- **Reference Option**: A read-only selectable representation containing stable identifier and display name. A department option exists only for an active department; a category option exists only when both category and parent department are active.
- **Reference Change Event**: Non-sensitive operational evidence for a create, update, activation, deactivation, denial, or conflict, linked to the actor and affected reference identifier when safe.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of administrators can create a department and its first category in under 2 minutes without assistance.
- **SC-002**: At least 95% of administrators can find, update, activate, or deactivate a reference record in under 60 seconds.
- **SC-003**: In 100% of authorization tests, only administrators modify reference data and non-administrator denials disclose no restricted record-existence difference.
- **SC-004**: In 100% of uniqueness and concurrency tests, no duplicate department or within-department category is created and no newer update is overwritten.
- **SC-005**: In 100% of active-option tests, inactive departments, inactive categories, and categories under inactive departments are absent from new-work choices.
- **SC-006**: In 100% of lifecycle tests, deactivated records retain their stable identity and relationships and can still resolve historical references.
- **SC-007**: All administrator and active-option Flutter journeys pass checks for their applicable loading, success, empty, validation, unauthorized, offline, conflict, and server-error states without stale results.
- **SC-008**: Under normal connectivity, 95% of users see progress within 1 second and the requested reference-data result within 3 seconds.
- **SC-009**: Usability testing shows at least 90% of representative administrators complete create, edit, deactivate, and reactivate tasks correctly on the first attempt.
- **SC-010**: Zero permanent-delete operations, ticket behaviors, or user/role administration controls are exposed by this feature.

## Assumptions

- The existing Sanctum authentication, active-account enforcement, user roles, and consistent response envelope from the authentication feature are available and remain authoritative.
- Administrators may reassign a category to another active department; the change must satisfy target-department uniqueness and concurrency rules.
- Department deactivation is allowed even when it has active or historically referenced categories; it changes effective selectability without changing each child's stored active state.
- Historical workflows will store stable department/category references. This feature guarantees records remain resolvable but does not implement or define ticket records.
- Administrative lists are complete, deterministic name-ordered collections at the expected version-one scale; pagination and advanced filtering/search are deferred until demonstrated volume requires them.
- Names are compared case-insensitively after trimming. Locale-specific display and normalization details will be recorded in planning without weakening uniqueness.
- A record version is returned with every administrative representation and supplied on mutations to detect stale changes.
- Activation and deactivation are reversible status changes; permanent deletion and archival retention schedules are outside this feature.
