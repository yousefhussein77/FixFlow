# Account Registration Approval

## Lifecycle and permissions

Public registration accepts an optional requested `reporter` or `technician` role (default `reporter`) and creates the account in `pending` status with `is_active = false`. It returns the user profile without a Sanctum token. Public callers cannot request `administrator`; administrator accounts remain a trusted seeder/database operation.

The account lifecycle is:

- `pending`: awaiting an administrator decision; cannot sign in or use protected routes.
- `approved`: active and eligible to sign in according to the requested role.
- `rejected`: blocked; the optional rejection reason is retained for administrator oversight but is not exposed by the sign-in response.
- `inactive`: blocked independently of an approval request.

Approval and rejection are terminal decisions in this workflow. Repeating a decision, reversing it, or deciding a non-public role returns `409 ACCOUNT_REQUEST_NOT_PENDING` without changing the stored audit record. The decision action locks the user row and commits the status and audit fields in one database transaction.

## Database changes

Migration `2026_08_01_090000_add_account_approval_fields_to_users_table.php` adds:

- `account_status`, constrained to `pending`, `approved`, `rejected`, or `inactive`
- `approved_by` and `approved_at`
- `rejected_by`, `rejected_at`, and nullable `rejection_reason`

Existing active users are preserved as `approved`; existing inactive users become `inactive`. Reviewer foreign keys use `nullOnDelete`, preserving the decision timestamps and reason if a reviewer record is later removed.

## REST API

All responses use the canonical `{ success, message, data, errors, code }` envelope.

### Public registration

`POST /api/register`

```json
{
  "name": "Ahmed Ali",
  "email": "ahmed@example.com",
  "role": "technician",
  "password": "StrongPassword123",
  "password_confirmation": "StrongPassword123"
}
```

A successful response is `201`, contains `data.user.account_status = "pending"`, contains no token, and uses the Arabic pending-review message specified by the application contract.

```json
{
  "success": true,
  "message": "تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.",
  "data": {
    "user": {
      "id": 42,
      "name": "Ahmed Ali",
      "email": "ahmed@example.com",
      "role": "technician",
      "is_active": false,
      "account_status": "pending"
    }
  },
  "errors": null,
  "code": null
}
```

### Administrator requests

These routes require Sanctum authentication, an approved active account, and the `administrator` role:

- `GET /api/admin/account-requests?status=pending`
- `PATCH /api/admin/account-requests/{account}/approve` with an empty JSON object
- `PATCH /api/admin/account-requests/{account}/reject` with optional `rejection_reason` up to 1000 characters

Example rejection body:

```json
{
  "rejection_reason": "The submitted account information could not be verified."
}
```

Successful decisions return the updated account request in `data`. A stale, repeated, reversed, or otherwise invalid decision returns:

```json
{
  "success": false,
  "message": "لا يمكن اعتماد هذا الطلب لأن حالته تغيرت.",
  "data": null,
  "errors": null,
  "code": "ACCOUNT_REQUEST_NOT_PENDING"
}
```

The list accepts `pending`, `approved`, `rejected`, `inactive`, or `all`. It includes only public-role account records and exposes name, email, requested role, registration time, status, decision reviewer/timestamp, and rejection reason. Passwords, tokens, and internal exceptions are never returned.

## Validation

- Names are trimmed, repeated whitespace is collapsed, and length is 2-100 characters. Arabic and English letters, combining marks, spaces, hyphens, straight apostrophes, and typographic apostrophes are accepted. Numbers-only names and unsupported symbols are rejected.
- Emails are trimmed, lowercased, RFC-validated, limited to 255 characters, and unique after normalization. The database unique index is the final duplicate-write boundary.
- Registration passwords are 12-128 characters and require letters, uppercase and lowercase characters, a number, and matching confirmation. Laravel's hashed cast stores only the secure hash.
- Public roles are limited to `reporter` and `technician`.
- Registration, login, approval, and rejection reject unexpected fields.
- Validation responses are structured as `422 VALIDATION_ERROR`. Non-debug API failures return safe Arabic messages and do not expose SQL, host, port, class, or stack-trace data.

## Flutter flow and architecture

The registration screen validates and normalizes input locally, lets the applicant choose reporter or technician, prevents duplicate submission, and preserves editable values after recoverable errors. Successful submission remains in the signed-out registration flow and displays the pending-review message.

Sign-in distinguishes pending, rejected, inactive, invalid credentials, offline, and server failures with safe Arabic copy. The administrator dashboard includes an account-requests destination with status filters, responsive request cards, confirmation before approval/rejection, optional rejection reason, and an authoritative refresh after a successful decision.

The Laravel controller delegates decisions to transactional actions, Form Requests own input validation, middleware owns role/access enforcement, and API Resources own response projection. In Flutter, `services/` handles HTTP and safe failure mapping, `repositories/` owns token access and payload transformation, `state/` owns view state, and `screens/` owns Arabic RTL presentation.

## Local setup and verification

Apply the additive migration without resetting existing data:

```powershell
cd backend
php artisan migrate
php artisan test
composer validate --strict
vendor\bin\pint --test
```

Validate the Flutter client:

```powershell
cd mobile
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Live Android/device verification remains environment-dependent and is separate from the automated suites.

## Cleanup record

`backend/app/Actions/Auth/RegisterReporter.php` was removed because registration now delegates exclusively to `RegisterPendingAccount`; repository-wide reference search found no remaining runtime, test, route, container, or documentation dependency on the old action. No migration, asset, golden, fixture, environment example, or uncertain legacy file was removed.
