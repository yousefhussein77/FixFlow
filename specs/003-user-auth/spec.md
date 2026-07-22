# Feature Specification: User Authentication and Session Management

**Feature Branch**: `main`

**Created**: 2026-07-22

**Status**: Draft

**Input**: User description: "Create a focused authentication specification for FixFlow covering reporter registration, email/password sign-in, own-profile access, sign-out, secure session restoration, inactive-account enforcement, consistent errors, and complete Flutter client states using Laravel Sanctum API tokens."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Register as a Reporter (Priority: P1)

As a visitor, I want to create a reporter account with my name, email address, and password so that I can later access FixFlow's protected features. Public registration always assigns the reporter role and offers no way to request or select a privileged role.

**Why this priority**: Registration establishes the only public account-creation path and is the prerequisite for a new reporter to authenticate.

**Independent Test**: Submit valid registration details as a visitor and verify that exactly one active reporter account is created, an authenticated session is returned, and the mobile client reaches the signed-in profile state.

**Acceptance Scenarios**:

1. **Given** a visitor supplies a valid name, an unused normalized email address, a valid password, and matching password confirmation, **When** registration is submitted, **Then** one active account with the reporter role is created, a session token is issued, and the reporter is shown their profile.
2. **Given** a visitor submits an email already assigned to an account, **When** registration is submitted, **Then** a validation error identifies the email field and no account or token is created.
3. **Given** a visitor submits missing or invalid fields, **When** registration is submitted, **Then** field-level validation errors use the consistent error structure and no account or token is created.
4. **Given** a visitor attempts to include a technician or administrator role in registration input, **When** registration is submitted, **Then** the input cannot create a privileged account and the request is rejected as invalid or ignored in favor of reporter assignment.
5. **Given** the mobile device is offline or the service fails while registration is submitted, **When** no confirmed success is received, **Then** the client shows the corresponding recoverable error state and does not represent the visitor as registered or signed in.

---

### User Story 2 - Sign In and Restore a Session (Priority: P1)

As an active registered user, I want to sign in with email and password and have the mobile app restore my session when possible so that I can use FixFlow without repeatedly entering credentials.

**Why this priority**: Authentication and reliable session restoration are the entry point to every protected FixFlow workflow.

**Independent Test**: Sign in with valid credentials, restart the mobile app with the securely retained token, and verify that the app confirms the session and returns to the authenticated profile without requesting credentials again.

**Acceptance Scenarios**:

1. **Given** an active account and correct email and password, **When** the user signs in, **Then** a new revocable session token is issued and the client enters the authenticated state.
2. **Given** an incorrect email or password, **When** sign-in is attempted, **Then** the same generic invalid-credentials response is shown regardless of whether the email exists and no token or other state change occurs.
3. **Given** an inactive account with otherwise correct credentials, **When** sign-in is attempted, **Then** access is denied, no token is issued, and the response does not expose sensitive account details.
4. **Given** a securely stored valid token, **When** the app starts, **Then** it checks the current profile and restores the authenticated session when the account remains active.
5. **Given** a missing, invalid, revoked, or inactive-account token, **When** session restoration is attempted, **Then** the token is removed from active client use and the visitor is shown the sign-in screen.
6. **Given** connectivity is unavailable during restoration, **When** the stored token cannot be verified, **Then** the app shows an offline state with retry and does not claim protected access has been confirmed.

---

### User Story 3 - View Own Profile (Priority: P2)

As an authenticated active user, I want to view my own profile so that I can confirm which account and role are active in the app.

**Why this priority**: The profile confirms authenticated identity and provides the minimal protected operation needed to validate the session and ownership boundary.

**Independent Test**: Authenticate as each supported role, request the current profile, and verify that only the token owner's allowed profile fields are returned.

**Acceptance Scenarios**:

1. **Given** a valid token belonging to an active account, **When** the current profile is requested, **Then** only that account's permitted profile data is returned.
2. **Given** no token or an invalid or revoked token, **When** the current profile is requested, **Then** the request is rejected as unauthenticated using the consistent error structure.
3. **Given** an account becomes inactive after receiving a token, **When** its current profile is requested, **Then** the request is rejected and the client clears the token from active use.
4. **Given** a profile request is loading, succeeds, is unauthenticated, occurs offline, or fails at the service, **When** the state changes, **Then** the profile screen displays the corresponding state without leaking stale data from another account.

---

### User Story 4 - Sign Out (Priority: P2)

As an authenticated user, I want to sign out so that the current mobile session can no longer access my account.

**Why this priority**: Sign-out is a required security boundary on shared or lost devices and completes session lifecycle management.

**Independent Test**: Sign out with a valid token, then attempt a protected operation with that same token and verify it is rejected while unrelated sessions remain valid.

**Acceptance Scenarios**:

