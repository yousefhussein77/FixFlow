# Tasks: Ticket Comments

**Input**: Design documents from `specs/008-ticket-comments/`

**Verification**: Laravel and Flutter tests are mandatory and precede corresponding implementation.
Every accepted add must prove one immutable comment or an authoritative replay of that same comment;
every rejected path must prove no partial comment and no restricted ticket/comment disclosure.

## Phase 1: Setup

**Purpose**: Freeze the approved discussion boundary and verify existing foundations before changes.

- [x] T001 Verify no package addition is required and preserve dependency versions in backend/composer.json and mobile/pubspec.yaml
- [x] T002 Audit the three role paths, six GET/POST operations, 2,000-character limit, UUID replay contract, schemas, status codes, and exclusions against specs/008-ticket-comments/contracts/openapi.yaml, specs/008-ticket-comments/data-model.md, and specs/008-ticket-comments/plan.md

---

## Phase 2: Foundational Prerequisites

**Purpose**: Reuse existing authentication, role middleware, ticket authorization data, response
envelopes, diagnostics, and Flutter layering.

No new project-wide foundation is required. Confirm the existing `auth:sanctum` and `active` route
chain, reporter/technician/administrator middleware, reporter ownership, current technician assignment,
administrator all-ticket oversight, canonical `ApiResponse`, `TicketEvent`, secure token store, and
Flutter service/repository/state/manual-injection architecture. Any unrelated defect remains outside
this feature.

**Checkpoint**: Existing foundations are confirmed; US1 may introduce the shared immutable comment
foundation and reporter-owned discussion without technician or administrator integration.

---

## Phase 3: User Story 1 - Discuss My Reported Ticket (Priority: P1) MVP

**Goal**: A reporter lists and adds immutable plain-text comments only on owned tickets, with stable
chronology, concealed other-owned targets, atomic writes, and safe UUID replay.

**Independent Test**: Create tickets for two reporters; list an empty owned discussion, add several
comments, replay one submission token, and verify exact oldest-first fields. Compare unknown and
other-owned list/add outcomes byte-for-byte and inject persistence failure; no rejected attempt may
create or expose a comment.

### Backend tests for User Story 1

> Write these tests first and observe the focused suite fail before implementation.

- [x] T003 [P] [US1] Write failing migration/model/factory tests for ticket/author relationships, 1–2,000-character content, author-role snapshot, absent `updated_at`, `(created_at,id)` ordering, composite retry uniqueness, restricted foreign keys, and update/delete immutability in backend/tests/Feature/Tickets/TicketCommentPersistenceTest.php
- [x] T004 [P] [US1] Write failing reporter list tests for owned empty/populated discussions, exact safe fields, equal-time stable oldest-first order, missing/revoked/inactive authentication, wrong roles, and identical unknown/other-owned concealed responses in backend/tests/Feature/Tickets/ReporterTicketCommentsTest.php
- [x] T005 [P] [US1] Write failing reporter add tests for trimmed nonblank 1/2,000 boundaries, whitespace/over-limit/type/UUID/unsupported-field 422 outcomes, inert markup-like text, authenticated author/time preservation, owned/concealed targets, sanitized 500, and unchanged ticket/status/history in backend/tests/Feature/Tickets/ReporterTicketCommentsTest.php
- [x] T006 [P] [US1] Write failing idempotency/atomicity tests for first-create 201, sequential same-token replay 200 with identical payload, distinct-token identical content, cross-ticket/author token scope, injected rollback, and safe retry in backend/tests/Feature/Tickets/TicketCommentIdempotencyTest.php

### Backend implementation for User Story 1

