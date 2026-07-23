# Tasks: Reporter Ticket Creation and Tracking

**Input**: Design documents from `specs/005-ticket-creation/`

## Phase 1: Setup

- [X] T001 Verify repository ignore rules cover Laravel, Flutter, secrets, generated output, and IDE files in .gitignore
- [X] T002 Verify ticket API and mobile implementation need no new dependencies in backend/composer.json and mobile/pubspec.yaml

## Phase 2: Foundational

- [X] T003 Add reporter-role middleware and registration alias in backend/app/Http/Middleware/EnsureUserIsReporter.php and backend/bootstrap/app.php
- [X] T004 [P] Add ticket and ticket-photo migrations in backend/database/migrations/2026_07_23_100000_create_tickets_table.php and backend/database/migrations/2026_07_23_100100_create_ticket_photos_table.php
- [X] T005 [P] Add Ticket and TicketPhoto factories in backend/database/factories/TicketFactory.php and backend/database/factories/TicketPhotoFactory.php
- [X] T006 Add ticket relationships to backend/app/Models/User.php, backend/app/Models/Department.php, and backend/app/Models/Category.php
- [X] T007 Add ticket models and invariants in backend/app/Models/Ticket.php and backend/app/Models/TicketPhoto.php
- [X] T008 [P] Add shared ticket REST resource mappings in backend/app/Http/Resources/TicketSummaryResource.php and backend/app/Http/Resources/TicketResource.php
- [X] T009 [P] Add shared Flutter ticket contract models and failure states in mobile/lib/tickets/models/ticket_models.dart

## Phase 3: User Story 1 - Create a Maintenance Ticket (P1)

**Goal**: An active authenticated reporter creates exactly one validated ticket with zero to five photos.

**Independent Test**: Submit valid zero/five-photo requests and invalid relationship/upload/failure/retry requests; verify authoritative fields, atomic records/files, and one result per reporter token.

- [X] T010 [US1] Write failing creation, validation, authorization, idempotency, and rollback Feature Tests in backend/tests/Feature/Tickets/CreateTicketTest.php
- [X] T011 [P] [US1] Add create-ticket Form Request validation and trimming in backend/app/Http/Requests/Tickets/CreateTicketRequest.php
- [X] T012 [US1] Implement transactional idempotent ticket and photo creation in backend/app/Actions/Tickets/CreateTicket.php
- [X] T013 [US1] Add thin create endpoint and reporter route group in backend/app/Http/Controllers/Api/TicketController.php and backend/routes/api.php
- [X] T014 [P] [US1] Write Flutter creation model, repository, controller, and widget tests in mobile/test/tickets/ticket_creation_test.dart
- [X] T015 [US1] Implement multipart ticket API transport and repository mapping in mobile/lib/tickets/services/ticket_api_service.dart and mobile/lib/tickets/repositories/ticket_repository.dart
- [X] T016 [US1] Implement creation state, photo validation, stale option rejection, and duplicate-submit prevention in mobile/lib/tickets/state/ticket_creation_controller.dart
- [X] T017 [US1] Implement accessible localized-ready Create Ticket screen states in mobile/lib/tickets/screens/create_ticket_screen.dart

## Phase 4: User Story 2 - List My Tickets (P2)

**Goal**: A reporter sees only owned tickets in stable newest-first pages with empty and retry states.

**Independent Test**: Seed two reporters and tied timestamps; traverse pages and verify owned counts, ordering, no duplicates, empty state, validation, authorization, offline, and server recovery.

