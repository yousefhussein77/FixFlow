# Tasks: Ticket Assignment

**Input**: Design documents from `specs/006-ticket-assignment/`

**Verification**: Laravel and Flutter tests are mandatory and precede the corresponding implementation.
Every accepted assignment must prove one-time atomic technician/status/history behavior; every rejected
path must prove unchanged ticket and history state and non-disclosure where required.

## Phase 1: Setup

**Purpose**: Confirm the approved boundaries and existing foundations before implementation changes.

- [X] T001 Verify no new package is required and preserve dependency versions in backend/composer.json and mobile/pubspec.yaml
- [X] T002 Audit the three approved operations, response fields, error codes, page limits, and excluded routes against specs/006-ticket-assignment/contracts/openapi.yaml and specs/006-ticket-assignment/plan.md before changing application files

---

## Phase 2: Foundational Prerequisites

**Purpose**: Reuse existing project-wide authentication, response, and layering foundations.

No new shared foundation is required. Implementation begins only after confirming the existing
`auth:sanctum`, `active`, and `administrator` middleware chain in `backend/routes/api.php`, the
canonical envelope in `backend/app/Support/ApiResponse.php`, and the Flutter service/repository/state
separation under `mobile/lib/tickets/`. Any defect found in those shared foundations must be resolved
as a separately reviewed prerequisite rather than hidden inside this feature.

**Checkpoint**: Existing authentication and architecture foundations are confirmed; US1 may begin.

---

## Phase 3: User Story 1 - Assign Tickets for Resolution (P1) MVP

**Goal**: An active administrator lists all Version 1 oversight tickets, loads minimal active-technician
choices, and assigns one `new` unassigned ticket exactly once so technician, `assigned` status, and one
immutable history row commit atomically.

**Independent Test**: Create tickets for multiple reporters; verify the administrator queue and active
technician choices; assign one ticket; then exercise malformed/ineligible users, wrong actors, unknown
or concealed tickets, stale state, database failure, and competing requests. Exactly one valid attempt
must commit and all rejected attempts must leave assignment, status, update time, and history unchanged.

### Backend tests for User Story 1

> Write these tests first and observe the focused suite fail before implementation.

- [X] T003 [P] [US1] Write failing migration, relationship, invariant, immutability, and factory tests for the ticket technician and status-history schema in backend/tests/Feature/Tickets/TicketAssignmentPersistenceTest.php
- [X] T004 [P] [US1] Write failing administrator list tests for multi-reporter visibility, explicit null/assigned technician, exact summary fields, stable `(created_at,id)` pagination, empty/out-of-range pages, invalid page inputs, and 401/403 non-disclosure in backend/tests/Feature/Tickets/AdminListTicketsTest.php
- [X] T005 [P] [US1] Write failing active-technician option tests for minimal id/name output, deterministic ordering, empty results, exclusion of inactive/non-technician users, and 401/403 non-disclosure in backend/tests/Feature/Tickets/TechnicianOptionsTest.php
- [X] T006 [P] [US1] Write failing assignment Feature Tests for success/history, unknown/inactive/non-technician 422 rollback, concealed 404, non-new/already-assigned 409, inactive/wrong-role actors, injected transaction failure, competing assignments, sanitized envelopes, and unchanged timestamps/history in backend/tests/Feature/Tickets/AssignTicketTest.php

### Backend implementation for User Story 1

