# Implementation Plan: Department and Category Reference Data

**Branch**: `main` | **Date**: 2026-07-22 | **Spec**: [spec.md](spec.md)

## Summary

Add administrator-only lifecycle management for departments and categories plus authenticated active-option reads. Laravel uses migrations, policies/middleware, Form Requests, Actions, Resources, the existing envelope, and optimistic version checks. Flutter extends the existing layered client with reference-data models, API service, repository, state controller, administrator screens, and reusable active-option loading.

## Technical Context

**Language/Version**: PHP 8.3+ / Laravel 13; Dart 3.11.5 / Flutter stable

**Primary Dependencies**: Existing Laravel, Sanctum, Flutter `http`; no new packages

**Storage**: MariaDB; departments/categories use retained rows, normalized names, active flags, and integer versions

**Testing**: PHPUnit Feature Tests; Flutter unit/widget tests; Pint; Dart format; Flutter analyze; dependency audits

**Target Platform**: Existing Laravel JSON API and Flutter Android-first client

**Project Type**: Existing `backend/` + `mobile/` monorepo

**Performance Goals**: feedback within 1 second and 95% of operations complete within 3 seconds

**Constraints**: admin lookup concealed behind authorization; no delete routes; atomic uniqueness/relationship/version checks; inactive rows retained

**Scale/Scope**: complete deterministic lists at v1 scale; only departments/categories and option reads

**Package Justification**: No package additions; existing transport/state primitives are sufficient.

## Constitution Check

*GATE: Passed before research and after design.*

- **Traceability — PASS**: Components map to US1–US3, FR-001–FR-031, and VR-001–VR-006.
- **Independent value — PASS**: Department management is the MVP; category and option phases are separately verifiable.
- **Verification — PASS**: Backend authorization/contract tests and Flutter state/widget tests precede implementation.
- **Security and operations — PASS**: Admin authorization happens before record lookup; failures are atomic and diagnostics avoid payloads.
- **Simplicity and packages — PASS**: Existing dependencies and architecture are reused.
- **Architecture — PASS**: Laravel REST, MariaDB migrations, Sanctum, and Flutter boundaries are preserved.
- **Backend layering — PASS**: Requests, Actions, Resources, middleware, and thin controllers are planned.
- **Feature tests — PASS**: Success, validation, authentication, role denial, relationship, lifecycle, option filtering, and conflicts are covered.
- **Mobile states — PASS**: Models/services/repository/state/UI are separated with every required state.
- **V1 scope — PASS**: No tickets, users/roles, deletion, analytics, or other deferred behavior.

## Project Structure

```text
backend/app/{Actions/ReferenceData,Http/Controllers/Api,Http/Middleware,Http/Requests/ReferenceData,Http/Resources,Models}/
backend/database/{migrations,factories,seeders}/
backend/tests/Feature/ReferenceData/
mobile/lib/reference_data/{models,services,repositories,state,screens,widgets}/
mobile/test/reference_data/
specs/004-reference-data-management/{plan,research,data-model,quickstart,contracts,tasks}.md
```

**Structure Decision**: Extend the existing application roots and response/authentication infrastructure; no alternate roots or shared domain framework.

## Complexity Tracking

No violations or exceptions.
