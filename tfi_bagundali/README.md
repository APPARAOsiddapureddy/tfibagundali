# TFI Bagundali (Flutter)

Mobile app for **TFI Bagundali** — daily quiz, share zone, fan army, profile, premium (IAP), and push notifications.

## Requirements

- Flutter SDK (stable), Dart **>= 3.3**
- Xcode + CocoaPods for iOS (`cd ios && pod install`)
- Android Studio / SDK for Android

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib test
flutter test
```

## Run

```bash
flutter run
```

API base URL is configured in `lib/core/config/app_config.dart` and via `--dart-define=ENV=...` / `API_URL=...`.

## Important

- Do **not** copy a full Flutter SDK into this folder. Use a system-wide Flutter install only.
- Firebase: add `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` locally (not committed if the repo is public and you use private keys).

For the full monorepo (API, web client, Docker), see the **repository root `README.md`**.
