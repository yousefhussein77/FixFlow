# Presentation Data Model: Design System and UI Polish

**Feature**: `010-design-system-ui-polish`
**Purpose**: Define immutable presentation contracts and relationships. This feature adds no database entity, migration, API field, or persisted business state.

## Model Boundaries

The entities below are compile-time or runtime presentation values. They consume existing authenticated application state but never authorize, validate, persist, transition, or submit a ticket. Existing domain models and state controllers remain authoritative.

```text
FixFlowThemeDefinition
|-- ColorScheme (light/dark)
|-- FixFlowSemanticColors
|   |-- FeedbackStyle
|   |-- TicketStatusStyle
|   `-- TicketPriorityStyle
|-- FixFlowTypography
|-- FixFlowSpacing
|-- FixFlowRadius
|-- FixFlowBorders
|-- FixFlowElevation
|-- FixFlowIconography
`-- FixFlowMotion

BrandAssetDefinition --> BrandVariant --> AssetUsageRule

SharedComponentContract
|-- ComponentVariant
|-- InteractionState
|-- AccessibilityContract
`-- ResponsiveContract

ScreenMigrationRecord --> ExistingScreenBehavior + SharedComponentContract[]

VisualReviewCase = Theme × LocaleDirection × Viewport × TextScale × Role × Screen × State
```

## 1. Theme Definition

### FixFlowThemeDefinition

| Field | Type | Rules |
|---|---|---|
| `brightness` | `light` or `dark` | Exactly one value; both definitions are mandatory |
| `materialScheme` | color-role collection | Every Material role used by enabled components has a foreground/background pair |
| `semanticColors` | `FixFlowSemanticColors` | Complete for both themes; no null status/priority mapping |
| `typography` | `FixFlowTypography` | Same semantic scale in both themes and directions |
| `componentThemes` | named theme collection | Covers buttons, fields, cards, navigation, dialogs, sheets, snackbars, chips, segmented controls, progress, and dividers |
| `systemOverlayStyle` | system-bar presentation | Maintains readable system icons for current surface/brightness |

**Validation**:

- Both brightness variants must be constructible independently.
- Brand anchors are exact where the approved role calls for them.
- No semantic foreground/container pair may rely on opacity alone for disabled or error meaning.
- Normal text targets 4.5:1; large text and meaningful graphics/control boundaries target 3:1.
- Switching definitions must not recreate or clear feature controllers.

### FixFlowSemanticColors

| Field group | Required members |
|---|---|
| Feedback | information, success, warning, error/destructive, each with foreground, container, on-container, border/icon |
| Ticket status | new, assigned, in-progress, completed, rejected |
| Ticket priority | low, medium, high |
| Interaction | focus, selected, disabled foreground, disabled container |
| Neutral | background, surface, elevated surface, primary/supporting text, border, divider |

Every status/priority entry is a `SemanticBadgeStyle`:

| Field | Meaning |
|---|---|
| `foreground` | Text/icon color on the container |
| `container` | Background color |
| `border` | Boundary color where required |
| `icon` | Consistent line-style semantic icon |
| `labelKey` | Localization key or caller-provided approved label; never hard-coded domain inference |
| `semanticsKey` | Accessible phrase pattern including kind and value |

**Invariant**: A style maps an existing value to presentation. It cannot expose allowed transitions, permissions, or requests.

## 2. Token Families

### Color Tokens

#### Immutable brand anchors

| Token | Value |
|---|---:|
| `brandPrimary` | `#1E4DB7` |
| `brandSecondary` | `#386CFF` |
| `brandAccent` | `#F28A1B` |
| `brandSuccess` | `#22C55E` |
| `lightBackground` | `#F3F4F6` |
| `lightSurface` | `#FFFFFF` |
| `lightPrimaryText` | `#111827` |

#### Planned dark and supporting roles

| Token | Light target | Dark target |
|---|---:|---:|
| `background` | `#F3F4F6` | `#0B1220` |
| `surface` | `#FFFFFF` | `#111827` |
| `surfaceRaised` | `#FFFFFF` | `#1F2937` |
| `textPrimary` | `#111827` | `#F9FAFB` |
| `textSupporting` | `#4B5563` | `#D1D5DB` |
| `borderSubtle` | `#D1D5DB` | `#4B5563` |
| `disabledContainer` | `#E5E7EB` | `#374151` |
| `disabledContent` | `#6B7280` | `#9CA3AF` |
| `information` | `#1D4ED8` | `#93C5FD` |
| `warning` | `#B45309` | `#FCD34D` |
| `error` | `#B91C1C` | `#FCA5A5` |
| `focus` | `#386CFF` | `#8AA7FF` |

Container/on-container values are paired and contrast-tested during implementation. A failed pair must be adjusted within its semantic family without replacing the approved brand anchors.

### Typography Tokens