- [X] T007 [P] [US1] Add the nullable restricted `assigned_technician_id` ticket foreign key/index and append-only status-history table/indexes in backend/database/migrations/2026_07_23_110000_add_assigned_technician_to_tickets_table.php and backend/database/migrations/2026_07_23_110100_create_ticket_status_histories_table.php
- [X] T008 [P] [US1] Add reproducible assigned-ticket and immutable-history factory states in backend/database/factories/TicketFactory.php and backend/database/factories/TicketStatusHistoryFactory.php using existing administrator/technician UserFactory states
- [X] T009 [US1] Add `STATUS_ASSIGNED`, guarded technician assignment, technician/history relationships, chronological history ordering, and the TicketStatusHistory model in backend/app/Models/Ticket.php, backend/app/Models/User.php, and backend/app/Models/TicketStatusHistory.php
- [X] T010 [P] [US1] Implement page/per-page validation with default 20 and maximum 100 in backend/app/Http/Requests/Tickets/AdminListTicketsRequest.php
- [X] T011 [P] [US1] Implement assignment payload shape validation for only `technician_id` while leaving authoritative eligibility to the transaction in backend/app/Http/Requests/Tickets/AssignTicketRequest.php
- [X] T012 [P] [US1] Implement administrator-only ticket, user summary, and technician option mappings with explicit nullable assignee and no restricted extra fields in backend/app/Http/Resources/AdminTicketSummaryResource.php and backend/app/Http/Resources/TechnicianOptionResource.php
- [X] T013 [P] [US1] Implement the all-ticket Version 1 oversight query with eager loading and stable newest-first pagination in backend/app/Actions/Tickets/ListAdminTickets.php
- [X] T014 [P] [US1] Implement the minimal active-technician query ordered by normalized name then id in backend/app/Actions/Tickets/ListActiveTechnicians.php
- [X] T015 [US1] Implement one-time assignment in backend/app/Actions/Tickets/AssignTicket.php using a database transaction and ticket row lock, commit-time technician revalidation, `new`/null invariant checks, atomic ticket update plus one history insert, 422 eligibility outcomes, 409 conflicts, and full rollback on failure
- [X] T016 [US1] Add thin administrator list/assignment and technician-option controllers with canonical success/error envelopes and concealed ticket lookup in backend/app/Http/Controllers/Api/AdminTicketController.php and backend/app/Http/Controllers/Api/AdminTechnicianOptionController.php
- [X] T017 [US1] Register only GET `/api/admin/tickets`, GET `/api/admin/options/technicians`, and PATCH `/api/admin/tickets/{reference}/assignment` behind `auth:sanctum`, `active`, and `administrator` middleware in backend/routes/api.php
- [X] T018 [US1] Record sanitized list, option, assignment, eligibility-denial, concealed-target, conflict, and failure events without ticket content or user personal data in backend/app/Support/TicketEvent.php and the new admin Actions/controllers
- [X] T019 [US1] Run the focused ticket-assignment Laravel tests and verify migrations, exact envelopes, one-winner concurrency, rollback, immutable history, and absence of reassignment/unassignment routes using backend/tests/Feature/Tickets/

### Flutter tests for User Story 1

> Write these tests before the corresponding Flutter implementation and observe them fail.

- [X] T020 [P] [US1] Write failing admin model, API-envelope, repository mapping, nullable-assignee, pagination, 401/403/404/409/422/500, offline, and malformed-contract tests in mobile/test/tickets/admin_ticket_repository_test.dart
- [X] T021 [P] [US1] Write failing administrator queue controller/widget tests for loading, populated, empty, loading-more, stable de-duplication, explicit Unassigned display, retry, stale results, authorization loss, offline, server error, and excluded controls in mobile/test/tickets/admin_ticket_list_test.dart
- [X] T022 [P] [US1] Write failing technician option controller/widget tests for loading, ready, empty, minimal choices, stale-response rejection, unauthorized, offline, server error, and disabled assignment when empty in mobile/test/tickets/technician_options_test.dart
- [X] T023 [P] [US1] Write failing assignment controller/widget tests for duplicate-submit prevention, authoritative success update, field validation, selected-option preservation, concealed not-found, conflict refresh, ambiguous offline/server refresh, authorization loss, and no optimistic state in mobile/test/tickets/ticket_assignment_test.dart
- [X] T024 [P] [US1] Write failing administrator navigation and access-denied tests proving only administrator profiles expose the queue entry and restricted response data is cleared in mobile/test/auth/administrator_ticket_access_test.dart

### Flutter implementation for User Story 1

