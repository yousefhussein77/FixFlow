# Feature Specification: Design System and UI Polish

**Feature Branch**: Not created (no branch hook configured)

**Created**: 2026-07-25

**Status**: Draft

**Input**: Create a complete visual identity and reusable UI/UX design-system specification for the existing FixFlow application without changing approved business workflows.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recognize and Navigate a Cohesive FixFlow Experience (Priority: P1)

As any FixFlow user, I experience one recognizable, professional visual language across authentication, profile, navigation, tickets, and feedback so that I can understand the application quickly and trust that I am in the correct product.

**Why this priority**: A coherent brand, hierarchy, navigation pattern, and shared visual vocabulary are the foundation for every role and screen.

**Independent Test**: Review authentication, profile, one list, one detail screen, and global navigation in light and dark themes in Arabic and English; verify approved branding, token usage, hierarchy, navigation, and feedback are consistent without changing any available action or outcome.

**Acceptance Scenarios**:

1. **Given** a user opens FixFlow, **When** the splash, authentication, and authenticated shell appear, **Then** approved logo variants, colors, typography, spacing, and navigation identify one consistent product.
2. **Given** equivalent controls or states occur on different screens, **When** they are compared, **Then** they use the same component treatment, terminology, interaction feedback, and semantic meaning.
3. **Given** light or dark appearance is active, **When** the user traverses supported screens, **Then** content remains legible, brand recognition is preserved, and no screen falls back to an incompatible or incomplete theme.

---

### User Story 2 - Complete Reporter Work Clearly (Priority: P1)

As a reporter, I can create, find, understand, discuss, and rate my authorized tickets through a clear and supportive interface so that visual polish reduces effort without changing ticket permissions or workflow rules.

**Why this priority**: Reporting and following maintenance work is the primary end-user journey and exercises forms, lists, details, comments, ratings, and all major feedback states.

**Independent Test**: Complete the existing reporter journey from sign-in through ticket creation, owned-ticket list and detail, comments, and completed-ticket rating; verify visual hierarchy, form guidance, states, and feedback while all existing authorization, validation, and lifecycle outcomes remain unchanged.

**Acceptance Scenarios**:

1. **Given** an authenticated reporter, **When** they browse their ticket list or an owned ticket detail, **Then** status, priority, key metadata, history, photos, comments, and rating eligibility are visually distinguishable without relying on color alone.
2. **Given** a reporter creates a ticket or adds text, **When** fields are empty, focused, valid, invalid, disabled, or submitting, **Then** labels, supporting text, counters, validation messages, and progress remain clear and preserve entered data according to existing behavior.
3. **Given** an existing loading, empty, unauthorized, offline, conflict, or server-error outcome, **When** it occurs, **Then** the reporter sees a consistent state with an appropriate explanation and only the retry or navigation actions already approved for that workflow.

---

### User Story 3 - Manage the Queue with Clear Administrative Oversight (Priority: P1)

As an administrator, I can scan the ticket queue, assign technicians, manage approved reference data, and oversee ticket details and comments through dense but readable layouts so that administrative work is efficient and does not expose unsupported actions.

**Why this priority**: Administrator screens combine high information density, destructive reference-data actions, assignment decisions, filters, dialogs, and oversight states that require a consistent system.

**Independent Test**: Exercise the existing administrator queue, technician selection and assignment, reference-data screens, ticket oversight, and comments; verify hierarchy, role-appropriate actions, confirmation, validation, and responsive behavior with no reassignment, processing, rating, or other added capability.

**Acceptance Scenarios**:

1. **Given** an administrator views the queue, **When** tickets have different priorities, statuses, reporters, departments, categories, or assignment states, **Then** the information is scannable in a stable hierarchy and every badge includes a non-color cue.
2. **Given** an administrator performs an existing assignment or reference-data action, **When** confirmation, validation, loading, success, conflict, or failure occurs, **Then** the shared control and feedback patterns communicate the authoritative result without optimistic or duplicate action.
3. **Given** an administrator uses a narrow supported phone, **When** a screen contains many fields or actions, **Then** content reflows or scrolls without clipping, inaccessible controls, or horizontal overflow.