| Token | Size | Weight | Line-height multiplier | Use |
|---|---:|---:|---:|---|
| `display` | 32 | 700 | 1.25 | Branded or major empty-state headline |
| `pageTitle` | 28 | 700 | 1.30 | Screen title |
| `sectionTitle` | 20 | 600 | 1.35 | Section heading |
| `cardTitle` | 17 | 600 | 1.40 | Ticket/list title |
| `body` | 16 | 400 | 1.50 | Main and user-authored content |
| `supporting` | 14 | 400 | 1.45 | Metadata/help |
| `label` | 14 | 600 | 1.40 | Controls/chips/fields |
| `caption` | 12 | 400 | 1.45 | Timestamp/tertiary metadata |
| `ticketReference` | 14 | 600 | 1.35 | Ticket identifier with appropriate directional isolation |

**Validation**:

- Font fallback covers Arabic and Latin glyphs, digits, punctuation, and diacritics.
- No style is below 12 logical pixels.
- Scale remains semantic under 200% text scaling.
- Weight is not the only hierarchy cue; size, position, and spacing also contribute.

### Spacing Tokens

| Token | Value | Typical use |
|---|---:|---|
| `space0` | 0 | Explicit reset only |
| `spaceHalf` | 4 | Compact icon/label or internal alignment only |
| `space1` | 8 | Tight element separation |
| `space2` | 16 | Default component padding/gap |
| `space3` | 24 | Section separation |
| `space4` | 32 | Major content separation |
| `space5` | 40 | Large composition gap |
| `space6` | 48 | Touch target/minimum large gap |
| `space8` | 64 | Rare page-level breathing space |

### Radius Tokens

| Token | Value | Component mapping |
|---|---:|---|
| `none` | 0 | Dividers, full-bleed regions |
| `small` | 8 | Compact controls, small images |
| `medium` | 12 | Fields, buttons, list items |
| `large` | 16 | Cards and state panels |
| `extraLarge` | 24 | Dialogs and bottom sheets |
| `pill` | maximum/full | Chips, badges, circular/pill controls |

### Border Tokens

| Token | Width | Rule |
|---|---:|---|
| `subtle` | 1 | Default boundary/divider |
| `emphasized` | 2 | Selected/error emphasis with a non-color cue |
| `focus` | 2 | Visible outer focus indicator with sufficient contrast |

### Elevation and Shadow Tokens

| Token | Conceptual level | Use |
|---|---:|---|
| `flat` | 0 | Default page/surface |
| `low` | 1 | Cards where a border alone is insufficient |
| `raised` | 2 | Floating action or elevated navigation |
| `overlay` | 3 | Dialog/sheet/menu hierarchy |

Each level defines elevation, shadow color, blur, spread, and offset. Shadows remain soft and restrained; dark mode may use tonal surface separation plus minimal shadow.

### Icon Tokens

| Token | Glyph size | Hit target |
|---|---:|---:|
| `compact` | 16 | at least 48 when interactive |
| `standard` | 20 | at least 48 when interactive |
| `action` | 24 | at least 48 |
| `prominent` | 32 | at least 48 |
| `state` | 48 | presentation container sized responsively |

Icons use a consistent Material line family. Directional arrows/chevrons may mirror; brand marks, check/cancel, universal symbols, rating values, and ticket references do not mirror merely because direction changes.

### Motion Tokens

| Token | Duration | Use |
|---|---:|---|
| `immediate` | 0–50 ms | State replacement where animation adds no value |
| `short` | 150 ms | Press/focus/selection feedback |
| `standard` | 250 ms | Small layout/state transitions |
| `emphasized` | 350 ms | Dialog/sheet/page emphasis only |

**Reduced motion**: nonessential motion becomes immediate or a simple fade; no information depends on animation.

## 3. Brand Asset Definition

### BrandAssetDefinition

| Field | Rule |
|---|---|
| `canonicalSource` | One editable vector source for approved geometric blue/orange concept |
| `geometryVersion` | Version identifier for reproducible derivatives |
| `primaryColors` | Approved primary blue and accent orange only for full-color mark |
| `clearSpaceUnit` | Stable unit derived from mark geometry and documented with examples |
| `minimumSize` | Separate minimum dimensions for horizontal and icon-only variants |
| `fallbackText` | Accessible “FixFlow” product name when art cannot render |

### BrandVariant

| Variant | Intended context | Constraints |
|---|---|---|
| `primary` | General approved light neutral surface | Full blue/orange identity |
| `horizontalLight` | Wide placement on light background | Mark plus approved FixFlow wordmark/lockup |
| `horizontalDark` | Wide placement on dark background | Contrast-adjusted approved lockup |
| `iconLight` | Compact/app-icon light context | Mark only; platform-safe padding |
| `iconDark` | Compact dark context | Mark only with approved contrast treatment |
| `monochromeLight` | Single dark ink on light surface | One color, geometry unchanged |
| `monochromeDark` | Single light ink on dark surface | One color, geometry unchanged |
| `splash` | Centered startup surface | No tiny wordmark, no status claim, safe insets |

### Naming Contract

```text
fixflow_<mark-or-lockup>_<orientation>_<light-or-dark-or-mono>.<ext>
```

Platform output names follow platform conventions but retain a generation record mapping them to the canonical source.

### Prohibited States

