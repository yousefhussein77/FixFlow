# Tasks: User Authentication and Session Management

**Input**: Design documents from `/specs/003-user-auth/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/auth.openapi.yaml, quickstart.md

**Verification**: Tests precede story implementation. Every security boundary and required client state has automated coverage or a final explicit audit.

**Organization**: Tasks are grouped by user story and executed sequentially in priority order.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it uses different files and no incomplete dependency.
- **[Story]**: Maps the task to its specification user story.

## Phase 1: Setup

**Purpose**: Add only the dependencies and configuration required by the approved plan.

- [X] T001 Add `http` and `flutter_secure_storage` dependencies in `mobile/pubspec.yaml`
- [X] T002 Verify repository, backend, and mobile ignore rules cover secrets and generated artifacts in `.gitignore`, `backend/.gitignore`, and `mobile/.gitignore`
- [X] T003 Resolve Laravel and Flutter dependencies using `backend/composer.lock` and `mobile/pubspec.lock`

---

## Phase 2: Foundational

**Purpose**: Establish shared identity, response, authorization, transport, and session primitives.

- [X] T004 Create the user schema migration with normalized unique email, reporter/technician/administrator role, and active status in `backend/database/migrations/2026_07_22_120000_create_users_table.php`
- [X] T005 Create the Sanctum-capable User model and reproducible factory in `backend/app/Models/User.php` and `backend/database/factories/UserFactory.php`
- [X] T006 [P] Create the consistent success/error envelope helper in `backend/app/Support/ApiResponse.php`
- [X] T007 Configure JSON validation, authentication, and safe server errors plus active-account middleware alias in `backend/bootstrap/app.php`
- [X] T008 [P] Create active-account protected-operation middleware in `backend/app/Http/Middleware/EnsureUserIsActive.php`
- [X] T009 [P] Create profile serialization without secrets in `backend/app/Http/Resources/UserResource.php`
- [X] T010 [P] Create mobile API/profile/failure models in `mobile/lib/auth/models/auth_models.dart`
- [X] T011 [P] Create HTTP authentication transport and typed failures in `mobile/lib/auth/services/auth_api_service.dart`
- [X] T012 [P] Create protected token-store abstraction and secure implementation in `mobile/lib/auth/services/token_store.dart`
- [X] T013 Create authentication repository orchestration in `mobile/lib/auth/repositories/auth_repository.dart`

**Checkpoint**: Shared foundations compile and contain no user-story UI or privileged account management.

---

## Phase 3: User Story 1 - Register as a Reporter (Priority: P1) MVP

**Goal**: A visitor can create only an active reporter account and enter a securely retained session.

**Independent Test**: Valid registration creates exactly one reporter and token; invalid, duplicate, or role-injection requests create no partial state; Flutter shows registration loading/success/validation/offline/server states.

### Tests for User Story 1

- [X] T014 [P] [US1] Add failing Laravel reporter registration, validation, atomicity, role-injection, and secret-leak tests in `backend/tests/Feature/Auth/RegisterTest.php`
- [X] T015 [P] [US1] Add failing Flutter registration repository/state/widget tests in `mobile/test/auth/registration_test.dart`

### Implementation for User Story 1

- [X] T016 [P] [US1] Create normalized reporter-only registration request in `backend/app/Http/Requests/Auth/RegisterRequest.php`
- [X] T017 [US1] Create transactional reporter registration action in `backend/app/Actions/Auth/RegisterReporter.php`
- [X] T018 [US1] Add thin registration endpoint coordination in `backend/app/Http/Controllers/Api/AuthController.php` and `backend/routes/api.php`
- [X] T019 [US1] Implement immutable session/operation state and registration transition in `mobile/lib/auth/state/auth_controller.dart`
- [X] T020 [US1] Implement registration screen states and navigation link in `mobile/lib/auth/screens/register_screen.dart`
- [X] T021 [US1] Run and pass the independent US1 Laravel and Flutter tests in `backend/tests/Feature/Auth/RegisterTest.php` and `mobile/test/auth/registration_test.dart`

---

## Phase 4: User Story 2 - Sign In and Restore a Session (Priority: P1)

**Goal**: Active accounts sign in generically and the app safely restores only verified sessions.

**Independent Test**: Correct active credentials issue a token; unknown/wrong/inactive failures are non-enumerating and atomic; valid stored sessions restore, while unauthorized tokens clear and offline/server failures remain recoverable.

### Tests for User Story 2

- [X] T022 [P] [US2] Add failing Laravel generic-login and inactive-account tests in `backend/tests/Feature/Auth/LoginTest.php`
- [X] T023 [P] [US2] Add failing Flutter sign-in and restoration state/widget tests in `mobile/test/auth/sign_in_restore_test.dart`

### Implementation for User Story 2

- [X] T024 [P] [US2] Create normalized login request in `backend/app/Http/Requests/Auth/LoginRequest.php`
- [X] T025 [US2] Create generic active-account login action and controller route in `backend/app/Actions/Auth/LoginUser.php`, `backend/app/Http/Controllers/Api/AuthController.php`, and `backend/routes/api.php`
- [X] T026 [US2] Implement sign-in/restoration transitions and late-result protection in `mobile/lib/auth/state/auth_controller.dart`
- [X] T027 [US2] Implement sign-in and restoration screens plus app composition in `mobile/lib/auth/screens/sign_in_screen.dart`, `mobile/lib/auth/screens/session_gate.dart`, `mobile/lib/app.dart`, and `mobile/lib/main.dart`
- [X] T028 [US2] Run and pass the independent US2 Laravel and Flutter tests in `backend/tests/Feature/Auth/LoginTest.php` and `mobile/test/auth/sign_in_restore_test.dart`

---

## Phase 5: User Story 3 - View Own Profile (Priority: P2)

**Goal**: A valid active session displays only its own profile and clears protected state on rejection.

**Independent Test**: Profile derives identity solely from the token, rejects every invalid/inactive credential, and Flutter handles loading/success/unauthenticated/offline/server/contract states without stale data.

### Tests and Implementation for User Story 3

- [X] T029 [US3] Add failing profile ownership/token/inactivity tests, implement the protected route, and pass them in `backend/tests/Feature/Auth/ProfileTest.php` and `backend/routes/api.php`
- [X] T030 [US3] Add profile state/widget tests and implement required UI states in `mobile/test/auth/profile_test.dart` and `mobile/lib/auth/screens/profile_screen.dart`

---

## Phase 6: User Story 4 - Sign Out (Priority: P2)

**Goal**: Sign-out revokes only the current token and always removes it from active mobile use.

**Independent Test**: The current token is rejected after logout, another session remains valid, and online/offline/server/unauthenticated mobile logout outcomes all end signed out without late restoration.

### Tests and Implementation for User Story 4

- [X] T031 [US4] Add failing current-token logout tests, implement the logout action/route, and pass them in `backend/tests/Feature/Auth/LogoutTest.php`, `backend/app/Actions/Auth/LogoutUser.php`, `backend/app/Http/Controllers/Api/AuthController.php`, and `backend/routes/api.php`
- [X] T032 [US4] Add logout state/widget tests and implement online/offline local sign-out in `mobile/test/auth/logout_test.dart`, `mobile/lib/auth/state/auth_controller.dart`, and `mobile/lib/auth/screens/profile_screen.dart`

---

## Phase 7: Polish and Cross-Cutting Verification

**Purpose**: Validate the complete contract, diagnostics, security boundary, code quality, and approved scope.

- [X] T033 [P] Add reproducible reporter/technician/administrator/inactive development seed data in `backend/database/seeders/DatabaseSeeder.php`
- [X] T034 [P] Update authentication validation and endpoint documentation in `backend/README.md` and `mobile/README.md`
- [X] T035 Run all Laravel tests and formatting using `backend/phpunit.xml` and Laravel Pint
- [X] T036 Run all Flutter tests, Dart formatting, and Flutter analysis for `mobile/lib/` and `mobile/test/`
- [X] T037 Run Composer and Flutter dependency security/outdated audits using `backend/composer.lock` and `mobile/pubspec.lock`
- [X] T038 Audit changed files for password/token logging, response leakage, endpoint scope, and forbidden feature additions against `specs/003-user-auth/spec.md`
- [X] T039 Execute the automated portions of `specs/003-user-auth/quickstart.md` and record final evidence in `specs/003-user-auth/tasks.md`

---

## Dependencies & Execution Order

- Setup T001–T003 precedes foundational work.
- Foundation T004–T013 blocks all stories.
- US1 T014–T021 is the MVP and precedes shared authenticated app composition.
- US2 T022–T028 depends on the foundation and integrates the US1 session primitives.
- US3 T029 and US4 T031 are backend-independent after the foundation; mobile T030/T032 depend on the session controller from US2.
- Polish T033–T039 starts after all story checkpoints pass.
- Within every story, failing tests are created and observed before implementation.

## Parallel Opportunities

- T006, T008–T012 touch independent foundation files.
- T014 and T015 can be authored independently; T016 can be prepared after the failing backend test is observed.
- T022 and T023 can be authored independently; T024 can be prepared after the failing backend test is observed.
- T033 and T034 are independent documentation/data tasks.

## Implementation Strategy

1. Establish the smallest shared authentication foundation.
2. Deliver and verify reporter registration as the MVP.
3. Add generic sign-in and verified restoration without expanding scope.
4. Add own-profile and current-session logout as bounded protected operations.
5. Run the entire regression, formatting, analysis, dependency, security, and scope suite.
6. Mark each task `[X]` only after its files or checks are complete; do not commit or push.

## Completion Evidence

- 2026-07-22 Laravel: `php artisan test` passed 13 tests with 92 assertions; authentication subset passed 9 tests with 72 assertions.
- 2026-07-22 Backend formatting: Laravel Pint applied one bootstrap formatting correction, then `pint --test` passed.
- 2026-07-22 Backend dependencies: `composer validate --strict` passed and `composer audit --locked` reported no vulnerability advisories.
- 2026-07-22 Flutter: Dart formatter checked 16 files with zero changes; `flutter analyze` reported no issues; `flutter test` passed 14 tests.
- 2026-07-22 Flutter dependencies: upgraded direct `flutter_secure_storage` to 10.3.1, removing discontinued `js`; direct dependencies are current and the final outdated report found only SDK/plugin-constrained transitive updates.
- 2026-07-22 API/migrations: route inspection showed exactly register, login, profile, and logout; testing migration status showed the users and Sanctum token migrations ran.
- 2026-07-22 security/scope: source scans found no password/token logging calls and no reset, verification, social, two-factor, ticket, profile-editing, push, or role-management additions. Feature tests verify response secrecy, generic credentials, reporter-only registration, token rejection/revocation, active-account denial, ownership, and atomic failure counts.
- 2026-07-22 hooks: no `.specify/extensions.yml` hooks were configured for planning, tasks, or implementation.
