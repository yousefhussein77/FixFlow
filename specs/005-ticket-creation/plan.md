# Implementation Plan: Reporter Ticket Creation and Tracking

**Branch**: `005-ticket-creation` | **Date**: 2026-07-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-ticket-creation/spec.md`

## Summary

Deliver reporter-only ticket creation, active classification options, optional immutable creation-time
photos, owned newest-first ticket listing, and concealed owned detail access through Laravel REST APIs
and three Flutter experiences. Creation uses a reporter-scoped submission token, validated uploads,
staged files, and one database transaction so any failure removes staged/durable files and rolls back
ticket and photo records. Assignment, workflow updates, comments, ratings, edits, deletion, maps,
notifications, and exports remain excluded.

## Technical Context

**Language/Version**: PHP 8.5 / Laravel 13.21.1; Dart SDK ^3.11.5 / installed Flutter SDK

**Primary Dependencies**: Existing Laravel Sanctum 4 for API authentication; existing Flutter `http`
for REST and `flutter_secure_storage` for session tokens. No package additions.

**Storage**: MariaDB in deployed environments; SQLite in isolated tests; Laravel filesystem private
disk for ticket photos; all schema changes through Laravel migrations

**Testing**: PHPUnit 12 Laravel Feature Tests; Flutter unit and widget tests; Android emulator smoke
verification when an emulator is available

**Target Platform**: Laravel API on PHP-capable Linux/Windows hosts; Flutter Android client (existing
project also remains build-compatible with configured Flutter targets)

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter app, `docs/` documentation

**Performance Goals**: Visible progress within 1 second; 95% of non-upload request outcomes within
3 seconds under normal connectivity; default list page 20 and maximum 100

**Constraints**: Sanctum plus active-account and reporter-role authorization on every endpoint;
ownership filtering before counts and lookup; 5 photos maximum, 10 MiB each, verified JPEG/PNG/WebP;
atomic records/files; localized and accessible mobile UI; no offline persistence

**Scale/Scope**: Reporter intake and private personal tracking only. Stable `(created_at, id)` ordering
supports normal v1 ticket volumes without search/filter infrastructure.

**Package Justification**: None added. Laravel validation, transactions, filesystem, resources,
policies, and multipart support plus Dart/Flutter SDK facilities and existing `http` cover all needs.

## Constitution Check

*GATE: PASS before research; PASS after Phase 1 design.*

- **Traceability**: REST operations and client states map directly to US1-US3, FR-001-FR-031, and
  VR-001-VR-007.
- **Independent value**: US1 produces a usable ticket; optional photos, listing, and detail remain
  bounded increments.
- **Verification**: Contract, validation, rollback, authorization, state, repository, and widget tests
  are explicitly planned before corresponding implementation.
- **Security and operations**: Requests validate every trust boundary; policies conceal non-ownership;
  logs omit tokens, content, descriptions, locations, and storage paths; failures are recoverable.
- **Simplicity and packages**: Existing framework facilities are sufficient; no dependency or service
  is introduced.
- **Architecture**: Changes stay in the required monorepo roots; Flutter consumes documented REST;
  migrations represent every schema change.
- **Backend layering**: Form Requests, thin controllers, an Action, Resources, middleware/policy,
  factories, and Feature Tests are used.
- **Feature tests**: Success, boundary validation, authentication, roles, ownership, idempotency,
  rollback, pagination, options, and sanitized failures are covered.
- **Mobile states**: Models, service, repository, controllers, and screens remain separated and cover
  all applicable states.
- **V1 scope and increments**: Only reporter creation and owned tracking are included.

No constitution violation or exception is required.

## Project Structure

### Documentation (this feature)

```text
specs/005-ticket-creation/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- openapi.yaml
`-- tasks.md
```

### Source Code (repository root)

```text
backend/
|-- app/Actions/Tickets/CreateTicket.php
|-- app/Http/Controllers/Api/TicketController.php
|-- app/Http/Middleware/EnsureUserIsReporter.php
|-- app/Http/Requests/Tickets/
|-- app/Http/Resources/Ticket*.php
|-- app/Models/{Ticket,TicketPhoto}.php
|-- app/Policies/TicketPolicy.php
|-- database/{factories,migrations}/
|-- routes/api.php
`-- tests/Feature/Tickets/

mobile/
|-- lib/tickets/{models,repositories,services,state,screens,widgets}/
|-- lib/auth/screens/session_gate.dart
`-- test/tickets/
```

**Structure Decision**: Extend the existing Laravel and Flutter layer conventions. Ticket mutation
logic belongs in one Action; controllers only authorize/dispatch/respond. Flutter screen controllers
own async state while repositories map contracts and the API service owns transport.

## Complexity Tracking

No violations.