- [X] T025 [US1] Add admin ticket summary/page, technician option, assignment result, nullable assignee, and typed failure models without changing reporter payload models in mobile/lib/tickets/models/admin_ticket_models.dart
- [X] T026 [US1] Implement authenticated GET/PATCH transport for the three documented admin endpoints with canonical envelope and HTTP/failure mapping in mobile/lib/tickets/services/admin_ticket_api_service.dart
- [X] T027 [US1] Implement secure-token access, strict response/meta parsing, and admin list/options/assignment repository methods in mobile/lib/tickets/repositories/admin_ticket_repository.dart
- [X] T028 [P] [US1] Implement administrator queue loading/populated/empty/loading-more/unauthorized/offline/server states, generation-based stale-result suppression, and reference de-duplication in mobile/lib/tickets/state/admin_ticket_list_controller.dart
- [X] T029 [P] [US1] Implement technician option loading/ready/empty/unauthorized/offline/server states and stale-result suppression in mobile/lib/tickets/state/technician_options_controller.dart
- [X] T030 [US1] Implement ready/submitting/success/validation/unauthorized/not-found/conflict/offline/server assignment states, duplicate-submit blocking, no optimistic update, and mandatory refresh after ambiguous or stale outcomes in mobile/lib/tickets/state/ticket_assignment_controller.dart
- [X] T031 [US1] Implement the accessible localization-ready administrator ticket queue with reporter, status, priority, classification, technician/Unassigned, paging, retry, and assign eligibility rendering in mobile/lib/tickets/screens/admin_ticket_list_screen.dart
- [X] T032 [US1] Implement active-technician loading/empty/error selection and one-time assignment confirmation without reassignment, unassignment, processing, discussion, rating, or deletion controls in mobile/lib/tickets/widgets/ticket_assignment_sheet.dart
- [X] T033 [US1] Wire existing manual dependency injection and administrator-only navigation while clearing restricted state on denial/session loss in mobile/lib/main.dart, mobile/lib/app.dart, and mobile/lib/auth/screens/profile_screen.dart
- [X] T034 [US1] Run all focused Flutter ticket-assignment tests and verify authoritative row refresh, access-denied data clearing, duplicate-submit protection, conflict/offline recovery, accessible labels, and absence of excluded actions under mobile/test/tickets/ and mobile/test/auth/

**Checkpoint**: US1 is independently demonstrable from administrator queue through one accepted
assignment, with all rejection/privacy/concurrency paths verified and no later workflow capability.

---

## Phase 4: Polish and Cross-Cutting Validation

**Purpose**: Prove compatibility, security, scope, quality, and reproducibility across the repository.

- [X] T035 Run `php artisan migrate:fresh --env=testing` and the complete Laravel Feature suite with `php artisan test --testsuite=Feature` from backend/, then record results in specs/006-ticket-assignment/quickstart.md
- [X] T036 Run `vendor/bin/pint --test` and `composer validate --strict` from backend/, fix formatting/manifest failures, and record results in specs/006-ticket-assignment/quickstart.md
- [X] T037 Run `composer audit` from backend/, resolve or explicitly document any applicable advisory, and record the result in specs/006-ticket-assignment/quickstart.md
- [X] T038 Run `dart format --output=none --set-exit-if-changed lib test` from mobile/, fix formatting failures, and record the result in specs/006-ticket-assignment/quickstart.md
- [X] T039 Run `flutter analyze` from mobile/, fix all analysis failures, and record the result in specs/006-ticket-assignment/quickstart.md
- [X] T040 Run the complete `flutter test` suite from mobile/, fix regressions, and record the result in specs/006-ticket-assignment/quickstart.md
- [ ] T041 **DEFERRED — environment blocker:** Execute all eleven end-to-end and failure scenarios in specs/006-ticket-assignment/quickstart.md against an isolated live API/mobile environment and record reproducible evidence without sensitive payloads; no Android phone or emulator is available on this machine
- [X] T042 Run `flutter devices` and an administrator assignment smoke test with `flutter run -d <device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>` from mobile/, or record the concrete external blocker in specs/006-ticket-assignment/quickstart.md
- [X] T043 Audit backend/routes/api.php, mobile/lib/tickets/, dependency manifests, migrations, diagnostics, and tests for authorization ordering, restricted-data behavior, exactly three approved operations, immutable history, and zero reassignment, unassignment, processing, discussion, rating, or deletion capability
- [X] T044 Run `git diff --check`, review the full diff for secrets/generated files/unrelated changes, trace FR-001-FR-025 and VR-001-VR-007 to tests, then mark completed items and record final evidence in specs/006-ticket-assignment/tasks.md and specs/006-ticket-assignment/quickstart.md

