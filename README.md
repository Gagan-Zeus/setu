# Setu — ಸೇತು

A maternal health platform for rural Karnataka. Three Flutter apps over one
Supabase project, so that what an ASHA worker records at a doorstep with no
signal is what the doctor sees at the PHC, and what the mother reads on her own
phone.

*Setu* means bridge. The bridge is the point: today the mother's record is a
paper Thayi Card she carries, the ASHA's record is a register in her bag, and
the doctor's record is whatever is in front of him at the visit. None of the
three can see the other two.

| App | Who holds the phone | Directory |
|---|---|---|
| **Thayi Setu** — ತಾಯಿ ಸೇತು | the pregnant woman. Reads her record, never edits it. | [`thayi/`](thayi/) |
| **ASHA Setu** | the ASHA worker. Registers mothers, records visits, works offline. | [`asha/`](asha/) |
| **Setu Care** | the PHC doctor. Reviews caseloads, assigns work back to ASHAs. | [`care/`](care/) |

Each app has its own README with how to run it and what is load-bearing inside
it. This file is about the platform the three of them share.

## How the three connect

```
        ASHA Setu                    Supabase                   Setu Care
   (offline-first, Drift)     (Postgres + RLS + Auth)        (doctor console)
            │                          │                           │
   visit recorded in a         anc_visits (append-only)     reads her facility,
   village, queued in          tasks, alerts, referrals     assigns a task
   a local outbox ───push──▶   mothers, staff, labs   ◀──── to the right ASHA
                                       │                    (resolved from the
                                       │                     mother, not picked)
                                       ▼
                                  Thayi Setu
                          she reads her own record only
```

[`core/schema.sql`](core/schema.sql) is the contract. Column names there must
match the Drift tables in ASHA Setu and the typed models in Setu Care — if they
drift apart, the three clients stop being one platform.

Three roles, resolved in the database rather than in any client:

- `mother` — reads her own record only
- `asha` — reads and writes the mothers in her sub-centre
- `doctor` — reads everything in her facility, assigns work

Identity lives in `auth.users`; role and scope live in `public.staff`. One
function, `can_access_mother()`, is the rule behind every clinical table's Row
Level Security policy. `anc_visits` is append-only — a correction is a new row
pointing at the original, so two offline handsets can never conflict and the
audit trail costs nothing.

## Repository layout

```
thayi/    Flutter — the mother app (Kannada default, Supabase + mock fallback)
asha/     Flutter — the field app (Kannada default, local-first Drift + outbox)
care/     Flutter — the doctor console (English)
core/     the shared backend: schema, SQL, Edge Functions, ops scripts
brand/    logos for the three apps, plus 128px cuts for email
admin/    React — the admin portal: PHCs, staff, assignments, partner API, audit
```

Inside `core/`:

| | |
|---|---|
| `schema.sql` | tables, helper functions, RLS. The contract. |
| `seed.sql`, `demo_seed.sql`, `demo_dataset.sql` | reference data and the demo caseload |
| `generate_demo_dataset.py` | regenerates `demo_dataset.sql` |
| `pregnancy_faqs*.sql` | the clinician-approved answers Ask Setu is grounded on |
| `functions/ask-setu/` | the assistant behind Ask Setu (Gemini, grounded) |
| `functions/speak/`, `functions/transcribe/` | Kannada speech out and in (ElevenLabs) |
| `functions/admin-api/` | staff and key creation, the only holder of the service-role key |
| `functions/partner-api/` | KMC-backed partner keys and the QR lookup |
| `bootstrap_new_project.sh`, `run_sql.py` | stand up a fresh Supabase project |
| `deploy_functions.sh`, `enable_email_hook.sh` | deploy the six Edge Functions |
| `point_apps_at_project.sh` | write the root `.env` all three apps build against |
| `MIGRATE_PROJECT.md` | the full walkthrough for standing up your own project |

The sixth Edge Function, `send-email`, lives in
[`thayi/supabase/functions/send-email/`](thayi/supabase/functions/send-email/)
because that is where `supabase/` was initialised. It is not the mother app's
function — it sends the OTP for all three, wearing the right app's logo, chosen
from the *recipient's* role. Its own README explains why it keys on the
recipient and not on which app made the request.

## Running it

```bash
cp .env.example .env        # then fill in SUPABASE_URL and SUPABASE_ANON_KEY
```

Then any of the three:

```bash
cd thayi && flutter pub get && flutter run --dart-define-from-file=../.env
cd asha  && flutter pub get && flutter run --dart-define-from-file=../.env
cd care  && flutter pub get && flutter run --dart-define-from-file=../.env
```

Leave `--dart-define-from-file` out and the app still builds and starts — on
mock data, which is the same path a field phone with no signal takes. It never
half-connects to a project that is not there.

Requires Flutter with Dart SDK 3.5+. iOS deployment target is 15.0.

To stand up a Supabase project of your own and repoint all three apps at it,
work through [`core/MIGRATE_PROJECT.md`](core/MIGRATE_PROJECT.md) top to bottom
— it covers the schema, the demo data, storage buckets, the Auth settings that
silently break sign-in if left at their defaults, and the function deploy.

## Keys and what may ship

Only the **publishable (anon)** key ever reaches a device. It is designed to —
it is useless without a session, because RLS decides what any signed-in user
can read. Keeping it out of the repo is hygiene, not secrecy: anyone can pull
it back out of a release APK.

The **service_role / secret** key bypasses RLS completely. It belongs only in
Supabase's own secrets, where the Edge Functions read it. Same for the third
party keys — Gemini, ElevenLabs, Resend. None of them appears in any of the
three apps, which is the whole reason the model and the speech calls run in
Edge Functions instead of on the handset.

`.env` is gitignored; `.env.example` is the tracked copy that shows the shape.

## Three things that hold across all three apps

1. **Safety checks run on the device, deterministically.** The ASHA app's risk
   engine is a pure function over a visit; Thayi's danger sign detector is a
   hard-coded Kannada/English keyword matcher. Neither is a model call, which
   is why both still fire in a village in airplane mode.

2. **No personal data in the QR code, and no permanent credential.** What the
   Thayi Card renders is a server-signed token that lapses after five minutes,
   minted only for whoever holds the mother's own session — never her record
   id, which would be a credential a photograph could copy forever. No name, no
   phone number, no clinical data, either way. Her holding the phone out is
   what makes reading her file consent, so nobody — not her ASHA, not an
   administrator — can mint one on her behalf. The offline demo build keeps the
   old static `setu://m/<uuid>?t=<token>` payload, and Setu Care still accepts
   it, because a handset that has not updated yet is not hers to solve at a
   counter.

3. **Kannada first.** Thayi Setu and ASHA Setu default to Kannada, with English
   as the toggle, never the other way round. Display strings live in ARB files,
   the Kannada font is bundled as an asset so glyphs render with no network.
