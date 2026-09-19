# Setu Admin Portal

The control plane for Setu: PHCs, staff, ASHA-to-doctor assignments, mother
records, partner API access, and the audit trail.

React 18 + Vite + TypeScript + Tailwind, Supabase for auth and data, TanStack
Query for server state, Zod for every form.

## Run it

```bash
cp .env.example .env.local     # fill in the project URL and publishable key
npm install
npm run dev                    # http://localhost:5174
```

`npm run build` type-checks and bundles to `dist/`.

## What is deliberately not here

**No service-role key.** The portal authenticates as the signed-in
administrator and nothing else. Anything shipped to a browser is readable by
whoever opens it, and the service role bypasses RLS entirely — so key
generation and staff invites live in Edge Functions, which are the only things
that hold that key. Both verify the caller's own JWT before they do anything,
and both refuse a `viewer`; issuing a key refuses anyone but a `super_admin`.

Two screens call them, at the same host as everything else — the functions
live under the Supabase URL, so there is no second address to configure and
none to get wrong:

- registering a medical officer or ASHA — `admin-api/staff`, which creates the
  auth user *and* the staff row, which has to happen together
- issuing a partner API key — `partner-api/admin/issue-key` (CSPRNG, hashed
  before storage)

**A partner key is never shown in this portal.** It is emailed to the address
the medical council holds for the doctor behind the request, not to one typed
into a form, and only its SHA-256 hash is kept. The screen shows where it went
and the last four characters — enough to tell two keys apart, and no use to
anyone who photographs it. If the mailer fails, the screen says the key exists
and did not arrive, because the fix for that is to revoke and reissue rather
than to try again.

**No column-hiding in the client.** `api_keys.key_hash` is never granted to
`authenticated`, so `select('*')` on that table is refused by Postgres. The
query asks for an explicit column list for that reason.

**No admin writes to clinical data.** RLS cannot restrict which columns an
update touches, so admins have no UPDATE policy on `mothers` at all.
Reassignment and deactivation go through `admin_reassign_mother()` and
`admin_set_mother_active()`, which touch those columns and no others.

## Routes

| Route | Who |
|---|---|
| `/partner-access` | public — the API request form |
| `/` | dashboard |
| `/phcs`, `/staff`, `/assignments`, `/mothers` | any admin; writes need super or district admin |
| `/partners` | any admin reads; only super_admin approves |
| `/audit` | any admin, viewers included |

A `viewer` never sees a control that would fail at the database anyway.

## Migrations

`migrations/0001…0006` — apply in order. See the header of `0001` for why
administrators are not `staff` rows; it is the load-bearing decision.

## Deploying to Vercel

Import the repo at vercel.com/new with **Root Directory: `admin`**. Everything
else comes from `vercel.json` — Vite preset, `npm run build`, `dist/`, the SPA
rewrite, and the security headers.

Set both environment variables before the first deploy:

```
VITE_SUPABASE_URL       https://<ref>.supabase.co
VITE_SUPABASE_ANON_KEY  sb_publishable_xxxx
```

They are read at **build** time, not runtime — Vite compiles them into the
bundle — so a deploy without them produces an app that throws on load.
`src/lib/supabase.ts` fails loudly rather than silently pointing at nothing.

`vercel.json` carries no comments on purpose. Vercel validates it with
`additionalProperties: false` at the top level and inside `rewrites[]` and
`headers[]`, so a `"//"` key fails the deploy with "should NOT have additional
properties". The reasoning lives here instead:

- **rewrite** `/((?!assets/).*)` → `/index.html` — every route except the built
  assets is client-side, and without this a hard refresh on `/partner-access`
  returns a 404.
- **X-Robots-Tag: noindex** — the portal renders mothers' names and risk
  levels. It should never appear in a search index.
- **X-Frame-Options: DENY** — nothing here should ever be framed.

For GitHub Pages instead, build with `VITE_BASE=/setu/`, copy `index.html` to
`404.html`, and add `.nojekyll`.