---

### User Story 4 - Process Assigned Work Confidently (Priority: P1)

As a technician, I can scan my assigned tickets, inspect details and history, perform only permitted status actions, provide a rejection reason, and use comments through a calm, unambiguous interface so that status consequences are clear.

**Why this priority**: Technician processing contains consequential confirmations, terminal outcomes, history, conflict recovery, and assignment-concealment behavior that visual polish must not weaken.

**Independent Test**: Exercise the existing technician assigned list, ticket detail, Start Work confirmation, completion, rejection, history, and comments; verify only approved controls appear, destructive or terminal actions are distinguished, and authoritative refresh/error behavior is preserved.

**Acceptance Scenarios**:

1. **Given** an assigned or in-progress ticket, **When** a technician opens its details, **Then** current status, permitted next actions, history, and comments have a clear hierarchy and no unsupported transition is offered.
2. **Given** Start Work, Complete, or Reject is selected, **When** confirmation or a rejection reason is required, **Then** the interface clearly names the ticket and consequence, protects against accidental duplicate submission, and preserves existing validation.
3. **Given** assignment loss, authorization loss, conflict, offline failure, or server failure occurs, **When** the workflow refreshes or recovers, **Then** the error remains understandable, restricted content is handled according to existing rules, and no stale state is presented as success.

---

### User Story 5 - Use FixFlow Accessibly in Arabic or English (Priority: P1)

As a user with different language, text-size, input, or assistive-technology needs, I can perceive and operate FixFlow in Arabic-first RTL and correct English LTR layouts so that core tasks do not depend on vision, color perception, precise touch, or one reading direction.

**Why this priority**: Accessibility, localization, and directionality are system-wide quality requirements, not optional cosmetic enhancements.

**Independent Test**: Run representative reporter, technician, and administrator screens in Arabic RTL and English LTR at supported text scales and phone widths, with semantic inspection and keyboard focus where applicable; verify readable contrast, logical order, complete labels, minimum targets, and no clipped essential content.

**Acceptance Scenarios**:

1. **Given** Arabic is active, **When** a supported screen is displayed, **Then** layout direction, alignment, navigation, directional icons, mixed-language content, numbers, dates, and input behavior are correct for RTL.
2. **Given** English is active, **When** the same screen is displayed, **Then** it uses correct LTR order without inheriting inappropriate mirroring or alignment.
3. **Given** larger text or assistive technology is used, **When** a user completes a core task, **Then** meaningful labels, reading order, focus, validation, and actions remain available without color-only meaning or inaccessible truncation.

### Edge Cases

- A brand mark is displayed on a very small surface, dark background, photographic background, or single-color medium; the correct approved variant and minimum-size rule applies.
- Arabic and English appear in the same ticket reference, person name, description, or comment; surrounding layout follows the active direction while mixed content remains readable and uncorrupted.
- Text reaches the largest supported accessibility scale; controls wrap or grow, essential actions remain reachable, and fixed-height clipping is avoided.
- A narrow phone, landscape orientation, keyboard, or system inset reduces available space; forms and bottom actions remain visible through safe reflow or scrolling.
- A status or priority color is difficult to distinguish; text, iconography, shape, or another non-color cue preserves meaning.
- Content is loading for longer than expected; progress and skeleton treatments do not imply fabricated ticket data or block safe navigation unnecessarily.
- A list is empty because there is no data versus empty because filtering or authorization removed data; the message and available approved action reflect the actual state without disclosing restricted information.
- A dialog, bottom sheet, snackbar, keyboard, and navigation transition overlap; focus, safe areas, dismissal, and announcements remain predictable.
- An image or logo asset is unavailable; the interface retains an accessible product name or fallback without broken layout.
- Device dark mode changes while a screen is open; semantic colors, system overlays, surfaces, and controls update without losing state or contrast.
- A long translated label, validation message, department, category, reporter, or technician name exceeds one line; content wraps or truncates only when the full meaning remains accessible.
- Reduced-motion preference is active; nonessential movement is removed and essential state changes remain understandable.

