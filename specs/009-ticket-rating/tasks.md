# Tasks: Ticket Rating

**Input**: Design documents from `specs/009-ticket-rating/`

**Verification**: Laravel and Flutter tests are mandatory and precede corresponding implementation.
Every accepted rating must prove exactly one immutable record or an authoritative replay of that same
logical submission; every rejected path must prove the original rating and all ticket workflow data
remain unchanged, with concealed responses where ownership requires it.

## Phase 1: Setup

**Purpose**: Freeze the approved one-rating boundary and verify reusable project foundations.

- [x] T001 Verify no package addition is required and preserve dependency versions in backend/composer.json, backend/composer.lock, mobile/pubspec.yaml, and mobile/pubspec.lock
- [x] T002 Audit the one POST operation, additive reporter-detail rating field, integer 1–5 boundary, UUID replay semantics, status codes, schemas, authorization precedence, and exclusions against specs/009-ticket-rating/contracts/openapi.yaml, specs/009-ticket-rating/data-model.md, specs/009-ticket-rating/research.md, and specs/009-ticket-rating/plan.md

---

## Phase 2: Foundational Prerequisites

**Purpose**: Reuse authentication, reporter ownership, ticket completion state, canonical envelopes,
diagnostics, secure token access, and Flutter layering without introducing unrelated infrastructure.

No new shared project-wide foundation is required. Confirm the existing `auth:sanctum`, `active`, and
`reporter` route chain; ownership-scoped ticket detail; canonical `ApiResponse`; `TicketEvent`;
transaction support; secure token store; and Flutter model/service/repository/state/manual-injection
architecture. Any unrelated defect remains outside this feature.

**Checkpoint**: Existing foundations are confirmed; User Story 1 can add one immutable rating and
authorized reporter-detail visibility without changing ticket workflow data.

---

## Phase 3: User Story 1 - Rate My Completed Ticket (Priority: P1) MVP

**Goal**: An active reporter rates an owned completed unrated ticket exactly once, safely replays the
same accepted UUID submission, and sees the authoritative immutable score on owned ticket details.

**Independent Test**: Create owned completed tickets, submit valid values including 1 and 5, replay
one accepted token, and verify exactly one immutable rating with authoritative value/time appears on
the matching reporter detail while unrated detail remains explicitly null.

### Backend tests for User Story 1

> Write these tests first and observe the focused suite fail before implementation.

- [x] T003 [P] [US1] Write failing migration/model/factory tests for ticket/reporter relationships, integer 1–5 boundaries, unique ticket, scoped UUID uniqueness, absent `updated_at`, restricted foreign keys, and update/delete immutability in backend/tests/Feature/Tickets/TicketRatingPersistenceTest.php
- [x] T004 [P] [US1] Write failing reporter creation tests for values 1–5, authenticated author and authoritative time preservation, exact 201 resource/envelope, unchanged ticket/status/history/comments, and nullable/filled authorized detail visibility in backend/tests/Feature/Tickets/ReporterTicketRatingTest.php
- [x] T005 [P] [US1] Write failing retry tests for same-token 200 replay with identical payload, distinct tokens across different tickets, retained original creation time, no duplicate row, and safe replay after an ambiguous accepted response in backend/tests/Feature/Tickets/TicketRatingIdempotencyTest.php
- [x] T006 [P] [US1] Write failing atomicity/idempotency tests for sequential same-token replay and distinct-token conflict, database uniqueness, deterministic mapping, injected persistence rollback, safe later retry, and zero ticket workflow mutation in backend/tests/Feature/Tickets/TicketRatingIdempotencyTest.php

### Backend implementation for User Story 1

