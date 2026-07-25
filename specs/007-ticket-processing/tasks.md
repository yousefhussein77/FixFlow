# Tasks: Technician Ticket Processing

**Input**: Design documents from `specs/007-ticket-processing/`

**Verification**: Laravel and Flutter tests are mandatory and precede corresponding implementation.
Every accepted transition must prove one atomic ticket update plus one immutable history entry; every
rejected path must prove unchanged ticket timestamp/status/assignment/history and concealed data where
required.

## Phase 1: Setup

**Purpose**: Freeze the approved processing boundary and confirm existing foundations before changes.

- [x] T001 Verify no package addition is required and preserve dependency versions in backend/composer.json and mobile/pubspec.yaml
- [x] T002 Audit the three approved operations, exact four-transition matrix, schemas, error codes, pagination limits, and exclusions against specs/007-ticket-processing/contracts/openapi.yaml, specs/007-ticket-processing/data-model.md, and specs/007-ticket-processing/plan.md

---

## Phase 2: Foundational Prerequisites

**Purpose**: Reuse existing authentication, ticket assignment, history, envelope, and mobile layering.

No new shared implementation foundation is required before a user story. Confirm the existing
`auth:sanctum` and `active` route chain, one-time assignment schema, immutable
`TicketStatusHistory`, canonical `ApiResponse`, private photo representation, secure token store, and
Flutter service/repository/state separation. Any unrelated defect must remain outside this feature.

**Checkpoint**: Existing foundations are confirmed; US1 may begin without introducing processing
mutation.

---

## Phase 3: User Story 1 - View My Assigned Work (Priority: P1) MVP

**Goal**: An active technician lists and opens only tickets currently assigned to that technician,
including complete chronological status history, without cross-technician disclosure.

**Independent Test**: Assign tickets to two technicians across statuses; verify each technician's
stable pages, empty result, owned detail/history/photos, role denial, assignment-loss handling, and
identical unknown/non-assigned 404 envelopes.

### Backend tests for User Story 1

> Write these tests first and observe the focused suite fail before implementation.

- [x] T003 [P] [US1] Write failing assigned-list Feature Tests for assignment-first counts, exact fields, stable `(created_at,id)` pagination, empty/out-of-range pages, invalid page inputs, and no cross-technician rows in backend/tests/Feature/Tickets/TechnicianListTicketsTest.php
- [x] T004 [P] [US1] Write failing assigned-detail Feature Tests for complete work fields, photos, current assignment, chronological immutable history, assignment loss, and identical unknown/non-assigned 404 responses in backend/tests/Feature/Tickets/TechnicianShowTicketTest.php
- [x] T005 [P] [US1] Write failing route/authorization Feature Tests for unauthenticated, revoked, inactive, reporter, administrator, and active-technician actors with non-disclosing 401/403 outcomes in backend/tests/Feature/Tickets/TechnicianTicketAuthorizationTest.php

### Backend implementation for User Story 1

- [x] T006 [P] [US1] Implement technician-role middleware with inactive-account precedence and canonical denial envelopes in backend/app/Http/Middleware/EnsureUserIsTechnician.php and register its alias in backend/bootstrap/app.php
- [x] T007 [P] [US1] Implement page/per-page validation with default 20 and maximum 100 in backend/app/Http/Requests/Tickets/TechnicianListTicketsRequest.php
- [x] T008 [P] [US1] Implement technician summary, detail, and chronological history mappings without reporter contact or internal persistence fields in backend/app/Http/Resources/TechnicianTicketSummaryResource.php, backend/app/Http/Resources/TechnicianTicketResource.php, and backend/app/Http/Resources/TicketStatusHistoryResource.php
- [x] T009 [US1] Implement assignment-scoped stable newest-first pagination in backend/app/Actions/Tickets/ListTechnicianTickets.php
- [x] T010 [US1] Implement thin assigned-list and assignment-scoped detail handlers with identical concealed lookup in backend/app/Http/Controllers/Api/TechnicianTicketController.php
- [x] T011 [US1] Register only GET `/api/technician/tickets` and GET `/api/technician/tickets/{reference}` behind `auth:sanctum`, `active`, and `technician` middleware in backend/routes/api.php
- [x] T012 [US1] Record sanitized technician list/detail allow, role denial, assignment-loss, and concealed-target diagnostics without ticket content or rejection text in backend/app/Support/TicketEvent.php and backend/app/Http/Controllers/Api/TechnicianTicketController.php
- [x] T013 [US1] Run focused US1 Laravel tests and verify assignment filtering occurs before counts/lookup and unknown/non-assigned envelopes are byte-equivalent in backend/tests/Feature/Tickets/TechnicianListTicketsTest.php, backend/tests/Feature/Tickets/TechnicianShowTicketTest.php, and backend/tests/Feature/Tickets/TechnicianTicketAuthorizationTest.php

