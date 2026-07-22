# Implementation Plan: User Authentication and Session Management

**Branch**: `main` | **Date**: 2026-07-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-user-auth/spec.md`

## Summary

Deliver the minimum identity boundary for FixFlow: visitor registration restricted to reporter accounts, email/password sign-in, active-user own-profile access, current-token sign-out, and secure Flutter session restoration. The backend uses Laravel Sanctum bearer tokens behind thin controllers, Form Requests, Actions, Resources, active-account middleware, and a uniform response envelope. The Flutter client separates models, transport, secure storage, repository, session state, and three screens while representing every required loading and failure state.

## Technical Context

**Language/Version**: PHP 8.3+ (validated with PHP 8.5) / Laravel 13; Dart 3.11.5 / Flutter stable revision `00b0c91f`

**Primary Dependencies**: Existing Laravel Sanctum 4 for revocable API tokens; Flutter `http` for REST transport; Flutter `flutter_secure_storage` for Android Keystore/iOS Keychain-backed token persistence

**Storage**: MariaDB for user and token records through Laravel migrations; device-protected secure storage for the current mobile bearer token

**Testing**: PHPUnit 12 Laravel Feature Tests; Flutter unit and widget tests with fakes; Laravel Pint; Dart formatter; Flutter analyzer; Composer security audit; Flutter dependency/outdated audit

**Target Platform**: Laravel JSON API on the existing deployment target; Flutter Android first with portable secure-storage abstraction for other supported Flutter platforms

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter app, `docs/` documentation

**Performance Goals**: Visible progress within 1 second; 95% of authentication/profile operations complete within 3 seconds under normal connectivity; session restoration resolves to authenticated, signed-out, or recoverable failure without stale protected data

**Constraints**: Passwords/tokens never logged or returned outside token issuance; generic credential failures; atomic failures; active-account check on every protected request; public role fixed to reporter; secure-storage failure never falls back to plaintext; no speculative role administration

**Scale/Scope**: Four REST endpoints, one user table, existing Sanctum token table, three Flutter screens, and one active mobile session; ticket features and all deferred authentication features remain excluded

**Package Justification**: Sanctum already satisfies the constitutional token requirement. `http` provides a small maintained REST client without generated-client complexity. `flutter_secure_storage` is necessary because Flutter core has no protected credential store; ordinary preferences were rejected as insecure. Built-in `ChangeNotifier` avoids adding a state-management package for this bounded flow.

## Constitution Check

*GATE: Passed before research and passed again after Phase 1 design.*

- **Traceability — PASS**: Plan and tasks map backend/mobile components to US1–US4, FR-001–FR-027, SR-001–SR-007, and SC-001–SC-010.
- **Independent value — PASS**: US1 produces a usable reporter registration/profile increment; shared response, identity, transport, and session primitives are limited to cross-story blockers.
- **Verification — PASS**: Contract and widget/unit tests cover successes, validation, authentication, ownership, inactivity, revocation, secure storage, and recovery before implementation.
- **Security and operations — PASS**: Trust boundaries, atomic transactions, safe credential messages, token handling, active-account enforcement, and redacted structured diagnostics are designed.
- **Simplicity and packages — PASS**: Only two focused Flutter dependencies are added; no new backend dependency or service is introduced.
- **Architecture — PASS**: Work stays in the required monorepo roots, uses documented REST, migrations, MariaDB-compatible schema, Flutter, and Sanctum.
- **Backend layering — PASS**: Requests validate, Actions own state changes, Resources shape output, middleware enforces active status, and controllers only coordinate.
- **Feature tests — PASS**: Each operation has automated success and material failure coverage, including public-role injection and current-token scope.
- **Mobile states — PASS**: UI, state, repository, service, storage, and models are separated; impossible empty/validation profile states become contract/server failures.
- **V1 scope and increments — PASS**: Authentication only; no reset, verification, social, 2FA, tickets, editing, notifications, or role management.

## Project Structure

### Documentation (this feature)

```text
specs/003-user-auth/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/auth.openapi.yaml
`-- tasks.md
```

### Source Code (repository root)

```text
backend/
|-- app/Actions/Auth/              # register, login, logout operations
|-- app/Http/Controllers/Api/      # thin authentication controller
|-- app/Http/Middleware/           # active-account enforcement
|-- app/Http/Requests/Auth/        # registration and login validation
|-- app/Http/Resources/            # consistent user response
|-- app/Models/User.php            # authenticatable token owner
|-- app/Support/ApiResponse.php    # response envelope
|-- database/factories/UserFactory.php
|-- database/migrations/*create_users_table.php
|-- database/seeders/DatabaseSeeder.php
|-- routes/api.php
`-- tests/Feature/Auth/             # endpoint/security coverage

mobile/
|-- lib/auth/models/               # profile and API failure models
|-- lib/auth/services/             # HTTP transport and secure token store
|-- lib/auth/repositories/         # authentication orchestration
|-- lib/auth/state/                # session and operation states
|-- lib/auth/screens/              # registration, sign-in, profile UI
|-- lib/app.dart
|-- lib/main.dart
`-- test/auth/                      # repository/state/widget coverage
```

**Structure Decision**: Use the existing Laravel and Flutter roots. The backend controller never contains validation or business rules. The mobile UI depends on session state only; state depends on the repository; the repository alone coordinates API transport and secure storage.

## Complexity Tracking

No constitution violations or exceptions are required.
