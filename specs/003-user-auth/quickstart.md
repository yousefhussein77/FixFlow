# Quickstart: Validate User Authentication and Session Management

## Prerequisites

- PHP and Composer versions compatible with `backend/composer.json`
- MariaDB configured through `backend/.env` for manual API validation
- Flutter stable and an Android emulator/device for secure-storage validation
- Backend and mobile dependencies installed

The authoritative request/response shapes are in [contracts/auth.openapi.yaml](contracts/auth.openapi.yaml); entity rules are in [data-model.md](data-model.md).

## Automated backend validation

From `backend/`:

```powershell
composer install
php artisan test
vendor\bin\pint --test
composer audit
```

Expected: all authentication feature tests pass, formatting reports clean, and no known dependency advisories are reported.

## Automated Flutter validation

From `mobile/`:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter pub outdated
```

Expected: formatting, analysis, unit tests, and widget tests pass. Dependency output contains no unresolved security warning.

## Manual API journey

1. Start the API from `backend/` with `php artisan serve`.
2. Register using `POST /api/register` with a new name, email, 12+ character alphanumeric password, and confirmation.
3. Confirm `201`, reporter role, standard envelope, and one token; confirm no password appears.
4. Call `GET /api/profile` with the bearer token and confirm only the same account profile is returned.
5. Call `POST /api/logout`, then retry the profile request with the old token and confirm `401`.
6. Sign in with `POST /api/login`, then mark the test account inactive directly in a controlled development database fixture.
7. Confirm the existing token can no longer access profile/logout and correct credentials cannot create another token.
8. Compare unknown-email and wrong-password responses and confirm identical status, code, message, and shape.
9. Attempt registration with `role=administrator` and confirm the account cannot become privileged.

## Manual Flutter journey

1. Configure the development API base URL and run the app on a device/emulator.
2. Register a reporter and confirm loading, authenticated navigation, and own-profile display.
3. Restart the app and confirm session restoration verifies the profile before showing protected UI.
4. Disable connectivity and exercise registration/sign-in/profile to confirm offline states and safe retry.
5. Return malformed/500 test responses and confirm server-error states contain no internal details.
6. Revoke or invalidate the token, then refresh profile and confirm protected data clears and sign-in appears.
7. Sign in again, sign out, and confirm the old session does not restore after restart.

## Scope audit

Search changed application routes and screens and confirm there is no password reset, email verification, social login, two-factor authentication, ticket behavior, profile editing, push notification, or role-management path.