## Requirements *(mandatory)*

### Functional Requirements

#### Brand System

- **FR-001**: FixFlow MUST use a geometric blue-and-orange identity that communicates modern, clean, professional, trustworthy maintenance service.
- **FR-002**: The brand system MUST define primary, horizontal, icon-only, monochrome, light-background, and dark-background logo variants, including the backgrounds and contexts permitted for each.
- **FR-003**: The brand system MUST define app-icon and splash-screen treatments that remain recognizable at supported platform sizes and do not distort, crop, animate excessively, or combine the mark with unapproved text.
- **FR-004**: Logo guidance MUST define clear space relative to a stable feature of the mark, minimum digital sizes for full and icon-only variants, and an accessible fallback when the full mark cannot fit.
- **FR-005**: Logo usage MUST prohibit stretching, rotation, recoloring outside approved variants, rearrangement, effects, insufficient contrast, crowding, unapproved lockups, and placement on visually conflicting backgrounds.

#### Design Tokens and Themes

- **FR-006**: The core brand palette MUST use primary blue `#1E4DB7`, secondary blue `#386CFF`, accent orange `#F28A1B`, success green `#22C55E`, light background `#F3F4F6`, light surface `#FFFFFF`, and primary light-theme text `#111827`.
- **FR-007**: Light and dark themes MUST define semantic roles rather than direct screen-specific colors for backgrounds, elevated surfaces, primary and secondary text, borders, disabled content, focus, selection, information, success, warning, error, and destructive action.
- **FR-008**: Dark-theme colors MUST preserve FixFlow brand recognition while meeting the same legibility and semantic requirements as light theme; light-theme hexadecimal values MUST NOT be reused where they produce inadequate dark-theme contrast.
- **FR-009**: Semantic colors MUST be defined for ticket priorities and every existing ticket status, and each MUST be paired with a readable label plus icon, shape, or other non-color cue.
- **FR-010**: Text and essential icon contrast MUST target at least 4.5:1 for normal text, 3:1 for large text, and 3:1 for interactive boundaries and meaningful graphics in their intended states.
- **FR-011**: Typography MUST define a named scale for display, page title, section title, body, supporting text, label, button, caption, and numeric or ticket-reference content, with explicit weights, line heights, and intended hierarchy.
- **FR-012**: Arabic and Latin typography MUST use compatible families or fallbacks with comparable weight, legibility, baseline, numeral, punctuation, and line-height behavior; text MUST remain selectable and must not be converted into images.
- **FR-013**: Layout spacing MUST use an 8-point base grid with documented 4-point half-step exceptions only for compact internal alignment.
- **FR-014**: Tokens MUST define rounded radii for compact controls, fields, cards, dialogs, sheets, and fully rounded chips without arbitrary per-screen values.
- **FR-015**: Borders, restrained elevations, and soft shadows MUST communicate grouping and interaction without reducing contrast, creating heavy visual noise, or being the only separation cue.
- **FR-016**: The system MUST define consistent icon sizes and use one line-style icon language; directional icons MUST mirror when their meaning is directional, while universal symbols and brand marks MUST not be mirrored.
- **FR-017**: Motion tokens MUST define immediate, short, standard, and emphasized durations with restrained easing; transitions MUST provide orientation or feedback rather than decoration and MUST honor reduced-motion preferences.

#### Shared Components and States