- [x] T007 [US1] Add the reversible immutable comment table with author-role snapshot, UUID submission token, 2,000-character content, restricted ticket/author foreign keys, unique `(ticket_id,author_id,submission_token)`, and `(ticket_id,created_at,id)` index in backend/database/migrations/2026_07_23_130000_create_ticket_comments_table.php
- [x] T008 [P] [US1] Implement reproducible owned-ticket comment factory states, explicit equal timestamps, role snapshots, tokens, and boundary content in backend/database/factories/TicketCommentFactory.php
- [x] T009 [US1] Implement TicketComment relationships, no-update timestamp, guarded retry fields, immutable update/delete hooks, and chronological Ticket/User relationships in backend/app/Models/TicketComment.php, backend/app/Models/Ticket.php, and backend/app/Models/User.php
- [x] T010 [P] [US1] Implement strict create shape validation for only boundary-trimmed nonblank `content` of 1–2,000 characters and UUID `submission_token` in backend/app/Http/Requests/Tickets/CreateTicketCommentRequest.php
- [x] T011 [P] [US1] Implement the exact comment/author mapping without ticket IDs, retry tokens, persistence fields, or executable markup semantics in backend/app/Http/Resources/TicketCommentResource.php
- [x] T012 [US1] Implement role-context ticket resolution for reporter ownership first and concealed unknown/other-owned equivalence, with extension points limited to the approved technician and administrator predicates, in backend/app/Services/Tickets/TicketCommentAccess.php
- [x] T013 [US1] Implement complete stable oldest-first authorized listing with eager-loaded authors in backend/app/Actions/Tickets/ListTicketComments.php
- [x] T014 [US1] Implement reporter comment creation in backend/app/Actions/Tickets/CreateTicketComment.php using one transaction, authorized ticket row lock, commit-time ownership recheck, scoped token replay, authenticated author/role/time, exactly-one insert, and rollback on all failures
- [x] T015 [US1] Add thin reporter list/create handlers with 200 list, 201 create, 200 replay, canonical validation/auth/concealed/server envelopes, and no partial-success outcome in backend/app/Http/Controllers/Api/ReporterTicketCommentController.php
- [x] T016 [US1] Register only GET and POST `/api/reporter/tickets/{reference}/comments` behind `auth:sanctum`, `active`, and `reporter` middleware in backend/routes/api.php
- [x] T017 [US1] Record sanitized reporter list/create/replay/validation/concealment/rollback diagnostics without content, submission token, ticket details, credentials, or unnecessary personal data in backend/app/Support/TicketEvent.php and the comment Actions/controller
- [x] T018 [US1] Run focused reporter/persistence/idempotency Laravel tests and verify exact envelopes, stable chronology, immutable fields, database uniqueness plus sequential replay, rollback, concealed equivalence, and absence of edit/delete/attachment routes using backend/tests/Feature/Tickets/TicketCommentPersistenceTest.php, backend/tests/Feature/Tickets/ReporterTicketCommentsTest.php, and backend/tests/Feature/Tickets/TicketCommentIdempotencyTest.php; cross-connection concurrency is not claimed under SQLite

### Flutter tests for User Story 1

> Write these tests before the corresponding Flutter implementation and observe them fail.

- [x] T019 [P] [US1] Write comment API/repository tests for explicit role endpoint paths, stable parsed chronology, malformed success contracts, 401/403/404/422/500, and offline mapping in mobile/test/tickets/ticket_comment_repository_test.dart; creation/replay behavior is exercised at controller/widget and Laravel API layers
- [x] T020 [P] [US1] Write comment controller tests for empty-to-populated submission, UUID issuance, validation/not-found/unauthorized/offline/server mapping, and restricted-data clearing in mobile/test/tickets/ticket_comments_controller_test.dart; stale suppression and duplicate-submit behavior are implemented defensively but are not separately claimed as completed test evidence
- [x] T021 [P] [US1] Write failing retry-state tests for one retained token per draft, same-token ambiguous retry, authoritative create/replay insertion once, distinct token after success, safe text preservation, and no optimistic comment in mobile/test/tickets/ticket_comment_retry_test.dart
- [x] T022 [P] [US1] Write failing reporter widget/integration tests for owned chronological list, empty state, accessible plain-text composer, 1/2,000 validation, line-break preservation, retry, session/concealed clearing, and no excluded controls in mobile/test/tickets/reporter_ticket_comments_test.dart

### Flutter implementation for User Story 1