- [x] T007 [US1] Add a reversible `ticket_ratings` migration with restricted ticket/reporter foreign keys, integer value check, UUID submission token, authoritative `created_at` only, unique `ticket_id`, and unique `(ticket_id,reporter_id,submission_token)` in backend/database/migrations/2026_07_25_090000_create_ticket_ratings_table.php
- [x] T008 [P] [US1] Implement reproducible rating factory states for owned completed tickets, explicit reporter/value/token/time, boundary values, and rated/unrated scenarios in backend/database/factories/TicketRatingFactory.php
- [x] T009 [US1] Implement TicketRating fill rules, casts, no-update timestamp, ticket/reporter relationships, and update/delete immutability guards in backend/app/Models/TicketRating.php
- [x] T010 [US1] Add optional one-to-one rating and authored-ratings relationships without changing existing ticket fillable workflow fields in backend/app/Models/Ticket.php and backend/app/Models/User.php
- [x] T011 [P] [US1] Implement the exact immutable public `{value,rated_at}` mapping without persistence IDs, reporter profile, token, or internal fields in backend/app/Http/Resources/TicketRatingResource.php
- [x] T012 [US1] Implement a transactional CreateTicketRating Action that ownership-scopes and locks the ticket, replays an identical scoped token, rejects a distinct existing rating, verifies exact `completed` status, inserts authenticated reporter/value/time once, and safely maps uniqueness races in backend/app/Actions/Tickets/CreateTicketRating.php
- [x] T013 [US1] Implement a thin reporter rating controller returning canonical 201 creation, 200 replay, 404 concealment, 409 conflict, and sanitized 500 outcomes in backend/app/Http/Controllers/Api/ReporterTicketRatingController.php
- [x] T014 [US1] Register only POST `/api/reporter/tickets/{reference}/rating` behind existing `auth:sanctum`, `active`, and `reporter` middleware in backend/routes/api.php
- [x] T015 [US1] Eager-load and add nullable `rating` to authorized reporter detail only through backend/app/Http/Controllers/Api/TicketController.php and backend/app/Http/Resources/TicketResource.php
- [x] T016 [US1] Record sanitized rating accepted/replayed/conflict/rollback events without rating value, submission token, ticket text, credentials, or unnecessary personal data in backend/app/Support/TicketEvent.php and backend/app/Http/Controllers/Api/ReporterTicketRatingController.php
- [x] T017 [US1] Run focused US1 Laravel tests and verify one immutable rating, authoritative sequential replay, ticket locking/database uniqueness, rollback, exact resource shape, additive owned detail visibility, and zero edit/delete route in backend/tests/Feature/Tickets/TicketRatingPersistenceTest.php, backend/tests/Feature/Tickets/ReporterTicketRatingTest.php, and backend/tests/Feature/Tickets/TicketRatingIdempotencyTest.php; true cross-connection races are not claimed under SQLite

### Flutter tests for User Story 1

> Write these tests before the corresponding Flutter implementation and observe them fail.

- [x] T018 [P] [US1] Write failing rating model/API/repository tests for strict nullable detail mapping, POST request shape/path, values 1 and 5, 201 creation, 200 replay, malformed success contracts, canonical failures, and offline mapping in mobile/test/tickets/ticket_rating_repository_test.dart
- [x] T019 [P] [US1] Write rating controller tests for selected-value validation, authoritative success, and distinct already-rated/not-completed conflict states in mobile/test/tickets/ticket_rating_controller_test.dart; retry/token behavior and widget replacement synchronization are verified in their dedicated test files
- [x] T020 [P] [US1] Write failing retry tests for one UUID per logical attempt, same-token ambiguous retry, no optimistic success, authoritative create/replay reconciliation, token clearing after success, and detail refresh in mobile/test/tickets/ticket_rating_retry_test.dart
- [x] T021 [P] [US1] Write failing reporter detail/widget tests for completed-unrated input, accessible 1–5 selection, explicit submission, success display, already-rated display, unrated non-completed display, and no edit/delete/review/second-rating controls in mobile/test/tickets/reporter_ticket_rating_test.dart

### Flutter implementation for User Story 1

