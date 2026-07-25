# Research: Design System and UI Polish

**Feature**: `010-design-system-ui-polish`
**Date**: 2026-07-25
**Status**: Complete — no unresolved clarification

## Repository Findings

The current Flutter application uses Flutter 3.41.9 and Dart 3.11.5. `mobile/lib/app.dart` creates one light `ThemeData` from an indigo seed. There is no centralized dark theme, semantic ticket palette, token layer, brand asset declaration, locale/direction system, shared state-view library, or design-system test directory.

The application already separates screens, state controllers, repositories, API services, and models. That boundary is appropriate and must remain intact. Most visual construction is currently local to screens using Material `Scaffold`, `AppBar`, `TextField`, `FilledButton`, `OutlinedButton`, `Card`, `AlertDialog`, and progress widgets. Four ticket-specific shared widgets already exist for assignment, processing, comments, and rating.

The inventory in `plan.md` covers all current presentation files and 29 current test files. The existing tests are valuable behavioral regression gates but are not a substitute for token, theme, semantics, directionality, responsive, and golden coverage.

## Decision 1: Use Flutter ThemeData as the Single Theme Entry Point

**Decision**: Create explicit `FixFlowTheme.light()` and `FixFlowTheme.dark()` builders backed by complete `ColorScheme` values and component themes. Application widgets consume `Theme.of(context)` and focused theme extensions.

**Rationale**:

- Native Material theming already supports application-wide color, typography, control, overlay, and navigation configuration.
- A single entry point prevents screen-local drift and permits reliable light/dark tests.
- Existing Material widgets can be migrated incrementally without changing controllers or workflow code.

**Alternatives considered**:

- Continue styling each screen locally: rejected because it cannot guarantee consistency or efficient dark/RTL support.
- Introduce a third-party design-system package: rejected because it adds dependency and abstraction cost without a documented capability gap.
- Use `ColorScheme.fromSeed` as the final palette: rejected because derived colors do not guarantee the approved anchors or intentional status/priority semantics.

## Decision 2: Use ThemeExtension for FixFlow-Specific Semantics

**Decision**: Store status, priority, feedback-container, and other non-core semantic styles in immutable `ThemeExtension` objects. Core Material roles remain in `ColorScheme`.

**Rationale**:

- Ticket statuses and priorities do not map safely to generic Material roles.
- A typed extension keeps light/dark pairs complete, interpolatable, and accessible through context.
- Presentation mappings remain separate from ticket lifecycle rules.

**Alternatives considered**:

- Global static color maps: rejected because they are not theme-aware and encourage use outside context.
- Add fields to ticket models: rejected because visual styling is not domain data and must not contaminate API models.
- Infer workflow actions from colors: prohibited; semantic styles describe display only.

## Decision 3: Preserve Approved Brand Anchors and Add Accessible Semantic Tones

**Decision**: Preserve the exact anchors below and define supporting tones by semantic purpose. Every foreground/container pair must be verified before implementation acceptance.

| Role | Light | Dark | Usage |
|---|---:|---:|---|
| Primary anchor | `#1E4DB7` | `#6F96FF` | Primary actions, selected navigation, key focus |
| Secondary anchor | `#386CFF` | `#8AA7FF` | Secondary emphasis and information accents |
| Accent anchor | `#F28A1B` | `#FFB55C` | Brand accent and limited attention cues |
| Success anchor | `#22C55E` | `#4ADE80` | Success identity; darker foreground variants where needed |
| Background | `#F3F4F6` | `#0B1220` | Root canvas |
| Surface | `#FFFFFF` | `#111827` | Cards, sheets, dialogs |
| Elevated surface | `#FFFFFF` | `#1F2937` | Raised/selected dark surfaces |
| Primary text | `#111827` | `#F9FAFB` | Main readable content |
| Supporting text | `#4B5563` | `#D1D5DB` | Secondary content |
| Border | `#D1D5DB` | `#4B5563` | Fields, dividers, component boundaries |
| Disabled surface | `#E5E7EB` | `#374151` | Disabled containers |
| Disabled content | `#6B7280` | `#9CA3AF` | Disabled labels/icons with non-opacity cue |
| Information | `#1D4ED8` | `#93C5FD` | Informational messages |
| Warning | `#B45309` | `#FCD34D` | Warning text/icons with themed container |
| Error/destructive | `#B91C1C` | `#FCA5A5` | Validation and destructive actions |
| Focus | `#386CFF` | `#8AA7FF` | Visible 2-pixel focus treatment |

