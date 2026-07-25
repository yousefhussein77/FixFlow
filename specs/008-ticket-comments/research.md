# Research: Ticket Comments

## Role-scoped routes with shared behavior

**Decision**: Expose list/create beneath each established ticket role surface:
`/api/reporter/tickets/{reference}/comments`, `/api/technician/tickets/{reference}/comments`, and
`/api/admin/tickets/{reference}/comments`. Existing role middleware applies first; thin controllers
delegate to shared comment access and Actions.

**Rationale**: Reporter ownership, current technician assignment, and administrator oversight have
different concealment semantics. Explicit route groups preserve existing contracts while shared
business behavior prevents duplication.

**Alternatives considered**: One generic `/api/tickets/{reference}/comments` endpoint obscures role
precedence and complicates existing navigation. Duplicated role implementations risk inconsistent
validation/retry behavior. Embedding comments in every ticket detail response prevents an independent
empty/list/retry state and over-fetches when discussion is not opened.

## Authorization and concealed resolution

**Decision**: `TicketCommentAccess` accepts the authenticated user and role context, then builds the
ticket lookup itself: reporter by `reporter_id`, technician by current `assigned_technician_id`, and
administrator by the existing all-ticket oversight rule. Unknown and unauthorized reporter/technician
targets share `TICKET_NOT_FOUND`; wrong route role remains `FORBIDDEN`; inactive authentication is
handled before role middleware.

**Rationale**: Scoping before resolution prevents comment count, content, and target existence from
affecting unauthorized responses. Centralizing the predicates makes read and commit checks identical.

**Alternatives considered**: Global route-model binding followed by a policy may reveal resolution
differences. Client filtering is not authorization. Treating a former technician as forbidden confirms
the ticket and assignment relationship.

## Plain-text validation and immutability

**Decision**: Accept a `content` string, trim only leading/trailing whitespace, require at least one
non-whitespace character, and cap the accepted result at 2,000 Unicode characters. Preserve internal
line breaks and punctuation. Render as text only. Store no `updated_at`, expose no update/delete route,
and reject model update/delete operations.

**Rationale**: Two thousand characters accommodates ordinary maintenance questions and work notes
while bounding request/storage abuse. Trimming accidental boundary whitespace retains original
meaning. Append-only storage directly expresses the Version 1 contract.

**Alternatives considered**: Rich text conflicts with plain-text scope and increases injection risk.
Unlimited content is unnecessary. A 255-character limit is too restrictive for work notes. Soft delete
and edit metadata would create explicitly excluded workflows.

## Retry-safe atomic creation

**Decision**: Require `submission_token` as a UUID generated once per logical client submission. Scope
uniqueness to `(ticket_id, author_id, submission_token)`. In one transaction, resolve and lock the
ticket, recheck current authorization, return an existing scoped token match as a replay, or insert one
comment. The response is `201` for creation and `200` for replay. A different token creates a distinct
comment even if content is identical.

**Rationale**: Content cannot identify retries because intentional repeated text is valid. The ticket
lock serializes comment creation with assignment-sensitive writes, and the unique constraint is the
final duplicate guard. The transaction prevents partial records.

**Alternatives considered**: Client-only duplicate disabling cannot cover reconnects or multiple
devices. Content hashing incorrectly merges intentional repeats. A global token could collide across
tickets/authors. Queued offline writes and a distributed lock are unnecessary Version 1 complexity.

## Comment chronology and author representation

**Decision**: Return all comments for one authorized ticket ordered by `(created_at, id)` ascending.
Each item contains `id`, `content`, `author {id,name,role}`, and `created_at`. Persist `author_role` as
the role at creation while resolving the author's current display name through the retained user
relationship. Internal retry tokens and ticket IDs are never serialized.

**Rationale**: Stable order handles equal timestamps. A role snapshot preserves discussion context if
roles later change, while the user relationship preserves durable identity. Restricting the resource
prevents internal idempotency information from leaking.

**Alternatives considered**: Timestamp-only sorting is nondeterministic. Returning retry tokens is
unnecessary. Copying the author's name creates stale personal data and adds update/retention concerns.

## Flutter shared workflow and ambiguous recovery

**Decision**: Use shared comment contract models, HTTP service, repository, ChangeNotifier controller,
and `TicketCommentsSection`, parameterized by an explicit reporter/technician/administrator route
context. Generate and retain one UUID-like submission token for a draft until authoritative creation
or replay succeeds. Disable duplicate submit; do not add optimistic comments. On ambiguous offline or
server failure, retain text/token and retry the same attempt. Clear comments and draft on authorization,
concealed target, assignment, or session loss.

**Rationale**: The behavior is identical across roles while endpoint selection remains explicit. Token
retention gives safe recovery without an offline queue or new dependency.

**Alternatives considered**: Three independent UI stacks duplicate failure logic. Optimistic insertion
can show comments that never committed. Generating a new token on retry defeats idempotency. Background
offline queues and real-time refresh are excluded.

## Testing and live verification

**Decision**: Laravel Feature Tests cover each actor, concealed target equivalence, chronology,
validation, immutable model guards, locked current-assignment checks, retry replay, distinct tokens,
competing same-token requests, injected rollback, envelopes, and sanitized diagnostics. Flutter tests
cover parsing, endpoint selection, state transitions, safe draft/token preservation, access clearing,
and shared widgets for all roles. Full suites guard earlier features. Android live/API verification is
a separate final check and is recorded as deferred—not passed—when unavailable.

**Rationale**: Deterministic automated tests cover the security and persistence risks; device testing
adds integration evidence without weakening truthful environment reporting.

**Alternatives considered**: Manual-only validation violates project governance. Treating desktop/web
as Android proof is inaccurate. Making unavailable device verification a claimed pass is prohibited.
