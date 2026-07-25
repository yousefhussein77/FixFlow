# Implementation Plan: Ticket Rating

**Branch**: `009-ticket-rating` | **Date**: 2026-07-25 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/009-ticket-rating/spec.md`

## Summary

Add one reporter-only operation that atomically records a whole-number 1–5 rating for an owned, completed, unrated ticket. Persist the rating as an immutable one-to-one record with a UUID submission token, lock the authorized ticket during creation, use database uniqueness as the concurrent-write backstop, replay the same accepted token safely, and reject a distinct duplicate without altering the original. Add a nullable rating to the existing authorized reporter detail contract and integrate rating entry and authoritative result states into the existing Flutter reporter ticket detail flow. No rating mutation, text review, other-role rating, or ticket workflow mutation is introduced.

## Technical Context

**Language/Version**: PHP 8.3+ / Laravel 13.21.1; Dart 3.11.5 / Flutter 3.41.9

**Primary Dependencies**: Existing Laravel Framework, Laravel Sanctum 4.3.3, Eloquent/database transactions, Flutter SDK, `http`, and `flutter_secure_storage`; no package addition

**Storage**: Existing MariaDB relational store; one reversible Laravel migration creates an immutable ticket-ratings table

**Testing**: Laravel Feature Tests with factories and isolated database; Flutter unit and widget tests; separate environment-dependent Android smoke verification

**Target Platform**: Existing Laravel API deployment and Flutter-supported clients; automated validation on the current host, with Android verification only when a device/emulator and reachable isolated API exist

**Project Type**: Monorepo: `backend/` Laravel REST API, `mobile/` Flutter application, `specs/` feature documentation

**Performance Goals**: Visible submission progress within 1 second; 95% of rating creation, replay, validation, or conflict outcomes within 2 seconds under normal connectivity

**Constraints**: Sanctum and active reporter middleware; ownership concealed as not found; only authoritative `completed` tickets; integer 1–5; one immutable rating per ticket; atomic creation; safe same-token replay; distinct duplicate conflict; no optimistic client success; accessible and localization-ready UI; no offline queue

**Scale/Scope**: One optional rating per ticket and one additive nullable field on owned reporter detail. No aggregate rating workload, review text, analytics, or expanded ticket access.

**Package Justification**: No dependency is added. Existing database locking, unique constraints, secure token storage, HTTP transport, and test facilities satisfy the requirements more simply than a new idempotency, UUID, state-management, or persistence package.

## Constitution Check

*GATE: Passed before research and re-checked after design.*

- **Traceability — PASS**: The schema, endpoint, client states, and tests trace to P1 stories, FR-001–FR-030, VR-001–VR-007, and SC-001–SC-009.
- **Independent value — PASS**: Reporter rating creation and detail visibility form one bounded, independently demonstrable completed-ticket journey.
- **Verification — PASS**: Backend and Flutter tests cover success, validation, eligibility, authorization, concealment, duplicate/replay, concurrency, rollback, contract parsing, and client states.
- **Security and operations — PASS**: Authentication, role, ownership, status, prior rating, retry identity, atomic failure, concealed responses, and sanitized diagnostics are explicitly designed.
- **Simplicity and packages — PASS**: One table, one create endpoint, and an additive detail field reuse existing layers and require no package.
- **Architecture — PASS**: Laravel remains API-only, Flutter consumes only the documented REST contract, and MariaDB changes are migration-owned.
- **Backend layering — PASS**: A Form Request validates shape, an Action owns locked transactional behavior, an API Resource maps output, and a thin controller returns canonical envelopes.
- **Feature tests — PASS**: Planned tests cover primary success, invalid inputs, unauthenticated and wrong-role access, ownership concealment, conflicts, retry, concurrency, and material failure.
- **Mobile states — PASS**: Models, service, repository, controller/state, and widgets remain separate and cover entry, submitting, success, already-rated, validation, unauthorized, concealed, offline, and server states.
- **V1 scope and increments — PASS**: Work implements only core User Story 5 and excludes every listed adjacent workflow.

**Post-design re-check**: PASS. Research, data model, OpenAPI contract, and quickstart introduce no constitution exception or unresolved clarification.

## Project Structure

### Documentation (this feature)

```text
specs/009-ticket-rating/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- openapi.yaml
`-- tasks.md                 # generated later
```

### Source Code (repository root)

```text
backend/
|-- app/Actions/Tickets/CreateTicketRating.php
|-- app/Http/Controllers/Api/ReporterTicketRatingController.php
|-- app/Http/Requests/Tickets/CreateTicketRatingRequest.php
|-- app/Http/Resources/TicketRatingResource.php
|-- app/Models/TicketRating.php
|-- app/Models/Ticket.php                         # one-to-one rating relationship
|-- app/Models/User.php                           # authored ratings relationship
|-- database/factories/TicketRatingFactory.php
|-- database/migrations/*_create_ticket_ratings_table.php
|-- routes/api.php
`-- tests/Feature/Tickets/
    |-- TicketRatingPersistenceTest.php
    |-- ReporterTicketRatingTest.php
    |-- TicketRatingIdempotencyTest.php
    `-- TicketRatingAuthorizationTest.php

mobile/
|-- lib/tickets/models/ticket_rating_models.dart
|-- lib/tickets/services/ticket_rating_api_service.dart
|-- lib/tickets/repositories/ticket_rating_repository.dart
|-- lib/tickets/state/ticket_rating_controller.dart
|-- lib/tickets/widgets/ticket_rating_section.dart
|-- lib/tickets/models/ticket_models.dart          # nullable detail rating
|-- lib/tickets/screens/ticket_details_screen.dart
|-- lib/main.dart                                  # existing manual composition
`-- test/tickets/
    |-- ticket_rating_repository_test.dart
    |-- ticket_rating_controller_test.dart
    |-- ticket_rating_retry_test.dart
    `-- reporter_ticket_rating_test.dart
```

**Structure Decision**: Extend the established ticket domain in place. The backend controller delegates all eligibility, locking, idempotency, and persistence to one Action; the Resource is shared by creation and reporter details. Flutter adds focused rating layers and embeds one role-appropriate section in the existing reporter detail screen. Technician and administrator screens and endpoints are not extended with rating submission.

## Design Phases

### Phase 0 — Research

Resolve the representation, endpoint, authorization precedence, one-time/retry distinction, concurrency strategy, detail compatibility, diagnostics, and Flutter recovery behavior in [research.md](research.md). No unresolved clarification remains.

### Phase 1 — Data and Contract Design

- Define the immutable one-to-one Rating and its ticket/reporter/retry relationships in [data-model.md](data-model.md).
- Define reporter creation and additive detail behavior, exact statuses, envelopes, and schemas in [contracts/openapi.yaml](contracts/openapi.yaml).
- Define reproducible backend, Flutter, audit, and separately deferred Android verification in [quickstart.md](quickstart.md).

### Phase 2 — Planned Implementation Sequence

1. Write failing persistence, reporter behavior, idempotency/concurrency, authorization, and rollback Feature Tests.
2. Add the reversible rating migration, model relationships, factory, strict request, Resource, transactional Action, controller, diagnostics, route, and additive reporter detail mapping.
3. Run focused backend tests before client integration.
4. Write failing Flutter contract, state, retry, and reporter widget tests.
5. Add rating models, service, repository, state controller, section widget, detail integration, and manual dependency wiring.
6. Run focused and full validation, route/scope/dependency/secret/diff audits, then execute or truthfully defer the separate Android check.

## Complexity Tracking

No constitution violations or exceptions are required.