These values are planning targets, not permission to use raw hex values in screens. Contrast tests may require a nearby accessible semantic tone while the immutable brand anchors remain available in their approved contexts.

**Alternatives considered**:

- Use identical colors in both themes: rejected because luminance and surface relationships differ.
- Lighten all colors algorithmically: rejected because semantic contrast must be verified intentionally.
- Use orange for every warning and brand accent: rejected because overuse weakens brand recognition and state clarity.

## Decision 4: Define Status and Priority as Complete Visual Styles

**Decision**: Each status and priority receives a label, icon/non-color cue, foreground, container, and border treatment. Initial semantic direction:

| Kind | Semantic direction | Non-color cue |
|---|---|---|
| Status `new` | information blue | inbox/new icon + localized label |
| Status `assigned` | violet/indigo distinct from primary action | person-assigned icon + label |
| Status `in_progress` | orange/amber | progress/work icon + label |
| Status `completed` | success green | check icon + label |
| Status `rejected` | error red | cancel/rejected icon + label |
| Priority `low` | neutral/slate | downward/low icon + label |
| Priority `medium` | warning amber | neutral priority icon + label |
| Priority `high` | destructive red | high-priority icon + label |

**Rationale**: Color alone is insufficient, and complete paired styles avoid unreadable text or ad hoc screen mappings.

**Alternatives considered**:

- One color per status without labels: rejected for accessibility.
- Reuse status styles as transition buttons: rejected because a current state and an available action have different semantics.

## Decision 5: Use an 8-Point Grid with a Controlled Half Step

**Decision**: Use 8 logical pixels as the base spacing unit and permit 4 pixels only for compact internal alignment. Adopt consistent token families for radius, border, elevation, icon size, and motion.

**Rationale**: The grid supports predictable rhythm and responsive composition while the half-step accommodates icon-to-label and dense metadata alignment.

**Alternatives considered**:

- A 4-point primary grid: rejected because it provides more choices than the application needs and increases drift.
- Arbitrary screen-specific spacing: rejected as untestable and inconsistent.

## Decision 6: Typography Must Support Arabic and Latin Together

**Decision**: Define one semantic text scale with Arabic/Latin-compatible font fallbacks. Use these baseline metrics:

| Style | Size | Weight | Line height | Primary use |
|---|---:|---:|---:|---|
| Display | 32 | 700 | 1.25 | Rare branded/empty-state headline |
| Page title | 28 | 700 | 1.30 | Primary page identity |
| Section title | 20 | 600 | 1.35 | Detail/form sections |
| Card title | 17 | 600 | 1.40 | Ticket/list item title |
| Body | 16 | 400 | 1.50 | Main content and user text |
| Supporting | 14 | 400 | 1.45 | Metadata and help |
| Label | 14 | 600 | 1.40 | Fields, buttons, chips |
| Caption | 12 | 400 | 1.45 | Timestamps and tertiary metadata |
| Ticket reference | 14 | 600 | 1.35 | Stable identifiers; preserve LTR run where necessary |

**Rationale**: Shared semantics permit controlled scaling and reduce mismatched hierarchy. Generous line height supports Arabic marks and large text.

**Alternatives considered**:

- Separate unrelated Arabic and English scales: rejected because hierarchy would drift across locale.
- Bundle a new font immediately: deferred. The implementation must first verify existing supported fonts. Any font asset/package needs license, size, Arabic coverage, and dependency review.
- Convert brand/type to images: prohibited for accessibility and localization.

## Decision 7: Treat RTL as a First-Class Layout, Not a Mirror Filter