- [x] T022 [US1] Implement strict rating representation, create result, request, and typed failure models in mobile/lib/tickets/models/ticket_rating_models.dart and add nullable rating parsing to mobile/lib/tickets/models/ticket_models.dart
- [x] T023 [US1] Implement authenticated reporter POST transport with exact `{rating,submission_token}` shape and canonical 200/201/401/403/404/409/422/500, offline, and contract mapping in mobile/lib/tickets/services/ticket_rating_api_service.dart
- [x] T024 [US1] Implement secure-token rating creation/replay repository behavior with strict integer validation and authoritative response parsing in mobile/lib/tickets/repositories/ticket_rating_repository.dart
- [x] T025 [US1] Implement eligible/selection/submitting/success/already-rated/validation/concealed/unauthorized/offline/server states, generation-based stale suppression, duplicate-submit blocking, and one-token retry lifecycle in mobile/lib/tickets/state/ticket_rating_controller.dart
- [x] T026 [US1] Implement accessible localization-ready whole-number 1–5 input, explicit submit, progress, authoritative success, and immutable already-rated display without optimistic, edit, delete, or review-text controls in mobile/lib/tickets/widgets/ticket_rating_section.dart
- [x] T027 [US1] Integrate the rating section only into authorized reporter ticket detail, pass authoritative status/rating, refresh detail after success/conflict, and clear restricted rating state after access loss in mobile/lib/tickets/screens/ticket_details_screen.dart and mobile/lib/tickets/state/ticket_details_controller.dart
- [x] T028 [US1] Wire the existing manual dependency composition for TicketRatingApiService and TicketRatingRepository without exposing technician/admin rating navigation in mobile/lib/main.dart, mobile/lib/app.dart, mobile/lib/auth/screens/session_gate.dart, and mobile/lib/auth/screens/profile_screen.dart
- [x] T029 [US1] Run focused US1 Flutter tests and verify strict contracts, eligible entry, authoritative success/replay, already-rated display, retained-token retry, duplicate blocking, detail refresh, and absence of excluded controls in mobile/test/tickets/ticket_rating_repository_test.dart, mobile/test/tickets/ticket_rating_controller_test.dart, mobile/test/tickets/ticket_rating_retry_test.dart, and mobile/test/tickets/reporter_ticket_rating_test.dart

**Checkpoint**: User Story 1 independently delivers one immutable reporter-owned completed-ticket
rating with safe replay and authorized detail visibility. No rating mutation or ticket workflow
mutation exists.

---

## Phase 4: User Story 2 - Prevent Invalid or Premature Ratings (Priority: P1)

**Goal**: Invalid values and every non-completed ticket are rejected clearly and atomically without
creating a rating or altering ticket, status history, assignment, comments, or an original rating.

**Independent Test**: Submit missing, fractional, textual, Boolean, structured, and out-of-range
values against completed tickets and valid values against every non-completed status; verify exact
422/409 behavior, unchanged data, and corresponding Flutter validation/eligibility states.

### Backend tests for User Story 2

- [x] T030 [P] [US2] Extend failing request tests for missing, 0, 6, negative, fractional, numeric-string, text, Boolean, array, object, malformed UUID, and unsupported fields with no write in backend/tests/Feature/Tickets/ReporterTicketRatingTest.php
- [x] T031 [P] [US2] Write failing eligibility tests for owned `new`, `assigned`, `in_progress`, and `rejected` tickets returning `409 TICKET_NOT_COMPLETED` with unchanged rating/ticket/timestamp/assignment/history/comments in backend/tests/Feature/Tickets/TicketRatingEligibilityTest.php

### Backend implementation for User Story 2

- [x] T032 [US2] Implement strict additional-field rejection and native integer 1–5 plus UUID validation in backend/app/Http/Requests/Tickets/CreateTicketRatingRequest.php
- [x] T033 [US2] Finalize commit-time completed-status conflict mapping without any status/history/assignment mutation in backend/app/Actions/Tickets/CreateTicketRating.php and backend/app/Http/Controllers/Api/ReporterTicketRatingController.php
- [x] T034 [US2] Run focused invalid-input and eligibility Laravel tests and verify exact field errors/conflict codes and zero stored mutation in backend/tests/Feature/Tickets/ReporterTicketRatingTest.php and backend/tests/Feature/Tickets/TicketRatingEligibilityTest.php

