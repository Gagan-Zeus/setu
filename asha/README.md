# ASHA Setu

The field app of Setu, a maternal health platform for rural Karnataka. It is
what the ASHA worker carries: her caseload, the visits she records at each
doorstep, and the work the PHC doctor has sent back to her.

Flutter, one codebase, Android + iOS. Kannada is the default language.

## Who it is for

An ASHA worker walking between houses in a village, on a mid-range Android
phone, on a connection that is unreliable where it exists at all. Large
targets, Kannada first, and nothing that waits on a server before it will let
her carry on.

She reads and writes the mothers in her sub-centre, and only those.

## Running it

```bash
flutter pub get
flutter run --dart-define-from-file=../.env
flutter build apk --release --dart-define-from-file=../.env
```

The release APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

Without `--dart-define-from-file` the app builds and runs fine — it just stays
entirely local, which is the same path a handset with no signal takes. Root
`.env` setup is in the [repo README](../README.md); a Supabase project of your
own is [`core/MIGRATE_PROJECT.md`](../core/MIGRATE_PROJECT.md).

Sign-in is a six digit code emailed to her address, then a PIN she sets on
first sign-in and is asked for on every open afterwards — the phone is shared
and it holds other women's medical records.

## Layout

```
lib/
  db/            Drift database — every read and write in the app goes here
  data/          seed data, SyncService + SyncWorker, OCR, email verification
  risk/          risk_engine.dart  <- the safety mechanism
  l10n/          Kannada and English strings
  theme/         tokens.dart (C, T, S), app_theme.dart
  widgets/       SetuCard, StatCard, RiskChip, SyncBanner, AshaScaffold, …
  screens/       one file per screen
assets/rules/    risk_rules.json — the tunable thresholds
```

## Local-first is not a feature here, it is the architecture

Every screen reads from Drift and writes to Drift. Nothing in the UI awaits the
network, ever. A write also appends a row to an **outbox** table; a background
worker drains it whenever there is a connection.

Two things make a push safe to retry, which matters because it runs on a link
that drops mid-request:

- Local ids are text (`m-1755364…`) and Supabase keys on `uuid`, so every id is
  mapped through **uuid v5** against a fixed namespace. The same local row
  resolves to the same uuid on every device and on every attempt. Changing that
  namespace would orphan everything already synced.
- Every write is an **upsert**. A push that succeeded server-side but lost its
  reply gets retried and lands on the same row rather than a duplicate.

`SyncService` is the interface; `MockSyncService` fakes a server with a small
deliberate failure rate so the retry path stays honest, and
`SupabaseSyncService` is the real one. The Sync Status screen exists to answer
"and what happens when this fails", which is why failures have to actually
happen.

The demo the app is built around: force offline in Settings, register a mother,
record a visit, watch the risk alert fire anyway, go back online, watch the
outbox drain. Covered by `test/offline_sequence_test.dart`.

## The risk engine

`lib/risk/risk_engine.dart` is a pure function over a visit and a mother's
profile. No network, no model call, synchronous — which is exactly why it still
fires in a village in airplane mode. On a red rule the alert takes the whole
screen before she can save and move on; the advice is on-device and the
referral it creates is a local row that syncs later.

Thresholds live in `assets/rules/risk_rules.json` (R1–R8) so they can be tuned
without a rebuild. The evaluation for each rule id lives in Dart.

## Other things worth knowing

- **Registering a mother** can start from the camera: `OcrService` reads the
  paper Thayi Card. OCR output is never saved silently — every extracted field
  is shown back to the ASHA for confirmation first.
- **Email verification at the doorstep** (`data/email_verification.dart`) sends
  the mother Supabase's own login OTP, not a scheme of ours, so what is being
  confirmed is exactly the thing that matters: that this address receives the
  code she will later sign in with. It runs on an isolated Supabase client that
  is signed out and thrown away immediately — verifying an OTP returns a
  session, and that session is the mother's, so putting it on the app's own
  client would sign the ASHA out of her own account on her own handset.
- **Tasks** are what the doctor assigned in Setu Care. The ASHA is resolved
  from the mother, never chosen by the doctor.
- **The incentive screen** is built entirely from local rows, so it is readable
  even if sync has never once succeeded. Counts and categories only — it never
  shows a guaranteed rupee amount.

## Commands

```
flutter pub get
flutter gen-l10n                      # after editing any .arb file
dart run build_runner build           # after changing the Drift tables
flutter analyze
flutter test
```

`lib/db/database.g.dart` is generated — edit `database.dart` and rerun
`build_runner`, never the `.g.dart`.

## Notes

- The Kannada font is bundled in `assets/google_fonts/`, so glyphs render with
  no network. `google_fonts` finds it in the asset manifest before it tries to
  fetch anything.
- Call buttons use `ACTION_DIAL` via `url_launcher`, so the app never asks for
  the `CALL_PHONE` permission — she confirms every call herself.
- Column names must match [`core/schema.sql`](../core/schema.sql). That file is
  the contract between this app, Setu Care and Thayi Setu.
- `path_provider_android` is pinned in `dependency_overrides`; see the comment
  in `pubspec.yaml`.