1. **Given** a valid authenticated session, **When** the user signs out, **Then** the current token is revoked, the locally retained token is removed, and the sign-in screen is shown.
2. **Given** a revoked token, **When** it is reused for a protected operation, **Then** the operation is rejected as unauthenticated.
3. **Given** the same account has another valid session, **When** the current session signs out, **Then** only the current token is revoked and the other session remains valid.
4. **Given** sign-out cannot reach the service because the device is offline, **When** the user confirms sign-out, **Then** local credentials are removed immediately, the app enters the signed-out state, and the client does not reuse the token; server-side revocation is retried only if the token can be retained safely for that limited purpose.

### Edge Cases

- Email comparison treats leading/trailing whitespace and letter case consistently so equivalent email forms cannot create duplicate accounts or cause unpredictable sign-in behavior.
- Concurrent registration attempts for the same email result in at most one account; every losing request receives a validation-style conflict with no token.
- Repeated sign-in submissions while a request is in progress are prevented from creating unintended duplicate active-session state.
- A password containing accepted Unicode, spaces, or punctuation is evaluated by length and confirmation without silent modification.
- A token revoked immediately before a protected request is rejected even if it remains stored on the device.
- If an account becomes inactive while the app is open, its next protected operation is rejected; cached profile data is no longer presented as an active authenticated session.
- If session restoration succeeds after the user has already chosen to sign out, the late response cannot restore the cleared session.
- A malformed request, unsupported content type, or unexpected field produces a consistent safe error and no state change.
- Empty profile data is not a valid success state because every authenticated account has a profile; a successful response missing required profile fields is treated by the client as a server/contract error.
- Device secure-storage read or write failure leaves the app signed out, displays a recoverable device-security error, and never falls back to unprotected storage.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose exactly four authentication operations in this feature: register reporter, sign in, get current profile, and sign out.
- **FR-002**: Public registration MUST accept a name, email address, password, and password confirmation and MUST create only an account with the reporter role.
- **FR-003**: Public registration MUST NOT accept any input that can create or elevate an account to technician or administrator.
- **FR-004**: Registration MUST require a syntactically valid email address that is unique after the system's documented normalization rules are applied.
- **FR-005**: Registration passwords MUST be at least 12 and at most 128 characters, MUST include at least one letter and at least one number, MUST match password confirmation, and MUST be checked without trimming or silently altering the submitted password.
- **FR-006**: Passwords MUST be stored only in a one-way protected representation and MUST never be returned in any response, diagnostic event, or application log.
- **FR-007**: A successful registration MUST create exactly one active reporter account and issue one revocable token for the new session.
- **FR-008**: Users MUST be able to sign in using an email address and password.
- **FR-009**: A successful sign-in MUST require correct credentials for an active account and MUST issue a new revocable token representing the current session.
- **FR-010**: All invalid email/password combinations MUST produce the same generic authentication failure in message, status, and response shape, without revealing whether the email exists or the account password was wrong.
- **FR-011**: An inactive account MUST NOT receive a new token and MUST NOT complete sign-in.
- **FR-012**: Every protected operation MUST require a present, valid, unrevoked token belonging to an active account.
- **FR-013**: The current-profile operation MUST return only the authenticated token owner's permitted fields: stable account identifier, name, email, role, active status, and account creation timestamp.
- **FR-014**: The current-profile operation MUST NOT accept a user identifier that permits accessing another user's profile.
- **FR-015**: Sign-out MUST revoke the token used for the current request; subsequent use of that token MUST be rejected while other tokens remain unaffected.
- **FR-016**: Registration validation failure, authentication failure, inactive-account denial, and failed sign-out authorization MUST make no partial persistent state change.
- **FR-017**: Success and error responses MUST use the project's consistent envelope with a success indicator, human-readable message, data on success, field errors for validation failures, and a stable machine-readable error code for failures.
- **FR-018**: The mobile client MUST provide registration, sign-in, and own-profile screens and MUST route users according to confirmed authentication state.
- **FR-019**: The mobile client MUST store an active token only in device-protected secure storage and MUST NOT place it in logs, analytics, ordinary preferences, UI text, or error reports.
- **FR-020**: On launch, the mobile client MUST attempt restoration when a stored token exists by requesting the current profile before treating the session as authenticated.
- **FR-021**: The mobile client MUST remove a missing, invalid, revoked, or inactive-account token from active use after an unauthenticated response and MUST return to sign-in without showing protected data.
- **FR-022**: Registration and sign-in screens MUST represent idle, loading, success, validation-error, unauthenticated/authentication-failure, offline, and server-error states; duplicate submission MUST be disabled while loading.
- **FR-023**: The profile screen MUST represent loading, success, unauthenticated, offline, and server-error states. Validation-error is not applicable because current-profile accepts no user-entered fields; empty success is invalid and MUST be treated as a contract/server error.
- **FR-024**: Sign-out MUST represent loading, success, unauthenticated, offline, and server-error states and MUST always remove the token from normal local use when the user chooses to sign out.
- **FR-025**: Offline and transient server-error states MUST offer a retry where the action is safe; retries MUST NOT silently duplicate account creation or alter authentication state without confirmed success.
- **FR-026**: Error displays MUST preserve field-level validation guidance, distinguish offline from server failure, and avoid exposing credentials, tokens, internal exception details, or account-enumeration clues.
- **FR-027**: Role management, role changes, and privileged-account provisioning MUST NOT be available through any operation or screen in this feature.

