# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command.

## Summary

[Extract the primary requirement, small increment boundary, and technical approach]

## Technical Context

**Language/Version**: PHP [VERSION] / Laravel [VERSION]; Dart [VERSION] / Flutter [VERSION]

**Primary Dependencies**: Laravel Sanctum plus [document each package purpose and justification]

**Storage**: MariaDB [VERSION]; all schema changes through Laravel migrations

**Testing**: Laravel Feature Tests; Flutter unit/widget/integration tests as appropriate

**Target Platform**: [Supported backend deployment and Flutter platforms]

**Project Type**: Monorepo: `backend/` Laravel API, `mobile/` Flutter app, `docs/` documentation

**Performance Goals**: [Measurable user-facing and system constraints or NEEDS CLARIFICATION]

**Constraints**: [Offline, security, privacy, accessibility, or other constraints]

**Scale/Scope**: [Expected users, tickets, data volume, and explicit v1 boundary]

**Package Justification**: [For each added package: purpose, necessity, and rejected alternative]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Traceability**: Every design element maps to a prioritized user story, requirement, and
  measurable acceptance criterion.
- **Independent value**: The P1 story is viable; shared foundations contain only cross-story blockers.
- **Verification**: Each normative requirement has a verification method and risk-based automation.
- **Security and operations**: Trust boundaries, secrets, authorization, failures, recovery, and
  sensitive-data-safe diagnostics are addressed.
- **Simplicity and packages**: Every dependency and abstraction is documented and justified.
- **Architecture**: Work stays within `backend/`, `mobile/`, and `docs/`; Flutter uses only documented
  REST APIs; MariaDB migrations and Sanctum are used where applicable.
- **Backend layering**: Controllers are thin; Form Requests, Service/Action classes, API Resources,
  consistent JSON responses, policies/permissions/ownership checks, factories, and seeders are planned.
- **Feature tests**: Every important backend feature includes Laravel Feature Tests for applicable
  success, validation, unauthenticated, unauthorized, ownership, and error paths.
- **Mobile states**: UI, state, repository, service, and model layers are separated, and loading,
  success, empty, validation, unauthorized, offline, and server-error states are designed.
- **V1 scope and increments**: Work advances the core maintenance-ticket workflow, excludes deferred
  advanced features, and is divided into small reviewable increments rather than whole-app generation.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
`-- tasks.md
```

### Source Code (repository root)

```text
backend/                  # Laravel API-only application
|-- app/Actions/          # focused application operations
|-- app/Http/Controllers/ # thin REST controllers
|-- app/Http/Requests/    # Laravel Form Requests
|-- app/Http/Resources/   # Laravel API Resources
|-- app/Policies/         # authorization policies
|-- app/Services/         # reusable business services
|-- database/factories/   # test data factories
|-- database/migrations/  # all schema changes
|-- database/seeders/     # development/reference data
`-- tests/Feature/        # important backend behavior

mobile/                   # Flutter application
`-- lib/                  # separated UI, state, repositories, services, and models

docs/                     # project and documented REST API contracts
```

**Structure Decision**: [Document affected paths and layer responsibilities within the required
monorepo; alternate application roots are prohibited]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that require a constitution amendment or a
> narrow, time-bounded remediation exception permitted by governance.**

| Violation | Why Needed | Simpler Alternative Rejected Because | Remediation |
|-----------|------------|-------------------------------------|-------------|
| [specific rule] | [documented need] | [why insufficient] | [owner/task/deadline] |