### Flutter tests and implementation for User Story 2

- [x] T035 [P] [US2] Extend failing repository/controller/widget tests for integer boundary validation, malformed input prevention, `TICKET_NOT_COMPLETED`, stale completed state, safe selected-value preservation, and no non-completed submission control in mobile/test/tickets/ticket_rating_repository_test.dart, mobile/test/tickets/ticket_rating_controller_test.dart, and mobile/test/tickets/reporter_ticket_rating_test.dart
- [x] T036 [US2] Implement local integer-boundary validation, field error presentation, non-completed read-only unrated state, and authoritative eligibility-conflict refresh in mobile/lib/tickets/repositories/ticket_rating_repository.dart, mobile/lib/tickets/state/ticket_rating_controller.dart, and mobile/lib/tickets/widgets/ticket_rating_section.dart
- [x] T037 [US2] Run focused US2 Flutter tests and verify values 1–5 only, clear validation, non-completed suppression, preserved safe selection, authoritative refresh, and no false success in mobile/test/tickets/ticket_rating_repository_test.dart, mobile/test/tickets/ticket_rating_controller_test.dart, and mobile/test/tickets/reporter_ticket_rating_test.dart

**Checkpoint**: User Story 2 independently proves rating data integrity for value and completion
eligibility without introducing status processing.

---

## Phase 5: User Story 3 - Protect Rating Ownership (Priority: P1)

**Goal**: Reporter ownership is enforced before eligibility disclosure; unknown and non-owned targets
are concealed, and technician/administrator/unauthenticated actors cannot rate or gain rating access.

**Independent Test**: Compare unknown and other-owned completed/uncompleted/rated targets, then test
missing, revoked, inactive, technician, and administrator actors; prove materially equivalent
concealment, no rating information, no write, and restricted Flutter state clearing.

### Backend tests for User Story 3

- [x] T038 [P] [US3] Write failing ownership tests comparing unknown and non-owned rated/unrated/completed/non-completed references for identical 404 status, code, message, shape, and no timing-dependent data fields in backend/tests/Feature/Tickets/TicketRatingAuthorizationTest.php
- [x] T039 [P] [US3] Write failing route-role tests for unauthenticated, invalid/revoked token, inactive reporter, technician, and administrator actors proving 401/403 precedence before target resolution and only one POST rating operation in backend/tests/Feature/Tickets/TicketRatingAuthorizationTest.php
- [x] T040 [P] [US3] Extend reporter detail tests proving nullable rating visibility only through owned reporter detail and no rating field leakage through non-owned, technician, administrator, list, or unauthorized responses beyond separately approved contracts in backend/tests/Feature/Tickets/ReporterTicketRatingTest.php

### Backend implementation for User Story 3

- [x] T041 [US3] Finalize reporter ownership-scoped locked lookup and identical concealed target mapping before completion/rating checks in backend/app/Actions/Tickets/CreateTicketRating.php and backend/app/Http/Controllers/Api/ReporterTicketRatingController.php
- [x] T042 [US3] Ensure rating eager loading/resource composition occurs only after existing reporter-owned detail resolution and does not broaden technician/admin/list contracts in backend/app/Http/Controllers/Api/TicketController.php and backend/app/Http/Resources/TicketResource.php
- [x] T043 [US3] Record sanitized role denial, concealed target, and authorization-loss diagnostics without reference when unsafe or any rating/ticket content in backend/app/Support/TicketEvent.php and backend/app/Http/Controllers/Api/ReporterTicketRatingController.php
- [x] T044 [US3] Run focused authorization Laravel tests and prove middleware precedence, ownership-first concealment, rating-detail isolation, exact one-route scope, and zero unauthorized writes in backend/tests/Feature/Tickets/TicketRatingAuthorizationTest.php and backend/tests/Feature/Tickets/ReporterTicketRatingTest.php