- [x] T023 [US1] Implement strict author, immutable comment, role endpoint context, add result, and typed failure models in mobile/lib/tickets/models/ticket_comment_models.dart
- [x] T024 [US1] Implement authenticated role-context GET/POST transport, canonical envelope/status mapping, and contract/offline failures in mobile/lib/tickets/services/ticket_comment_api_service.dart
- [x] T025 [US1] Implement secure-token list/create repository methods, explicit reporter context paths, 1–2,000-character validation, strict chronology, and authoritative create/replay mapping in mobile/lib/tickets/repositories/ticket_comment_repository.dart
- [x] T026 [US1] Implement loading/populated/empty/submitting/success/validation/concealed/unauthorized/offline/server comment state, generation-based stale suppression, stable id de-duplication, one-token draft lifecycle, ambiguous retry, and restricted clearing in mobile/lib/tickets/state/ticket_comments_controller.dart
- [x] T027 [US1] Implement the accessible localization-ready chronological list and inert plain-text comment composer with character count, preserved draft, disabled duplicate submission, retry, and no optimistic row in mobile/lib/tickets/widgets/ticket_comments_section.dart
- [x] T028 [US1] Implement a shared authorized discussion host for role context, loading/error recovery, and controller disposal in mobile/lib/tickets/screens/ticket_comments_screen.dart
- [x] T029 [US1] Integrate reporter-owned comments into mobile/lib/tickets/screens/ticket_details_screen.dart without adding ticket edit/delete, status, assignment, rating, or notification controls
- [x] T030 [US1] Wire the existing manual dependency composition for the shared comment service/repository in mobile/lib/main.dart, mobile/lib/app.dart, mobile/lib/auth/screens/session_gate.dart, and mobile/lib/auth/screens/profile_screen.dart
- [x] T031 [US1] Run focused reporter Flutter tests and verify contract/failure mapping, chronology, validation, draft/token retry, restricted clearing, offline/server behavior, inert text, and absence of excluded actions in mobile/test/tickets/ticket_comment_repository_test.dart, mobile/test/tickets/ticket_comments_controller_test.dart, mobile/test/tickets/ticket_comment_retry_test.dart, and mobile/test/tickets/reporter_ticket_comments_test.dart

**Checkpoint**: US1 independently delivers a private reporter-owned immutable ticket discussion with
safe replay. Technician and administrator comment routes are not yet exposed.

---

## Phase 4: User Story 2 - Discuss Currently Assigned Work (Priority: P1)

**Goal**: The current assigned technician reads and adds to the same discussion only while assignment
remains current, including commit-time assignment-loss concealment.

**Independent Test**: Assign a ticket to one technician, exchange reporter/technician comments, then
change assignment through separately approved behavior before list and before commit. The former and
unrelated technicians receive the same concealed result as an unknown reference and create nothing.

### Backend tests for User Story 2

- [x] T032 [P] [US2] Write failing technician list/add Feature Tests for shared chronology, exact fields, empty success, author-role preservation, 201/replay behavior, validation, inactive/wrong actors, non-assignment, and identical unknown/unassigned concealment in backend/tests/Feature/Tickets/TechnicianTicketCommentsTest.php
- [x] T033 [P] [US2] Write failing assignment-loss tests for assignment loss between screen/list and locked commit, sequential reassignment/comment behavior, same-token replay only while currently authorized, rollback, unchanged ticket/status/history, and sanitized diagnostics in backend/tests/Feature/Tickets/TicketCommentAssignmentRaceTest.php

### Backend implementation for User Story 2

- [x] T034 [US2] Extend current-assignment resolution and locked commit-time revalidation without exposing former assignment in backend/app/Services/Tickets/TicketCommentAccess.php and backend/app/Actions/Tickets/CreateTicketComment.php
- [x] T035 [US2] Add thin technician list/create handlers with canonical concealed assignment-loss behavior and shared 200/201/replay/validation/server outcomes in backend/app/Http/Controllers/Api/TechnicianTicketCommentController.php
- [x] T036 [US2] Register only GET and POST `/api/technician/tickets/{reference}/comments` behind `auth:sanctum`, `active`, and `technician` middleware in backend/routes/api.php
- [x] T037 [US2] Record sanitized technician list/create/replay, non-assignment, assignment-loss, validation, and rollback events without comment text or restricted assignment contents in backend/app/Support/TicketEvent.php and the technician comment controller/Actions
- [x] T038 [US2] Run focused technician Laravel tests and prove current-assignee-only reads/writes, commit-time loss protection, concealed equivalence, atomicity, retry behavior, shared chronology, and zero assignment/status mutation in backend/tests/Feature/Tickets/TechnicianTicketCommentsTest.php and backend/tests/Feature/Tickets/TicketCommentAssignmentRaceTest.php