### Flutter tests for User Story 1

> Write these tests before the corresponding Flutter implementation and observe them fail.

- [x] T014 [P] [US1] Write failing technician model/API/repository tests for list/detail envelopes, nullable history reason, pagination, malformed contracts, 401/403/404/422/500, and offline mapping in mobile/test/tickets/technician_ticket_repository_test.dart
- [x] T015 [P] [US1] Write failing assigned-list controller/widget tests for loading, populated, empty, loading-more, stable de-duplication, stale-result suppression, unauthorized data clearing, offline/server retry, and no excluded controls in mobile/test/tickets/assigned_tickets_test.dart
- [x] T016 [P] [US1] Write failing assigned-detail controller/widget tests for full fields/history/photos, loading, concealed-not-found, authorization loss, assignment loss, offline, photo-unavailable, server retry, and restricted-state clearing in mobile/test/tickets/technician_ticket_details_test.dart
- [x] T017 [P] [US1] Write failing profile/navigation tests proving only technicians see Assigned Tickets and reporters/administrators receive no technician entry or retained restricted state in mobile/test/auth/technician_ticket_access_test.dart

### Flutter implementation for User Story 1

- [x] T018 [US1] Implement technician summary/detail/history/page and typed failure models with strict contract parsing in mobile/lib/tickets/models/technician_ticket_models.dart
- [x] T019 [US1] Implement authenticated GET transport for technician list/detail with canonical envelope and HTTP/offline/contract mapping in mobile/lib/tickets/services/technician_ticket_api_service.dart
- [x] T020 [US1] Implement secure-token access and assignment-private list/detail repository mapping in mobile/lib/tickets/repositories/technician_ticket_repository.dart
- [x] T021 [P] [US1] Implement loading/populated/empty/loading-more/unauthorized/offline/server list states with generation-based stale suppression and reference de-duplication in mobile/lib/tickets/state/assigned_tickets_controller.dart
- [x] T022 [P] [US1] Implement loading/populated/concealed-not-found/unauthorized/offline/photo-unavailable/server detail states with restricted-data clearing in mobile/lib/tickets/state/technician_ticket_details_controller.dart
- [x] T023 [US1] Implement accessible localization-ready Assigned Tickets pagination, empty, retry, and owned-row navigation UI in mobile/lib/tickets/screens/assigned_tickets_screen.dart
- [x] T024 [US1] Implement accessible assigned-ticket detail, photo availability, and chronological history UI without transition controls yet in mobile/lib/tickets/screens/technician_ticket_details_screen.dart
- [x] T025 [US1] Wire existing manual dependency injection and technician-only navigation while clearing restricted state on denial/session loss in mobile/lib/main.dart, mobile/lib/app.dart, mobile/lib/auth/screens/session_gate.dart, and mobile/lib/auth/screens/profile_screen.dart
- [x] T026 [US1] Run focused US1 Flutter tests and verify contract mapping, pagination, stale-result rejection, assignment isolation, access-denied clearing, and absence of excluded actions under mobile/test/tickets/ and mobile/test/auth/technician_ticket_access_test.dart

**Checkpoint**: US1 independently delivers a private read-only assigned-work queue and detail/history
experience. No ticket mutation is exposed.

---

## Phase 4: User Story 2 - Start Assigned Work (Priority: P1)

**Goal**: The current technician atomically moves an `assigned` ticket to `in_progress` exactly once
and receives authoritative refreshed status/history.

**Independent Test**: Start one owned assigned ticket; verify one update and one immutable history row.
Repeat for another technician, sequential stale/invalid/terminal attempts, and injected history
failure; locking and revalidation permit only one eligible commit. A true cross-connection race is
not claimed under the SQLite test environment.

### Backend tests for User Story 2

- [x] T027 [US2] Write failing start-work Feature Tests for success/history, current-assignee concealment, wrong actors, sequential stale/duplicate/invalid/terminal conflicts, assignment loss, injected rollback, sanitized 500, and unchanged timestamps/history in backend/tests/Feature/Tickets/TechnicianStartTicketTest.php

### Backend implementation for User Story 2

