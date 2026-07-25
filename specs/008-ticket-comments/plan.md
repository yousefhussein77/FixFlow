# Implementation Plan: Ticket Comments

**Branch**: `008-ticket-comments` | **Date**: 2026-07-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/008-ticket-comments/spec.md`

## Summary

Add immutable chronological plain-text comments to authorized ticket details for the ticket reporter,
current assigned technician, and administrators. Three role-scoped Laravel REST surfaces reuse shared
list/create Actions, current-state authorization, a Comment Resource, and an additive comments table.
Creation runs in one transaction, locks the ticket while rechecking access, and uses a caller-generated
UUID plus a database uniqueness constraint for safe replay. Flutter adds shared comment models,
transport, repository, controller, and widgets embedded into each role's existing authorized ticket
detail flow. No chat, mutation of existing comments, attachments, notifications, ticket workflow
changes, ratings, or unsupported collaboration is introduced.

## Technical Context

**Language/Version**: PHP ^8.3 / Laravel ^13.0; Dart SDK ^3.11.5 / installed Flutter SDK

**Primary Dependencies**: Existing Laravel Sanctum ^4.0 for API authentication; existing Flutter
`http` ^1.3.0 for REST and `flutter_secure_storage` ^10.3.1 for session tokens. No package additions.

**Storage**: MariaDB in deployed environments and SQLite in isolated tests. Add one
`ticket_comments` table through a reversible Laravel migration; no ticket/status/history changes.

**Testing**: PHPUnit 12 Laravel Feature Tests; Flutter unit and widget tests; live Android/API smoke
verification tracked separately and deferred when an Android target or reachable isolated API is absent

**Target Platform**: Laravel API on PHP-capable Linux/Windows hosts; Flutter Android client while
preserving existing configured Flutter targets

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter application, `specs/` feature artifacts

**Performance Goals**: Visible progress within 1 second; 95% of comment list/add outcomes within 2
seconds under normal connectivity; deterministic oldest-first lists at normal Version 1 ticket volume

**Constraints**: Sanctum and active-account checks; reporter ownership, current technician assignment,
or administrator oversight; 2,000-character trimmed nonblank plain text; immutable comments; atomic
commit-time authorization; UUID retry identity; concealed reporter/technician targets; sanitized
diagnostics; accessible/localization-ready UI; no optimistic or queued offline creation

**Scale/Scope**: All comments for one authorized ticket are returned because Version 1 discussion is
bounded to maintenance notes. Search, pagination, streaming, retention changes, moderation, and chat
presence are outside this increment.

**Package Justification**: None added. Laravel validation, transactions, row locks, database unique
constraints, Eloquent, API Resources, and existing Flutter HTTP/token/state/widget layers satisfy the
requirements.

## Constitution Check

*GATE: PASS before research; PASS after Phase 1 design.*

- **Traceability**: The role-specific list/add surfaces, comment schema, retry invariant, client states,
  and tests map to US1-US3, FR-001-FR-029, VR-001-VR-007, and SC-001-SC-010.
- **Independent value**: Authorized chronological reading is independently useful; reporter,
  technician, and administrator creation are separable increments over the shared immutable contract.
- **Verification**: Ownership, assignment, oversight, chronology, validation, immutability, atomicity,
  replay, competing attempts, response mapping, state, and widget behavior have automated coverage.
- **Security and operations**: Authentication precedes role and ticket checks; concealed lookups avoid
  restricted counts/content; commit-time checks close assignment races; diagnostics omit comment text.
- **Simplicity and packages**: One table, one shared authorization service, two Actions, and existing
  layers suffice. No message broker, websocket, notification, rich-text, or new state package is added.
- **Architecture**: Work remains in `backend/`, `mobile/`, and `specs/`; Flutter uses documented REST;
  MariaDB changes are migration-owned and reproducible.
- **Backend layering**: Thin role controllers use Form Requests, shared Actions/authorization,
  Resources, factories, transactions, and Feature Tests.
- **Feature tests**: Every actor, ownership/assignment boundary, empty/list/add outcome, content
  validation, retry race, rollback, concealment, envelope, and diagnostic category is planned.
- **Mobile states**: Models, service, repository, ChangeNotifier controller, and shared UI cover
  loading, populated, empty, submitting, validation, denial, assignment loss, offline, replay, and server states.
- **V1 scope and increments**: Only core User Story 4 comments are included; all excluded collaboration,
  ticket-processing, assignment, and rating capabilities remain absent.

No constitution violation or exception is required. Post-design review confirms that research, data
model, contract, and quickstart preserve these gates.

## Project Structure

### Documentation (this feature)

```text
specs/008-ticket-comments/
|-- spec.md
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
|-- app/Actions/Tickets/{ListTicketComments,CreateTicketComment}.php
|-- app/Http/Controllers/Api/{Reporter,Technician,Admin}TicketCommentController.php
|-- app/Http/Requests/Tickets/CreateTicketCommentRequest.php
|-- app/Http/Resources/TicketCommentResource.php
|-- app/Models/{Ticket,TicketComment,User}.php
|-- app/Services/Tickets/TicketCommentAccess.php
|-- database/factories/TicketCommentFactory.php
|-- database/migrations/        # create ticket_comments table
|-- routes/api.php
`-- tests/Feature/Tickets/      # role, contract, atomicity, retry, immutability suites

mobile/
|-- lib/tickets/models/ticket_comment_models.dart
|-- lib/tickets/services/ticket_comment_api_service.dart
|-- lib/tickets/repositories/ticket_comment_repository.dart
|-- lib/tickets/state/ticket_comments_controller.dart
|-- lib/tickets/widgets/ticket_comments_section.dart
|-- lib/tickets/screens/        # existing reporter, technician, admin detail integration
|-- lib/auth/screens/profile_screen.dart
|-- lib/{app.dart,main.dart}    # existing manual dependency composition
`-- test/                       # contract, controller, role integration, widget tests
```

**Structure Decision**: Keep role-specific routes/controllers so existing middleware and concealed
lookup rules remain explicit, while all three delegate to shared comment Actions and access logic.
The shared Flutter component receives the already-authorized role/ticket context and never infers
broader access. Existing reporter and technician details are extended; administrator comment entry is
integrated through the existing administrator ticket surface without adding unrelated admin detail or
ticket mutation capability.

## Delivery Increments

1. **Immutable foundation and reads**: migration/model/factory, role-aware access service, chronological
   list Action/Resource/routes, and Laravel privacy/chronology tests.
2. **Reporter discussion**: validated idempotent create Action, reporter controller, Flutter shared
   contracts/state/UI integrated with owned reporter details, and retry/atomicity tests.
3. **Technician and administrator participation**: current-assignment commit checks, oversight routes,
   role-specific detail integration, assignment-loss/restricted-state tests, and identical shared UI behavior.
4. **Quality gates**: full Laravel/Flutter suites, migration/format/static/security/scope audits, and a
   separately recorded Android live-device check that may be truthfully deferred.

## Complexity Tracking

No violations.
