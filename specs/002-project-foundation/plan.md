# Implementation Plan: FixFlow Project Foundation

**Branch**: `002-project-foundation` | **Date**: 2026-07-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-project-foundation/spec.md`

**Note**: This plan describes implementation only. No application initialization or source implementation occurs during planning.

## Summary

Create the smallest reproducible FixFlow monorepo baseline on the already-installed Windows 11 toolchain: a Laravel 13 API-only application under `backend/`, a Flutter 3.41.9 Android application under `mobile/`, an empty tracked documentation area under `docs/`, safe environment examples, root secret/build exclusions, and a root README that drives clean-checkout verification. XAMPP MariaDB 10.4.32 is configured exclusively through Laravel environment variables. Verification proves the built-in backend health response, MariaDB connectivity and safe failure, and a crash-free Flutter starter launch on Android emulator `emulator-5554`. No domain route, model, UI flow, authentication behavior, business logic, or toolchain upgrade is added.

## Technical Context

**Language/Version**: PHP 8.5.0 / Laravel 13.x (`^13.0`); Dart 3.11.5 / Flutter 3.41.9 stable

**Primary Dependencies**: Composer-managed Laravel framework; Laravel Sanctum installed by Laravel's API setup command solely to establish the constitution-mandated future authentication mechanism; Flutter SDK packages only

**Storage**: MariaDB 10.4.32 supplied by the installed XAMPP environment; `utf8mb4`; environment-driven connection; generated framework/Sanctum migrations remain versioned, but this feature adds no domain migration or entity

**Testing**: Laravel's generated PHPUnit test tooling plus a focused Feature Test for the health contract and environment/config safety checks; Flutter's generated `flutter_test` widget test; analyzer checks; one manual emulator launch check

**Target Platform**: Windows 11 with PowerShell, PHP CLI, and XAMPP; Android mobile application on the already-configured emulator `emulator-5554`; production deployment and iOS/web/desktop validation are out of scope

**Performance Goals**: After dependencies are present, backend and mobile startup verification each completes within 5 minutes; full documented clean-checkout setup completes within 20 minutes excluding downloads

**Constraints**: Use installed PHP 8.5.0, Flutter 3.41.9 stable, Dart 3.11.5, XAMPP MariaDB 10.4.32, Windows 11, and emulator `emulator-5554`; do not require toolchain upgrades; API-only backend; MariaDB values supplied through local environment; zero tracked real secrets; no domain/API/mobile integration; commands must state their working directory; diagnostics and evidence must redact credentials

**Scale/Scope**: One contributor-facing foundation, three top-level project areas, one backend health endpoint, one generated mobile starter screen, zero product users/tickets/domain records, and exactly the exclusions in FR-011

**Package Justification**: Laravel and Flutter are constitution-mandated application foundations. Laravel 13 officially supports PHP 8.3–8.5 and is compatible with installed PHP 8.5.0. Sanctum is constitution-mandated for future authentication and is installed through the official API setup path, but no authentication behavior is enabled. XAMPP MariaDB uses Laravel's built-in MySQL-compatible PDO driver. No optional Composer, pub, state-management, HTTP, dotenv, logging, or testing package is added because built-in capabilities satisfy this feature.

## Constitution Check

*GATE: Passed before Phase 0 research. Passed again after Phase 1 design.*

- **Traceability — PASS**: The plan maps the three stories to FR-001–FR-012, SC-001–SC-007, the verification matrix in `quickstart.md`, and the `/up` contract.
- **Independent value — PASS**: P1 yields both runnable application foundations; P2 adds safe local configuration; P3 adds contributor guidance. No story-specific product capability is introduced.
- **Verification — PASS**: Every functional requirement appears in the quickstart traceability matrix. Automated health/widget/static checks cover reproducible behavior; emulator rendering and clean-checkout timing remain manual because they depend on a provisioned host.
- **Security and operations — PASS**: Environment-only secrets, layered ignore files, tracked-file scans, redacted evidence, negative database verification, retry instructions, and explicit local-only treatment of the installed MariaDB version cover the applicable trust boundary and failures.
- **Simplicity and packages — PASS**: Only mandated framework dependencies are used. Built-in drivers, tests, health routing, and starter UI replace optional packages and abstractions.
- **Architecture — PASS**: Source is confined to `backend/`, `mobile/`, and `docs/`. MariaDB configuration and migrations are versioned. No client/backend integration exists yet. Sanctum is present but unused.
- **Backend layering — PASS (not applicable to domain behavior)**: No application controller, request, resource, action/service, policy, factory, seeder, or domain endpoint is introduced. Empty architectural directories are not created speculatively; later features add layers when required.
- **Feature tests — PASS**: A backend Feature Test verifies the only exposed foundation behavior, `GET /up`. Authentication, validation, ownership, and domain errors cannot occur and are explicitly deferred.
- **Mobile states — PASS (not applicable to data flows)**: The starter app has launch success/failure only and performs no HTTP, persistence, repository, service, model, or state-management work. Layer directories are deferred until a data-driven flow exists.
- **V1 scope and increments — PASS**: The foundation unblocks the core ticket workflow and excludes authentication behavior, tickets, advanced features, and business logic. Implementation is divided into bounded scaffold, configuration, backend verification, mobile verification, and documentation increments.

### Post-Design Re-check

Phase 1 introduces no domain entity or cross-component integration. The OpenAPI contract documents only the non-business readiness probe; the data-model artifact explicitly records the absence of persisted domain data; and the quickstart covers every requirement without expanding scope. All gates remain passed with no exception or constitution amendment.

## Project Structure

### Documentation (this feature)

```text
specs/002-project-foundation/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- foundation-health.openapi.yaml
`-- tasks.md                         # generated in the later tasks phase
```