- **FR-018**: Shared components MUST cover primary, secondary, outline, text, destructive, icon, and floating buttons with default, pressed, focused, disabled, loading, and applicable destructive states.
- **FR-019**: Every interactive control MUST provide a minimum 48 by 48 logical-pixel touch target or an equivalent accessible hit area, visible focus where applicable, an accessible name, and a disabled state distinguishable without opacity alone.
- **FR-020**: Shared inputs MUST cover text, password, search, dropdown, multiline text area, validation message, supporting text, and character counter behavior with persistent labels and unambiguous required, focused, filled, disabled, read-only, and error states.
- **FR-021**: Password fields MUST provide an accessible visibility control without changing the entered value, focus, validation, or submission behavior.
- **FR-022**: Shared presentation components MUST cover cards, ticket list items, status chips, priority badges, avatars, dividers, dialogs, bottom sheets, snackbars, banners, tabs, segmented controls, pagination, and bottom navigation.
- **FR-023**: Cards and list items MUST use consistent information order, padding, selection behavior, and affordances; a whole-card tap target MUST not hide or conflict with nested actions.
- **FR-024**: Dialogs and bottom sheets MUST identify their purpose, preserve logical focus, provide explicit safe and consequential actions, avoid ambiguous dismissal during submission, and adapt to keyboard and safe-area insets.
- **FR-025**: Snackbars and banners MUST use concise supportive language, appropriate semantic announcement, and an action only when an existing safe recovery action is available; transient feedback MUST not be the sole record of a consequential result.
- **FR-026**: Shared state patterns MUST cover loading, skeleton, empty, success, validation, unauthorized, offline, conflict, and server error with consistent iconography, hierarchy, language, and approved recovery actions.
- **FR-027**: Skeletons MUST approximate real layout without displaying fabricated readable content, implying success, causing major layout shifts, or replacing progress that requires an accessible announcement.
- **FR-028**: Empty and error states MUST explain what occurred in plain supportive language, avoid blame and internal details, and present only navigation, retry, authentication, or creation actions already authorized by the existing workflow.
- **FR-029**: Components MUST expose reusable semantic roles and configurable content while preventing screen-specific variants from silently changing validation, authorization, navigation, or business behavior.

#### Screen-Level Experience

- **FR-030**: Authentication and profile screens MUST share brand placement, readable field grouping, password behavior, loading protection, validation hierarchy, safe error language, role identity, and clear navigation between existing authentication actions.
- **FR-031**: Reporter ticket lists MUST distinguish loading, empty, populated, pagination, offline, unauthorized, and server states and present ticket reference, subject, status, priority, and essential metadata in a stable scannable order.
- **FR-032**: Reporter ticket creation MUST group reference selection, ticket information, location, description, priority, and photos logically; preserve existing validation and retry behavior; and keep primary submission visible without obscuring fields or system insets.
- **FR-033**: Reporter ticket details MUST establish a stable hierarchy for status and priority, description, location, department/category, timestamps, photos, comments, history where authorized, and rating state without exposing new actions.
- **FR-034**: Reporter comments and rating MUST use the shared composer, validation, retry, conflict, read-only, and success patterns while preserving immutable comments and exactly-once completed-ticket rating rules.
- **FR-035**: Administrator queue screens MUST support rapid scanning of ticket, reporter, priority, status, department/category, and current assignment while preserving current pagination and assignment eligibility.
- **FR-036**: Technician assignment MUST use clear technician identity, confirmation, submitting, success, validation, conflict, and refresh behavior and MUST NOT imply reassignment or unassignment.
- **FR-037**: Reference-data management MUST visually distinguish existing create, update, activate, and deactivate operations, use confirmation for consequential state changes, and preserve current authorization and validation.
- **FR-038**: Administrator oversight details and comments MUST remain visually consistent with reporter and technician ticket patterns while displaying only data and actions already authorized for administrators.
- **FR-039**: Technician assigned-ticket lists and details MUST emphasize current status, priority, reporter-provided work information, photos, history, comments, and only the exact permitted processing actions.
- **FR-040**: Start Work, Complete, and Reject treatments MUST distinguish progression from terminal or destructive outcomes, require all existing confirmations and rejection validation, prevent duplicate submission, and preserve authoritative refresh after ambiguous outcomes.
- **FR-041**: Ticket history MUST present events in stable chronological order with status, actor, time, and rejection reason where authorized, using a timeline or list that remains understandable without color.
- **FR-042**: Navigation MUST be role-gated exactly as currently authorized, use consistent labels and selected states, preserve back behavior and screen state where existing behavior requires it, and expose no cross-role or excluded destination.
- **FR-043**: Interface language MUST be clear, concise, supportive, localization-ready, and consistent for equivalent actions and states; it MUST avoid unexplained technical terms, blame, sensitive details, and promises not guaranteed by the workflow.