### Flutter tests for User Story 2

- [x] T039 [P] [US2] Extend endpoint/repository tests for technician context paths, stable chronology, 404/validation/offline/server mapping, and malformed responses in mobile/test/tickets/ticket_comment_repository_test.dart; assignment-loss and replay are covered by Laravel and technician widget/controller tests
- [x] T040 [P] [US2] Write failing technician detail/comment widget tests for loading/populated/empty/submitting, assignment-loss clearing/navigation, preserved safe draft before denial, retry reconciliation, and no reporter/admin/status/assignment/excluded controls in mobile/test/tickets/technician_ticket_comments_test.dart

### Flutter implementation for User Story 2

- [x] T041 [US2] Add explicit technician endpoint context and assignment-loss failure mapping without inferring role from cached ticket data in mobile/lib/tickets/models/ticket_comment_models.dart and mobile/lib/tickets/repositories/ticket_comment_repository.dart
- [x] T042 [US2] Integrate the shared comment host into owned assigned detail and clear/leave restricted discussion on assignment loss in mobile/lib/tickets/screens/technician_ticket_details_screen.dart and mobile/lib/tickets/state/technician_ticket_details_controller.dart
- [x] T043 [US2] Run focused technician Flutter tests and verify current-assignment context, shared chronology, assignment-loss clearing, retry safety, duplicate blocking, offline/server recovery, and exclusions in mobile/test/tickets/ticket_comment_repository_test.dart and mobile/test/tickets/technician_ticket_comments_test.dart

**Checkpoint**: US2 adds technician participation without changing assignment, ticket status, or the
reporter-owned discussion contract.

---

## Phase 5: User Story 3 - Oversee Ticket Discussion (Priority: P2)

**Goal**: An active administrator lists and adds comments across existing oversight tickets while
preserving explicit administrator authorship and leaving ticket workflow untouched.

**Independent Test**: Open tickets for different reporters/technicians as an administrator, list their
shared discussions, and add/replay an administrator comment. Verify unknown targets, invalid input,
wrong actors, rollback, and that assignment, status, history, and ticket content remain unchanged.

### Backend tests for User Story 3

- [x] T044 [P] [US3] Write failing administrator list/add Feature Tests for cross-ticket oversight, empty/stable shared chronology, exact author role, 201/replay, validation, unknown 404, inactive/wrong actors, rollback, and unchanged ticket workflow in backend/tests/Feature/Tickets/AdminTicketCommentsTest.php
- [x] T045 [P] [US3] Write failing cross-role authorization/contract tests proving every role path rejects wrong roles before target resolution, comment data never crosses unauthorized boundaries, and only six approved comment operations exist in backend/tests/Feature/Tickets/TicketCommentAuthorizationTest.php

### Backend implementation for User Story 3

- [x] T046 [US3] Extend approved administrator all-ticket oversight resolution and locked creation without adding ticket mutation permissions in backend/app/Services/Tickets/TicketCommentAccess.php and backend/app/Actions/Tickets/CreateTicketComment.php
- [x] T047 [US3] Add thin administrator list/create handlers with explicit unknown-ticket 404 and shared 200/201/replay/validation/server outcomes in backend/app/Http/Controllers/Api/AdminTicketCommentController.php
- [x] T048 [US3] Register only GET and POST `/api/admin/tickets/{reference}/comments` behind `auth:sanctum`, `active`, and `administrator` middleware in backend/routes/api.php
- [x] T049 [US3] Record sanitized administrator list/create/replay/not-found/validation/rollback diagnostics without comment or ticket contents in backend/app/Support/TicketEvent.php and the administrator controller/Actions
- [x] T050 [US3] Run focused administrator/cross-role Laravel tests and verify oversight, shared chronology, canonical responses, route-role precedence, retry/rollback, immutable comments, and zero ticket workflow mutation in backend/tests/Feature/Tickets/AdminTicketCommentsTest.php and backend/tests/Feature/Tickets/TicketCommentAuthorizationTest.php