### Flutter tests and implementation for User Story 3

- [x] T045 [P] [US3] Extend failing Flutter tests for 401/403/404 mapping, restricted ticket/rating clearing, session loss, malformed unauthorized bodies, offline/server retry, and absence of technician/admin rating entry in mobile/test/tickets/ticket_rating_repository_test.dart, mobile/test/tickets/ticket_rating_controller_test.dart, mobile/test/tickets/reporter_ticket_rating_test.dart, mobile/test/auth/technician_ticket_access_test.dart, and mobile/test/auth/administrator_ticket_access_test.dart
- [x] T046 [US3] Implement concealed/unauthorized restricted-data clearing and reporter-only dependency/navigation integration without cached ownership claims in mobile/lib/tickets/state/ticket_rating_controller.dart, mobile/lib/tickets/screens/ticket_details_screen.dart, mobile/lib/auth/screens/session_gate.dart, and mobile/lib/auth/screens/profile_screen.dart
- [x] T047 [US3] Run focused US3 Flutter tests and verify reporter-only access, concealed/session clearing, offline/server recovery, malformed failure safety, and zero technician/admin rating controls in mobile/test/tickets/ and mobile/test/auth/

**Checkpoint**: All approved rating behavior is complete and ownership-private. No other role receives
rating submission or broader ticket visibility.

---

## Phase 6: Polish and Cross-Cutting Validation

**Purpose**: Prove migrations, compatibility, security, scope, reproducibility, and truthful device evidence.

- [x] T048 Run `php artisan migrate:fresh --env=testing --force`, `php artisan test --filter=TicketRating`, and the complete `php artisan test --testsuite=Feature` from backend/, then record exact results in specs/009-ticket-rating/quickstart.md
- [x] T049 Run `vendor/bin/pint --test` and `composer validate --strict` from backend/, fix failures, and record exact results in specs/009-ticket-rating/quickstart.md
- [x] T050 Run `composer audit` from backend/, resolve or explicitly document applicable advisories, and record the result in specs/009-ticket-rating/quickstart.md
- [x] T051 Run `dart format --output=none --set-exit-if-changed lib test` from mobile/, fix formatting failures, and record the result in specs/009-ticket-rating/quickstart.md
- [x] T052 Run focused rating tests, the complete `flutter test` suite, and `flutter analyze` from mobile/, fix failures, and record exact results in specs/009-ticket-rating/quickstart.md
- [x] T053 Execute all twelve automated acceptance/failure scenarios in specs/009-ticket-rating/quickstart.md through Laravel and Flutter test layers and record reproducible non-device evidence without sensitive payloads
- [x] T054 Run `flutter devices` and a live reporter rating smoke test plus technician/administrator absence check with `flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>` from mobile/ when an Android target and isolated API are available, otherwise record `DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED` with the concrete reason in specs/009-ticket-rating/quickstart.md
- [x] T055 Audit backend/routes/api.php, rating model/Action/request/resource/controller, reporter detail resource, mobile/lib/tickets/, and tests for reporter-only ownership precedence, completed-only integer 1–5 creation, one immutable record, same-token replay, distinct duplicate conflict, detail isolation, and zero edit/delete/review/multiple/anonymous/technician/admin/discussion/status/assignment capability
- [x] T056 Audit backend/composer.json, backend/composer.lock, mobile/pubspec.yaml, mobile/pubspec.lock, ignored environment files, diagnostics, and the complete changed-file list for dependency drift, embedded credentials/tokens/private keys, rating/token/ticket-content logging, generated artifacts, and unrelated scope
- [x] T057 Run `git diff --check`, review the full diff and `git status --short`, trace FR-001–FR-030 and VR-001–VR-007 to tests, confirm no application route/control exceeds specs/009-ticket-rating/contracts/openapi.yaml, and verify no commit or push occurred
- [x] T058 Mark completed items and final migration/test/audit/device evidence in specs/009-ticket-rating/tasks.md and specs/009-ticket-rating/quickstart.md, leaving only genuine external blockers explicitly identified

