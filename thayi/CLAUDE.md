# Thayi Setu

Flutter app for pregnant women in rural Karnataka. Android + iOS, one codebase.

Kannada is the default language — all strings live in `lib/l10n/*.arb`, never inline.
Ids in the data layer resolve to text through `lib/l10n/content.dart`.
She reads her record, never edits it. The only thing she can change is today's
tablet tick and her language.

Data comes from `MockMotherRepository` behind the `MotherRepository` interface.
Supabase will be swapped in later — do not couple UI to any backend.
All demo data is in `lib/data/mock_data.dart` and is relative to today, so she is
always 32 weeks pregnant whenever the demo is run.

Safety: `DangerSignDetector` runs client-side before any chat message is sent.
It is a hard-coded keyword matcher, not a model call, and must fire every time.
It is covered by `test/danger_sign_detector_test.dart` — keep those tests green.

Never put personal data in the QR payload. It is `setu://m/<uuid>?t=<token>` and
nothing else.

The chat never answers about medicines or dosages — `MedicineGuard` refuses
those in the client, before anything is sent, so the refusal does not depend on
a server or on the model behaving. Covered by `test/chat_service_test.dart`.

Ask Setu is a real conversation, not a menu of prepared answers. The model runs
in the `ask-setu` Supabase Edge Function (`core/functions/ask-setu/`), which
holds the Gemini key — it must never appear in this app, for the same reason as
the Supabase service key. The function retrieves approved rows from
`pregnancy_faqs` and tells the model to answer only from those, so replies stay
inside clinician-reviewed material. If nothing matches, it says it does not know
and offers her ASHA worker; it never fills the gap from the model's own
knowledge.

Speech runs through `VoiceService` (`lib/data/voice_service.dart`) and two Edge
Functions, `speak` and `transcribe`. The ElevenLabs key lives in Supabase
secrets, never in this app — it is billed per character.

Kannada constrains the models: ElevenLabs only supports it on `eleven_v3`
(Multilingual v2 and Flash v2.5 do not include Kannada at all), and Scribe v2
transcribes it at under 5% word error, which beats the recogniser on most cheap
Android handsets. `speech_to_text` is kept only as the offline fallback.

Synthesised audio is cached in the private `speech-cache` bucket under a hash of
the text, because danger-sign warnings are the same sentences every time and
each re-synthesis is paid for.

The danger alert screen speaks itself aloud on open. That is the one screen a
woman who cannot read would otherwise get nothing from.

## Design system

Use `C`, `T`, `S` from `lib/theme/tokens.dart` everywhere. No raw `Colors.*`, no
magic numbers. Build screens from `lib/widgets/` — `SetuCard`, `StatCard`,
`RiskChip`, `BigActionButton`, `CallButton`, `SetuScaffold`, `SectionHeader`,
`EmptyState`. Red appears only on emergency and danger elements.

Every post-login screen is wrapped in `SetuScaffold`, which is what puts the
floating emergency button on screen. Do not add it per screen.

Never leave a screen blank while loading — use `SkeletonList`/`SkeletonCard`,
and `EmptyState` for errors, never a red Flutter exception box.

## Commands

```
flutter pub get
flutter gen-l10n          # after editing any .arb file
flutter analyze
flutter test
flutter build apk --release
```
