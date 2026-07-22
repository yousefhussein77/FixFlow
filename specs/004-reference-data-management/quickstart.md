# Quickstart: Reference Data Validation

## Automated checks

From `backend/`: `php artisan test`, `vendor\\bin\\pint --test`, `composer audit --locked`.

From `mobile/`: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `flutter pub outdated`.

## API journey

1. Authenticate an administrator and create/update/deactivate/reactivate a department.
2. Create categories in two departments; verify same-department duplicate rejection and cross-department allowance.
3. Submit a stale version and confirm `409` with unchanged current data.
4. Use reporter/technician tokens against admin IDs that exist and do not exist; confirm identical safe `403` responses.
5. Load option endpoints and confirm all inactive combinations are excluded.
6. Confirm no DELETE routes exist and inactive rows remain queryable administratively.

## Flutter journey

Exercise populated/empty lists, forms, lifecycle confirmation, conflict refresh, auth loss, offline/server failures, and active-option empty/populated states. Confirm stale results never replace newer state.