---

## Dependencies

- Setup (T001-T002) confirms scope and dependencies before any implementation.
- Existing foundational authentication/envelope/layering must be confirmed before US1.
- Backend tests T003-T006 must be written and observed failing before backend implementation.
- Persistence T007-T009 precedes Actions/controllers; request/resource tasks T010-T012 can proceed in
  parallel after the failing tests exist.
- List and option Actions T013-T014 can proceed in parallel; atomic assignment T015 depends on T007-T012.
- Controllers/routes/diagnostics T016-T018 depend on their Actions/resources; focused verification T019
  follows all backend US1 work.
- Flutter tests T020-T024 may be written in parallel once the OpenAPI contract is fixed. Models T025
  precede service T026 and repository T027; controllers T028-T030 depend on repository interfaces.
- Screens T031-T032 depend on their controllers; composition/navigation T033 follows working screens;
  focused Flutter verification T034 follows all mobile US1 work.
- Cross-cutting validation T035-T044 follows the complete US1 checkpoint.

## Parallel Opportunities

- T003-T006 are separate backend test files and can be authored in parallel.
- T007, T008, T010, T011, and T012 affect separate migration/factory/request/resource files after the
  failing test baseline is observed.
- T013 and T014 are independent read Actions.
- T020-T024 are separate Flutter test files and can be authored in parallel.
- T028 and T029 are independent read-state controllers after the repository contract exists.
- Backend validation T036-T037 and mobile validation T038-T040 may run concurrently when no formatter
  is actively changing the same worktree.

## Parallel Example: User Story 1

```text
Task T003: Persistence/history failing tests
Task T004: Administrator list failing tests
Task T005: Technician option failing tests
Task T006: Atomic assignment/concurrency failing tests

Task T020: Flutter contract/repository failing tests
Task T021: Flutter administrator queue failing tests
Task T022: Flutter technician option failing tests
Task T023: Flutter assignment failing tests
Task T024: Flutter administrator access failing tests
```

## Implementation Strategy

1. Freeze the approved contract and verify existing foundations.
2. Write and observe failing backend tests.
3. Deliver the administrator queue as the first read-only reviewable increment.
4. Deliver active-technician discovery as the second read-only increment.
5. Deliver locked transactional one-time assignment and immutable history as the mutation increment.
6. Write and observe failing Flutter tests, then deliver models/transport/repository, read states, and
   assignment UI in small reviewable increments.
7. Stop at the US1 checkpoint and prove all acceptance, failure, privacy, and concurrency scenarios.
8. Run the complete formatting, test, analysis, security, diff, scope, and emulator validation matrix.

The MVP is US1 only. No task introduces reassignment, unassignment, technician processing,
discussions, ratings, deletion, bulk assignment, advanced filtering, or any status transition other
than `new` to `assigned`.

## Notes

- `[P]` tasks touch distinct files and have no incomplete dependency beyond the stated checkpoint.
- `[US1]` maps every story-phase task to the sole P1 user story.
- Tests precede implementation and must be observed failing before production changes.
- Commit after each task or small logical group; do not implement the whole backend or mobile slice in
  one operation.
- Stop if implementation conflicts with spec.md, plan.md, data-model.md, or contracts/openapi.yaml.
