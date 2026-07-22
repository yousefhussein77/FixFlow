<!--
Sync Impact Report
- Version change: 1.0.0 -> 1.1.0
- Modified principles:
  - Template Principle 1 -> I. Specification Is the Source of Truth
  - Template Principle 2 -> II. Deliver Independent User Value
  - Template Principle 3 -> III. Verification Is Mandatory
  - Template Principle 4 -> IV. Secure, Reliable, and Observable by Design
  - Template Principle 5 -> V. Simplicity and Explicit Tradeoffs
- Modified principles: none; all five existing principles are preserved
- Added sections:
  - Required Architecture and Technology
  - Backend Engineering Rules
  - Mobile Engineering Rules
  - Version 1 Scope Boundary
- Removed sections: none (template placeholders were concretized)
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
- Command guidance requiring updates:
  - ✅ .agents/skills/speckit-tasks/SKILL.md
- Runtime guidance reviewed: no README.md, docs/quickstart.md, or AGENTS.md exists yet
- Spec Kit command guidance reviewed: no outdated project-principle references found
- Follow-up TODOs: none
-->
# FixFlow Constitution

## Core Principles

### I. Specification Is the Source of Truth
Every change MUST trace to a prioritized user story, a functional requirement, and measurable
acceptance criteria before implementation begins. Requirements MUST describe observable outcomes,
edge cases, assumptions, and failure behavior without depending on a particular implementation.
Plans and tasks MUST preserve explicit links back to those requirements. If implementation and an
approved specification disagree, work MUST stop until the specification or implementation is
corrected. This prevents undocumented behavior and makes scope decisions auditable.

### II. Deliver Independent User Value
Features MUST be decomposed into the smallest independently testable user journeys, ordered by user
value. The highest-priority journey MUST form a viable, demonstrable increment without requiring
lower-priority stories. Shared foundations MUST contain only capabilities that block multiple
stories; story-specific work MUST remain in its story. Each increment MUST preserve previously
accepted behavior. This keeps delivery incremental and prevents infrastructure work from becoming
an end in itself.

### III. Verification Is Mandatory
Every acceptance scenario and normative requirement MUST have a documented verification method.
Automated tests MUST cover behavior whose regression could cause incorrect data, security exposure,
broken contracts, or failure of a core user journey. Tests MUST be written before the corresponding
implementation when a feature specification requires test-first development, and the failing test
MUST be observed before implementation. All required tests, static checks, and quickstart validation
MUST pass before a change is considered complete. Defects MUST receive a regression test when the
failure can be reproduced automatically.

### IV. Secure, Reliable, and Observable by Design
Inputs and authorization boundaries MUST be validated at every trust boundary. Secrets and sensitive
data MUST NOT be committed, logged, or exposed in user-facing errors. Specifications MUST define
expected behavior for invalid input, dependency failure, retries, partial completion, and recovery
where applicable. Operationally meaningful failures and state transitions MUST produce structured,
actionable diagnostics without sensitive payloads. Security, reliability, privacy, and observability
requirements MUST be planned and tested in proportion to the documented risk.

### V. Simplicity and Explicit Tradeoffs
Designs MUST use the least complex approach that satisfies current approved requirements. New
abstractions, dependencies, services, persistence layers, and cross-story coupling MUST solve a
documented need and MUST include the simpler alternative considered. Speculative extensibility and
premature optimization are prohibited. Complexity that violates a constitution gate MUST be recorded
in the plan with its necessity, rejected alternative, and mitigation. This keeps FixFlow maintainable
while allowing justified evolution.

## Product and Engineering Constraints

- FixFlow MUST remain a monorepo with `backend/` for the Laravel REST API, `mobile/` for the Flutter
  application, and `docs/` for project documentation. Feature artifacts remain under `specs/`.
- Technology versions and supporting package choices MUST be recorded in the implementation plan.
- Interfaces, persisted data, and shared schemas MUST have explicit contracts and compatibility
  expectations before implementation.
- Performance, availability, accessibility, localization, retention, and privacy constraints MUST be
  measurable when they affect the feature; otherwise the specification MUST explicitly mark them as
  out of scope or record a justified assumption.
- A package or dependency MUST NOT be added unless its purpose, necessity, and rejected built-in or
  existing alternative are documented. Dependencies MUST be actively maintained, minimally scoped,
  and compatible with project license and deployment constraints.
- Generated artifacts, migrations, and configuration changes MUST be reproducible from versioned
  inputs and documented commands.

## Required Architecture and Technology