- [x] T028 [P] [US2] Add `in_progress`, `completed`, and `rejected` status constants plus exact allowed-transition helpers and reproducible in-progress/terminal factory states in backend/app/Models/Ticket.php and backend/database/factories/TicketFactory.php
- [x] T029 [P] [US2] Implement transition request validation for only `in_progress`, `completed`, or `rejected`, trim reason, and reject unsupported fields/status shapes in backend/app/Http/Requests/Tickets/TransitionTicketStatusRequest.php
- [x] T030 [US2] Implement `assigned → in_progress` using current-assignment lookup, one transaction, ticket row lock, commit-time assignment/status revalidation, atomic update/history insert, and `STATUS_TRANSITION_CONFLICT` in backend/app/Actions/Tickets/TransitionTicketStatus.php
- [x] T031 [US2] Add the thin PATCH status handler and register PATCH `/api/technician/tickets/{reference}/status` behind technician middleware in backend/app/Http/Controllers/Api/TechnicianTicketController.php and backend/routes/api.php
- [x] T032 [US2] Record sanitized accepted start, concealed target, invalid transition, conflict, assignment loss, and rollback diagnostics in backend/app/Support/TicketEvent.php and backend/app/Actions/Tickets/TransitionTicketStatus.php
- [x] T033 [US2] Run focused US2 Laravel tests and prove transaction locking plus sequential stale-conflict preservation, immutable history, atomic rollback, exact error envelopes, and absence of alternative status routes in backend/tests/Feature/Tickets/TechnicianStartTicketTest.php; SQLite does not provide reliable cross-connection race evidence

### Flutter tests for User Story 2

- [x] T034 [US2] Write failing start-work service/repository/controller/widget tests for ready, submitting, authoritative success, duplicate-submit blocking, concealed-not-found, conflict refresh, assignment loss, unauthorized clearing, ambiguous offline/server refresh, and no optimistic state in mobile/test/tickets/technician_start_ticket_test.dart

### Flutter implementation for User Story 2

- [x] T035 [US2] Implement PATCH status transport and strict authoritative-detail mapping in mobile/lib/tickets/services/technician_ticket_api_service.dart and mobile/lib/tickets/repositories/technician_ticket_repository.dart
- [x] T036 [US2] Implement ready/submitting/success/unauthorized/not-found/conflict/offline/server transition states, duplicate-submit prevention, and mandatory authoritative refresh after ambiguous outcomes in mobile/lib/tickets/state/ticket_status_transition_controller.dart
- [x] T037 [US2] Implement the accessible start-work action with confirmation, disabled duplicate submission, and no optimistic status in mobile/lib/tickets/widgets/ticket_processing_actions.dart
- [x] T038 [US2] Integrate authoritative detail/list refresh after accepted or ambiguous start-work outcomes in mobile/lib/tickets/screens/technician_ticket_details_screen.dart and mobile/lib/tickets/screens/assigned_tickets_screen.dart
- [x] T039 [US2] Run focused US2 Flutter tests and verify start-work mapping, authoritative refresh, duplicate-submit protection, access loss, conflict, offline/server recovery, and absence of unsupported controls in mobile/test/tickets/technician_start_ticket_test.dart

**Checkpoint**: US2 independently proves the assignment-to-work transition with no completion,
rejection, reassignment, or other mutation.

---

## Phase 5: User Story 3 - Finish or Reject Assigned Work (Priority: P2)

**Goal**: The current technician completes in-progress work or rejects assigned/in-progress work with
a required immutable reason, while completed/rejected tickets remain terminal.

**Independent Test**: Seed owned `in_progress` and `assigned` tickets; complete one and reject each
eligible source independently. Verify reason validation, exact transition matrix, sequential stale and
terminal conflicts, locking, rollback, immutable history, and concealed non-assignment.

### Backend tests for User Story 3

- [x] T040 [P] [US3] Write failing migration/model/factory tests for nullable 1000-character history reason, legacy null reasons, rejection persistence, chronological ordering, and update/delete immutability in backend/tests/Feature/Tickets/TicketProcessingPersistenceTest.php
- [x] T041 [P] [US3] Write failing resolve/reject Feature Tests for `in_progress → completed`, `assigned → rejected`, `in_progress → rejected`, missing/blank/over-limit reason 422, `assigned → completed` 409, sequential stale/terminal conflicts, concealment, rollback, and exact history in backend/tests/Feature/Tickets/TechnicianResolveTicketTest.php

### Backend implementation for User Story 3

