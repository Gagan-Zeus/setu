# send-email

The OTP email for all three apps.

It lives under `thayi/` for historical reasons — that is where `supabase/`
was initialised — but it is **not** the mother app's function. One Supabase
project (`idngqijhodyahdgodybt`) backs Thayi, ASHA and Care, so there is one
Auth "Send Email" hook, and it sends every code for every app. Before this it
sent all of them wearing the mother app's face: an ASHA got a code branded
ತಾಯಿ ಸೇತು, and so did a doctor.

## How it decides which app

`index.ts` → `resolveBrand()`:

1. An explicit marker in the redirect URL — `.../auth/care`, or `?app=care`.
   Nothing sends one today; it is an escape hatch for a future app.
2. **The recipient's role**, from `public.setu_role_for_email` (see
   `core/brand_for_email.sql`). `doctor` → Care, `asha` → ASHA, `mother` →
   Thayi.
3. Thayi, if neither answered.

It keys on **who is receiving** rather than which app made the request,
because those differ in a real flow: when an ASHA verifies a mother's address
at the doorstep (`asha/lib/data/email_verification.dart`), the request comes
from the ASHA app and the email lands in the mother's inbox. It has to wear
Thayi's logo, and keyed on the address it does, with nobody having to
remember.

Step 3 covers the mother registered offline whose row has not synced yet —
she is not in `mothers` when her first code goes out, and Thayi is the right
guess. The lookup also fails soft: a timeout or a 500 costs a logo, never a
login.

No Flutter change was needed for any of this, and none of the three apps was
touched.

## Files

| | |
|---|---|
| `index.ts` | hook: verify signature, resolve brand, hand to Resend |
| `brands.ts` | the three brands — name, tagline, language, font, copy |
| `template.ts` | one table-based layout, shared by all three |

There is one layout on purpose. A fix to the code block or the dark-mode guard
should land in all three apps at once, and a brand should not be able to drift
into its own half-maintained template. Everything that differs is a field on
`Brand`.

## Logos

Email cannot use `assets/brand/logo.png` — those are 1254px, ~1.5MB, and the
client fetches over the reader's connection. `core/build_email_logos.py` cuts
them to 128px discs of ~20KB in `brand/email/`, and
`core/upload_email_logos.sh` puts them in the public `brand` storage bucket,
which is what `BRAND_ASSET_BASE` defaults to.

Most clients block remote images by default, so the masthead carries the
wordmark in text beside the logo — with images off the header still says which
app this is.

## Preview

```
node core/preview_otp_email.mjs && open /tmp/setu-otp/thayi.html
```

Renders all three from the same `brands.ts` and `template.ts` the deployed
function uses, with local logos, to `/tmp/setu-otp/`.

## Deploy

Paste `core/brand_for_email.sql` into the dashboard SQL editor and Run it —
the repo has no `psql` and the SQL files are written to be pasted.

```
python3 core/build_email_logos.py
SUPABASE_SERVICE_ROLE_KEY=... ./core/upload_email_logos.sh

cd thayi && npx supabase secrets set OTP_FROM_ADDRESS=no-reply@mysetu.live
cd .. && ./core/deploy_functions.sh <project-ref> send-email
```

`deploy_functions.sh` rather than `supabase functions deploy` because the CLI
bundles with Docker by default and there is none on this machine; the script
passes `--use-api` and stages the function tree. Standing up a project from
scratch is `core/MIGRATE_PROJECT.md`.

`OTP_FROM` is no longer set per deployment — the display name is now per brand
(`Thayi Setu`, `ASHA Setu`, `Setu Care`) over the one `OTP_FROM_ADDRESS`. If
`OTP_FROM` is still in the project's secrets it overrides all three, so unset
it:

```
supabase secrets unset OTP_FROM
```

Verify with one sign-in per app and check the function log — it prints
`send-email: sending as <key>` and nothing identifying.