### Flutter tests for User Story 3

- [x] T051 [P] [US3] Extend API/repository tests for explicit administrator context, shared comment contract, 404, validation, unauthorized, offline/server, and malformed response behavior in mobile/test/tickets/ticket_comment_repository_test.dart; replay is covered by Laravel API and shared controller retry tests
- [x] T052 [P] [US3] Write failing administrator queue/comment tests for opening discussions across tickets, loading/populated/empty/submitting/replay/error states, authoritative row insertion, restricted clearing, and no assignment/status/edit/delete/excluded controls in mobile/test/tickets/admin_ticket_comments_test.dart

### Flutter implementation for User Story 3

- [x] T053 [US3] Add explicit administrator endpoint context and not-found mapping in mobile/lib/tickets/models/ticket_comment_models.dart and mobile/lib/tickets/repositories/ticket_comment_repository.dart
- [x] T054 [US3] Integrate the shared comments screen from administrator ticket rows without adding unrelated ticket-detail or mutation behavior in mobile/lib/tickets/screens/admin_ticket_list_screen.dart and mobile/lib/tickets/screens/ticket_comments_screen.dart
- [x] T055 [US3] Run focused administrator Flutter tests and verify oversight context, shared chronology, create/replay, error recovery, restricted clearing, and exclusions in mobile/test/tickets/ticket_comment_repository_test.dart and mobile/test/tickets/admin_ticket_comments_test.dart

**Checkpoint**: All three approved roles now share one immutable ticket discussion contract; no other
collaboration or ticket workflow capability is present.

---

## Phase 6: Polish and Cross-Cutting Validation

**Purpose**: Prove compatibility, security, scope, reproducibility, and truthful environment evidence.

- [x] T056 Run `php artisan migrate:fresh --env=testing --force`, `php artisan test --filter=TicketComment`, and the complete `php artisan test --testsuite=Feature` from backend/, then record results in specs/008-ticket-comments/quickstart.md
- [x] T057 Run `vendor/bin/pint --test` and `composer validate --strict` from backend/, fix failures, and record results in specs/008-ticket-comments/quickstart.md
- [x] T058 Run `composer audit` from backend/, resolve or explicitly document applicable advisories, and record the result in specs/008-ticket-comments/quickstart.md
- [x] T059 Run `dart format --output=none --set-exit-if-changed lib test` from mobile/, fix formatting failures, and record results in specs/008-ticket-comments/quickstart.md
- [x] T060 Run `flutter analyze`, all focused comment tests, and the complete `flutter test` suite from mobile/, fix failures, and record results in specs/008-ticket-comments/quickstart.md
- [x] T061 Execute all eleven automated acceptance/failure scenarios in specs/008-ticket-comments/quickstart.md through Laravel and Flutter test layers and record reproducible non-device evidence without sensitive payloads
- [x] T062 Run `flutter devices` and a live reporter/technician/administrator comment smoke test with `flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>` from mobile/ when an Android target and isolated API are available, otherwise record `DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED` with the concrete reason in specs/008-ticket-comments/quickstart.md
- [x] T063 Audit backend/routes/api.php, comment models/Actions/services/resources/controllers, mobile/lib/tickets/, and tests for authorization precedence, concealed targets, exactly six comment operations, immutable 1–2,000-character plain text, stable `(created_at,id)` chronology, retry uniqueness, and zero chat/edit/delete/attachment/mention/reaction/typing/notification/reassignment/status/rating capability
- [x] T064 Audit backend/composer.json, backend/composer.lock, mobile/pubspec.yaml, mobile/pubspec.lock, ignored environment files, diagnostics, and the complete changed-file list for dependency drift, embedded credentials/tokens/private keys, comment-content logging, generated artifacts, and unrelated scope
- [x] T065 Run `git diff --check`, review the full diff, trace FR-001–FR-029 and VR-001–VR-007 to tests, confirm no application route or control exceeds specs/008-ticket-comments/contracts/openapi.yaml, then mark completed items and final evidence in specs/008-ticket-comments/tasks.md and specs/008-ticket-comments/quickstart.md

