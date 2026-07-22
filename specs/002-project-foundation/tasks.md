# Tasks: FixFlow Project Foundation

**Input**: Design documents from `/specs/002-project-foundation/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/foundation-health.openapi.yaml`, `quickstart.md`

**Verification**: Every functional requirement maps to an explicit verification task. Automated tests cover the readiness contract and starter mobile rendering; live checks cover XAMPP MariaDB, Laravel startup, and Android emulator `emulator-5554`.

**Organization**: Tasks are grouped by user story so the runnable baseline, safe environment, and setup guide remain independently reviewable increments.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it changes different files and has no dependency on an incomplete task
- **[Story]**: Maps the task to User Story 1, 2, or 3
- Every task names the exact file or directory it creates, changes, or validates

## Fixed Environment

- Windows 11 and PowerShell
- PHP 8.5.0 with Laravel 13.x (`^13.0`)
- Flutter 3.41.9 stable with Dart 3.11.5
- XAMPP MariaDB 10.4.32
- Android emulator `emulator-5554`
- Do not upgrade or replace these tools during this feature

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the repository boundary and prove the fixed machine prerequisites before either application is generated.

- [X] T001 Create the required monorepo roots `backend/`, `mobile/`, and `docs/`, retaining the initially empty documentation root with `docs/.gitkeep`
- [X] T002 Run the fixed-toolchain checks from `specs/002-project-foundation/quickstart.md` and record PHP 8.5.0, Flutter 3.41.9 stable, Dart 3.11.5, XAMPP MariaDB 10.4.32, Windows 11, and `emulator-5554` status in `docs/foundation-verification.md`; stop rather than upgrade on a mismatch
- [X] T003 Define repository-wide exclusions for real environment files, credentials, dependency folders, build output, logs, editor state, and device-local artifacts in `.gitignore`, while explicitly allowing committed `.env.example` files

**Checkpoint**: Required roots exist, fixed prerequisites are evidenced, and repository-wide secret/build exclusions precede generated content.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Generate and review each mandated framework foundation as a separate bounded increment.

**CRITICAL**: Complete and review each scaffold task before dependent customization; do not generate or customize both applications as one opaque operation.

- [X] T004 Generate a plain Laravel 13.x application with installed PHP 8.5.0 in `backend/`, without a web starter kit, then review `backend/composer.json`, `backend/routes/`, and the generated file set before continuing
- [X] T005 Enable Laravel's official API routing and Sanctum foundation in `backend/bootstrap/app.php`, `backend/routes/api.php`, `backend/composer.json`, and generated Sanctum migration files without adding login, users, tokens in use, protected routes, or other authentication behavior
- [X] T006 Generate the Flutter Android application with installed Flutter 3.41.9/Dart 3.11.5 in `mobile/`, excluding unneeded platform projects where supported, then review `mobile/pubspec.yaml`, `mobile/lib/main.dart`, and the generated file set before continuing
- [X] T007 Audit `backend/composer.json`, `backend/composer.lock`, and `mobile/pubspec.yaml` against `specs/002-project-foundation/research.md`, removing no framework-required dependency but rejecting any optional package not justified by the plan

**Checkpoint**: Both separately reviewed framework foundations exist with only mandated dependencies; no domain capability has been introduced.

---

## Phase 3: User Story 1 - Obtain a Runnable Project Baseline (Priority: P1) MVP

**Goal**: A contributor can start the API-only backend, receive the readiness response, and launch the starter mobile application on `emulator-5554`.

**Independent Test**: With Phase 1–2 prerequisites complete, verify `GET /up` returns HTTP 200 without an application UI or business route, and verify the starter mobile screen opens without a crash on `emulator-5554`.

### Tests for User Story 1

- [X] T008 [P] [US1] Add a Laravel Feature Test for the 200 response and content type defined by `specs/002-project-foundation/contracts/foundation-health.openapi.yaml` in `backend/tests/Feature/HealthTest.php`
- [X] T009 [P] [US1] Align the generated starter widget test with the retained minimal starter screen and crash-free render expectation in `mobile/test/widget_test.dart`

### Implementation for User Story 1