### Source Code (repository root)

```text
backend/                             # generated Laravel 13 API application
|-- app/                             # generated framework application code only
|-- bootstrap/app.php               # API routing and built-in health route registration
|-- config/database.php             # environment-driven MariaDB-compatible connection
|-- database/migrations/             # generated framework/Sanctum migrations only
|-- routes/api.php                   # no business routes
|-- tests/Feature/HealthTest.php     # /up contract verification
|-- .env.example                    # inert local configuration template
`-- .gitignore                      # backend secrets and generated files

mobile/                              # generated Flutter 3.41.9 Android application
|-- android/                         # generated Android host project
|-- lib/main.dart                    # generated starter UI only
|-- test/widget_test.dart            # starter render verification
|-- pubspec.yaml                     # SDK dependencies only
`-- .gitignore                      # Flutter/Android generated files

docs/
`-- .gitkeep                         # retains the required empty documentation root

.gitignore                           # repository-wide secret/build/editor exclusions
`-- README.md                        # authoritative contributor setup and verification entry point
```

**Structure Decision**: Use the constitution-mandated application roots exactly. Preserve generated framework structure where needed for reproducibility, but do not pre-create domain layering or mobile architecture folders with no behavior to own. `docs/` is retained with a neutral placeholder until project documentation beyond the root setup guide exists.

## Implementation Strategy

1. **Repository skeleton**: Create only the three required roots and confirm the feature directory remains under `specs/`.
2. **Backend scaffold**: Confirm PHP 8.5.0, then generate Laravel 13 into an empty `backend/`, enable the official API routing/Sanctum foundation, remove or avoid frontend starter assets, and preserve the built-in `/up` readiness route.
3. **Configuration safety**: Select the MySQL-compatible Laravel driver with XAMPP MariaDB environment defaults (`DB_CONNECTION=mysql`, host `127.0.0.1`, port `3306`, database, username, password), use inert example values, and layer root/backend ignore rules. Do not commit a generated application key or local `.env`.
4. **Backend verification**: Add the narrow `/up` Feature Test, run generated tests, inspect routes for absence of business/UI behavior, verify valid database connectivity via a framework database command, and capture an invalid-password failure without sensitive output.
5. **Mobile scaffold and verification**: Confirm Flutter 3.41.9 stable with Dart 3.11.5, generate Android-only Flutter application output, retain the minimal starter screen and generated widget test, run format/analyze/test, select emulator `emulator-5554` explicitly, and launch once to confirm a crash-free initial screen.
6. **Documentation and audit**: Write the root README from `quickstart.md`, ensure every command states its working directory, scan tracked content/status for secrets and out-of-scope concepts, and record pass/fail evidence.

Each step is a separate reviewable increment. Backend and mobile generator output MUST be reviewed before dependent edits; implementation MUST NOT scaffold both applications and customize them as one opaque operation.

## Verification Mapping

| Requirement | Planned evidence |
|-------------|------------------|
| FR-001 | Root directory assertion and README layout section |
| FR-002, FR-007 | Route inspection, `HealthTest`, and live `/up` response |
| FR-003, FR-008 | Flutter 3.41.9/Dart 3.11.5 analyze/test output, `emulator-5554` device listing, and launch observation |
| FR-004 | Configuration inspection plus valid/invalid MariaDB readiness checks |
| FR-005, FR-006 | Example-file review, ignore checks, Git status, and tracked-content secret scan |
| FR-009 | Clean-checkout README walkthrough and timing record |
| FR-010 | Secret-free evidence table containing command/action, expected outcome, and result |
| FR-011 | Route/source/dependency keyword and behavior audit |
| FR-012 | Dependency manifest review against `research.md` package decisions |

## Complexity Tracking

No constitution violations or exceptions are required.