### Version 1 Scope Alignment *(mandatory)*

- **Core Workflow Contribution**: This feature supplies the minimum identity and session boundary required for reporters and future provisioned staff to participate safely in the maintenance ticket workflow.
- **Deferred Features Check**: Password reset, email verification, social login, two-factor authentication, role/permission administration, ticket functionality, profile editing, maps, QR codes, push notifications, PDF export, and analytics are excluded.
- **Increment Boundary**: The smallest reviewable increment is visitor registration as a reporter with validation, token issuance, secure client retention, and transition to the authenticated own-profile view. Sign-in/restoration, profile enforcement, and sign-out can then be verified as bounded increments.

### API and Client Contract *(mandatory when backend or mobile is affected)*

- **REST Contract**:
  - `POST /api/register`: Public. Request fields are `name`, `email`, `password`, and `password_confirmation`. Success returns `201` with the standard envelope containing the permitted profile and a bearer token. Invalid fields or duplicate email return `422` with field errors. The response never accepts or returns a password or privileged role selection.
  - `POST /api/login`: Public. Request fields are `email` and `password`. Success returns `200` with the standard envelope containing the permitted profile and a newly issued bearer token. Invalid credentials or an inactive account return a generic `401` authentication failure with no field that reveals account existence.
  - `GET /api/profile`: Protected by Sanctum token authentication and active-account enforcement. Success returns `200` with the standard envelope containing only the current token owner's permitted profile. Missing, invalid, revoked, or inactive-account credentials return `401`.
  - `POST /api/logout`: Protected by Sanctum token authentication and active-account enforcement. Success revokes only the current token and returns `200` with the standard envelope and no sensitive session data. Missing, invalid, revoked, or inactive-account credentials return `401`.
  - Success envelope: `{ "success": true, "message": string, "data": object|null, "errors": null, "code": null }`. Error envelope: `{ "success": false, "message": string, "data": null, "errors": object|null, "code": string }`. Internal exceptions and sensitive values are excluded.
  - This is the initial authentication contract. Incompatible field, semantic, or status changes require a versioned compatibility decision in a future specification.
- **Authorization Rules**: Visitors can call only register and sign-in. Any active reporter, technician, or administrator with a valid token can read only their own profile and sign out their current session. Registration always creates a reporter. No endpoint accepts a target account identifier, role assignment, or role change.
- **Flutter States**:
  - Registration: idle form; loading with submission disabled; success and authenticated navigation; field validation errors; authentication failure if the service denies account creation; offline with retry; server error with retry.
  - Sign-in: idle form; loading with submission disabled; success and authenticated navigation; local field validation; generic unauthenticated/invalid-credentials state; offline with retry; server error with retry.
  - Session restoration: loading/splash; authenticated success; no-token signed-out state; unauthenticated with token clearance; offline with retry or explicit sign-out; server error with retry. Validation error and empty success are impossible under a conforming contract and are treated as server/contract errors.
  - Profile: loading; populated success; unauthenticated with protected data cleared; offline with retry; server error with retry. Empty and validation states are not valid contract outcomes.
  - Sign-out: loading; signed-out success; already-unauthenticated completion; offline local sign-out; server error local sign-out. The token is never restored to normal use after the user confirms sign-out.

### Risk and Failure Requirements *(mandatory)*

- **Trust Boundaries**: Untrusted boundaries include all visitor form input, authorization headers, stored client tokens, response payloads, and account active/role state. Sensitive data includes passwords, password representations, and tokens. Every protected request requires authentication plus active-account enforcement; own-profile access is derived solely from the authenticated identity.
- **Failure and Recovery**: Validation, credential, inactive-account, and authorization failures are atomic and make no partial change. Concurrent registration enforces uniqueness. Transient failures show safe retry options. Registration retries cannot create more than one account for the same email. Session restoration never grants protected UI state until verified. Local sign-out completes even if remote revocation is temporarily unreachable, and the old token is never resumed as an active session.
- **Operational Evidence**: The system records structured outcomes for registration, sign-in, protected-request rejection, account-inactive rejection, and token revocation with timestamp, event category, outcome, and a non-sensitive correlation identifier. Logs MUST exclude passwords, password representations, full tokens, authorization headers, and raw credential payloads. Invalid-credential diagnostics MUST not create user-facing enumeration differences.
- **Quality Constraints**: Under normal connectivity, 95% of users receive visible progress within 1 second of submitting an authentication action and a final result within 3 seconds. Screens and error messages must remain usable with text scaling and assistive labels. User-facing authentication text is prepared for localization; translation beyond the app's currently supported languages is out of scope. Tokens remain locally only for the active/restorable session and are removed from active use on sign-out or invalidation. Password and token privacy requirements apply to all diagnostics and responses.