Stretched, rotated, rearranged, recolored, gradient-treated without approval, shadowed, outlined, crowded, low contrast, placed on busy imagery without an approved container, combined with another mark, or replaced with an unrelated maintenance symbol.

## 4. Shared Component Contract

### SharedComponentContract

| Field | Description |
|---|---|
| `name` | Stable component name |
| `variants` | Approved visual variants only |
| `states` | Supported interaction/presentation states |
| `contentSlots` | Labels, leading/trailing icon, supporting/error content |
| `semantics` | Accessible name/value/state/announcement behavior |
| `directionPolicy` | Directional layout and icon behavior |
| `responsivePolicy` | Wrap, grow, scroll, truncate, or reflow rule |
| `businessBoundary` | Explicit statement that caller owns authorization/workflow |

### Required Component Families

- Buttons: primary, secondary, outline, text, destructive, icon, floating.
- Forms: text, password, search, dropdown, multiline, help/error, character counter.
- Content: card, ticket list item, metadata row, status chip, priority badge, avatar, divider, history item, comment item, photo tile.
- Overlays: confirmation dialog, form dialog, adaptive bottom sheet, snackbar, banner.
- Navigation: app bar, role destination, bottom navigation, tabs, segmented control, pagination.
- States: loading/progress, skeleton, empty, success, validation, unauthorized, offline, conflict, server error.

### InteractionState

```text
idle -> hovered/focused/pressed -> idle
idle -> disabled
idle -> loading -> success | validation | unauthorized | offline | conflict | serverError
```

The component displays a supplied state. Existing controllers own transitions. Shared widgets must not fabricate success or recover business state independently.

## 5. Responsive Contract

### Viewport Classes

| Class | Width | Expected composition |
|---|---:|---|
| `compactMinimum` | 320–359 | Single column, wrapping labels, scroll-safe actions |
| `compact` | 360–389 | Standard phone single column |
| `regularPhone` | 390–599 | Single column with increased max-width padding |
| `largePhone` | 600+ supported mobile viewport | Centered constrained content; no tablet-specific information architecture |

### Rules

- Respect safe areas and keyboard insets.
- Avoid fixed heights for text-bearing content.
- Preserve a readable maximum line length for forms and descriptions.
- Use directional padding and alignment.
- Horizontal scrolling is prohibited for ordinary page content; only an explicitly appropriate contained control may scroll.
- Essential action and error content cannot be ellipsized without an accessible full value.

## 6. Accessibility Contract

| Requirement | Verification |
|---|---|
| Contrast | Calculated token-pair tests and manual inspection |
| Touch target | Widget size/hit-test assertions at ≥48×48 |
| Semantics | Semantic tree labels, values, selected/disabled/loading state tests |
| Focus | Logical traversal, visible focus, modal containment, restoration |
| Text scale | 100%, representative intermediate, and 200% widget tests |
| Direction | Arabic RTL and English LTR widget/golden cases |
| Non-color meaning | Labels/icons/shapes present for semantic states |
| Motion | Reduced-motion configuration suppresses nonessential animation |

## 7. Screen Migration Record

Each migrated screen records:

| Field | Required evidence |
|---|---|
| `screenPath` | Exact current source file |
| `roleContext` | public/reporter/administrator/technician/shared |
| `existingStates` | All currently reachable controller/view states |
| `existingActions` | Existing actions only, with confirmations/validation |
| `componentsUsed` | Shared design-system components adopted |
| `behavioralTests` | Existing tests proving preserved workflow |
| `visualTests` | Theme/direction/scale/viewport/golden coverage |
| `excludedControlsCheck` | Confirmation no new operation appeared |

**Migration state**:

```text
inventoried -> foundationReady -> componentReady -> migrated -> automatedVerified
-> visuallyReviewed | environmentDeferred
```

A screen cannot be marked `migrated` if behavior tests regress. `environmentDeferred` is not equivalent to `visuallyReviewed`.

## 8. Visual Review Case

### VisualReviewCase

| Dimension | Values |
|---|---|
| Theme | light, dark |
| Language/direction | Arabic/RTL, English/LTR |
| Width | 320, 360, 390, representative larger phone |
| Orientation | portrait, landscape where supported |
| Text scale | 100%, 200% |
| Role | signed out, reporter, administrator, technician |
| Screen | inventory in `plan.md` |
| State | loading, skeleton where applicable, empty, success, validation, unauthorized, offline, conflict, server error |
| Target | widget test, golden, Android device/emulator, other explicitly named target |
| Result | pass, fail with defect, environment-deferred |

### Review Invariants

- No essential clipping, overlap, overflow, or unreachable action.
- Correct brand variant, clear space, minimum size, and contrast.
- Correct reading order, alignment, directional icons, and mixed-content handling.
- No color-only meaning.
- Existing role/action/state behavior is unchanged.
- Automated evidence and live-device evidence are recorded separately.

## 9. Domain and Persistence Impact

- No new backend entity.
- No migration.
- No API contract change.
- No new application preference persistence.
- No change to ticket, photo, assignment, history, comment, or rating models.
- No change to state-transition matrices or role authorization.
