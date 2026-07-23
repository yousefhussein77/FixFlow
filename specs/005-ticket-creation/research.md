# Research: Reporter Ticket Creation and Tracking

## Atomic photo persistence

- **Decision**: Validate all uploads first, stage each file on the private disk, then create the ticket
  and photo rows inside a database transaction. On every exception, delete every staged/durable path;
  commit only after all rows and files are ready.
- **Rationale**: Database transactions cannot roll back filesystem writes. Explicit path tracking plus
  rollback provides the required all-or-nothing externally observable result.
- **Alternatives considered**: Store files after commit (can leave a ticket without photos); database
  blobs (unnecessary schema/storage cost); distributed transaction (unsupported and excessive).

## Repeat submission safety

- **Decision**: Persist a normalized UUID submission token with a unique composite index on
  `(reporter_id, submission_token)`. Replay a completed matching reporter token as the original ticket;
  treat unique-key races as a safe replay lookup or conflict.
- **Rationale**: A database uniqueness constraint remains authoritative under concurrent requests.
- **Alternatives considered**: Client-only tap prevention (cannot protect retries); cache locks (not
  durable); global token uniqueness (unnecessarily leaks/couples reporters).

## References and ordering

- **Decision**: Use immutable `TKT-` plus an uppercase random 12-character identifier, protected by a
  unique index. List by `created_at DESC, id DESC`.
- **Rationale**: Human-readable references avoid sequential disclosure; a unique tie-breaker makes each
  returned page deterministic.
- **Alternatives considered**: Sequential IDs (enumerable); timestamp-only references/order (collide).

## Authorization and concealment

- **Decision**: Apply active and reporter middleware to the route group. Query detail through the
  authenticated reporter's `tickets()` relation by reference, returning the same 404 envelope for
  absent and non-owned tickets.
- **Rationale**: Ownership is applied before model resolution, counts, or serialization.
- **Alternatives considered**: Global route-model binding followed by a policy (may create observable
  differences); client filtering (not an authorization boundary).

## Upload validation and delivery

- **Decision**: Laravel Form Request rules enforce count, 10 MiB, and MIME/content via image/mimetype
  validation for JPEG, PNG, and WebP. Store with generated names on the private disk and expose an
  authenticated owned-photo endpoint only if needed by the details UI.
- **Rationale**: Framework MIME inspection checks content rather than trusting extensions, and private
  storage avoids public cross-user access.
- **Alternatives considered**: Public disk URLs (bypass ownership); extension checks (spoofable).

## Flutter structure and uploads

- **Decision**: Use existing `http.MultipartRequest`, byte-backed selected-photo models, repository
  contract mapping, ChangeNotifier controllers, and widget screens. Selection validation is a pure
  function and the controller rejects concurrent submit calls.
- **Rationale**: This matches the repository's architecture without adding packages. Platform gallery
  picking is not added because no picker dependency exists and dependency addition is unnecessary for
  contract/state/widget verification; injectable selection supports platform wiring later.
- **Alternatives considered**: Add image-picker/state-management packages (not necessary for approved
  scope); direct HTTP from widgets (violates architecture).