- [x] T042 [US3] Add the nullable 1000-character rejection reason to immutable history with a reversible migration in backend/database/migrations/2026_07_23_120000_add_reason_to_ticket_status_histories_table.php
- [x] T043 [P] [US3] Add reason fill/cast/factory support while preserving append-only update/delete guards in backend/app/Models/TicketStatusHistory.php and backend/database/factories/TicketStatusHistoryFactory.php
- [x] T044 [P] [US3] Expose nullable history reason only in technician history resources and strict response mapping in backend/app/Http/Resources/TicketStatusHistoryResource.php and backend/app/Http/Resources/TechnicianTicketResource.php
- [x] T045 [US3] Extend conditional request validation and the locked Action for only `assigned → rejected`, `in_progress → completed`, and `in_progress → rejected`, storing trimmed rejection reason and null for non-rejection in backend/app/Http/Requests/Tickets/TransitionTicketStatusRequest.php and backend/app/Actions/Tickets/TransitionTicketStatus.php
- [x] T046 [US3] Record sanitized completion/rejection, reason-validation category, terminal/invalid conflict, concealment, competing transition, and rollback diagnostics without reason text in backend/app/Support/TicketEvent.php and backend/app/Actions/Tickets/TransitionTicketStatus.php
- [x] T047 [US3] Run focused US3 Laravel tests and verify all four and only four transitions, terminal preservation, conditional reason validation, atomic rollback, locked sequential stale-conflict behavior, and immutable history in backend/tests/Feature/Tickets/TicketProcessingPersistenceTest.php and backend/tests/Feature/Tickets/TechnicianResolveTicketTest.php; true competing transactions remain outside reliable SQLite test coverage

### Flutter tests for User Story 3

- [x] T048 [US3] Write failing completion/rejection model, repository, controller, and widget tests for all three terminal paths, required/blank/over-limit reason, preserved input, terminal controls, authoritative success, conflict/assignment-loss refresh, duplicate submit, offline/server recovery, and no excluded actions in mobile/test/tickets/technician_resolve_ticket_test.dart

### Flutter implementation for User Story 3

- [x] T049 [P] [US3] Extend technician contract models and repository input validation for nullable history reason and exact terminal requests in mobile/lib/tickets/models/technician_ticket_models.dart and mobile/lib/tickets/repositories/technician_ticket_repository.dart
- [x] T050 [US3] Extend transition state for rejection field errors, preserved safe reason input, terminal outcomes, and authoritative refresh in mobile/lib/tickets/state/ticket_status_transition_controller.dart
- [x] T051 [US3] Implement complete/reject controls shown only for eligible current statuses, required rejection-reason interaction, terminal read-only state, and no unsupported controls in mobile/lib/tickets/widgets/ticket_processing_actions.dart
- [x] T052 [US3] Integrate authoritative status/history/list refresh for completion and rejection in mobile/lib/tickets/screens/technician_ticket_details_screen.dart and mobile/lib/tickets/screens/assigned_tickets_screen.dart
- [x] T053 [US3] Run focused US3 Flutter tests and verify exact transition controls, reason behavior, terminal state, authoritative refresh, denial/conflict/offline recovery, and exclusions in mobile/test/tickets/technician_resolve_ticket_test.dart

**Checkpoint**: US3 closes the approved technician workflow with immutable terminal outcomes and no
later workflow capability.

---

## Phase 6: Polish and Cross-Cutting Validation

**Purpose**: Prove compatibility, security, scope, reproducibility, and truthful environment evidence.

- [x] T054 Run `php artisan migrate:fresh --env=testing --force` and the complete Laravel Feature suite with `php artisan test --testsuite=Feature` from backend/, then record results in specs/007-ticket-processing/quickstart.md
- [x] T055 Run `vendor/bin/pint --test` and `composer validate --strict` from backend/, fix failures, and record results in specs/007-ticket-processing/quickstart.md
- [x] T056 Run `composer audit` from backend/, resolve or explicitly document applicable advisories, and record the result in specs/007-ticket-processing/quickstart.md
- [x] T057 Run `dart format --output=none --set-exit-if-changed lib test` from mobile/, fix formatting failures, and record results in specs/007-ticket-processing/quickstart.md
- [x] T058 Run `flutter analyze` from mobile/, fix all analysis failures, and record results in specs/007-ticket-processing/quickstart.md
- [x] T059 Run the complete `flutter test` suite from mobile/, fix regressions, and record results in specs/007-ticket-processing/quickstart.md
- [x] T060 Execute the eleven automated acceptance and failure scenarios through Laravel/Flutter test layers in specs/007-ticket-processing/quickstart.md and record reproducible non-device evidence without sensitive payloads
- [x] T061 Run `flutter devices` and a live technician-processing smoke test with `flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>` from mobile/ when an Android device/emulator and isolated API are available, otherwise record `DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED` with the concrete reason in specs/007-ticket-processing/quickstart.md — **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED:** `flutter devices` found only Windows, Chrome, and Edge; no Android phone or emulator is available.
- [x] T062 Audit backend/routes/api.php, mobile/lib/tickets/, dependency manifests, migration/history guards, diagnostics, resources, and tests for authorization ordering, concealed assignment, exactly three technician operations, exactly four transitions, and zero discussion, rating, reassignment, unassignment, deletion, reference-management, or unsupported-transition capability
- [x] T063 Run `git diff --check`, review the full diff for secrets/generated files/unrelated changes, trace FR-001-FR-029 and VR-001-VR-007 to tests, then mark completed items and record final evidence in specs/007-ticket-processing/tasks.md and specs/007-ticket-processing/quickstart.md

