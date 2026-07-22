# Research: User Authentication and Session Management

## Revocable API authentication

- **Decision**: Use Laravel Sanctum personal access tokens supplied as bearer credentials; issue one token on registration/login and delete only the current access token on sign-out.
- **Rationale**: Sanctum is constitutionally mandated, already installed, supports independent sessions, and provides direct current-token revocation.
- **Alternatives considered**: Cookie sessions add browser/CSRF concerns not needed by the mobile API. JWT adds key and revocation complexity. Revoking every user token on logout would violate the approved independent-session behavior.

## Active-account enforcement

- **Decision**: Persist an `is_active` boolean and run explicit active-account middleware after Sanctum authentication on every protected route.
- **Rationale**: Sign-in checking alone would allow previously issued tokens to continue operating. Route middleware provides one auditable enforcement point for profile and logout.
- **Alternatives considered**: Checking only inside controllers is repetitive and easy to omit. Deleting all tokens when an external process deactivates a user cannot be guaranteed by this feature and does not replace request-time enforcement.

## Atomic registration and authentication failure

- **Decision**: Wrap account creation and token issuance in a database transaction; validate uniqueness at both request and database levels; make login verification read-only until credentials and activity pass.
- **Rationale**: This enforces the specification's no-partial-state requirement during concurrency and failures.
- **Alternatives considered**: Request validation alone is race-prone. Creating the account then issuing a token without a transaction can leave a partial account.

## Password and credential behavior

- **Decision**: Require 12–128 characters with at least one letter and number, confirmed on registration, preserve exact password text, use the framework password hasher, and return a single generic login failure for unknown email, wrong password, or inactive account.
- **Rationale**: Matches FR-005/FR-010 and prevents account enumeration while retaining clear registration validation.
- **Alternatives considered**: Complexity-class rules beyond the approved spec would change scope. Distinct inactive messages disclose account state.

## Consistent API responses

- **Decision**: Centralize success/error envelope construction and normalize validation/authentication exceptions in the application exception configuration.
- **Rationale**: Ensures endpoints and framework failures share stable fields and prevents raw exceptions from reaching clients.
- **Alternatives considered**: Per-controller arrays drift over time. A third-party response package is unnecessary.

## Flutter client architecture and state

- **Decision**: Use built-in `ChangeNotifier` with immutable operation/session state, a repository boundary, a focused HTTP service, and a token-store interface.
- **Rationale**: It cleanly separates UI from transport/persistence without adding a broad state package for three screens.
- **Alternatives considered**: Provider/Riverpod/BLoC add dependencies and conventions that are not necessary at this scope. Direct HTTP in widgets violates the constitution.

## Secure token persistence

- **Decision**: Use `flutter_secure_storage`; never fall back to shared preferences or a file. Clear the active token on unauthorized responses and user-confirmed logout.
- **Rationale**: Flutter core lacks cross-platform protected credential storage. The package maps to platform security facilities and is narrowly scoped.
- **Alternatives considered**: Shared preferences and files are not suitable for bearer secrets. Memory-only storage cannot restore sessions.

## Offline sign-out

- **Decision**: Remove the token from active UI/repository use immediately. Attempt remote revocation first when reachable; if transport fails, finish local sign-out and do not reactivate the token.
- **Rationale**: The user must regain local privacy even offline. The bounded client holds no background job framework, so automatic durable revocation retry is deferred; the abandoned token remains subject to server controls and cannot be reused by this app.
- **Alternatives considered**: Blocking local sign-out on network availability is unsafe on shared devices. Persisting the raw token solely for retry prolongs sensitive retention and complicates logout semantics.

## Verification tooling

- **Decision**: Use PHPUnit feature tests, Laravel Pint, Flutter unit/widget tests, `dart format`, `flutter analyze`, `composer audit`, and `flutter pub outdated`.
- **Rationale**: These are native or already configured checks that cover behavior, style, static analysis, and known dependency advisories without adding tooling.
- **Alternatives considered**: New static-analysis and coverage packages would expand dependencies; they may be proposed separately if project-wide policy requires them.