#### Accessibility, Directionality, and Responsiveness

- **FR-044**: Arabic MUST be the primary design direction, with correct RTL alignment, reading order, navigation order, form layout, mixed-content handling, and directional icon mirroring throughout all supported screens.
- **FR-045**: English MUST receive complete LTR support from the same component system without manual per-screen positioning that breaks direction changes.
- **FR-046**: Screen-reader semantics MUST identify product branding, page purpose, fields, values, validation, ticket status and priority, loading, errors, selected navigation, controls, confirmations, and material state changes without redundant announcements.
- **FR-047**: Keyboard and focus behavior where supported MUST follow visual and reading order, keep focus visible, trap focus only in modal contexts, restore focus sensibly after dismissal, and allow activation without gesture-only interaction.
- **FR-048**: Core workflows MUST remain usable at text scaling through at least 200%, allowing wrapping, scrolling, or responsive reflow without loss of content, overlap, or unreachable actions.
- **FR-049**: Supported phone layouts MUST remain usable from 320 logical pixels wide through common larger phone widths in portrait and landscape, respecting safe areas, keyboard insets, and system navigation.
- **FR-050**: The interface MUST NOT convey action, status, priority, validation, selection, or success through color alone.

#### Preservation and Verification

- **FR-051**: This feature MUST preserve every existing API contract, route, authentication rule, authorization and concealed-access rule, validation rule, transaction and retry behavior, ticket lifecycle transition, and accepted automated test outcome.
- **FR-052**: Visual changes MUST NOT add, remove, reorder semantically, or broaden business operations; where layout moves an existing action, its label, preconditions, confirmation, request, and outcome MUST remain equivalent.
- **FR-053**: Existing user input, loading, empty, success, validation, unauthorized, offline, conflict, server-error, retry, and authoritative-refresh behavior MUST not regress during visual replacement.
- **FR-054**: Reusable visual components and tokens MUST be independently testable and MUST avoid duplicating role or workflow rules that belong to existing application behavior.
- **FR-055**: Automated widget verification MUST cover shared component states, RTL/LTR direction, text scaling, semantics, supported narrow widths, theme switching, role-gated navigation, and representative reporter, technician, and administrator journeys.
- **FR-056**: Golden-image verification SHOULD cover stable, high-value shared components and representative light/dark and RTL/LTR screen states where rendering is deterministic; nondeterministic content MUST use widget assertions or manual review instead.
- **FR-057**: Formatting and static analysis MUST pass, and all existing application tests MUST remain green after UI work.
- **FR-058**: Manual visual review MUST use a documented matrix covering light/dark appearance, Arabic RTL/English LTR, supported phone widths, normal/large text, all three roles, shared states, and the major ticket workflows.
- **FR-059**: Manual review evidence MUST distinguish automated checks, deterministic golden comparisons, emulator or device observations, and any environment-dependent verification that could not run.
- **FR-060**: This feature MUST NOT introduce chat, maps, analytics, notifications, exports, offline synchronization, new ticket operations, changed permissions, changed lifecycle rules, or any unsupported workflow.

### Visual Consistency Requirements

