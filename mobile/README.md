# fixflow

## Authentication client

The Flutter app provides registration, sign-in, session restoration, own-profile, and sign-out flows. Tokens are stored only through platform-protected secure storage. Configure the API when running:

```powershell
flutter run --dart-define=FIXFLOW_API_URL=http://10.0.2.2:8000
```

The default URL is the Android emulator host alias above. Registration submits a reporter or technician account request for administrator review and does not sign the applicant in. Authentication screens distinguish pending, rejected, inactive, validation, unauthenticated, offline, secure-storage, and server/contract failures and disable duplicate submission while loading.

Validate with `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.

Administrators can review pending, approved, and rejected account requests in addition to the existing ticket and reference-data workflows. Approval and rejection require confirmation and refresh the authoritative list after completion. See [`docs/account-approval.md`](../docs/account-approval.md) for API and architecture details.

Authenticated role screens include an unread notification bell and Arabic notification center. Notifications refresh every minute while the app is open and when it returns to the foreground. See [`docs/notifications.md`](../docs/notifications.md) for API, event, destination, and safety details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
