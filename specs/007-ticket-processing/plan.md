# Implementation Plan: Technician Ticket Processing

**Branch**: `007-ticket-processing` | **Date**: 2026-07-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/007-ticket-processing/spec.md`

## Summary

Deliver a technician-only assigned-ticket queue, owned assigned-ticket details with chronological
history, and exactly four forward processing transitions through documented Laravel REST endpoints
and separated Flutter ticket layers. A focused transition Action locks the ticket, revalidates current
assignment and status, then atomically updates status and appends one immutable history row. A nullable
history reason field supports required rejection reasons. Discussions, ratings, reassignment,
unassignment, deletion, reference-data management, and unsupported transitions remain excluded.

## Technical Context

**Language/Version**: PHP ^8.3 / Laravel ^13.0; Dart SDK ^3.11.5 / installed Flutter SDK

**Primary Dependencies**: Existing Laravel Sanctum ^4.0 for API authentication; existing Flutter
`http` ^1.3.0 for REST and `flutter_secure_storage` ^10.3.1 for session tokens. No package additions.

**Storage**: MariaDB in deployed environments; SQLite in isolated tests. Reuse the ticket assignee and
immutable history schema from feature 006; add one nullable rejection-reason history column through a
Laravel migration.

**Testing**: PHPUnit 12 Laravel Feature Tests; Flutter unit and widget tests; live Android/API
verification tracked separately and deferred when no device/emulator or required artifact access exists

**Target Platform**: Laravel API on PHP-capable Linux/Windows hosts; Flutter Android client while
preserving existing configured Flutter targets

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter app, `docs/` documentation

**Performance Goals**: Visible progress within 1 second; 95% of list, detail, and transition outcomes
within 3 seconds under normal connectivity; default page size 20 and maximum 100

**Constraints**: Sanctum, active-account, technician-role, and current-assignment authorization;
assignment filtering before counts/lookup; exact transition graph; required trimmed rejection reason;
terminal completed/rejected states; transaction plus ticket row lock; immutable history; concealed
non-assignment; sanitized diagnostics; accessible/localization-ready UI; no optimistic/offline mutation

**Scale/Scope**: Current technician assignments at normal Version 1 ticket volumes. Stable
`(created_at, id)` ordering supports pagination without search, filtering, background jobs, or caching.

**Package Justification**: None added. Existing Laravel middleware, Form Requests, Resources,
transactions, pessimistic locking, and Eloquent plus the existing Flutter HTTP, token store,
ChangeNotifier, and widgets satisfy the approved requirements.

## Constitution Check

*GATE: PASS before research; PASS after Phase 1 design.*

- **Traceability**: The three REST operations, one additive history field, client states, and tests map
  to US1-US3, FR-001-FR-029, VR-001-VR-007, and SC-001-SC-009.
- **Independent value**: Assigned list/detail is a read-only first increment; start work and terminal
  outcomes are separately testable transitions.
- **Verification**: Contract, assignment isolation, transition matrix, immutable history, rollback,
  concurrency, mapping, controller, and widget tests precede implementation.
- **Security and operations**: Middleware and assignment-scoped queries precede restricted resolution;
  commit-time checks close stale races; diagnostics omit ticket/reason contents and secrets.
- **Simplicity and packages**: One transition Action and existing layers suffice. No dependency,
  workflow engine, queue, event store, or speculative transition framework is introduced.
- **Architecture**: Changes stay in `backend/`, `mobile/`, and `specs/`; Flutter uses only documented
  REST; the single schema addition is reproducible through a migration.
- **Backend layering**: Thin controllers use Form Requests, technician middleware, assignment-scoped
  queries, an Action, API Resources, factories, and Laravel Feature Tests.
- **Feature tests**: Lists/details, pagination, every role and assignment boundary, all allowed and
  forbidden transitions, reason validation, terminal state, concealment, concurrency, rollback,
  history immutability, envelopes, and diagnostics are planned.
- **Mobile states**: Technician models, service, repository, ChangeNotifier controllers, and screens
  cover all applicable loading, success, empty, validation, denial, conflict, offline, and server states.
- **V1 scope and increments**: Only core User Story 3 processing is included; excluded capabilities
  remain absent.

No constitution violation or exception is required. Post-design review confirms the data model,
OpenAPI contract, quickstart, and deferred live-device gate preserve every check.

## Project Structure

### Documentation (this feature)

```text
specs/007-ticket-processing/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- openapi.yaml
`-- tasks.md                    # generated later
```

### Source Code (repository root)

```text
backend/
|-- app/Actions/Tickets/TransitionTicketStatus.php
|-- app/Http/Controllers/Api/TechnicianTicketController.php
|-- app/Http/Middleware/EnsureUserIsTechnician.php
|-- app/Http/Requests/Tickets/{TechnicianListTicketsRequest,TransitionTicketStatusRequest}.php
|-- app/Http/Resources/{TechnicianTicketSummaryResource,TechnicianTicketResource,TicketStatusHistoryResource}.php
|-- app/Models/{Ticket,TicketStatusHistory,User}.php
|-- database/factories/{TicketFactory,TicketStatusHistoryFactory}.php
|-- database/migrations/        # nullable history rejection reason
|-- routes/api.php
`-- tests/Feature/Tickets/      # technician list/detail/transition suites

mobile/
|-- lib/tickets/models/         # technician summary/detail/history/page/result contracts
|-- lib/tickets/services/       # technician GET/PATCH transport
|-- lib/tickets/repositories/   # authenticated technician ticket boundary
|-- lib/tickets/state/          # list, detail, and transition controllers
|-- lib/tickets/screens/        # assigned queue and owned details
|-- lib/tickets/widgets/        # permitted transition/rejection interaction
|-- lib/auth/screens/profile_screen.dart
|-- lib/{app.dart,main.dart}    # existing manual dependency composition
`-- test/tickets/               # mapping/controller/widget verification
```

**Structure Decision**: Extend the ticket feature with a technician-specific surface so reporter and
administrator contracts remain unchanged. Queries scope list/detail by authenticated technician before
serialization. The Action owns row locking, transition rules, atomic mutation, and history insertion.
Flutter service/repository/state/UI responsibilities follow existing manual dependency injection.

## Delivery Increments

1. **Assigned work reads**: technician middleware, assignment-scoped list/detail resources and routes,
   Flutter models/repository/list/detail states, and privacy/pagination tests. No mutation.
2. **Start work**: `assigned → in_progress` Action path, history insertion, conflict/rollback tests,
   and authoritative Flutter transition refresh.
3. **Terminal outcomes**: rejection-reason migration/validation plus `assigned|in_progress → rejected`
   and `in_progress → completed`, terminal-state tests, and Flutter reason/outcome states.
4. **Quality gates**: full Laravel/Flutter suites, formatting, analysis, security/scope audits, and a
   separately recorded live-device check that may be deferred for a concrete environment blocker.

## Complexity Tracking

No violations.