- [X] T010 [US1] Remove application-facing web behavior and confirm only framework readiness plus non-business API infrastructure remain in `backend/routes/web.php`, `backend/routes/api.php`, and `backend/bootstrap/app.php`
- [X] T011 [US1] Reduce the generated mobile experience to a stable starter-only screen with no HTTP, persistence, domain model, repository, service, or business state in `mobile/lib/main.dart`
- [X] T012 [US1] Run Laravel route inspection and automated tests for `backend/routes/`, `backend/tests/Feature/HealthTest.php`, and `backend/phpunit.xml`; record the commands, expected results, actual pass/fail state, and secret-free diagnostics in `docs/foundation-verification.md`
- [X] T013 [US1] Start the backend from `backend/`, request `http://127.0.0.1:8000/up`, compare the result with `specs/002-project-foundation/contracts/foundation-health.openapi.yaml`, and record HTTP status, timing, and safe diagnostics in `docs/foundation-verification.md`
- [X] T014 [US1] Run formatting, analysis, and widget tests over `mobile/lib/main.dart`, `mobile/test/widget_test.dart`, and `mobile/pubspec.yaml`, recording results in `docs/foundation-verification.md`
- [X] T015 [US1] Confirm `emulator-5554` is in `device` state, launch `mobile/` explicitly with that device ID, observe the initial screen without a crash within five minutes, and record the target, timing, and result in `docs/foundation-verification.md`

**Checkpoint**: User Story 1 is independently demonstrable and forms the MVP: backend readiness and mobile starter launch both pass on the fixed environment.

---

## Phase 4: User Story 2 - Configure a Safe Local Environment (Priority: P2)

**Goal**: A contributor can derive ignored local configuration from a safe example and connect Laravel to XAMPP MariaDB without exposing credentials.

**Independent Test**: Copy `backend/.env.example` to `backend/.env`, supply valid local MariaDB values, prove Git ignores the real file, pass database readiness, then prove an invalid password fails clearly without revealing it.

### Tests for User Story 2

- [X] T016 [P] [US2] Add assertions for environment-file ignore behavior, required safe example keys, blank secret fields, and absence of tracked real environment files to `backend/tests/Feature/EnvironmentSafetyTest.php`
- [X] T017 [P] [US2] Define the positive, invalid-password, recovery, and redaction evidence rows for the database readiness check in `docs/foundation-verification.md`

### Implementation for User Story 2

- [X] T018 [US2] Configure the MariaDB-compatible `mysql` connection to consume environment values in `backend/config/database.php` without embedding XAMPP paths, credentials, or production assumptions
- [X] T019 [US2] Create a safe configuration template in `backend/.env.example` with blank `APP_KEY` and `DB_PASSWORD`, local defaults for `DB_HOST=127.0.0.1` and `DB_PORT=3306`, and all fields specified by `specs/002-project-foundation/data-model.md`
- [X] T020 [US2] Align backend-specific secret and generated-file exclusions in `backend/.gitignore` with the root `.gitignore`, preserving explicit tracking of `backend/.env.example`
- [X] T021 [US2] Create ignored `backend/.env` from `backend/.env.example`, generate a local application key, and verify `git check-ignore backend/.env` succeeds while `git ls-files backend/.env` prints nothing; record secret-free results in `docs/foundation-verification.md`
- [X] T022 [US2] Start XAMPP MariaDB 10.4.32 and run the non-mutating Laravel 13 database inspection from `backend/` with valid local settings, recording a successful connection without credentials in `docs/foundation-verification.md`
- [X] T023 [US2] Repeat the database inspection with a temporary invalid password, verify actionable failure without password disclosure or tracked-file mutation, restore the valid value, rerun successfully, and record all three states in `docs/foundation-verification.md`

**Checkpoint**: User Story 2 independently proves safe example configuration, Git exclusion, valid MariaDB readiness, safe failure, and recovery.

---

## Phase 5: User Story 3 - Understand the Foundation Quickly (Priority: P3)

**Goal**: A new contributor can use one root guide to understand the repository and complete both startup checks without undocumented project-specific knowledge.

**Independent Test**: From a clean checkout on the fixed environment, follow only the root README and complete both startup outcomes on the first attempt within 20 minutes excluding downloads.

### Documentation and Validation for User Story 3

- [X] T024 [US3] Write `README.md` with the fixed prerequisites, `backend/`/`mobile/`/`docs/` layout, safe environment preparation, XAMPP MariaDB settings, dependency setup, backend `/up` startup, `emulator-5554` mobile launch, expected evidence, and recoverable failure guidance
- [X] T025 [US3] Ensure every command in `README.md` names its working directory and matches the commands and expected outcomes in `specs/002-project-foundation/quickstart.md`
- [X] T026 [US3] Perform a clean-checkout walkthrough using only `README.md`, record first-attempt completion, start/end times excluding downloads, failures and recovery, backend result, and mobile result in `docs/foundation-verification.md`
- [X] T027 [US3] Review `README.md` as a contributor unfamiliar with FixFlow and record whether all prerequisites, configuration fields, success signals, and retry actions were discoverable without undocumented project-specific knowledge in `docs/foundation-verification.md`

**Checkpoint**: User Story 3 independently proves the root guide is complete, repeatable, and usable on the fixed development environment.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Close traceability, security, scope, and full-journey quality gates without expanding the feature.

