# Implementation Plan: Ticket Assignment

**Branch**: `006-ticket-assignment` | **Date**: 2026-07-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/006-ticket-assignment/spec.md`

## Summary

Deliver an administrator-only, newest-first ticket queue, an active-technician option lookup, and a
one-time assignment interaction through documented Laravel REST endpoints and Flutter ticket layers.
The assignment Action locks the ticket in a database transaction, revalidates the technician and
ticket invariants, then atomically sets the technician, moves `new` to `assigned`, and appends one
immutable history row. Reassignment, unassignment, technician processing, discussions, ratings,
deletion, and other status transitions remain excluded.

## Technical Context

**Language/Version**: PHP ^8.3 / Laravel ^13.0; Dart SDK ^3.11.5 / installed Flutter SDK

**Primary Dependencies**: Existing Laravel Sanctum ^4.0 for API authentication; existing Flutter
`http` ^1.3.0 for REST and `flutter_secure_storage` ^10.3.1 for session tokens. No package additions.

**Storage**: MariaDB in deployed environments; SQLite in isolated tests. Add a nullable ticket
technician foreign key and an immutable ticket-status-history table through Laravel migrations.

**Testing**: PHPUnit 12 Laravel Feature Tests; Flutter unit and widget tests; optional Android device
smoke verification

**Target Platform**: Laravel API on PHP-capable Linux/Windows hosts; Flutter Android client, while
preserving the existing configured Flutter targets

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter app, `docs/` documentation

**Performance Goals**: Visible progress within 1 second; 95% of list, option, and assignment outcomes
within 3 seconds under normal connectivity; ticket pages default to 20 and are capped at 100

**Constraints**: Sanctum, active-account, administrator-role, and oversight authorization precede
restricted lookup; stable `(created_at, id)` ordering; commit-time technician eligibility; one-time
`new`-to-`assigned` mutation; transaction and row lock prevent partial or competing success; sanitized
diagnostics; accessible/localization-ready UI; no optimistic or offline assignment

**Scale/Scope**: All tickets are within every active administrator's Version 1 oversight. The global
queue targets normal Version 1 volumes without search, advanced filters, bulk assignment, or analytics.

**Package Justification**: None added. Laravel validation, middleware, transactions, pessimistic row
locking, Resources, and Eloquent plus existing Flutter HTTP, secure storage, ChangeNotifier, and SDK
widgets cover the feature. A queue, state-management package, or separate service would add complexity
without solving an approved requirement.

## Constitution Check

*GATE: PASS before research; PASS after Phase 1 design.*

- **Traceability**: The three REST operations, persistence changes, client states, and verification
  map to US1, FR-001-FR-025, VR-001-VR-007, and SC-001-SC-009.
- **Independent value**: The administrator list is the first demonstrable increment; technician
  lookup and atomic assignment extend the same P1 journey without unrelated foundations.
- **Verification**: Contract, migration invariants, authorization, eligibility, atomicity,
  concurrency, restricted-data, mapping, controller, and widget tests are planned before implementation.
- **Security and operations**: Middleware rejects unauthenticated/inactive/non-admin actors before
  ticket resolution; transaction-time checks close stale-choice races; logs omit restricted content.
- **Simplicity and packages**: One focused assignment Action and existing framework/client facilities
  suffice. No dependency, background service, or speculative workflow abstraction is introduced.
- **Architecture**: Changes remain in `backend/`, `mobile/`, and `specs/`; Flutter consumes only the
  documented REST contract; both schema changes use reproducible Laravel migrations.
- **Backend layering**: Thin controllers invoke Form Requests, authorization middleware/policy/query
  boundaries, an assignment Action, API Resources, factories, and Feature Tests.
- **Feature tests**: Listing, pagination, options, success, all eligibility failures, authentication,
  roles, concealment, stale state, competing assignment, rollback, and sanitized errors are covered.
- **Mobile states**: Admin models, service/repository methods, ChangeNotifier controllers, and screens
  remain separated and cover loading, success, empty, validation, unauthorized, concealed-not-found,
  conflict, offline, and server failure where applicable.
- **V1 scope and increments**: The plan advances the create-to-assign workflow only; all deferred
  workflow and advanced capabilities remain absent.

No constitution violation or exception is required. The post-design review confirms the data model,
OpenAPI contract, and quickstart preserve every gate.

## Project Structure

### Documentation (this feature)

```text
specs/006-ticket-assignment/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- openapi.yaml
`-- tasks.md                    # generated later; not part of this planning request
```

### Source Code (repository root)

```text
backend/
|-- app/Actions/Tickets/AssignTicket.php
|-- app/Http/Controllers/Api/AdminTicketController.php
|-- app/Http/Controllers/Api/AdminTechnicianOptionController.php
|-- app/Http/Requests/Tickets/{AdminListTicketsRequest,AssignTicketRequest}.php
|-- app/Http/Resources/{AdminTicketSummaryResource,TechnicianOptionResource}.php
|-- app/Models/{Ticket,TicketStatusHistory,User}.php
|-- database/factories/{TicketFactory,TicketStatusHistoryFactory,UserFactory}.php
|-- database/migrations/        # technician FK and status-history table
|-- routes/api.php
`-- tests/Feature/Tickets/{AdminListTicketsTest,TechnicianOptionsTest,AssignTicketTest}.php

mobile/
|-- lib/tickets/models/         # admin summaries, technician option, page/result models
|-- lib/tickets/services/       # admin GET/PATCH transport and envelope mapping
|-- lib/tickets/repositories/   # administrator ticket boundary
|-- lib/tickets/state/          # list, technician-choice, and assignment controllers
|-- lib/tickets/screens/        # admin queue and assignment interaction
|-- lib/auth/screens/profile_screen.dart
|-- lib/{app.dart,main.dart}    # existing manual dependency composition
`-- test/tickets/               # repository/controller/widget verification
```

**Structure Decision**: Extend the existing Laravel and Flutter ticket feature layers. Use a separate
admin controller/resource/repository surface so reporter endpoints and payloads do not broaden. The
assignment Action owns the transaction and invariants; controllers authorize, dispatch, and format.
Flutter services own HTTP, repositories own contract mapping/token access, controllers own async
state, and screens render state. Existing middleware remains authoritative for role gating.

## Delivery Increments

1. **Administrator queue**: migration-compatible admin summary model/resource, authorized paginated
   endpoint, Flutter list states, and list tests. No mutation.
2. **Eligibility choices**: active-technician-only option endpoint and Flutter option states/tests.
3. **Atomic assignment**: schema/history, assignment Action and contract, conflict/privacy tests,
   Flutter submit/refresh behavior, and end-to-end acceptance validation.

Each increment is reviewable and testable without implementing excluded capabilities.

## Complexity Tracking

No violations.