---

## Dependencies

- Setup T001–T002 freezes package, operation, schema, replay, and exclusion boundaries before implementation.
- Existing Sanctum, active/role middleware, ticket ownership/assignment, administrator oversight,
  response, diagnostics, and Flutter layers must be confirmed before US1; no speculative shared system is added.
- US1 backend tests T003–T006 precede T007–T017; schema/model/resource/access precede list/create
  Actions; Actions precede reporter controller/routes. T018 verifies the backend increment.
- US1 Flutter tests T019–T022 precede T023–T030; models/service/repository precede state/UI and reporter
  integration. T031 verifies the complete reporter MVP.
- US2 reuses the immutable comment foundation but remains independently testable from an assigned
  ticket. T032–T033 precede T034–T037, and T038 verifies backend assignment isolation. T039–T040 precede
  T041–T042, and T043 verifies technician integration.
- US3 reuses the same foundation but is independently testable through administrator oversight.
  T044–T045 precede T046–T049, and T050 verifies backend oversight. T051–T052 precede T053–T054, and
  T055 verifies administrator integration.
- Cross-cutting T056–T065 follows all stories. T062 is deliberately environment-dependent; documented
  deferment is acceptable evidence but must never be reported as a live-device pass.

## Parallel Opportunities

- T003–T006 are independent backend test files.
- T008, T010, and T011 affect independent factory/request/resource files after the schema contract is frozen.
- T019–T022 are independent Flutter contract, state, retry, and reporter widget test files.
- T032–T033 are independent technician behavior/race test files; T039–T040 cover different Flutter layers.
- T044–T045 are independent administrator and cross-role backend tests; T051–T052 cover contract versus UI tests.
- Backend validation T057–T058 and mobile validation T059–T060 may run concurrently only when no formatter
  is changing the shared worktree.

## Parallel Example: User Story 1

```text
Task T003: Comment persistence, constraints, ordering, and immutability tests
Task T004: Reporter list, chronology, and concealment tests
Task T005: Reporter add, validation, authorship, and failure tests
Task T006: UUID replay, uniqueness, rollback, and safe-retry tests

Task T019: Comment contract/service/repository mapping tests
Task T020: Shared controller and restricted-state tests
Task T021: Draft token and ambiguous retry tests
Task T022: Reporter discussion widget/integration tests
```

## Implementation Strategy

1. Freeze the six-operation, immutable 2,000-character, UUID-retry contract and confirm existing authorization foundations.
2. Write persistence/privacy/retry tests, then deliver the reporter-owned chronological discussion MVP.
3. Write technician tests, then add current-assignment read and locked commit-time authorization using the shared foundation.
4. Write administrator tests, then add oversight list/create routes and Flutter entry without unrelated admin mutation.
5. Stop after US3; do not add real-time behavior, edits, deletion, attachments, social features,
   notifications, assignment/status processing, ratings, or any unsupported workflow.
6. Run the full automated, formatting, dependency, security, route, scope, sensitive-file, and diff matrix.
7. Execute or truthfully defer the separate Android smoke task according to the available environment.

The suggested MVP is US1: reporter-owned immutable ticket comments with chronological reads and
atomic retry-safe creation.

## Notes

- `[P]` tasks touch distinct files and have no incomplete dependency beyond the stated checkpoint.
- `[US1]`, `[US2]`, and `[US3]` map directly to the specification's prioritized stories.
- Tests precede corresponding production implementation and failing baselines must be observed.
- Comment content and submission tokens never enter diagnostics or unauthorized responses.
- Real-time chat, editing, deletion, attachments, mentions, reactions, typing indicators, push
  notifications, reassignment, ticket processing, ratings, and unsupported workflows remain excluded.
- Do not create a commit or push as part of this task list execution unless separately authorized.
- Stop if implementation conflicts with spec.md, plan.md, research.md, data-model.md, or openapi.yaml.