### Security Verification Requirements

- **SR-001**: Automated verification MUST confirm passwords and password representations are absent from every success and failure response and from captured application logs for all four operations.
- **SR-002**: Automated verification MUST compare unknown-email and wrong-password failures and confirm identical status, stable error code, and response shape.
- **SR-003**: Automated verification MUST confirm technician and administrator roles cannot be created through public registration, including requests containing unexpected or nested role fields.
- **SR-004**: Automated verification MUST confirm missing, malformed, invalid, revoked, and inactive-account tokens are rejected by both protected operations.
- **SR-005**: Automated verification MUST confirm sign-out revokes the current token and does not revoke another valid token for the same account.
- **SR-006**: Automated verification MUST confirm all validation and authentication failures leave account and token counts unchanged.
- **SR-007**: Mobile verification MUST confirm tokens are stored only through protected device storage, cleared from active use on invalidation/sign-out, and never rendered or logged.

### Key Entities *(include if feature involves data)*

- **User Account**: A person's authentication identity with stable identifier, name, normalized unique email, protected password representation, role (`reporter`, `technician`, or `administrator`), active status, and creation timestamp. Public creation is restricted to active reporter accounts.
- **Authentication Token**: A revocable secret representing one authenticated session, owned by one user account and carrying issuance/revocation lifecycle information. Raw token values are visible only at issuance and secure client use, never in profiles or diagnostics.
- **Client Session State**: The mobile app's transient view of whether identity is unverified, authenticated, signed out, offline, or failed, associated with protected local token retention and the most recently confirmed own-profile data.
- **API Error**: A consistent failure representation containing a stable code, safe human-readable message, optional field-level errors, and a correlation reference without credentials or internal exception details.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 95% of first-time users with valid data complete reporter registration and reach their authenticated profile in under 2 minutes without assistance.
- **SC-002**: At least 95% of active returning users with correct credentials complete sign-in and see their profile in under 30 seconds.
- **SC-003**: In 100% of tested app restarts with a valid retained session, the app restores the authenticated profile without requesting credentials; with an invalid, revoked, or inactive session, it denies protected access and returns to sign-in.
- **SC-004**: In 100% of authorization tests, a user can retrieve only their own profile, and visitors or invalid sessions retrieve no protected profile data.
- **SC-005**: In 100% of public-registration tests, the resulting role is reporter; no submitted input can create a technician or administrator.
- **SC-006**: In 100% of sign-out tests, the signed-out token fails the next protected operation while unrelated valid sessions remain usable.
- **SC-007**: In 100% of validation and authentication failure tests, no account or token is partially created, changed, or left active by the failed operation.
- **SC-008**: All three mobile screens and session restoration pass documented checks for loading, success, applicable validation/unauthenticated behavior, offline recovery, and server-error recovery without exposing credentials or stale protected data.
- **SC-009**: Under normal connectivity, at least 95% of authentication and profile actions show progress within 1 second and a user-understandable final result within 3 seconds.
- **SC-010**: Usability testing shows at least 90% of representative users can register, sign in, identify their active profile, and sign out on the first attempt without guidance.

## Assumptions

- Successful public registration signs the new reporter in immediately and returns a token, minimizing friction while email verification remains out of scope.
- Newly registered reporter accounts are active by default; technician and administrator accounts may be seeded or provisioned by a future feature.
- Account deactivation is performed outside this feature, but every sign-in and protected request consumes the resulting active status immediately.
- Email addresses are trimmed and compared case-insensitively for uniqueness and sign-in; the stored/displayed representation does not change authentication semantics.
- Multiple concurrent sessions per account are allowed, and sign-out revokes only the current session token.
- The mobile app may retain a token across app restarts only in device-protected secure storage; it confirms the token with the current-profile operation before exposing protected state.
- The existing project-wide JSON response envelope is defined here as the initial contract because no earlier feature defines a more specific authentication envelope.
- Account lockout, rate limiting thresholds, password expiration, password reset, and recovery workflows are outside this feature; platform-level abuse protection may be planned separately without changing the observable generic credential failure.
