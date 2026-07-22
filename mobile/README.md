# fixflow

## Authentication client

The Flutter app provides registration, sign-in, session restoration, own-profile, and sign-out flows. Tokens are stored only through platform-protected secure storage. Configure the API when running:

```powershell
flutter run --dart-define=FIXFLOW_API_URL=http://10.0.2.2:8000
```

The default URL is the Android emulator host alias above. Registration creates reporter accounts only. Authentication screens distinguish validation, unauthenticated, offline, secure-storage, and server/contract failures and disable duplicate submission while loading.

Validate with `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.

Administrators see department and category management controls on their authenticated profile. Reference-data state distinguishes loading, populated/empty success, validation, authorization loss, offline, stale conflict, and server/contract failure. Reusable active-option loading is available for later ticket forms without implementing tickets.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