- **VC-001**: Equivalent elements MUST use the same token, component, interaction state, semantic role, and terminology across all screens.
- **VC-002**: Each screen MUST have one clear page purpose, one dominant hierarchy, and no more than one visually primary action within the same decision context.
- **VC-003**: Spacing, alignment, radius, borders, shadow, iconography, and type hierarchy MUST come from the shared system; unexplained one-off values are not acceptable.
- **VC-004**: Status, priority, role, selection, validation, and disabled treatments MUST remain consistent between lists, details, dialogs, sheets, and feedback.
- **VC-005**: Light/dark and RTL/LTR variants MUST preserve component identity and information hierarchy rather than behaving as separate visual products.

### Accessibility Requirements

- **AR-001**: All core text, meaningful graphics, focus indicators, and interactive boundaries MUST meet the contrast targets in FR-010 in every enabled state and theme.
- **AR-002**: All actionable elements MUST meet FR-019 touch-target and accessible-name requirements.
- **AR-003**: Every input error MUST be associated with its field, announced accessibly, and described in text rather than color alone.
- **AR-004**: Dynamic loading, success, conflict, and failure messages MUST be announced at an appropriate priority without repeatedly interrupting users.
- **AR-005**: Representative core journeys MUST pass semantic-order, text-scaling, RTL, keyboard/focus where applicable, and non-color-meaning verification.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature improves clarity, consistency, accessibility, and trust across the already approved authentication and maintenance-ticket workflows without changing their behavior.
- **Deferred Features Check**: Maps, QR codes, push notifications, analytics, exports, real-time chat, offline synchronization, and comparable advanced capabilities remain excluded.
- **Increment Boundary**: The smallest independently reviewable increment is the brand foundation and shared light/dark, RTL/LTR tokens applied to shared components without changing a business screen's behavior; representative screens can then adopt the system role by role.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**: No endpoint, method, path, request, response, status code, retry identity, or error envelope change is approved. Existing contracts remain the source of truth.
- **Authorization Rules**: All current role, ownership, assignment, active-account, concealed-access, and route-gating rules remain unchanged. Visual presence or client state MUST never grant authorization.
- **Flutter States**: Every currently applicable loading, populated, empty, submitting, validation, unauthorized, concealed/not-found, offline, conflict, server-error, retry, and authoritative-refresh state remains behaviorally intact and receives a consistent visual treatment.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Theme, locale, text scale, viewport, system accessibility settings, remote content, role-derived navigation, and cached screen state may affect presentation but MUST NOT alter authorization or workflow decisions.
- **Failure and Recovery**: Missing assets, oversized content, theme or locale changes, rendering overflow, and failed state restoration MUST degrade to readable, operable UI without data mutation, false success, restricted disclosure, or loss of safe user input.
- **Operational Evidence**: UI polish MUST NOT add logging of credentials, tokens, ticket descriptions, locations, photos, comments, rejection reasons, ratings, or personal data. Existing sanitized diagnostics remain unchanged unless a separately approved requirement permits otherwise.
- **Quality Constraints**: Representative screens SHOULD present visible response feedback within 100 milliseconds of local interaction and preserve existing network progress timing. Accessibility, localization, theme, and phone responsiveness are mandatory; tablet-specific redesign, desktop redesign, and formal availability changes are outside scope.

### Key Entities *(include if feature involves data)*

- **Brand Asset**: An approved logo, icon, or splash treatment with a defined variant, permitted background, clear space, minimum size, and prohibited uses.
- **Design Token**: A named semantic value for color, typography, spacing, radius, border, elevation, iconography, or motion that provides consistent meaning across themes and directions.
- **Shared Component**: A reusable presentation and interaction pattern with documented variants, states, accessibility semantics, responsive behavior, and no independent business authority.
- **Screen Pattern**: A role-appropriate composition of shared components that preserves the existing workflow, hierarchy, state model, navigation, and authorization boundary.
- **Visual Review Matrix**: The verification set spanning theme, locale/direction, viewport, text scale, role, screen, and state, with explicit pass, failure, or environment-deferred evidence.

## Explicit Exclusions