---

## Dependencies

- Setup T001–T002 freezes dependency, endpoint, schema, replay/conflict, detail, and exclusion boundaries before implementation.
- Existing Sanctum, active/reporter middleware, ownership-scoped detail, canonical envelopes, diagnostics, transactions, secure token access, and Flutter layers must be confirmed before User Story 1.
- User Story 1 backend tests T003–T006 precede T007–T016; migration/model/resource precede the Action; the Action precedes controller/route/detail integration. T017 verifies the backend increment.
- User Story 1 Flutter tests T018–T021 precede T022–T028; models/service/repository precede state/UI/detail integration. T029 verifies the reporter MVP.
- User Story 2 tests T030–T031 and T035 precede validation/eligibility implementation T032–T033 and T036. T034 and T037 verify the independent invalid/premature slice.
- User Story 3 tests T038–T040 and T045 precede concealment/detail-isolation hardening T041–T043 and T046. T044 and T047 verify the privacy slice.
- Cross-cutting T048–T058 follows all stories. T054 is environment-dependent; documented deferment is acceptable evidence but must never be reported as a live-device pass.

## Parallel Opportunities

- T003–T006 are independent backend test concerns in separate or non-overlapping test methods.
- T008 and T011 affect independent factory/resource files after the schema contract is frozen.
- T018–T021 cover independent Flutter contract, state, retry, and widget layers.
- T030–T031 cover request shape versus ticket eligibility in separate backend tests.
- T038–T040 cover concealment, route-role precedence, and detail isolation independently.
- Backend checks T049–T050 and mobile checks T051–T052 may run concurrently only after implementation is stable and no formatter is changing shared files.

## Parallel Example: User Story 1

```text
Task T003: Rating persistence, constraints, relationships, and immutability tests
Task T004: Reporter creation and authorized detail visibility tests
Task T005: Same-token replay and scoped-token tests
Task T006: Idempotency, uniqueness, rollback, and safe-retry tests

Task T018: Flutter contract/service/repository tests
Task T019: Flutter rating controller/state tests
Task T020: Flutter retained-token retry tests
Task T021: Reporter rating widget/detail integration tests
```

## Implementation Strategy

1. Freeze the singular reporter POST, additive detail field, integer 1–5, one-record, and UUID replay contract.
2. Write persistence, creation, sequential replay/conflict, locking, uniqueness, and rollback tests, then deliver User Story 1 as the independently usable MVP.
3. Add explicit invalid-input and non-completed eligibility tests before completing User Story 2 validation behavior.
4. Add concealed ownership, role precedence, and detail-isolation tests before completing User Story 3 privacy hardening.
5. Stop after User Story 3; do not add editing, deletion, review text, multiple/anonymous rating, other-role rating, discussions, status processing, assignment changes, or unsupported workflows.
6. Run the full automated, migration, formatting, dependency, security, route, scope, sensitive-file, and diff matrix.
7. Execute or truthfully defer the separate Android smoke task according to the available environment.

The suggested MVP is User Story 1: one immutable reporter-owned rating on a completed ticket with
safe same-token replay and authoritative reporter-detail visibility.

## Notes

- `[P]` tasks touch distinct files or isolated test concerns and have no incomplete dependency beyond the stated checkpoint.
- `[US1]`, `[US2]`, and `[US3]` map directly to the specification's three P1 user stories.
- Tests precede corresponding production implementation and failing baselines must be observed.
- Rating values and submission tokens never enter diagnostics or unauthorized responses.
- Editing, deletion, review text, multiple or anonymous ratings, technician/administrator rating,
  ratings for non-completed tickets, discussions, status changes, assignment changes, and unsupported workflows remain excluded.
- Do not create a commit or push as part of this task-list execution unless separately authorized.
- Stop if implementation conflicts with spec.md, plan.md, research.md, data-model.md, or openapi.yaml.
