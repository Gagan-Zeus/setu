# Thayi Setu — ತಾಯಿ ಸೇತು

The mother-facing app of Setu, a maternal health platform for rural Karnataka.
A digital version of the government paper Thayi Card that pregnant women carry.

Flutter, one codebase, Android + iOS. Kannada is the default language.

## Who it is for

A pregnant woman in a village who may have limited literacy, is not comfortable
in English, and shares a low-end Android phone with her family. Every screen is
built for her: one idea per screen, 18sp body text minimum, 56dp minimum touch
targets, icon **and** text on every action, high contrast for bright sunlight.

She only reads her health record. Her ASHA worker and her PHC doctor write it.

## Running it

```bash
flutter pub get
flutter run                    # or: flutter build apk --release
```

The release APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

Sign in with any 10 digit Indian mobile number and any 6 digit code — the app
runs entirely on mock data.

## Layout

```
lib/
  data/           models, mock data, MotherRepository, ChatService
  safety/         DangerSignDetector  <- the safety mechanism
  l10n/           app_kn.arb, app_en.arb, content.dart (id -> text)
  theme/          tokens.dart (C, T, S), app_theme.dart
  widgets/        SetuCard, StatCard, RiskChip, CallButton, SetuScaffold, …
  screens/        one file per screen
```

## Three rules that are not negotiable

1. **The danger sign detector is client-side and deterministic.** Every message
   typed or spoken into Ask Setu runs through `DangerSignDetector` before it
   reaches any chat service. On a match the message is *not sent* and a
   full-screen interrupt with call buttons appears. It is a hard-coded keyword
   matcher in Kannada and English, never a model call.
   See `test/danger_sign_detector_test.dart`.

2. **No personal data in the QR code.** The payload is
   `setu://m/<uuid>?t=<token>` and nothing else — no name, no phone number, no
   clinical data.

3. **No display string outside the ARB files.** Run `flutter gen-l10n` after
   editing `lib/l10n/*.arb`.

## Data layer

Everything comes from `MockMotherRepository` behind the `MotherRepository`
interface, with a short artificial delay. Supabase gets swapped in behind the
same interface later. All demo data is in `lib/data/mock_data.dart` and is
relative to today, so the mother is always 32 weeks pregnant and always has one
overdue checkup, whenever the demo is run.

## Notes

- The Kannada font is bundled in `assets/google_fonts/`, so glyphs render with
  no network. `google_fonts` finds it in the asset manifest before it tries to
  fetch anything.
- Call buttons use `ACTION_DIAL` via `url_launcher`, so the app never asks for
  the `CALL_PHONE` permission — she confirms every call herself.
- There are no camera permissions. This app displays a QR code, it never scans
  one.
- `path_provider_android` is pinned in `dependency_overrides`; see the comment
  in `pubspec.yaml`.