- New or changed backend endpoints, requests, responses, validation, persistence, authorization, or routes.
- New ticket permissions, roles, lifecycle transitions, assignment behavior, comment behavior, rating behavior, or reference-data operations.
- Ticket editing or deletion, reassignment or unassignment, unsupported technician transitions, comment mutation, or rating mutation.
- Real-time chat, maps, location mapping, QR codes, analytics, notifications, exports, attachments beyond existing ticket photos, offline queues, or offline synchronization.
- A tablet-specific, desktop-specific, or web-specific information architecture beyond safe responsive behavior on supported phone layouts.
- Decorative animation, gamification, marketing experiments, user tracking, or behavioral analytics.
- Rewriting user-authored ticket descriptions, locations, comments, names, or other content as part of interface-language polish.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a representative visual audit, 100% of reviewed screens use approved semantic colors, typography, spacing, radius, elevation, and icon treatments with no unexplained one-off visual values.
- **SC-002**: At least 90% of representative users can identify the current screen, ticket status, priority, and primary available action within 10 seconds on first viewing.
- **SC-003**: At least 90% of representative reporters, technicians, and administrators can complete their existing primary ticket journey without assistance or a workflow error attributable to visual hierarchy.
- **SC-004**: All tested normal text, large text, meaningful graphics, focus indicators, and interactive boundaries meet their specified contrast threshold in light and dark themes.
- **SC-005**: All tested interactive controls provide an accessible name and at least a 48 by 48 logical-pixel target or equivalent hit area.
- **SC-006**: Representative core screens complete RTL/LTR, 320-logical-pixel width, landscape, keyboard inset, and 200% text-scale tests with zero clipped essential content, horizontal overflow, overlapping controls, or unreachable primary actions.
- **SC-007**: In 100% of audited status, priority, validation, selection, disabled, success, warning, and error treatments, meaning remains understandable without color.
- **SC-008**: All representative loading, skeleton, empty, success, validation, unauthorized, offline, conflict, and server-error states use consistent language and recovery patterns and produce zero false-success outcomes.
- **SC-009**: All existing automated business-workflow tests pass unchanged in behavioral outcome, and route and contract audits detect zero added or changed business operations.
- **SC-010**: Shared component widget tests, applicable deterministic golden comparisons, formatting, static analysis, and the documented manual visual-review matrix complete with no unexplained failure.
- **SC-011**: Arabic-first screens and their English equivalents contain zero incorrect directional mirroring, reading-order defects, or mixed-content corruption in the representative review matrix.
- **SC-012**: The implemented application exposes zero excluded feature controls or implied capabilities across reporter, technician, administrator, authentication, and profile screens.

## Assumptions

- Existing approved feature specifications, API contracts, role permissions, validation, state controllers, repositories, and automated tests remain authoritative for behavior.
- Arabic is the primary design and review direction; English is fully supported as LTR. Exact translated copy and translation governance may use the project's established localization process during planning without changing user-authored content.
- The approved hexadecimal colors are immutable brand anchors. Planning may define accessible tonal variants for hover, focus, pressed, containers, dark theme, and semantic contexts while preserving the anchors and contrast requirements.
- Typography planning may select maintained fonts with complete Arabic and Latin coverage, but this specification does not mandate a particular font family or new dependency.
- Supported phones include viewports from 320 logical pixels wide through common larger phone sizes. Tablet and desktop redesigns require separate scope.
- Deterministic golden tests are practical for stable shared components and selected representative screens; dynamic timestamps, platform rendering differences, remote images, and other nondeterministic content use semantic/widget assertions and manual review.
- Existing platform support determines where hardware keyboard and focus traversal apply, but semantic order and touch accessibility apply to every supported mobile target.
- Dark mode follows the active application or system appearance decision established during planning; no new account preference or backend persistence is implied.
- Manual visual verification requires an available supported emulator or device. If unavailable, it is recorded as environment-deferred and is never represented as passed by automated checks alone.
