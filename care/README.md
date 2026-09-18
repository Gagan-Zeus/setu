# Setu Care

The doctor-facing console of Setu, a maternal health platform for rural
Karnataka. It is where a PHC doctor sees the caseload the ASHA workers have
been building in the field, and where she sends work back to them.

Flutter, one codebase, Android + iOS, laid out to work on a phone as well as
the tablet or desktop it is usually opened on. English only — this is the one
app in the platform whose users work in English all day.

## What it does

- **Dashboard** — the facility at a glance: who is high risk, what is overdue.
- **All Mothers** — the caseload, filterable, each opening a full record:
  visits, labs, clinical notes, alerts.
- **Referrals** — the red-rule referrals ASHA Setu raised in the field.
- **ASHA Workers** — the roster, and what each one's caseload looks like.
- **Analytics** — coverage and outcome trends across the facility.

Two things happen at the counter rather than at a desk:

- **Scanning a Thayi Card.** The one path into a mother's record that needs no
  request — she is standing there and has physically presented the card, which
  is the consent. The QR carries only her id and a token, no name and no
  clinical data, so the token is what proves the card was actually shown.
  Everything else goes through an access request she approves in her own app.
- **Photographing the prescription.** The sheet of paper she is handed gets
  lost between the clinic and the chemist. Photographed at the counter, she
  still has it later, and so does whoever sees her next.

Assigning a task picks the *mother*, not the worker: the ASHA is resolved from
the mother's assignment, so a task cannot be sent to someone who does not cover
her.

## Running it

```bash
flutter pub get
flutter run --dart-define-from-file=../.env
flutter build apk --release --dart-define-from-file=../.env
```

Without `--dart-define-from-file` — or signed in with no Supabase session — the
app runs on `MockCareApi`, invented data that demos the whole console with no
backend at all. A banner says so on every screen, so nobody mistakes it for a
real caseload. Root `.env` setup is in the [repo README](../README.md).

Sign-in is a six digit code emailed to the doctor's address. Her `public.staff`
row is what makes her a doctor and scopes her to a facility; there is no role
flag anywhere in this app.

## Layout

```
lib/
  data/       CareApi (the interface), MockCareApi, SupabaseCareApi, models
  features/   scan_thayi_card, prescription_capture, assign_task_sheet
  screens/    shell + one file per tab, plus the mother record
  theme/      tokens.dart (C, T, S), app_theme.dart
  widgets/    care_widgets, charts, care_logo
```

`CareApi` is the typed surface every screen talks to, and it has exactly two
implementations. No screen knows which one it holds — that is what lets the
demo path and the real path stay honest about each other.

`Shell` is the frame: the sidebar of the brief becomes a bottom navigation bar
on a phone, the top bar keeps the facility name and the user menu. Logout is a
menu action, never a route — no session, no app, by construction.

## Commands

```
flutter pub get
flutter analyze
flutter test
```

## Notes

- The typed models in `lib/data/models.dart` must match
  [`core/schema.sql`](../core/schema.sql). That file is the contract between
  this console, ASHA Setu and Thayi Setu.
- Only the publishable key reaches the device; Row Level Security and the
  `staff` row decide what a signed-in doctor can read. The service-role key
  must never appear in this app.
- Prescription photographs go to the private `prescriptions` storage bucket,
  whose policies are created by `core/schema.sql`.
- `path_provider_android` is pinned in `dependency_overrides`; see the comment
  in `pubspec.yaml`.
