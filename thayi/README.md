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
flutter run --dart-define-from-file=../.env
flutter build apk --release --dart-define-from-file=../.env
```

The release APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

Sign-in is a six digit code emailed to the address her ASHA worker registered
and verified at the doorstep. Leave `--dart-define-from-file` out and the app
still builds and starts — on mock data, which is the same path a field phone
with no signal takes. Root `.env` setup is in the [repo README](../README.md);
standing up a Supabase project of your own is
[`core/MIGRATE_PROJECT.md`](../core/MIGRATE_PROJECT.md).

Before she has an account there is a first-open flow that asks nothing but her
name, offers to sort nearby ASHA workers by location, and gives her a list
where every row is a call button. Declining location is a first-class path —
rural GPS fails often and this never blocks her.

## Layout

```
lib/
  data/           models, MotherRepository (mock + Supabase), ChatService,
                  VoiceService, access requests, ASHA directory
  safety/         DangerSignDetector  <- the safety mechanism
  l10n/           app_kn.arb, app_en.arb, content.dart (id -> text)
  theme/          tokens.dart (C, T, S), app_theme.dart
  widgets/        SetuCard, StatCard, RiskChip, CallButton, SetuScaffold, …
  screens/        one file per screen, plus screens/onboarding/
supabase/         the send-email Edge Function and the migrations
```

## Four rules that are not negotiable

1. **The danger sign detector is client-side and deterministic.** Every message
   typed or spoken into Ask Setu runs through `DangerSignDetector` before it
   reaches any chat service. On a match the message is *not sent* and a
   full-screen interrupt with call buttons appears. It is a hard-coded keyword
   matcher in Kannada and English, never a model call.
   See `test/danger_sign_detector_test.dart`.

2. **The chat never answers about medicines or dosages.** `MedicineGuard`
   refuses those in the client, before anything is sent, so the refusal does
   not depend on a server or on the model behaving.
   See `test/chat_service_test.dart`.

3. **No personal data in the QR code.** The payload is
   `setu://m/<uuid>?t=<token>` and nothing else — no name, no phone number, no
   clinical data.

4. **No display string outside the ARB files.** Run `flutter gen-l10n` after
   editing `lib/l10n/*.arb`.

## Ask Setu

A real conversation, not a menu of prepared answers — but the model never
supplies the medical fact. The `ask-setu` Edge Function
([`core/functions/ask-setu/`](../core/functions/ask-setu/)) retrieves approved
rows from `pregnancy_faqs` and tells the model to answer only from those, so
replies stay inside clinician-reviewed material. If nothing matches it says it
does not know and offers her ASHA worker; it never fills the gap from the
model's own knowledge.

It runs on Supabase rather than on her phone because that is where the Gemini
key can live. A key shipped inside an APK can be pulled back out of it in a
minute and spent by anyone.

## Voice

`VoiceService` talks to two more Edge Functions, `speak` and `transcribe`. The
ElevenLabs key lives in Supabase secrets, never in this app — it is billed per
character.

Kannada constrains the models: ElevenLabs supports it only on `eleven_v3`
(Multilingual v2 and Flash v2.5 do not include it at all), and Scribe v2
transcribes it at under 5% word error, which beats the recogniser on most cheap
Android handsets. `speech_to_text` is kept only as the offline fallback.

Synthesised audio is cached in the private `speech-cache` bucket under a hash
of the text, because danger sign warnings are the same sentences every time and
each re-synthesis is paid for. The danger alert screen speaks itself aloud on
open — that is the one screen a woman who cannot read would otherwise get
nothing from.

## Data layer

Every screen talks to the `MotherRepository` interface.
`SupabaseMotherRepository` is the real one; `MockMotherRepository` is invented
data with a short artificial delay, used when there is no configured project or
no session. No screen knows which one it holds.

All demo data is in `lib/data/mock_data.dart` and is relative to today, so the
mother is always 32 weeks pregnant and always has one overdue checkup, whenever
the demo is run.

A doctor who has not scanned her card has to **ask**: access requests arrive in
the app and she approves or rejects them herself. Her profile photo stays on
the phone, in the app's own documents directory — it works with no signal and
costs her no data.

## Commands

```
flutter pub get
flutter gen-l10n          # after editing any .arb file
flutter analyze
flutter test
```

## Notes

- The Kannada font is bundled in `assets/google_fonts/`, so glyphs render with
  no network. `google_fonts` finds it in the asset manifest before it tries to
  fetch anything.
- Call buttons use `ACTION_DIAL` via `url_launcher`, so the app never asks for
  the `CALL_PHONE` permission — she confirms every call herself.
- The camera is used for one thing only, her profile photo. This app displays
  a Thayi Card, it never scans one.
- `supabase/functions/send-email/` is here for historical reasons but belongs
  to the platform, not to this app — it sends the OTP for all three apps. See
  its own README.
- iOS deployment target is 15.0.
- `path_provider_android` is pinned in `dependency_overrides`; see the comment
  in `pubspec.yaml`.