---

## Dependencies

- Setup T001-T002 freezes scope and dependencies before any implementation.
- Existing authentication, assignment, history, response, and Flutter layers must be confirmed before
  US1; no speculative foundational code is permitted.
- US1 backend tests T003-T005 precede backend implementation T006-T012; T013 verifies the completed
  read increment. Flutter tests T014-T017 precede models/service/repository/state/UI T018-T025; T026
  verifies the completed mobile read increment.
- US2 requires US1 assignment-scoped detail. T027 precedes T028-T032; T030 precedes controller route
  T031. Flutter test T034 precedes T035-T038; T039 verifies the start-work increment.
- US3 may be tested from seeded assigned/in-progress states but production work follows the shared US2
  transition surface. Tests T040-T041 precede T042-T046; migration/model/resource work T042-T044
  precedes terminal Action extension T045. Flutter test T048 precedes T049-T052; T053 verifies US3.
- Cross-cutting T054-T063 follows all stories. T061 is deliberately separate and environment-dependent;
  a concrete deferment is acceptable evidence but must never be reported as a pass.

## Parallel Opportunities

- T003-T005 are independent backend test files.
- T006-T008 affect distinct middleware/request/resource files after failing tests exist.
- T014-T017 are independent Flutter contract, list, detail, and navigation test files.
- T021-T022 are independent read-state controllers after repository contracts exist.
- T028-T029 can proceed in parallel after T027 because they affect model/factory versus request files.
- T040-T041 are independent persistence and behavior test files.
- T043-T044 affect distinct model/factory and resource files after the migration contract is fixed.
- Backend validation T055-T056 and mobile validation T057-T059 may run concurrently only when no
  formatter is actively changing the shared worktree.

## Parallel Example: User Story 1

```text
Task T003: Assigned-list contract and privacy tests
Task T004: Assigned-detail/history and concealed-target tests
Task T005: Technician route and role authorization tests

Task T014: Technician API/repository contract tests
Task T015: Assigned-list state/widget tests
Task T016: Assigned-detail state/widget tests
Task T017: Technician-only navigation tests
```

## Implementation Strategy

1. Freeze the three-operation/four-transition contract and verify existing assignment/history layers.
2. Write failing backend tests, then deliver the read-only technician list/detail MVP.
3. Write failing Flutter tests, then deliver technician models/transport/repository/read states/UI.
4. Write start-work tests, then add the locked atomic `assigned → in_progress` path and authoritative
   client refresh.
5. Write terminal persistence/behavior tests, add nullable immutable reason history, then deliver
   completion and rejection paths plus Flutter reason handling.
6. Stop at the US3 checkpoint; do not add discussions, ratings, assignment changes, deletion,
   reference management, or any other transition.
7. Run the full non-device quality/security/scope matrix, then execute or truthfully defer the separate
   live-device smoke task according to the environment.

The suggested MVP is US1 only: technician-private assigned list and detail/history with no mutation.

## Notes

- `[P]` tasks touch distinct files and have no incomplete dependency beyond the stated checkpoint.
- `[US1]`, `[US2]`, and `[US3]` map story tasks directly to the specification's prioritized stories.
- Tests precede implementation and failing baselines must be observed before production changes.
- Discussions, ratings, reassignment, unassignment, deletion, reference-data management, and
  unsupported transitions are excluded from every phase.
- Do not create a commit or push as part of this task list execution unless separately authorized.
- Stop if implementation conflicts with spec.md, plan.md, research.md, data-model.md, or openapi.yaml.