- The backend MUST use Laravel as an API-only application. It MUST NOT render or serve application UI.
- The mobile client MUST use Flutter and MUST communicate with the backend only through documented
  REST APIs. It MUST NOT access MariaDB, backend internals, or undocumented endpoints directly.
- MariaDB MUST be the primary relational database. Every schema change MUST be represented by a
  version-controlled Laravel migration; manual or untracked production schema changes are prohibited.
- Authentication MUST use Laravel Sanctum. Alternative authentication mechanisms require a future
  constitution amendment rather than a feature-level exception.
- REST contracts MUST document endpoints, authentication, authorization, requests, validation
  failures, response schemas, status codes, and compatibility impact before client integration.

## Backend Engineering Rules

- Controllers MUST remain thin: accept the request, invoke authorization and validated application
  behavior, and return a response. Business logic MUST reside in dedicated Service or Action classes.
- Request validation MUST use Laravel Form Request classes. Inline controller validation is prohibited
  for application endpoints.
- API output MUST use Laravel API Resources and a consistent JSON envelope for success, data, errors,
  and metadata. Raw model serialization from controllers is prohibited.
- Authorization MUST apply roles, policies, permissions, and resource ownership checks wherever the
  operation or data requires them. Authentication alone MUST NOT be treated as authorization.
- Factories and seeders MUST provide reproducible test and development data. Tests MUST NOT depend on
  manually prepared database state.
- Every important backend feature MUST include automated Laravel Feature Tests covering its primary
  success path, validation failures, unauthenticated access, unauthorized access, ownership rules,
  and material error behavior as applicable.

## Mobile Engineering Rules

- Flutter code MUST separate UI, state management, repositories, API or platform services, and data
  models. UI code MUST NOT perform direct HTTP, persistence, or business-rule operations.
- Repositories MUST mediate application data access; services MUST encapsulate REST transport and
  external integrations; models MUST represent documented API contracts without leaking UI state.
- Every data-driven Flutter flow MUST define and handle loading, success, empty, validation-error,
  unauthorized, offline, and server-error states. States that cannot occur MUST be explicitly
  justified in the feature plan.
- Mobile behavior MUST be verified at the appropriate layer, including state transitions and API
  contract mapping for core maintenance-ticket journeys.

## Version 1 Scope Boundary

Version 1 MUST focus on the core maintenance ticket workflow and the minimum authentication,
authorization, data, and operational capabilities required to complete it. Feature specifications
MUST identify how proposed work advances that workflow. Maps, QR codes, push notifications, PDF
export, analytics, and comparable advanced capabilities are out of scope until the core version is
complete and its acceptance and automated tests pass. Adding any deferred capability earlier requires
a constitution amendment; it cannot be approved as ordinary feature complexity.

## Delivery Workflow and Quality Gates

1. Specify prioritized, independently testable user journeys and measurable outcomes.
2. Resolve material ambiguities or record explicit, reviewable assumptions.
3. Produce a plan that passes every Constitution Check before research and again after design.
4. Generate dependency-ordered tasks with requirement traceability, risk controls, and verification.
5. Implement in priority order, preserving an independently demonstrable increment at each story
   checkpoint.
6. Before completion, run required automated checks, validate the quickstart or equivalent journey,
   review security and operational impacts, and confirm all acceptance criteria.

Implementation MUST proceed through small, reviewable increments. The whole backend, mobile client,
or application MUST NOT be generated or implemented in one operation. Each increment MUST have a
bounded purpose, reviewable diff, and verification evidence before dependent work proceeds.

Reviews MUST reject unexplained constitution violations, missing traceability, unverified mandatory
behavior, or unresolved high-risk failures. Any approved exception MUST be narrow, time-bounded,
documented in the plan's Complexity Tracking table, and assigned a remediation task.

## Governance

This constitution supersedes conflicting project practices, plans, and templates. Amendments require
a documented proposal describing the motivation, affected principles and artifacts, migration impact,
and semantic version bump. Approval MUST occur before dependent work adopts the amendment, and all
affected templates and runtime guidance MUST be updated in the same change.

Versions follow semantic versioning: MAJOR for incompatible governance changes or principle removals
or redefinitions, MINOR for new principles or materially expanded obligations, and PATCH for
non-semantic clarifications. The ratification date remains fixed; the last-amended date changes for
every approved amendment.

Every feature plan MUST evaluate constitution compliance before research and after design. Every
implementation review MUST verify requirement traceability, mandated evidence, and documented
exceptions. A project-wide compliance review MUST occur before each release and whenever this
constitution changes.

**Version**: 1.1.0 | **Ratified**: 2026-07-22 | **Last Amended**: 2026-07-22
