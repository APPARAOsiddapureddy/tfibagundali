# TFI Bagundali — Flutter App

Native Flutter client matching the **`css/`** design system (tokens, armies, glass tab bar, missions, share zone, fan army war).

Uses the Node API in `../server`.

## Run

```bash
# Terminal 1 — API
cd ../server && npm run dev

# Terminal 2 — Flutter
cd mobile
flutter pub get
flutter run -d chrome   # or iOS Simulator / Android emulator
```

**Dev OTP:** `123456`

## API URL

| Platform | Base URL |
|----------|----------|
| iOS Simulator | `http://localhost:3001/v1` |
| Android Emulator | `http://10.0.2.2:3001/v1` |
| Flutter Web | `http://localhost:3001/v1` |

See `lib/core/config/api_config.dart`.

## Testing

```bash
flutter test
flutter test test/widget/login_test.dart
```

## Structure

```
lib/
  core/theme/     app_tokens.dart (from css/tokens.css)
  core/router/    5-tab shell + auth + stack routes
  features/       splash, auth, home, missions, quiz, share, army, profile
  widgets/        tfi_widgets.dart, tfi_tab_bar.dart
  data/           army_data.dart (8 hero armies from css)
```

## Tabs (from css design)

**Home · Quiz · Share · Army · Profile**

Design tokens: Bricolage Grotesque, Inter, Noto Sans Telugu, fire/gold gradients, trust badges, coin & army point chips.