- [X] T028 [P] Scan tracked content listed by Git for real credentials, generated keys, passwords, tokens, credential-bearing URLs, and accidentally tracked `.env` files; record the zero-secret result in `docs/foundation-verification.md`
- [X] T029 [P] Audit `backend/app/`, `backend/routes/`, `backend/database/migrations/`, `mobile/lib/`, `backend/composer.json`, and `mobile/pubspec.yaml` for excluded authentication behavior, users/roles, tickets, comments, ratings, notifications, maps, QR codes, push notifications, export, analytics, domain persistence, business logic, and unjustified packages
- [X] T030 Re-run every validation section in `specs/002-project-foundation/quickstart.md` and complete the requirement-to-evidence matrix for FR-001 through FR-012 and SC-001 through SC-007 in `docs/foundation-verification.md`
- [X] T031 Review the final tracked diff against `specs/002-project-foundation/spec.md` and `specs/002-project-foundation/plan.md`, confirm all constitution gates still pass, and document any failure instead of accepting unexplained scope or architecture drift in `docs/foundation-verification.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 — Setup**: Starts immediately; T001 precedes T002 because verification evidence lives in `docs/`; T003 precedes generators so exclusions protect generated local files.
- **Phase 2 — Foundational**: Depends on Phase 1. T004 must be reviewed before T005. T006 is a separate reviewed increment. T007 follows both application scaffolds.
- **Phase 3 — User Story 1**: Depends on Phase 2 and forms the MVP.
- **Phase 4 — User Story 2**: Depends on the Laravel scaffold from Phase 2, but not on completion of User Story 1 behavior.
- **Phase 5 — User Story 3**: Depends on User Stories 1 and 2 because the README must document verified final commands and outcomes.
- **Phase 6 — Polish**: Depends on all selected user stories.

### User Story Dependency Graph

```text
Setup -> Foundational -> US1 (P1 runnable MVP)
                      -> US2 (P2 safe environment)
US1 + US2 -> US3 (P3 authoritative setup guide)
US1 + US2 + US3 -> Final audit
```

### Within Each User Story

- Add or align automated checks before the behavior/configuration they verify where practical.
- Confirm a task's bounded diff and evidence before starting its dependent task.
- Never place secrets in commands, files intended for Git, logs, screenshots, or `docs/foundation-verification.md`.
- Stop on fixed-toolchain mismatch, unavailable `emulator-5554`, or unexplained constitution/scope drift; do not upgrade tools or silently substitute another target.

## Parallel Opportunities

- T008 and T009 can run in parallel after Phase 2 because they affect backend and mobile test files independently.
- T016 and T017 can run in parallel because they affect a backend test and the evidence document independently.
- Once Phase 2 completes, US1 test preparation and US2 test/evidence preparation can proceed concurrently, but live backend operations must coordinate port and local-environment use.
- T028 and T029 can run in parallel after all story phases because one audits secrets/tracking and the other audits scope/dependencies.
- Generator tasks T004 and T006 are intentionally not marked parallel: the constitution requires each generated application increment to be reviewed before dependent work proceeds.

## Parallel Example: User Story 1

```text
Task T008: Add the /up Feature Test in backend/tests/Feature/HealthTest.php
Task T009: Align the starter render test in mobile/test/widget_test.dart
```

## Parallel Example: User Story 2

```text
Task T016: Add environment safety checks in backend/tests/Feature/EnvironmentSafetyTest.php
Task T017: Define database readiness evidence rows in docs/foundation-verification.md
```

## Implementation Strategy

### MVP First — User Story 1

1. Complete Phase 1 and stop if the fixed environment differs.
2. Complete Phase 2 one scaffold/review increment at a time.
3. Complete Phase 3 and verify backend readiness plus mobile launch independently.
4. Stop and review the MVP before adding safe-configuration and documentation stories.

### Incremental Delivery

1. Setup creates protected monorepo boundaries and fixed-environment evidence.
2. Foundational work creates and reviews each framework scaffold separately.
3. US1 proves the runnable baseline.
4. US2 proves safe local configuration and MariaDB recovery behavior.
5. US3 turns verified actions into the contributor entry point.
6. Final audit closes requirement, security, scope, and constitution evidence.

## Notes

- `[P]` means the task touches independent files and has no incomplete dependency.
- `[US1]`, `[US2]`, and `[US3]` provide direct traceability to prioritized user stories in `spec.md`.
- Framework-generated files are reviewed inputs, not permission to add business behavior.
- Generated Sanctum files establish the constitution-selected future mechanism only; authentication behavior remains out of scope.
- No task may upgrade PHP, Flutter, Dart, MariaDB, replace XAMPP, create another emulator, or introduce an alternate application root.
- Commit or review after each task or tightly related bounded group; do not implement the entire foundation in one operation.