- [X] T018 [US2] Write failing owned pagination and authorization Feature Tests in backend/tests/Feature/Tickets/ListTicketsTest.php
- [X] T019 [P] [US2] Add pagination Form Request in backend/app/Http/Requests/Tickets/ListTicketsRequest.php
- [X] T020 [US2] Implement ownership-first paginated list endpoint in backend/app/Http/Controllers/Api/TicketController.php
- [X] T021 [P] [US2] Write Flutter list mapping, pagination, authorization, offline, retry, and widget tests in mobile/test/tickets/my_tickets_test.dart
- [X] T022 [US2] Implement owned list service/repository operations in mobile/lib/tickets/services/ticket_api_service.dart and mobile/lib/tickets/repositories/ticket_repository.dart
- [X] T023 [US2] Implement duplicate-safe pagination state in mobile/lib/tickets/state/my_tickets_controller.dart
- [X] T024 [US2] Implement My Tickets populated, empty, loading, and retry UI in mobile/lib/tickets/screens/my_tickets_screen.dart

## Phase 5: User Story 3 - View My Ticket Details (P3)

**Goal**: A reporter views complete owned details while non-owned and unknown tickets are indistinguishable.

**Independent Test**: Fetch owned/non-owned/unknown details and verify full fields, photos, identical concealed 404 behavior, auth denial, offline/server/photo-unavailable states.

- [X] T025 [US3] Write failing owned detail, concealment, role, and authentication Feature Tests in backend/tests/Feature/Tickets/ShowTicketTest.php
- [X] T026 [US3] Implement ownership-scoped detail endpoint in backend/app/Http/Controllers/Api/TicketController.php
- [X] T027 [P] [US3] Write Flutter detail mapping, concealment, recovery, photo-unavailable, and widget tests in mobile/test/tickets/ticket_details_test.dart
- [X] T028 [US3] Implement detail service/repository operation in mobile/lib/tickets/services/ticket_api_service.dart and mobile/lib/tickets/repositories/ticket_repository.dart
- [X] T029 [US3] Implement detail state and retry behavior in mobile/lib/tickets/state/ticket_details_controller.dart
- [X] T030 [US3] Implement Ticket Details screen states in mobile/lib/tickets/screens/ticket_details_screen.dart
- [X] T031 [US3] Integrate reporter ticket navigation without excluded controls in mobile/lib/auth/screens/profile_screen.dart

## Phase 6: Polish and Cross-Cutting Validation

- [X] T032 Add structured sanitized ticket diagnostics in backend/app/Support/TicketEvent.php and creation/read paths
- [X] T033 Run migrations and all Laravel Feature Tests, fix failures, and record commands in specs/005-ticket-creation/quickstart.md
- [X] T034 Run Pint, Composer validation, Composer security audit, and backend scope/authorization/secret/dependency/route/migration/storage audits
- [X] T035 Run Dart formatting, Flutter analysis, all unit/widget tests, and fix failures
- [X] T036 Record Android emulator verification as deferred because Gradle cannot reach dl.google.com:443 in specs/005-ticket-creation/quickstart.md
- [X] T037 Audit implementation against FR-001-FR-031 and excluded scope, then mark every completed task in specs/005-ticket-creation/tasks.md

## Dependencies

- Setup (T001-T002) precedes foundational work (T003-T009).
- Foundational work precedes all user stories.
- US1 (T010-T017) is the MVP and precedes UI navigation; US2 and US3 depend on ticket persistence but
  are independently testable after foundations. US3 navigation (T031) follows US1-US3 screens.
- Polish (T032-T037) follows all stories.

## Parallel Opportunities

- T004, T005, T008, and T009 affect distinct files after middleware setup.
- Within US1, T011 and T014 can proceed after the failing backend test is observed.
- T019/T021 and T027 can proceed independently from their backend endpoint implementation.

## Implementation Strategy

1. Complete foundations and observe the US1 backend tests fail.
2. Deliver and verify ticket creation without photos, then photo atomicity/idempotency, then Flutter.
3. Add owned list and detail as separate tested increments.
4. Run the complete quality/security/audit matrix and update this checklist.

All 37 tasks use the required checklist format with sequential IDs, story labels only in story phases,
parallel markers only for distinct files, and explicit paths.