**Decision**: Build with directional padding/alignment, locale-derived text direction, correct semantic order, and explicit icon-mirroring policy. Preserve ticket references and appropriate mixed-content runs.

**Rationale**: Blind mirroring breaks universal icons, brand marks, numbers, ticket references, and rating semantics. Direction-aware composition supports both Arabic and English from one component system.

**Alternatives considered**:

- Wrap the whole app in forced RTL: rejected because English must be correct and mixed content requires nuance.
- Maintain separate Arabic and English widget trees: rejected as duplication and regression risk.

## Decision 8: Use Presentation Components, Not Business-Aware Widgets

**Decision**: Shared components receive values, labels, state variants, and callbacks. Existing screens/controllers decide authorization, eligibility, validation, retry, refresh, and navigation.

**Rationale**: This preserves architecture and prevents a visual component from becoming an alternative business-rule source.

**Alternatives considered**:

- Put repository calls in shared state views: rejected by the constitution and existing layering.
- Consolidate all screens into generic data-driven pages: rejected because it adds complexity and obscures role-specific journeys.

## Decision 9: Migrate Incrementally by Foundation, Shared Components, Then Role

**Decision**: Use seven phases: foundation/brand; shared components; authentication/profile; reporter; administrator; technician; cross-role acceptance.

**Rationale**: Foundations block all screens, while role slices create reviewable checkpoints and preserve the full regression suite after each step.

**Alternatives considered**:

- Restyle the entire app in one change: rejected as too difficult to review and verify.
- Migrate file-by-file without shared foundations: rejected because temporary visual divergence would become permanent duplication.

## Decision 10: Combine Widget Assertions, Selective Goldens, and Manual Review

**Decision**:

- Use widget tests for semantics, interaction, states, role absence, RTL/LTR, text scale, and overflow.
- Use goldens only for deterministic stable components and representative screens.
- Require human approval for every intended golden update.
- Use the `quickstart.md` matrix for manual phone/emulator review.

**Rationale**: Pixel comparisons catch visual drift but are brittle with dynamic time, platform font rendering, remote images, and uncontrolled surfaces. Behavioral and semantic assertions are more reliable for those cases.

**Alternatives considered**:

- Golden-test every screen/state: rejected due maintenance cost and false positives.
- Rely only on manual screenshots: rejected because regressions would not be automatically detected.
- Treat Chrome/Windows review as Android verification: rejected; device evidence must name the actual target.

## Decision 11: Brand Asset Source and Generation

**Decision**: Preserve one canonical editable geometric FixFlow source and generate the approved variants and platform outputs reproducibly. The source concept remains blue structure plus orange accent; the implementation may refine geometry for clarity but may not replace the concept.

**Rationale**: One source prevents variant drift, and generated icons/splashes must remain reproducible.

**Alternatives considered**:

- Independently redraw every size: rejected because proportions and clear space would diverge.
- Use a temporary generic maintenance icon as final art: rejected because it violates the approved identity.
- Download a stock logo: rejected due concept, licensing, and uniqueness risks.

## Decision 12: No Backend or API Work

**Decision**: Make no backend, route, contract, validation, authorization, migration, or dependency change. Existing Laravel Feature tests serve only as regression evidence if implementation review indicates a possible contract impact.

**Rationale**: Feature 010 is strictly presentation and UX polish. The existing client already exposes the necessary states and operations.

**Alternatives considered**:

- Add endpoints for theme or language preferences: rejected as a new product/data feature.
- Change API messages to suit layouts: rejected; the client presentation must handle existing contracts.

## Resolved Questions and Remaining Inputs

- **Resolved**: Theme architecture, dark/light direction, token strategy, component boundaries, migration order, RTL policy, accessibility thresholds, responsive widths, testing layers, and device-evidence separation.
- **Implementation input, not a planning blocker**: A final canonical vector rendering of the already approved geometric logo must be produced or supplied and visually approved before launcher/splash outputs are finalized. The concept, palette, variants, usage, and validation rules are already fixed.
- **No genuine planning clarification remains.**
